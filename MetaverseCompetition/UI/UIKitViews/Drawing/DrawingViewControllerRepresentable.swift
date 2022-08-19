//
//  DrawingViewControllerRepresentable.swift
//  MetaverseCompetition
//
//  Created by HayeonKim on 2022/08/10.
//  Copyright © 2022 Apple. All rights reserved.
//

import SwiftUI
import PencilKit
import UIKit

struct DrawingViewControllerRepresentable: UIViewControllerRepresentable {

    @StateObject var viewModel: DrawingViewControllerRepresentable.ViewModel

    func makeUIViewController(context: Context) -> DrawingViewController {
        DrawingViewController(viewModel: viewModel)
    }

    func updateUIViewController(_ uiViewController: DrawingViewController, context: Context) {
    }
}

extension DrawingViewControllerRepresentable{
    class ViewModel: ObservableObject {
        @Published var transcript: String
        @Published var isTrascriptButtonPressed: Bool

        let container: DIContainer
        private var cancelBag = CancelBag()

        init(container: DIContainer) {
            self.container = container
            let appState = container.appState

            _transcript = .init(initialValue: appState.value.drawingViewAppState.transcript)
            _isTrascriptButtonPressed = .init(initialValue: appState.value.drawingViewAppState.isTrascriptButtonPressed)

            cancelBag.collect{
                $transcript.sink{
                    appState[\.drawingViewAppState.transcript] = $0
                }

                $isTrascriptButtonPressed.sink{
                    appState[\.drawingViewAppState.isTrascriptButtonPressed] = $0
                }

                appState.map(\.drawingViewAppState.transcript)
                    .removeDuplicates()
                    .weakAssign(to: \.transcript, on: self)

                appState.map(\.drawingViewAppState.isTrascriptButtonPressed)
                    .removeDuplicates()
                    .weakAssign(to: \.isTrascriptButtonPressed, on: self)
            }
        }

        func addTranscirptString(result: String) {
            container.services.drawingViewService.addTranscirptString(result: result)
        }
    }
}
