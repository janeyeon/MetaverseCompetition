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
import SwiftUI
import Vision

// First, set up arview using uikit
class ARViewController: UIViewController, ARSessionDelegate {

    //MARK: - set up variables
    let imagePredictor = ImagePredictor()
    var latestPrediction: String = "hello"
    var mainViewVM: MainView.ViewModel 
    let BUBBLE_DEPTH: Float = 0.01 // depth of 3D text
    var arView = CustomARView(frame: .zero)
    
    private var cancellable: AnyCancellable?
    private var arViewStateCancellable: AnyCancellable?

    // MARK: - initializer
    init(mainViewVM: MainView.ViewModel) {
        self.mainViewVM = mainViewVM
        super.init(nibName: nil, bundle: nil)

        cancellable = mainViewVM
            .$modelConfirmedForPlacement
            .compactMap { modelName in modelName }
            .flatMap {
                Publishers.Zip(
                    Entity.loadModelAsync(named: $0, in: nil),
                    Just($0).setFailureType(to: Error.self)
                )
            }
            .map { [weak self] (modelEntity, modelName) -> AnchorEntity in

                guard let self = self else { return AnchorEntity()}

                let result = self.camRayCast()
                let modelHeight = (modelEntity.model?.mesh.bounds.max.y)! - (modelEntity.model?.mesh.bounds.min.y)!

//                var position = result.worldTransform.position
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

                return anchorEntity
            }
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { [weak self] loadCompletion in
                defer {
                    self?.mainViewVM.modelConfirmedForPlacement = nil
                }
                if case let .failure(error) = loadCompletion {
                    assertionFailure("Unable to load a model due to error \(error)")
                }
            }, receiveValue: { [weak self] anchorEntity in
                guard let self = self else { return }

                self.arView.scene.addAnchor(anchorEntity)
            })

        arViewStateCancellable = mainViewVM.$arViewState
            .receive(on: RunLoop.main)
            .sink(receiveValue: { [weak self] arViewState in
                guard let self = self else { return }
                if arViewState == .handleImportedModel {
                    self.arView.setFocusSquare(isCreateNeeded: true)
                } else {
                    self.arView.setFocusSquare(isCreateNeeded: false)
                }

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

    // MARK: - ARSCNViewDelegate
    func sessionWasInterrupted(_ session: ARSession) {}

    func sessionInterruptionEnded(_ session: ARSession) {}

    func session(_ session: ARSession, didFailWithError error: Error) {}

    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {}

    // MARK: - Statue Bar
    override var prefersStatusBarHidden: Bool { true }

    func generateTextModel(text: String) -> ModelEntity {
        let lineHeight: CGFloat = 0.05
        let font = MeshResource.Font.systemFont(ofSize: lineHeight)
        let textMesh = MeshResource.generateText(text, extrusionDepth: Float(lineHeight * 0.1), font: font)
        let textMeterial = SimpleMaterial(color: UIColor.orange, isMetallic: true)
        let model = ModelEntity(mesh: textMesh, materials: [textMeterial])
//
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

        arView.installGestures(.all, for: sphere)

        return sphere
    }

    func generateExistTextEntity(position: SIMD3<Float>, modelName: String) -> ModelEntity {
        let textEntity = self.generateTextModel(text: modelName)
        let raycastDistance = distance(position, self.arView.cameraTransform.translation)

        textEntity.scale = .one * raycastDistance

        var resultWithCameraOrientation = self.arView.cameraTransform
          resultWithCameraOrientation.translation = position

          textEntity.orientation = simd_quatf(resultWithCameraOrientation.matrix)
        textEntity.name = "\(modelName)_text"

        return textEntity

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

        return textEntity
    }

    private func getCamVector() -> (position: SIMD3<Float>, direciton: SIMD3<Float>) {

        let cameraTransform = arView.cameraTransform

        let camDir = cameraTransform.matrix.columns.2
        return (cameraTransform.translation, -[camDir.x, camDir.y, camDir.z])
    }

    private func camRayCast() -> ARRaycastResult {
        let (camPos, camDir) = getCamVector()

        let rcQuery = ARRaycastQuery(origin: camPos, direction: camDir, allowing: arView.focusSquare.allowedRaycast, alignment: .any)

        let results = arView.session.raycast(rcQuery)
        return results.first!
    }

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

        // MARK: - 여기에서 반드시 WorldModel을 제대로 넣어주어야 함
        switch mainViewVM.arViewState {
        case .none:
            print("DEBUG: arViewState is none")
        case .handleExistingModel:
            handleExistModel(position: position)
        case .handleImportedModel:
            print("DEBUG: arViewState is handleImportedModel")
        case .selectModels:
            print("DEBUG: arViewState is selectModels")
            selectModel(tapLocation: tapLocation, worldMatrix: result.worldTransform)


        }
    }

    func selectModel(tapLocation: CGPoint, worldMatrix: simd_float4x4) {
        guard let hitEntity = self.arView.entity(at: tapLocation) else {
            return
        }

        let modelName = hitEntity.name.prefix(while: { $0 != "_" })
        print("DEBUG: Hit this!: \(hitEntity.name)")
        print("DEBUG: Model name: \(modelName)")

        let rotation = simd_float4x4(SCNMatrix4MakeRotation( -90.0 * .pi/180, 0,1,0))
        let transform = simd_mul(worldMatrix, rotation)


        // 여기에서 text 좀 바꿔주자
        arView.scene.findEntity(named: "\(modelName)_text")?.move(to: transform,
                                                                relativeTo: arView.scene.findEntity(named: "\(modelName)_text"),
                                                                duration: 1,
                                                                timingFunction: .linear)

    }
}


extension UIFont {
    // Based on: https://stackoverflow.com/questions/4713236/how-do-i-set-bold-and-italic-on-uilabel-of-iphone-ipad

    func withTraits(traits: UIFontDescriptor.SymbolicTraits...) -> UIFont {
        let descriptor = self.fontDescriptor.withSymbolicTraits(UIFontDescriptor.SymbolicTraits(traits))
        return UIFont(descriptor: descriptor!, size: 0)
    }
}
