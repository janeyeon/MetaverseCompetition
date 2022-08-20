//
//  TestStateView.swift
//  MetaverseCompetition
//
//  Created by HayeonKim on 2022/08/20.
//  Copyright © 2022 Apple. All rights reserved.
//

import SwiftUI

extension TestStateView {
    class ViewModel: ObservableObject {
        @Published var testState: TestState
        @Published var selectedModelForTest: SelectedWordModel?
        @Published var wordModels: [WordModel]
        @Published var isPopupView = false

        var isMemorizedFinishedCount: Int {
            return wordModels.filter { $0.isMemorizedFinished == true }.count
        }

        let container: DIContainer
        private var cancelBag = CancelBag()

        init(container: DIContainer) {
            self.container = container
            let appState = container.appState

            _testState = .init(initialValue: appState.value.testAppState.testState)

            _selectedModelForTest = .init(initialValue: appState.value.mainViewAppState.selectedModelForTest)

            _wordModels = .init(initialValue: appState.value.mainViewAppState.wordModels)

            cancelBag.collect {
                $testState.sink { appState[\.testAppState.testState] = $0 }

                $selectedModelForTest.sink { appState[\.mainViewAppState.selectedModelForTest] = $0 }

                $wordModels.sink { appState[\.mainViewAppState.wordModels] = $0 }

                appState.map(\.testAppState.testState)
                    .removeDuplicates()
                    .weakAssign(to: \.testState, on: self)

                appState.map(\.mainViewAppState.selectedModelForTest)
                    .removeDuplicates()
                    .weakAssign(to: \.selectedModelForTest, on: self)

                appState.map(\.mainViewAppState.wordModels)
                    .removeDuplicates()
                    .weakAssign(to: \.wordModels, on: self)
            }
        }

        func changeTestState(to state: TestState) {
            container.services.testService.changeTestState(to: state)
        }

    }
}

struct TestStateView: View {
    @StateObject var viewModel : ViewModel

    var body: some View {
        ZStack {
            // State, button등을 표시하는 화면
            buttonView

            // drawing view를 표시하는 화면
//            if viewModel.selectedModelForTest != nil {
//
//            }

            // next state view를 표시하는 화면
//            if viewModel.isStudyFinishedCount == viewModel.wordModels.count {
//                nextStateButton
//            }

            // popup view를 표시하는 화면
//            if viewModel.isPopupView {
//                popupView
//            }
        }
    }


    var buttonView: some View {
        ZStack {
            // status view
            statusView

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
                Spacer()
                HStack {
                    Text("지금까지 맞춘 단어:")
                        .bold()
                    Text("\(viewModel.isMemorizedFinishedCount)개")
                        .bold()
                        .foregroundColor(Color.inside.primaryColor)
                }

                //MARK: 이 밑에 timer 심어두기
            }
            .font(.statusTextSize)
            .foregroundColor(Color.white)
        }

    }

    var featureButtons: some View {
        HStack {
            Spacer()
            VStack(alignment: .trailing, spacing: 15) {

                FeatureButton {
                    viewModel.changeTestState(to: .home)
                } label: {
                    FeatureButtonView(buttonLabel: "홈", buttonIcon: Image(systemName: "house.fill"), isSelected: viewModel.testState == .home)
                }

                FeatureButton {
                    print("DEBUG: - press 다시하기 버튼 ")
                } label: {
                    FeatureButtonView(buttonLabel: "다시하기", buttonIcon: Image(systemName: "gobackward"), isSelected: false)
                }

                FeatureButton {
                    viewModel.changeTestState(to: .home)
                } label: {
                    FeatureButtonView(buttonLabel: "돌아 가기", buttonIcon: Image(systemName: "arrowshape.turn.up.left.fill"), isSelected: viewModel.testState == .home)
                }
                Spacer()
            }
            .padding()
        }
    }

}


