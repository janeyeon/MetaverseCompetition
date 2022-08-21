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
    
    private var cancellableBag: [AnyCancellable] = []


    var generateTextSphereEntity: GenerateTextSphereEntity?

    var classificationModel: Classification?

    // MARK: - initializer
    init(viewModel: MyARViewControllerRepresentable.ViewModel) {

        super.init(nibName: nil, bundle: nil)

        self.viewModel = viewModel

        self.generateTextSphereEntity = RealGenerateTextSphereEntity(arView: self.arView)
        self.classificationModel = RealClassification(arView: self.arView, generateTextSphereEntity: self.generateTextSphereEntity!, viewModel: self.viewModel!)

        // modelConfirmedForPlacement값이 바뀔때 이걸 받으라고 못하나?
        cancellableBag.append(viewModel.$modelConfirmedForPlacement
            .compactMap { modelName in modelName }
            .flatMap {
                Publishers.Zip(
                    Entity.loadAsync(named: $0, in: nil),
                    Just($0).setFailureType(to: Error.self)
                )
            }
            .map { [weak self] (modelEntity, modelName) -> (String, AnchorEntity, ARRaycastResult?) in

                guard let self = self else { return ("", AnchorEntity(), nil)}

                let modelHeight = (modelEntity.visualBounds(relativeTo: nil).max.y - modelEntity.visualBounds(relativeTo: nil).min.y)

                print("DEBUG: - modelHeight \(modelEntity.scale.y)")


                // 이름인자를 안넣어줌 ㅋㅋ
                modelEntity.name = "\(modelName)_model"

                var position = modelEntity.position

                let anchorEntity = AnchorEntity(plane: .any)
                // model 넣어줌
                anchorEntity.addChild(modelEntity)


                let sphereEntity = self.generateTextSphereEntity!.generateSphereEntity(position: position, modelName: modelName, textModelState: .add, modelHeight: modelHeight)

                let textEntity = self.generateTextSphereEntity!.generateTextEntity(position: position, modelName: modelName, textModelState: .add, modelHeight: modelHeight)

                anchorEntity.addChild(sphereEntity)
                anchorEntity.addChild(textEntity)
                anchorEntity.name = "\(modelName)_anchor"



                guard let result = self.arView.raycast(from: CGPoint(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2), allowing: .estimatedPlane, alignment: .any).first else {
                    return ("", AnchorEntity(), nil)
                }
                return (modelName, anchorEntity, result)
            }
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { [weak self] loadCompletion in
                defer {
                    self?.viewModel!.modelConfirmedForPlacement = nil
                }
                if case let .failure(error) = loadCompletion {
                    assertionFailure("Unable to load a model due to error \(error)")
                }
            }, receiveValue: { [weak self] (modelName, anchorEntity, rayCastResult) in
                guard let self = self else { return }

                self.arView.scene.addAnchor(anchorEntity)
                self.viewModel!.addNewWordModel(word: modelName, rayCastResult: rayCastResult!)
                // add animation
                self.viewModel!.addAnimation(anchorEntity: anchorEntity)
            }))

    // focus Entity를 생성하고 없애는 부분
        cancellableBag.append(
            viewModel.$addModelState
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
        )

        cancellableBag.append( viewModel.$selectedModelForStudy
            .receive(on: RunLoop.main)
            .sink(receiveValue: { [weak self] selectedModel in

                guard let self = self else { return }
                // nil로 바뀌면 아무것도 하지마라
                guard let selectedModel = selectedModel else { return }

                // 여기에 모델이 선택되면 해야할 일을 명시해 준다
                self.selectText(rayCastResult: selectedModel.rayCastResult, modelName: selectedModel.word)
            }))

// test 가 select되면 할 필요가 없다 
//        cancellableBag.append( viewModel.$selectedModelForTest
//            .receive(on: RunLoop.main)
//            .sink(receiveValue: { [weak self] selectedModel in
//
//                guard let self = self else { return }
//                // nil로 바뀌면 아무것도 하지마라
//                guard let selectedModel = selectedModel else { return }
//
//                // 여기에 모델이 선택되면 해야할 일을 명시해 준다
//                self.selectText(rayCastResult: selectedModel.rayCastResult, modelName: selectedModel.word)
//            }))

        cancellableBag.append(viewModel.$selectedModelForStudyOldValue
            .receive(on: RunLoop.main)
            .sink(receiveValue: { [weak self] selectedModel in

                guard let self = self else { return }

                // nil로 바뀌면 아무것도 하지마라
                guard let selectedModel = selectedModel else { return }

                // 다 끝내고 나서 다시 nil로 바꿔줘라
                defer {
                    self.viewModel!.setSelectedModelForStudyOldValue()
                }

                // 얘가 선택된거라면 -> 기존의 모델이 nil로 바뀌었다는 소리 -> texture를 바꾸어준다
                self.returnStudyModelTextTexture(rayCastResult: selectedModel.rayCastResult, modelName: selectedModel.word)

            }))


        // test state들어갈때 anchorEntities초기화
        cancellableBag.append(
            viewModel.$mainViewState
                .sink(receiveValue: { [weak self] mainViewState in

                    guard let self = self else { return }

                    // mainView가 test state일때만 실행
                    if mainViewState == .testState {
                        let anchors:[AnchorEntity] =  self.arView.scene.anchors.map { $0.anchor as! AnchorEntity }
                        self.viewModel?.setAnchorEntities(anchorEntities: anchors)
                        print("DEBUG: all anchors \(anchors)")

                        // 모든 text entity를 지우자
                        self.changeAllTextEntities()
                    }
                })
        )

        // test가 끝나고 맞았다면
        cancellableBag.append(viewModel.$selectedModelForTestOldValue
            .receive(on: RunLoop.main)
            .sink(receiveValue: { [weak self] selectedModel in

                guard let self = self else { return }

                // nil로 바뀌면 아무것도 하지마라
                guard let selectedModel = selectedModel else { return }

                // 다 끝내고 나서 다시 nil로 바꿔줘라
                defer {
                    self.viewModel!.setSelectedModelForTestOldValue()
                }

                // 얘가 선택된거라면 -> 기존의 모델이 nil로 바뀌었다는 소리 -> texture를 다시 원래대로 돌려놔야함
                self.returnTestModelTextTexture(rayCastResult: selectedModel.rayCastResult, modelName: selectedModel.word)

            }))

    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }

    deinit {
        cancellableBag.map { $0.cancel() }
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


    // MARK: - 모든 text entity를 ?으로 바꾸는 부분
    func changeAllTextEntities() {

        // 우선 모든 단어 이름들을 가져온다
//        let words = viewModel!.wordModels.map { $0.word }
        for wordModel in viewModel!.wordModels {
            // text entity를 지운다
            arView.scene.findEntity(named: "\(wordModel.word)_text")?.removeFromParent(preservingWorldTransform: true)

            // 기존에 있던 rayCastResult에서 position을
            let position = wordModel.rayTracingResult.worldTransform.position

            // 같은 자리에 ?를 넣는다
            let model = generateTextSphereEntity!.generateTextEntity(position: position, modelName: wordModel.word, textModelState: .questionMark, modelHeight: nil)

            // 그리고 기존의 anchor에 추가
            arView.scene.findEntity(named: "\(wordModel.word)_anchor")?.addChild(model)

        }
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

        let position = arView.scene.findEntity(named: "\(selectedModelName)_text")?.position


        // 그 모델을 전체 appState에서 바꿔준다
        viewModel?.setSelectedModelForStudy(selectedModel: SelectedWordModel(word: selectedModelName, rayCastResult: result))

    }

    /// 선택한 물체 테스트창 띄우기
    func handleTestState(tapLocation: CGPoint, result: ARRaycastResult) {
        // 모델을 선택하고
        guard let selectedModelName = selectedModelName(tapLocation: tapLocation) else {
            return
        }

        let position = arView.scene.findEntity(named: "\(selectedModelName)_text")?.position

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

        guard let _ = arView.scene.findEntity(named: "\(modelName)_sphere") else {
            return nil
        }

        return String(modelName)

    }

    /// 선택한 모델의 text의 texture를 다시 되돌리는 함수
    /// 만약 학습 성공시에는 -> .finished
    /// 학습 실패시에는 -> .justreturn
    func returnTestModelTextTexture(rayCastResult: ARRaycastResult, modelName: String) {

        let position = rayCastResult.worldTransform.position

        // 해당 text entity가 존재하는지 확인
        guard let _ = arView.scene.findEntity(named: "\(modelName)_text") else {
            return
        }

        print("DEBUG: - raycast position : \(position)")

        // 기존의 text entity 지우고
        arView.scene.findEntity(named: "\(modelName)_text")?.removeFromParent(preservingWorldTransform: true)

        // default는 그냥 return하는것
        var textModelState: TextModelState = .justReturn

        // 선택된 모델이 암기 완료 되었는가?
        if let model = viewModel?.wordModels.filter({ $0.word == modelName }).first, model.isMemorizedFinished {
            // 암기 성공
            textModelState = .finished
        }

        // 다시 만든다
        let model = generateTextSphereEntity!.generateTextEntity(position: position, modelName: String(modelName), textModelState: textModelState, modelHeight: nil)

        // 그걸 기존의 anchor에 추가
        arView.scene.findEntity(named: "\(modelName)_anchor")?.addChild(model)
    }

    /// 선택한 모델의 text의 texture를 다시 되돌리는 함수
    /// 만약 학습 성공시에는 -> .finished
    /// 학습 실패시에는 -> .justreturn
    func returnStudyModelTextTexture(rayCastResult: ARRaycastResult, modelName: String) {

        let position = rayCastResult.worldTransform.position

        // 해당 text entity가 존재하는지 확인
        guard let _ = arView.scene.findEntity(named: "\(modelName)_text") else {
            return
        }

//
        // 기존의 text entity 지우고
        arView.scene.findEntity(named: "\(modelName)_text")?.removeFromParent(preservingWorldTransform: true)

        // default는 그냥 return하는것
        var textModelState: TextModelState = .justReturn

        // 선택된 모델이 학습 완료 되었는가?
        if let model = viewModel?.wordModels.filter({ $0.word == modelName }).first, model.isStudyFinished {
            // 학습 성공
            textModelState = .finished
        }

        // 다시 만든다
        let model = generateTextSphereEntity!.generateTextEntity(position: position, modelName: String(modelName), textModelState: textModelState, modelHeight: nil)

        // 그걸 기존의 anchor에 추가
        arView.scene.findEntity(named: "\(modelName)_anchor")?.addChild(model)

//        // texture바꾸기
//        arView.scene.findEntity(named: "\(modelName)_text")?.parameters[OrbitAnimation.repeatingForever(OrbitAnimation())]
////            .model!.materials[1] = SimpleMaterial(color: .blue, isMetallic: true)
    }

    /// text를 눌렀을때 해야할 일을 명시
    func selectText(rayCastResult: ARRaycastResult, modelName: String) {

        let position = rayCastResult.worldTransform.position

        // 해당 text entity가 존재하는지 확인
        guard let _ = arView.scene.findEntity(named: "\(modelName)_text") else {
            return
        }

        print("DEBUG: - raycast position : \(position)")

        // 기존의 text entity 지우고
        arView.scene.findEntity(named: "\(modelName)_text")?.removeFromParent(preservingWorldTransform: true)

        // 다시 만든다
        // 근데 이제 .selected를 써서
        let model = generateTextSphereEntity!.generateTextEntity(position: position, modelName: String(modelName), textModelState: .selected, modelHeight: nil)

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
