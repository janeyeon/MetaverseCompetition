//
//  AddModelState.swift
//  MetaverseCompetition
//
//  Created by HayeonKim on 2022/08/18.
//  Copyright © 2022 Apple. All rights reserved.
//

import Foundation
import SwiftUI

extension AddModelStateView {
    class ViewModel : ObservableObject {
        // 뭘 선택할건지
        @Published var modelConfirmedForPlacement: String?
        @Published var addModelState: AddModelState
        @Published var wordModels: [WordModel]
        @Published var capturedImage: SelectedCapturedImage?

        @Published var isPlacementEnabled: Bool = false
        @Published var selectedModel: String?
        @Published var isPopupView: Bool = false
        @Published var isClassificationPopupView: Bool = false

        @Published var selectedModelForCancel: String?
        @Published var modelConfirmentForCancel: String?


        let container: DIContainer
        private var cancelBag = CancelBag()

        init(container: DIContainer) {
            self.container = container
            let appState = container.appState

            _modelConfirmedForPlacement = .init(initialValue: appState.value.addModelAppState.modelConfirmedForPlacement)

            _addModelState = .init(initialValue: appState.value.addModelAppState.addModelState)

            _wordModels = .init(initialValue: appState.value.mainViewAppState.wordModels)

            _capturedImage = .init(initialValue: appState.value.addModelAppState.capturedImage)

            _modelConfirmentForCancel = .init(initialValue: appState.value.addModelAppState.modelConfirmentForCancel)

            _selectedModelForCancel = .init(initialValue: appState.value.addModelAppState.selectedModelForCancel)

            cancelBag.collect{

                //바꾸기 원하는 값
                appState.map(\.addModelAppState.modelConfirmedForPlacement)
                    .removeDuplicates()
                    .weakAssign(to: \.modelConfirmedForPlacement, on: self)

                appState.map(\.addModelAppState.addModelState)
                    .removeDuplicates()
                    .weakAssign(to: \.addModelState, on: self)

                appState.map(\.mainViewAppState.wordModels)
                    .removeDuplicates()
                    .weakAssign(to: \.wordModels, on: self)

                appState.map(\.addModelAppState.capturedImage)
                    .removeDuplicates()
                    .weakAssign(to: \.capturedImage, on: self)

                appState.map(\.addModelAppState.modelConfirmentForCancel)
                    .removeDuplicates()
                    .weakAssign(to: \.modelConfirmentForCancel, on: self)

                appState.map(\.addModelAppState.selectedModelForCancel)
                    .removeDuplicates()
                    .weakAssign(to: \.selectedModelForCancel, on: self)

            }
        }


        static var possibleImportedModel: [String] = {
            let fileManager = FileManager.default

            guard let path = Bundle.main.resourcePath,
                    let files = try? fileManager.contentsOfDirectory(atPath: path) else {
                assertionFailure()
                return []
            }

            var fileNames: [String] = []
            for file in files where file.hasSuffix("usdz"){
                let modelName = file.replacingOccurrences(of: ".usdz", with: "")
                if modelName != "myCoin" {
                    fileNames.append(modelName)
                }
            }
            assert(!fileNames.isEmpty)
            return fileNames
        }()

        func changeAddModelState(to state: AddModelState) {
            container.services.addModelService.changeAddModelState(to: state)
        }


        func modelPlacementCancelButton() {
            container.services.addModelService.modelPlacementCancelButton()
            resetPlacementParameters()
        }

        func modelPlacementConfirmButton() {
            container.services.addModelService.modelPlacementConfirmButton(selectedModel: selectedModel!)
            resetPlacementParameters()
        }

        func resetPlacementParameters() {
            isPlacementEnabled = false
            selectedModel = nil
        }
        

        func changeToNextState() {
            // 여기에서 초기화등 필요한 함수 진행 
            container.services.mainViewService.changeMainViewState(to: .practiceState)
        }

        /// classification이 맞았을 경우
        func setisClassificationRight(to value: Bool) {
            container.services.addModelService.setisClassificationRight(to: value)
        }

        func setModelConfirmentForCancel() {
            container.services.addModelService.setModelConfirmentForCancel()
        }

        func setSelectedModelConfirmentForCancel(selectedModel: String?) {
            container.services.addModelService.setSelectedModelForCancel(selectedModel: selectedModel)
        }
    }
}

struct AddModelStateView: View {
    @StateObject var viewModel : ViewModel

    var body: some View {
        // focus view 표시
        if viewModel.addModelState == .handleExistingModel {
            focusView
        }

        // State, button등을 표시하는 화면
        buttonView

        // import할 모델을 검색하는 화면
        importModelView

        // next state button
        if viewModel.addModelState == .home && viewModel.wordModels.count > 0 {
            nextStateButton
        }

        // cancelView에서 주의문구 추가
        if viewModel.addModelState == .cancelModel {
            cancelWarning
        }

        // popup view를 표시하는 화면
        if viewModel.isPopupView {
            popupView
        }

        // 삭제하고자 하는 wordModel을 지울건지 확인하는 창
        if viewModel.selectedModelForCancel != nil {
            cancelPopupView
        }


//        if viewModel.capturedImage != nil {
//            Image(uiImage: viewModel.capturedImage!.capturedImage)
//                .resizable()
//                .scaledToFit()
//                .frame(width: 300)
//        }
    }

    var cancelWarning: some View {
        VStack(alignment: .center, spacing: .zero) {
            Spacer()
            Text(viewModel.wordModels.count == 0 ? "삭제할 단어가 없습니다. 단어를 추가한 후에 삭제를 진행해주세요" : "삭제할 단어를 선택해주세요")
                .font(.defaultTextSize)
                .padding()
                .background(RoundedRectangle(cornerRadius: 10).foregroundColor(Color.inside.darkerBackgroundColor))
                .padding(.bottom, 270)
        }
    }

    var cancelPopupView: some View {
        PopupView(confirmAction: {
            // 모델을 삭제하기
            viewModel.setModelConfirmentForCancel()
        }, cancelAction: {
            // 대충 선택해놨던 모델을 nil로 바꿔놓기
            viewModel.setSelectedModelConfirmentForCancel(selectedModel: nil)
        }, confirmText: "삭제하기", cancelText: "돌아가기", isCancelButtonExist: true, isXmarkExist: false, maxWidth: 450, content: {
            VStack(alignment: .center, spacing: 20) {
                HStack(spacing: 0) {
                    Text("\"\(viewModel.selectedModelForCancel ?? "아무거나")\"")
                        .foregroundColor(Color.inside.primaryColor)
                    Text("를")
                }
                Text("정말로 삭제하시겠습니까?")
            }
            .font(.popupTextSize)
            .foregroundColor(Color.white)
            .padding(.vertical, 60)
            .padding(.top, 30)
        })

    }

    var popupView: some View {
        PopupView(confirmAction: {
            viewModel.changeToNextState()
        }, cancelAction: {
            viewModel.isPopupView = false
        }, confirmText: "좋아요!", cancelText: "아직 아니요..", isCancelButtonExist: true, isXmarkExist: false, maxWidth: 450, content: {
            VStack(alignment: .center, spacing: 20) {
                Text("외울 단어들을 다 추가했나요? ")
                Text("그럼 다같이 단어를 외우러")
                Text("신나는 모험을 떠나볼까요?")
            }
            .font(.popupTextSize)
            .foregroundColor(Color.white)
            .padding(.vertical, 60)
            .padding(.top, 30)
        })
    }

//    var classificationPopupView: some View {
//        PopupView(confirmAction: {
//            // classification이 맞았음
//            viewModel.changeToNextState()
//        }, cancelAction: {
//            // classification이 틀렸음
//            viewModel.isPopupView = false
//        }, confirmText: "좋아요!", cancelText: "아직 아니요..", isCancelButtonExist: true, isXmarkExist: false, maxWidth: 450, content: {
//            VStack(alignment: .center, spacing: 20) {
//                Text("외울 단어들을 다 추가했나요? ")
//                Text("그럼 다같이 단어를 외우러")
//                Text("신나는 모험을 떠나볼까요?")
//            }
//            .font(.popupTextSize)
//            .foregroundColor(Color.white)
//            .padding(.vertical, 60)
//            .padding(.top, 30)
//        })
//    }

    var focusView: some View {
        ZStack {
            focusBackgroundView()
            focusSquareview()
                .frame(alignment: .center)
            Image(systemName: "plus")
                .resizable()
                .foregroundColor(Color.inside.primaryColor)
                .frame(width: 35, height: 35, alignment: .center)
            // 여기에 경고문구
            VStack(alignment: .center, spacing: .zero) {
                Spacer()
                Text("물체가 화면의 중앙에 오도록 해주세요!")
                    .font(.defaultTextSize)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 10).foregroundColor(Color.inside.darkerBackgroundColor))
                    .padding(.bottom, 270)
            }
        }
    }

    func focusSquareview() -> some View {
        let maxWidth = UIScreen.main.bounds.width
        let maxHeight = UIScreen.main.bounds.height
        let rectWidth : CGFloat = 500
        let rectHeight : CGFloat = 600
        let point1 = CGPoint(x: maxWidth/2 - rectWidth/2, y: maxHeight/2 - rectHeight/2)
        let point2 = CGPoint(x: maxWidth/2 + rectWidth/2, y: maxHeight/2 - rectHeight/2)
        let point3 = CGPoint(x: maxWidth/2 + rectWidth/2, y: maxHeight/2 + rectHeight/2)
        let point4 = CGPoint(x: maxWidth/2 - rectWidth/2, y: maxHeight/2 + rectHeight/2)
        let lineLength: CGFloat = 50

        return VStack {
            Path { path in
                // L
                path.addLines([
                    CGPoint(x: point1.x, y: point1.y + lineLength),
                    CGPoint(x: point1.x, y: point1.y),
                    CGPoint(x: point1.x + lineLength, y: point1.y)
                ])

                // _|
                path.addLines([
                    CGPoint(x: point2.x - lineLength, y: point2.y),
                    CGPoint(x: point2.x, y: point2.y),
                    CGPoint(x: point2.x, y: point2.y + lineLength)
                ])

                // ㄱ
                path.addLines([
                    CGPoint(x: point3.x - lineLength, y: point3.y),
                    CGPoint(x: point3.x, y: point3.y),
                    CGPoint(x: point3.x, y: point3.y - lineLength)
                ])

                // -|
                path.addLines([
                    CGPoint(x: point4.x, y: point4.y - lineLength),
                    CGPoint(x: point4.x, y: point4.y),
                    CGPoint(x: point4.x + lineLength, y: point4.y)
                ])
            }
            .stroke(style: StrokeStyle(lineWidth: 5, lineCap: .round))
            .foregroundColor(Color.inside.primaryColor)
        }
    }

    func focusBackgroundView() -> some View {
        let maxWidth = UIScreen.main.bounds.width
        let maxHeight = UIScreen.main.bounds.height
        let rectWidth : CGFloat = 500
        let rectHeight : CGFloat = 600

        let largeRect = UIBezierPath(rect: CGRect(x: 0, y: 0, width: maxWidth, height: maxHeight))

        let smallRect = UIBezierPath(rect: CGRect(x: maxWidth / 2 - rectWidth / 2, y: maxHeight / 2 - rectHeight / 2, width: rectWidth, height: rectHeight))

        largeRect.append(smallRect.reversing())
        let path = Path(largeRect.cgPath)

        return path.fill(Color.inside.backgroundColor)
    }

    var buttonView: some View {
        ZStack {
            // status view
            statusView

            // normal buttons
            featureButtons
        }
    }

    var statusView: some View {
        StatusView {
            Group {
                Text("Yeon 친구 환영해요!")
                    .bold()
                Spacer()
                HStack {
                    Text("오늘 함께 외워볼 단어:")
                        .bold()
                    Text("\(viewModel.wordModels.count)개")
                        .bold()
                        .foregroundColor(Color.inside.primaryColor)
                }
            }
            .font(.statusTextSize)
            .foregroundColor(Color.white)
        }

    }

    var nextStateButton: some View {
        VStack(alignment: .center) {
            Spacer()

            FeatureButton {
//                viewModel.changeToNextState()
                viewModel.isPopupView = true
            } label: {
                ChangeStateButtonView(buttonLabel: "학습 시작하기", buttonIcon: Image(systemName: "arrow.right"))
            }
            .padding(.bottom, 50)
        }
    }

    var featureButtons: some View {
        HStack {
            Spacer()
            VStack(alignment: .trailing, spacing: 15) {

                FeatureButton {
                    print("DEBUG: - press 홈 버튼 ")
                    viewModel.changeAddModelState(to: .home)
                } label: {
                    FeatureButtonView(buttonLabel: "홈", buttonIcon: Image(systemName: "house.fill"), isSelected: viewModel.addModelState == .home)
                }



                FeatureButton {
                    print("DEBUG: - press 추가하기 버튼 ")
                    // add change state button
                    viewModel.changeAddModelState(to: .handleImportedModel)
                } label: {
                    FeatureButtonView(buttonLabel: "추가 하기", buttonIcon: Image(systemName: "plus"), isSelected: viewModel.addModelState == .handleImportedModel)
                }

                FeatureButton {
                    print("DEBUG: - press 인식하기 버튼 ")
                    viewModel.changeAddModelState(to: .handleExistingModel)
                } label: {
                    FeatureButtonView(buttonLabel: "인식 하기", buttonIcon: Image(systemName: "eyes"), isSelected: viewModel.addModelState == .handleExistingModel)
                }

                FeatureButton {
                    print("DEBUG: - press 삭제하기 버튼 ")
                    viewModel.changeAddModelState(to: .cancelModel)
                } label: {
                FeatureButtonView(buttonLabel: "삭제하기", buttonIcon: Image(systemName: "xmark"), isSelected: viewModel.addModelState == .cancelModel)
                }
                Spacer()
            }
            .padding()
        }
    }

    var importModelView: some View {
        VStack {
            if viewModel.addModelState == .handleImportedModel  {
                if viewModel.isPlacementEnabled {
                    // placement button
                    placementButtonsView
                } else {
                    // picker
                    modelPickerView
                }
            }
        }
    }

    var modelPickerView: some View {
        VStack {
            Spacer()
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 30) {
                    ForEach(ViewModel.possibleImportedModel, id: \.self) { name in
                        FeatureButton {
                            print("press button named: \(name)")

                            viewModel.selectedModel = name
                            // placement
                            viewModel.isPlacementEnabled = true
                        } label: {
                            VStack {
                                Image(uiImage: UIImage(named: name)!)
                                    .resizable()
                                    .scaledToFit()
                                    .background(.white)
                                    .cornerRadius(12)
                                Text(name)
                                    .font(.defaultTextSize)
                                    .foregroundColor(Color.white)
                            }
                            .frame(height: 100)

//                            .aspectRatio(1/1, contentMode: .fit)


                        }

                    }
                }
                .padding(20)
                .background(Color.black.opacity(0.5))
            }
        }

    }

    var placementButtonsView: some View {
        VStack {
            Spacer()
            HStack {
                // Cancel button
                Button(action: {
                    print("DEBUG: press cancel button")
                    viewModel.modelPlacementConfirmButton()
                }) {
                    Image(systemName: "xmark")
                        .frame(width: 60, height: 60)
                        .font(.title)
                        .background(Color.white.opacity(0.75))
                        .cornerRadius(30)
                        .padding(20)
                }

                // confirm button
                Button {
                    print("DEBUG: press confirm button")
                    viewModel.modelPlacementConfirmButton()
                } label: {
                    Image(systemName: "checkmark")
                        .frame(width: 60, height: 60)
                        .font(.title)
                        .background(Color.white.opacity(0.75))
                        .cornerRadius(30)
                        .padding(20)
                }
            }
        }

        }

}
