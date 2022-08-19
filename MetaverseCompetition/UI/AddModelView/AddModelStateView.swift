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

        @Published var isPlacementEnabled: Bool = false
        @Published var selectedModel: String?
        @Published var wordModels: [WordModel]

        let container: DIContainer
        private var cancelBag = CancelBag()

        init(container: DIContainer) {
            self.container = container
            let appState = container.appState

            _modelConfirmedForPlacement = .init(initialValue: appState.value.addModelAppState.modelConfirmedForPlacement)

            _addModelState = .init(initialValue: appState.value.addModelAppState.addModelState)

            _wordModels = .init(initialValue: appState.value.mainViewAppState.wordModels)

            cancelBag.collect{
                // 관찰하기 원하는 값
                $modelConfirmedForPlacement.sink { appState[\.addModelAppState.modelConfirmedForPlacement] = $0 }

                $addModelState.sink { appState[\.addModelAppState.addModelState] = $0 }

                $wordModels.sink { appState[\.mainViewAppState.wordModels] = $0 }

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
                fileNames.append(modelName)
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
        nextStateButton

        // popup view를 표시하는 화면
    }

    var focusView: some View {
        ZStack {
            focusBackgroundView()
            Image("focusSquare")
                .resizable()
                .frame(width: 500, height: 600, alignment: .center)
            Image(systemName: "plus")
                .resizable()
                .foregroundColor(Color.inside.primaryColor)
                .frame(width: 35, height: 35, alignment: .center)
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

        return ZStack {

        }
        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        .background(.ultraThinMaterial, in: path)
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
        VStack {
            HStack {
                ZStack {
                    LinearGradient(colors: [Color.inside.darkerBackgroundColor, Color.clear], startPoint: .leading, endPoint: .trailing)
                    VStack(alignment: .leading) {
                        Spacer()
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
                        Spacer()
                    }
                }
                .frame(maxWidth: 400 ,maxHeight: 200)
                Spacer()
            }
            Spacer()
        }

    }

    var nextStateButton: some View {
        VStack(alignment: .center) {
            Spacer()
            TemporalButtonView(label: "학습 시작하기") {
                // 다음 상태로 넘어가기
                viewModel.changeToNextState()
            }
        }
    }

    var featureButtons: some View {
        HStack {
            Spacer()
            VStack(alignment: .trailing, spacing: 15) {

                FeatureButton {
                    print("DEBUG: - press 홈 버튼 ")
                    viewModel.changeAddModelState(to: .none)
                } label: {
                    FeatureButtonView(buttonLabel: "홈", buttonIcon: Image(systemName: "house.fill"), isSelected: viewModel.addModelState == .none)
                }

                FeatureButton {
                    print("DEBUG: - press 다시하기 버튼 ")
                } label: {
                    FeatureButtonView(buttonLabel: "다시하기", buttonIcon: Image(systemName: "gobackward"), isSelected: false)
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
                        Button {
                            print("press button named: \(name)")

                            viewModel.selectedModel = name
                            // placement
                            viewModel.isPlacementEnabled = true
                        } label: {
                            Image(uiImage: UIImage(named: name)!)
                                .resizable()
                                .frame(height: 80)
                                .aspectRatio(1/1, contentMode: .fit)
                                .background(.white)
                                .cornerRadius(12)
                        }
                        .buttonStyle(.plain)

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
