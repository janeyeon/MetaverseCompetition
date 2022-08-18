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

    }
}


struct MainView: View {

    @StateObject var viewModel: MainView.ViewModel

    var body: some View {
        ZStack{
            // 항상 보여주는 화면
            MyARViewControllerRepresentable(viewModel: .init(container: viewModel.container))

            switch viewModel.mainViewState {
            case .addModelState:
                AddModelStateView(viewModel: .init(container: viewModel.container))
            case .practiceState:
                EmptyView()
            case .testState:
                EmptyView()
            }
        }
    }
}
