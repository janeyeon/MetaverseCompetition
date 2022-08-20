//
//  TestStateView.swift
//  MetaverseCompetition
//
//  Created by HayeonKim on 2022/08/20.
//  Copyright © 2022 Apple. All rights reserved.
//

import SwiftUI
import Combine

extension TestStateView {
    class ViewModel: ObservableObject {
        @Published var testState: TestState
        @Published var selectedModelForTest: SelectedWordModel?
        @Published var wordModels: [WordModel]
        @Published var isPopupView = false
        @Published var transcriptionResult: String

        @Published var capturedImage: UIImage
        @Published var isTranscriptionFinished: Bool

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

            _transcriptionResult = .init(initialValue: appState.value.drawingViewAppState.transcriptionResult)

            _capturedImage = .init(initialValue: appState.value.drawingViewAppState.capturedImage)

            _isTranscriptionFinished = .init(initialValue: appState.value.drawingViewAppState.isTranscriptionFinished)


            cancelBag.collect {

                appState.map(\.testAppState.testState)
                    .removeDuplicates()
                    .weakAssign(to: \.testState, on: self)

                appState.map(\.mainViewAppState.selectedModelForTest)
                    .removeDuplicates()
                    .weakAssign(to: \.selectedModelForTest, on: self)

                appState.map(\.mainViewAppState.wordModels)
                    .removeDuplicates()
                    .weakAssign(to: \.wordModels, on: self)

                appState.map(\.drawingViewAppState.transcriptionResult)
                    .removeDuplicates()
                    .weakAssign(to: \.transcriptionResult, on: self)

                appState.map(\.drawingViewAppState.capturedImage)
                    .removeDuplicates()
                    .weakAssign(to: \.capturedImage, on: self)

                appState.map(\.drawingViewAppState.isTranscriptionFinished)
                    .removeDuplicates()
                    .weakAssign(to: \.isTranscriptionFinished, on: self)

            }
        }

        func changeTestState(to state: TestState) {
            container.services.testService.changeTestState(to: state)
        }

        /// 해당 단어 외우기에 성공했을때 해야하는 행동
        func pressIsMemorizedFinishedButton() {
            guard let selectedModel = selectedModelForTest else {
                return
            }

//            container.services.mainViewService.checkWorldModelIsStudyFinished(word: selectedModel.word)


            // 다시 selectedModelForTest nil로 만들어줌
            container.services.mainViewService.setSelectedModelForTest(selectedModel: nil)

        }

        /// 채점하기 시작
        func isTraslateStart() {
            container.services.drawingViewService.pressTrascriptionButton()
        }

        /// selectedModelForTest를 nil로 만들어주는곳
        func pressXmarkButton() {
            container.services.mainViewService.setSelectedModelForTest(selectedModel: nil)
        }

        /// transcirptionPopupView 의 값을 정해줌
        func settranscriptionPopupView(to value: Bool) {
            container.services.drawingViewService.setisTranscriptionFinished(to: value)
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
            if viewModel.selectedModelForTest != nil {
                studyView()
            }

            // MARK: - 나중에 지워야할 부분, test용
//            HStack {
//                Text(viewModel.transcriptionResult)
//                    .foregroundColor(Color.inside.primaryColor)
//                Image(uiImage: viewModel.capturedImage)
//                    .resizable()
//                    .scaledToFit()
//                    .frame(maxHeight: 200)
//            }


            // next state view를 표시하는 화면
//            if viewModel.isStudyFinishedCount == viewModel.wordModels.count {
//                nextStateButton
//            }

            // popup view를 표시하는 화면
            if viewModel.isTranscriptionFinished {
                transcriptionPopupView
            }

            // 최종 popup view를 표시하는 화면
            if viewModel.isMemorizedFinishedCount == viewModel.wordModels.count && !viewModel.isTranscriptionFinished {
                finalPopupView
            }
        }
    }

    var finalPopupView: some View {
        PopupView(confirmAction: {
            //MARK: 다시 초기화해서 처음으로 돌아가기
            print("finish!")
        }, cancelAction: {
            //MARK: 다시 초기화해서 처음으로 돌아가기
            print("finish!")
        }, confirmText: "다시 처음으로 돌아가기", cancelText: "아직 아니요..", isCancelButtonExist: false, isXmarkExist: false, maxWidth: 450, content: {
            VStack(alignment: .center, spacing: 20) {
                Text("오늘 yeon친구와 함께 배운 단어는")
                VStack {
                    ForEach(viewModel.wordModels, id: \.self) { wordModel in
                        VStack {
                            HStack {
                                Spacer()
                                Text(wordModel.word)
                                Spacer()
                                Text("\(wordModel.count) 회")
                            }
                            Divider()
                        }
                    }

                    Text("총 외운단어: \(viewModel.wordModels.count)개")
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 20).foregroundColor(Color.inside.backgroundColor))
                .padding(.horizontal)
                .padding(.top, 20)
            }
            .font(.popupTextSize)
            .foregroundColor(Color.white)
            .padding(.vertical, 60)
            .padding(.top, 30)
        })
    }

    var transcriptionPopupView: some View {
        ZStack {
            if viewModel.selectedModelForTest?.isRight == true {
                // 맞았을 때의 뷰
                PopupView(confirmAction: {
                    // 선택한 단어가 맞는지 틀린지에 따라 바꿔주기
        //            viewModel.isPopupView = false
                    viewModel.settranscriptionPopupView(to: false)
                }, cancelAction: {
                    viewModel.settranscriptionPopupView(to: false)
                }, confirmText: "좋아요!", cancelText: "아직 아니요..", isCancelButtonExist: false, isXmarkExist: false, maxWidth: 450, content: {
                    VStack(alignment: .center, spacing: 20) {
                        Text("잘했어요!!")
                            .font(.system(size: 50, weight: .heavy))
                        Text("정답:")
                        Text(viewModel.selectedModelForTest!.word)
                            .font(.system(size: 100, weight: .heavy))
                            .foregroundColor(Color.inside.primaryColor)
                    }
                    .font(.popupTextSize)
                    .foregroundColor(Color.white)
                    .padding(.vertical, 60)
                    .padding(.top, 30)
                })
            } else {
                // 틀렸을 때의 뷰
                PopupView(confirmAction: {
                    // 선택한 단어가 맞는지 틀린지에 따라 바꿔주기
        //            viewModel.isPopupView = false
                    viewModel.settranscriptionPopupView(to: false)
                }, cancelAction: {
                    viewModel.settranscriptionPopupView(to: false)
                }, confirmText: "좋아요!", cancelText: "아직 아니요..", isCancelButtonExist: false, isXmarkExist: false, maxWidth: 450, content: {
                    VStack(alignment: .center, spacing: 20) {
                        Text("정답:")
                        Text(viewModel.selectedModelForTest!.word)
                            .font(.system(size: 100, weight: .heavy))
                            .foregroundColor(Color.inside.primaryColor)
                        Text("내가 쓴 답:")
                        Text(viewModel.transcriptionResult)
                            .font(.system(size: 100, weight: .heavy))
                            .foregroundColor(Color.inside.accentColor)
                    }
                    .font(.popupTextSize)
                    .foregroundColor(Color.white)
                    .padding(.vertical, 60)
                    .padding(.top, 30)
                })
            }
        }

    }

    func studyView() -> some View {
        VStack {
            Spacer()
            ZStack {
                // background
                Rectangle()
                    .foregroundColor(Color.inside.backgroundColor)

                HStack {
                    Spacer()
                    drawingView
                    Spacer()
                    Spacer()
                    drawingViewButtons
                    Spacer()
                }
                xmarkButton


            }
            .frame(width: UIScreen.main.bounds.width, height: 500, alignment: .bottom)
        }
    }

    var xmarkButton: some View {
        HStack {
            VStack {
                FeatureButton {
                    viewModel.pressXmarkButton()
                } label: {
                    Image(systemName: "xmark")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .padding()
                }
                Spacer()
            }
            Spacer()
        }

    }

    var drawingView: some View {
        ZStack {
            // lines
            lines()

            DrawingViewControllerRepresentable(viewModel: .init(container: viewModel.container))

        }
        .background(RoundedRectangle(cornerRadius: 20))
        .frame(width: 727, height: 260)
    }

    func lines() -> some View {
        GeometryReader { geometry in
            let width = geometry.size.width

            let paddingSize: CGFloat = 2

            let horizontalLine = Path { path in
                path.addLines([
                    CGPoint(x: paddingSize, y: 0),
                    CGPoint(x: width - paddingSize, y: 0)
                ])
            }
                .stroke(style: StrokeStyle(lineWidth: 3, lineCap: .round))
                .foregroundColor(Color.blue.opacity(0.3))

            ZStack {
                VStack(spacing: 0) {
                    ForEach(0..<6) { _ in
                        horizontalLine
                        Spacer()
                    }
                }
            }
        }
    }

    var drawingViewButtons: some View {
        VStack {

            FeatureButton {
                viewModel.isTraslateStart()
            } label: {
                FeatureButtonView(buttonLabel: "채점 하기", buttonIcon: Image(systemName: "checkmark"), isSelected: false)
            }

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
                    viewModel.changeTestState(to: .previousState)
                } label: {
                    FeatureButtonView(buttonLabel: "돌아 가기", buttonIcon: Image(systemName: "arrowshape.turn.up.left.fill"), isSelected: viewModel.testState == .previousState)
                }
                Spacer()
            }
            .padding()
        }
    }

}


