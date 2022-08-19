//
//  ARView.swift
//  CoreML+ARKit+Reformatting
//
//  Created by HayeonKim on 2022/08/03.
//

import ARKit
import Combine
import FocusEntity
import RealityKit
import SceneKit
import SwiftUI
import Vision

// First, set up arview using uikit
class ARViewController: UIViewController, ARSessionDelegate {

    //MARK: - set up variables
    let imagePredictor = ImagePredictor()
    var latestPrediction: String = "hello"
    var viewModel: MyARViewControllerRepresentable.ViewModel?
    let BUBBLE_DEPTH: Float = 0.01 // depth of 3D text
    var arView = CustomARView(frame: .zero)
    
    private var cancellable: AnyCancellable?
    private var arViewStateCancellable: AnyCancellable?
    private var selectedModelForStudyCancellable: AnyCancellable?
    private var selectedModelForTestCancellable: AnyCancellable?

    // MARK: - initializer
    init(viewModel: MyARViewControllerRepresentable.ViewModel) {

        super.init(nibName: nil, bundle: nil)

        self.viewModel = viewModel

        // modelConfirmedForPlacement값이 바뀔때 이걸 받으라고 못하나?
        cancellable = viewModel.$modelConfirmedForPlacement
            .compactMap { modelName in modelName }
            .flatMap {
                Publishers.Zip(
                    Entity.loadModelAsync(named: $0, in: nil),
                    Just($0).setFailureType(to: Error.self)
                )
            }
            .map { [weak self] (modelEntity, modelName) -> (String, AnchorEntity) in

                guard let self = self else { return ("", AnchorEntity())}

                let modelHeight = (modelEntity.model?.mesh.bounds.max.y)! - (modelEntity.model?.mesh.bounds.min.y)!

                var position = modelEntity.position
                position.y += modelHeight / 100

                let anchorEntity = AnchorEntity(plane: .any)
                // model 넣어줌
                anchorEntity.addChild(modelEntity.clone(recursive: true))

                let sphereEntity = self.generateSphereEntity(position: position, modelName: modelName)
                let textEntity = self.generateTextEntity(position: position, modelName: modelName)

                anchorEntity.addChild(sphereEntity)
                anchorEntity.addChild(textEntity)
                anchorEntity.name = "\(modelName)_anchor"


                return (modelName, anchorEntity)
            }
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { [weak self] loadCompletion in
                defer {
                    self?.viewModel!.modelConfirmedForPlacement = nil
                }
                if case let .failure(error) = loadCompletion {
                    assertionFailure("Unable to load a model due to error \(error)")
                }
            }, receiveValue: { [weak self] (modelName, anchorEntity) in
                guard let self = self else { return }

                self.arView.scene.addAnchor(anchorEntity)
                self.viewModel!.addNewWordModel(word: modelName)
            })

        // focus Entity를 생성하고 없애는 부분
        arViewStateCancellable = viewModel.$addModelState
            .receive(on: RunLoop.main)
            .sink(receiveValue: { [weak self] arViewState in
                guard let self = self else { return }
                print("DEBUG: arviewState \(arViewState)")
                if arViewState == .handleImportedModel {
                    self.arView.setFocusSquare(isCreateNeeded: true)
                } else {
                    self.arView.setFocusSquare(isCreateNeeded: false)
                }

            })

        selectedModelForStudyCancellable
        = viewModel.$selectedModelForStudy
            .receive(on: RunLoop.main)
            .sink(receiveValue: { [weak self] selectedModel in

                guard let self = self else { return }
                guard let selectedModel = selectedModel else { return }

                // 여기에 모델이 선택되면 해야할 일을 명시해 준다
                self.changeModelTextTexture(result: selectedModel.rayCastResult, modelName: selectedModel.word)
            })
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }

    deinit {
        cancellable?.cancel()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        arView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(arView)
        NSLayoutConstraint.activate([
            arView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            arView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            arView.topAnchor.constraint(equalTo: view.topAnchor),
            arView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])

        arView.session.delegate = self

//        setupCoachingOverlay() 

        // setup Coaching Overlay()
        arView.environment.sceneUnderstanding.options = []

        // turn on occlusion from the scene reconstruction mesh
        arView.environment.sceneUnderstanding.options.insert(.occlusion)

        // turn on physics for the scene
        arView.environment.sceneUnderstanding.options.insert(.physics)

        // Debug session
        arView.debugOptions.insert(.showSceneUnderstanding)

        // Disable render options that are not required for this app
        arView.renderOptions = [
            .disablePersonOcclusion,
            .disableDepthOfField,
            .disableMotionBlur
        ]

        arView.automaticallyConfigureSession = false

        // Add tap gesture
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        arView.addGestureRecognizer(tapRecognizer)
    }


    // MARK: - Funcition for standard AR view handling
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        arView.session.pause()
    }


    // MARK: - Statue Bar
    override var prefersStatusBarHidden: Bool { true }

    func generateTextModel(text: String) -> ModelEntity {
        let lineHeight: CGFloat = 0.05
        let font = MeshResource.Font.systemFont(ofSize: lineHeight)
        let textMesh = MeshResource.generateText(text, extrusionDepth: Float(lineHeight * 0.1), font: font)


        let textMeterial = SimpleMaterial(color: UIColor.orange, isMetallic: true)
//        let model = ModelEntity(mesh: textMesh, materials: [textMeterial])
        let model = ModelEntity(mesh: textMesh, materials: [textMeterial])

        model.position.x -= model.visualBounds(relativeTo: nil).extents.x / 2
        model.position.y += 0.015
        model.position.x += Float(text.count) * 0.005
        return model
    }

    func generateSphereEntity(position: SIMD3<Float>, modelName: String, radius: Float = 0.01, color: UIColor = UIColor.green) -> ModelEntity {

        let sphere = ModelEntity(mesh: .generateSphere(radius: radius), materials: [SimpleMaterial(color: color, isMetallic: false)])

        // move sphere slightly up
        sphere.position = position
        sphere.position.y += radius

        sphere.physicsBody?.mode = .dynamic
        sphere.collision = CollisionComponent(shapes: [ShapeResource.generateSphere(radius: 0.05)])
        sphere.name = "\(modelName)_sphere"

        // 맘대로 움직일 수 있음, 다만 anchor위치는 안변하는듯?
//        arView.installGestures(.all, for: sphere)

        return sphere
    }

    func generateExistTextEntity(position: SIMD3<Float>, modelName: String) -> ModelEntity {
        let textEntity = self.generateTextModel(text: modelName)

        let raycastDistance = distance(position, self.arView.cameraTransform.translation)

        print("DEBUG: - first anchor position : \(position)")

        textEntity.scale = .one * raycastDistance

        var resultWithCameraOrientation = self.arView.cameraTransform
          resultWithCameraOrientation.translation = position

          textEntity.orientation = simd_quatf(resultWithCameraOrientation.matrix)
        textEntity.name = "\(modelName)_text"

        return textEntity

    }

    func generateExistTextEntityWithMaterial(position: SIMD3<Float>, modelName: String) -> ModelEntity {

        let lineHeight: CGFloat = 0.05
        let font = MeshResource.Font.systemFont(ofSize: lineHeight)
        let textMesh = MeshResource.generateText(modelName, extrusionDepth: Float(lineHeight * 0.1), font: font)

        // video material을 넣어주는 코드 
        guard let url = Bundle.main.url(forResource: "glowing1", withExtension: ".mp4") else {
            return ModelEntity()
        }

        let player = AVPlayer(url: url)
        let material = VideoMaterial(avPlayer: player)
        material.controller.audioInputMode = .spatial

        let model = ModelEntity(mesh: textMesh, materials: [material])

        player.play()

        model.position.x -= model.visualBounds(relativeTo: nil).extents.x / 2
        model.position.y += 0.015
        model.position.x += Float(modelName.count) * 0.005

        let raycastDistance = distance(position, self.arView.cameraTransform.translation)


        model.scale = .one * raycastDistance

        var resultWithCameraOrientation = self.arView.cameraTransform
          resultWithCameraOrientation.translation = position

        model.orientation = simd_quatf(resultWithCameraOrientation.matrix)
        model.name = "\(modelName)_text"

        return model

    }

    func generateTextEntity(position: SIMD3<Float>, modelName: String) -> ModelEntity {

//        let rayDirection = normalize(position - self.arView.cameraTransform.translation)

//        let textPositionInWorldCoordinates = position - (rayDirection * 0.1)

//        let textPositionInWorldCoordinates = position

        // 5. Create a 3D text to visualize the classification result
        let textEntity = self.generateTextModel(text: modelName)

        // 6. Scale the text depending on the distance
        let raycastDistance = distance(position, self.arView.cameraTransform.translation)

        textEntity.scale = .one * raycastDistance * 2


//        // 7. Place the text facing the camera
//        var resultWithCameraOrientation = self.arView.cameraTransform
////
//        resultWithCameraOrientation.translation = position
//
//        textEntity.orientation = simd_quatf(resultWithCameraOrientation.matrix)
        textEntity.position += position
        textEntity.name = "\(modelName)_text"
//        textEntity.scale

        return textEntity
    }

    private func getCamVector() -> (position: SIMD3<Float>, direciton: SIMD3<Float>) {

        let cameraTransform = arView.cameraTransform

        let camDir = cameraTransform.matrix.columns.2
        return (cameraTransform.translation, -[camDir.x, camDir.y, camDir.z])
    }

//    private func camRayCast() -> ARRaycastResult {
//        let (camPos, camDir) = getCamVector()
//
//        let rcQuery = ARRaycastQuery(origin: camPos, direction: camDir, allowing: arView.focusSquare.allowedRaycast, alignment: .any)
//
//        let results = arView.session.raycast(rcQuery)
//        return results.first!
//    }

    // MARK: - Handle gestures
    @objc
    func handleTap(_ sender: UITapGestureRecognizer) {
        // 1. Perform the raycast against the mesh
        let tapLocation = sender.location(in: arView)
        guard let result = arView.raycast(from: tapLocation, allowing: .estimatedPlane, alignment: .any).first
        else {
            print("raycast against the mesh failed")
            return
        }

        let position = result.worldTransform.position
        // 2. Visualize the intersection point of the ray

        // MARK: - State별로 구분 중요
        switch viewModel!.mainViewState {
        case .addModelState:
            handleAddModelState(position: position)
        case .practiceState:
            handlePracticeState(tapLocation: tapLocation, result: result)
        case .testState:
            handleTestState(tapLocation: tapLocation, result: result)
        }

    }

    /// 선택한 물체 학습창 띄우기
    func handlePracticeState(tapLocation: CGPoint, result: ARRaycastResult) {
        // 모델을 선택하고
        let selectedModelName = selectedModelName(tapLocation: tapLocation)

        // 그 모델을 전체 appState에서 바꿔준다
        viewModel?.setSelectedModelForStudy(selectedModel: SelectedWordModel(word: selectedModelName, rayCastResult: result))

    }

    /// 선택한 물체 테스트창 띄우기
    func handleTestState(tapLocation: CGPoint, result: ARRaycastResult) {
        // 모델을 선택하고
        let selectedModelName = selectedModelName(tapLocation: tapLocation)

        viewModel?.setSelectedModelForTest(selectedModel: SelectedWordModel(word: selectedModelName, rayCastResult: result))
    }

    /// 있던 물체를 불러오거나 classification 진행하기
    func handleAddModelState(position: SIMD3<Float>) {
        switch viewModel!.addModelState {
        case .none:
            print("DEBUG: arViewState is none")
        case .handleExistingModel:
            self.handleExistModel(position: position)
        case .handleImportedModel:
            print("DEBUG: arViewState is handleImportedModel")
        }
    }

    /// 선택한 모델의 이름을 return하기
    func selectedModelName(tapLocation: CGPoint) -> String {

        guard let hitEntity = self.arView.entity(at: tapLocation) else {
            return ""
        }

        let modelName = hitEntity.name.prefix(while: { $0 != "_" })

        print("DEBUG: Hit this!: \(hitEntity.name)")
        print("DEBUG: Model name: \(modelName)")

        return String(modelName)

    }

    /// 선택한 모델의 text의 texture를 바꾸는 함수
    func changeModelTextTexture(result: ARRaycastResult, modelName: String) {
        let worldMatrix = result.worldTransform
        let position = worldMatrix.position

        // 해당 text entity가 존재하는지 확인
        guard let _ = arView.scene.findEntity(named: "\(modelName)_text") else {
            return
        }

        print("DEBUG: - raycast position : \(position)")

        // 기존의 text entity 지우고
        arView.scene.findEntity(named: "\(modelName)_text")?.removeFromParent(preservingWorldTransform: true)

        // 다시 만든다
        let model = generateExistTextEntityWithMaterial(position: position, modelName: String(modelName))

        // 그걸 기존의 anchor에 추가
        arView.scene.findEntity(named: "\(modelName)_anchor")?.addChild(model)
    }


}


extension UIFont {
    // Based on: https://stackoverflow.com/questions/4713236/how-do-i-set-bold-and-italic-on-uilabel-of-iphone-ipad

    func withTraits(traits: UIFontDescriptor.SymbolicTraits...) -> UIFont {
        let descriptor = self.fontDescriptor.withSymbolicTraits(UIFontDescriptor.SymbolicTraits(traits))
        return UIFont(descriptor: descriptor!, size: 0)
    }
}