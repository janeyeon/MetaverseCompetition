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

    var viewModel: MyARViewControllerRepresentable.ViewModel?
    let BUBBLE_DEPTH: Float = 0.01 // depth of 3D text
    var arView = CustomARView(frame: .zero)
    
    private var cancellable: AnyCancellable?
    private var arViewStateCancellable: AnyCancellable?
    private var selectedModelForStudyCancellable: AnyCancellable?
    private var selectedModelForTestCancellable: AnyCancellable?
    private var selectedModelForStudyOldValueCancellable: AnyCancellable?

    var generateTextSphereEntity: GenerateTextSphereEntity?

    var classificationModel: Classification?

    // MARK: - initializer
    init(viewModel: MyARViewControllerRepresentable.ViewModel) {

        super.init(nibName: nil, bundle: nil)

        self.viewModel = viewModel

        self.generateTextSphereEntity = RealGenerateTextSphereEntity(arView: self.arView)
        self.classificationModel = RealClassification(arView: self.arView, generateTextSphereEntity: self.generateTextSphereEntity!, viewModel: self.viewModel!)

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

                let sphereEntity = self.generateTextSphereEntity!.generateSphereEntity(position: position, modelName: modelName)
                let textEntity = self.generateTextSphereEntity!.generateTextEntity(position: position, modelName: modelName)

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

        selectedModelForStudyOldValueCancellable
        = viewModel.$selectedModelForStudy
            .receive(on: RunLoop.main)
            .sink(receiveValue: { [weak self] selectedModel in

                guard let self = self else { return }
                // nil로 바뀌면 아무것도 하지마라
                guard let selectedModel = selectedModel else { return }

                // 여기에 모델이 선택되면 해야할 일을 명시해 준다
                self.changeModelTextTexture(result: selectedModel.rayCastResult, modelName: selectedModel.word)

            })

        selectedModelForStudyCancellable
        = viewModel.$selectedModelForStudyOldValue
            .receive(on: RunLoop.main)
            .sink(receiveValue: { [weak self] selectedModel in

                guard let self = self else { return }

                // nil로 바뀌면 아무것도 하지마라
                guard let selectedModel = selectedModel else { return }

                // 다 끝내고 나서 다시 nil로 바꿔줘라
                defer {
                    self.viewModel!.setSelectedModelForStudyOldValue()
                }

                // 얘가 선택된거라면 -> 기존의 모델이 nil로 바뀌었다는 소리 -> texture를 다시 원래대로 돌려놔야함
                self.returnModelTextTexture(result: selectedModel.rayCastResult, modelName: selectedModel.word)

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
        guard let selectedModelName = selectedModelName(tapLocation: tapLocation) else {
            return
        }

        // 그 모델을 전체 appState에서 바꿔준다
        viewModel?.setSelectedModelForStudy(selectedModel: SelectedWordModel(word: selectedModelName, rayCastResult: result))

    }

    /// 선택한 물체 테스트창 띄우기
    func handleTestState(tapLocation: CGPoint, result: ARRaycastResult) {
        // 모델을 선택하고
        guard let selectedModelName = selectedModelName(tapLocation: tapLocation) else {
            return
        }

        viewModel?.setSelectedModelForTest(selectedModel: SelectedWordModel(word: selectedModelName, rayCastResult: result))
    }

    /// 있던 물체를 불러오거나 classification 진행하기
    func handleAddModelState(position: SIMD3<Float>) {
        switch viewModel!.addModelState {
        case .home:
            print("DEBUG: arViewState is none")
        case .handleExistingModel:
            self.classificationModel!.handleExistModel(position: position)
        case .handleImportedModel:
            print("DEBUG: arViewState is handleImportedModel")
        }
    }

    /// 선택한 모델의 이름을 return하기
    func selectedModelName(tapLocation: CGPoint) -> String? {

        guard let hitEntity = self.arView.entity(at: tapLocation) else {
            return nil
        }

        let modelName = hitEntity.name.prefix(while: { $0 != "_" })

        print("DEBUG: Hit this!: \(hitEntity.name)")
        print("DEBUG: Model name: \(modelName)")

        guard let _ = arView.scene.findEntity(named: "\(modelName)_text") else {
            return nil
        }

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
        let model = generateTextSphereEntity!.generateExistTextEntityWithMaterial(position: position, modelName: String(modelName))

        // 그걸 기존의 anchor에 추가
        arView.scene.findEntity(named: "\(modelName)_anchor")?.addChild(model)
    }

    /// 선택한 모델의 text의 texture를 다시 되돌리는 함수
    func returnModelTextTexture(result: ARRaycastResult, modelName: String) {

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
        let model = generateTextSphereEntity!.generateExistTextEntity(position: position, modelName: String(modelName))

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
