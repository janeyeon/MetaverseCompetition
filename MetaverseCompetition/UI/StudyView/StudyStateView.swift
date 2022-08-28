//
//  StudyStateView.swift
//  MetaverseCompetition
//
//  Created by HayeonKim on 2022/08/19.
//  Copyright © 2022 Apple. All rights reserved.
//

import SwiftUI

extension StudyStateView {
    class ViewModel: ObservableObject {
        @Published var studyState: StudyState
        @Published var selectedModelForStudy: SelectedWordModel?
        @Published var wordModels: [WordModel]
        @Published var isPopupView = false
        @Published var isHeartView = false

        var isStudyFinishedCount: Int {
            return wordModels.filter { $0.isStudyFinished == true }.count
        }

        let container: DIContainer
        private var cancelBag = CancelBag()

        init(container: DIContainer) {
            self.container = container
            let appState = container.appState

            _studyState = .init(initialValue: appState.value.studyAppState.studyState)
            _selectedModelForStudy = .init(initialValue: appState.value.mainViewAppState.selectedModelForStudy)
            _wordModels = .init(initialValue: appState.value.mainViewAppState.wordModels)

            cancelBag.collect{

                appState.map(\.studyAppState.studyState)
                    .removeDuplicates()
                    .weakAssign(to: \.studyState, on: self)
                appState.map(\.mainViewAppState.selectedModelForStudy)
                    .removeDuplicates()
                    .weakAssign(to: \.selectedModelForStudy, on: self)
                appState.map(\.mainViewAppState.wordModels)
                    .removeDuplicates()
                    .weakAssign(to: \.wordModels, on: self)
            }
        }

        func changeToPreviousState() {
            // 여기에서 초기화 진행
            container.services.mainViewService.changeMainViewState(to: .addModelState)

        }

        func changeStudyState(to state: StudyState) {
            container.services.studyService.changeStudyState(to: state)
        }

        func pressIsStudyFinishedButton() {
            // selectedModelForStudy에 해당하는 wordModel의 변수값을 true로 바꿔줌
            guard let selectedModel = selectedModelForStudy else {
                return
            }

            container.services.mainViewService.checkWordModelIsStudyFinished(word: selectedModel.word)

            // 다시 selectedModelForStudy nil로 만들어줌
            container.services.mainViewService.setSelectedModelForStudy(selectedModel: nil)

            isHeartView = true
        }

        /// selectedModelForStudy를 nil로 만들어주는곳
        func pressXmarkButton() {
            container.services.mainViewService.setSelectedModelForStudy(selectedModel: nil)
        }

        func changeToNextState() {
            // 여기에서 초기화등 필요한 함수 진행
            container.services.mainViewService.changeMainViewState(to: .testState)
        }

        /// 아예 모든 진행이 다 끝난 상태
        func pressFinishButton() {
            
        }
    }
}

struct StudyStateView: View {
    @StateObject var viewModel : ViewModel

    var body: some View {
        ZStack {
            // State, button등을 표시하는 화면
            buttonView

            if viewModel.isHeartView {
                HeartView()
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            withAnimation(.easeOut) {
                                viewModel.isHeartView = false
                            }
                        }
                    }
            }

            // drawing view를 표시하는 화면
            if viewModel.selectedModelForStudy != nil {
                studyView()

            }



            // next state view를 표시하는 화면
            if viewModel.isStudyFinishedCount == viewModel.wordModels.count {
                nextStateButton
            }

            // popup view를 표시하는 화면
            if viewModel.isPopupView {
                popupView
            }
        }
    }

    var popupView: some View {
        PopupView(confirmAction: {
            viewModel.changeToNextState()
        }, cancelAction: {
            viewModel.isPopupView = false
        }, confirmText: "좋아요!", cancelText: "아직 아니요..", isCancelButtonExist: false, isXmarkExist: false, maxWidth: 450, content: {
            VStack(alignment: .center, spacing: 20) {
                Text("모든 단어들을 다 외웠나요?")
                Text("좋아요 버튼을 누르시면")
                Text("3초후에 테스트가 시작됩니다!")
                Text("빠르게 단어들을 맞춰주세요")
            }
            .font(.popupTextSize)
            .foregroundColor(Color.white)
            .padding(.vertical, 60)
            .padding(.top, 30)
        })
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

    var drawingViewButtons: some View {
        VStack {
//            FeatureButton {
//                print("hello")
//            } label: {
//                FeatureButtonView(buttonLabel: "다시하기", buttonIcon: Image(systemName: "gobackward"), isSelected: false)
//            }

            FeatureButton {
                viewModel.pressIsStudyFinishedButton()
            } label: {
                FeatureButtonView(buttonLabel: "다 외웠어요!", buttonIcon: Image(systemName: "checkmark"), isSelected: false)
            }

        }

    }

    var drawingView: some View {
        ZStack {
            // lines
            lines()

            Text(viewModel.selectedModelForStudy!.word)
                .font(.system(size: min(CGFloat(1200 / viewModel.selectedModelForStudy!.word.count), CGFloat(150)), weight: .heavy))
                .foregroundColor(Color.inside.textBackgroundColor)

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
//
//            let verticalLine = Path { path in
//                path.addLines([
//                    CGPoint(x: 0, y: paddingSize),
//                    CGPoint(x: 0, y: height - paddingSize)
//                ])
//            }
//                .stroke(style: StrokeStyle(lineWidth: 2, lineCap: .round))
//                .foregroundColor(Color.blue.opacity(0.3))

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
                    Text("학습을 끝낸 단어:")
                        .bold()
                    Text("\(viewModel.isStudyFinishedCount)개")
                        .bold()
                        .foregroundColor(Color.inside.primaryColor)
                }
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
                    viewModel.changeStudyState(to: .home)
                } label: {
                    FeatureButtonView(buttonLabel: "홈", buttonIcon: Image(systemName: "house.fill"), isSelected: viewModel.studyState == .home)
                }

                FeatureButton {
                    print("DEBUG: - press 다시하기 버튼 ")
                } label: {
                    FeatureButtonView(buttonLabel: "다시하기", buttonIcon: Image(systemName: "gobackward"), isSelected: false)
                }

                FeatureButton {
                    viewModel.changeStudyState(to: .previousState)
                } label: {
                    FeatureButtonView(buttonLabel: "돌아 가기", buttonIcon: Image(systemName: "arrowshape.turn.up.left.fill"), isSelected: viewModel.studyState == .previousState)
                }
                Spacer()
            }
            .padding()
        }
    }

    var nextStateButton: some View {
        VStack(alignment: .center) {
            Spacer()
            FeatureButton {
                viewModel.isPopupView = true
            } label: {
                ChangeStateButtonView(buttonLabel: "테스트 시작하기", buttonIcon: Image(systemName: "arrow.right"))
            }
            .padding(.bottom, 50)
        }
    }

}
