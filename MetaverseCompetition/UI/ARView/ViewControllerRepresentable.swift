//
//  ViewControllerRepresentable.swift
//  MetaverseCompetition
//
//  Created by HayeonKim on 2022/08/08.
//  Copyright © 2022 Apple. All rights reserved.
//

import SwiftUI

struct MyARViewControllerRepresentable: UIViewControllerRepresentable {
    @StateObject var viewModel: MyARViewControllerRepresentable.ViewModel

    func makeUIViewController(context: Context) -> ARViewController {
        ARViewController(viewModel: viewModel)
    }

    func updateUIViewController(_ uiViewController: ARViewController, context: Context) {
    }
}


extension MyARViewControllerRepresentable {
    class ViewModel: ObservableObject {
        @Published var modelConfirmedForPlacement: String?
        @Published var addModelState: AddModelState

        let container: DIContainer
        private var cancelBag = CancelBag()

        init(container: DIContainer) {
            self.container = container
            let appState = container.appState

            _modelConfirmedForPlacement = .init(initialValue: appState.value.addModelAppState.modelConfirmedForPlacement)

            _addModelState = .init(initialValue: appState.value.addModelAppState.addModelState)

            cancelBag.collect{

                $modelConfirmedForPlacement.sink{ appState[\.addModelAppState.modelConfirmedForPlacement] = $0 }

                $addModelState.sink { appState[\.addModelAppState.addModelState] = $0 }

                appState.map(\.addModelAppState.modelConfirmedForPlacement)
                    .removeDuplicates()
                    .weakAssign(to: \.modelConfirmedForPlacement, on: self)

                appState.map(\.addModelAppState.addModelState)
                    .removeDuplicates()
                    .weakAssign(to: \.addModelState, on: self)
            }
        }

    }
}
