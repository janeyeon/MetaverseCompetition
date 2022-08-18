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
        @Published var currentState: MainViewState = .addModelState
        @Published var addModelState: AddModelState = .handleExistingModel
        @Published var transcript: String = ""
        @Published var isTrascriptButtonPressed: Bool = false

        func changeMainViewState(to state: MainViewState) {
            currentState = state
        }

        func changeAddModelState(to state: AddModelState) {
            addModelState = state
        }
    }
}


struct MainView: View {

    @StateObject var viewModel: MainView.ViewModel = ViewModel()

    var body: some View {
        ZStack{
            // 항상 보여주는 화면
            MyARViewControllerRepresentable(mainViewVM: viewModel)

            switch viewModel.currentState {
            case .addModelState:
                AddModelStateView(mainViewModel: viewModel)
            case .practiceState:
                EmptyView()
            case .testState:
                EmptyView()
            }
        }
    }
}
