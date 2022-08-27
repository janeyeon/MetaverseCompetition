//
//  MainView.swift
//  CoreML+ARKit+Reformatting
//
//  Created by HayeonKim on 2022/08/03.
//

import Foundation
import SwiftUI

extension MainView {
    class ViewModel: ObservableObject {
        @Published var mainViewState: MainViewState
        @Published var isSplashDone: Bool = false
        @Published var opacity: Double = 1.0


        let container: DIContainer
        private var cancelBag = CancelBag()



        init(container: DIContainer) {
            self.container = container
            let appState = container.appState

            _mainViewState = .init(initialValue: appState.value.mainViewAppState.mainViewState)

            cancelBag.collect {
                $mainViewState.sink{
                    appState[\.mainViewAppState.mainViewState] = $0
                }

                appState.map(\.mainViewAppState.mainViewState)
                    .removeDuplicates()
                    .weakAssign(to: \.mainViewState, on: self)
            }


        }

        func changeMainViewState(to state: MainViewState) {
            container.services.mainViewService.changeMainViewState(to: state)
        }

        /// main view가 켜지자마자 해야하는 일
        func mainViewAppeared() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                withAnimation(.easeInOut(duration: 1.0)) {
                    self.opacity = 0.0
                }
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
                self.isSplashDone = true
            }
        }
    }
}


struct MainView: View {

    @StateObject var viewModel: MainView.ViewModel

    var body: some View {
        ZStack {
            if viewModel.isSplashDone {
                // main 화면
                ZStack{
                    // 항상 보여주는 화면
                    MyARViewControllerRepresentable(viewModel: .init(container: viewModel.container))

                    switch viewModel.mainViewState {

                    case .addModelState:
                        AddModelStateView(viewModel: .init(container: viewModel.container))

                    case .practiceState:
                        StudyStateView(viewModel: .init(container: viewModel.container))

                    case .testState:
                        TestStateView(viewModel: .init(container: viewModel.container))
                    }
                }
            } else {
                // splash 화면 켜지기
                SplashView()
                    .opacity(viewModel.opacity)
            }
        }
        .onAppear {
            viewModel.mainViewAppeared()
        }

    }
}
