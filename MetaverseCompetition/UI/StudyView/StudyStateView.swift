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

        let container: DIContainer
        private var cancelBag = CancelBag()

        init(container: DIContainer) {
            self.container = container
            let appState = container.appState
        }

        func changeToPreviousState() {
            // 여기에서 초기화 진행
            container.services.mainViewService.changeMainViewState(to: .addModelState)
            
        }
    }
}

struct StudyStateView: View {
    @StateObject var viewModel : ViewModel

    var body: some View {
        // State, button등을 표시하는 화면
        buttonView

        // drawing view를 표시하는 화면

        // next state view를 표시하는 화면

        // popup view를 표시하는 화면
    }

    var buttonView: some View {
        ZStack {
            featureButtons

            // 모든 단어를 다 학습하면 -> next state로 가는 버튼 활성화
        }
    }

    var featureButtons: some View {
        HStack {
            Spacer()
            VStack(alignment: .trailing) {
                TemporalButtonView(label: "다시 하기") {
                    print("DEBUG: - press 다시하기 버튼 ")
                }
                TemporalButtonView(label: "돌아 가기") {
                    print("DEBUG: - press 돌아가기 버튼 ")
                    // add change state button
                    viewModel.changeToPreviousState()
                }

                Spacer()
            }
            .padding()
        }
    }
}
