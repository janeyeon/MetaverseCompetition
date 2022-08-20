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
        @Published var capturedImage: UIImage
        @Published var isTranscriptionFinished: Bool


        let container: DIContainer
        private var cancelBag = CancelBag()

        init(container: DIContainer) {
            self.container = container
            let appState = container.appState

            _transcript = .init(initialValue: appState.value.drawingViewAppState.transcriptionResult)
            _isTrascriptButtonPressed = .init(initialValue: appState.value.drawingViewAppState.isTrascriptButtonPressed)
            _capturedImage = .init(initialValue: appState.value.drawingViewAppState.capturedImage)

            _isTranscriptionFinished = .init(initialValue: appState.value.drawingViewAppState.isTranscriptionFinished)

            cancelBag.collect{
                $transcript.sink{
                    appState[\.drawingViewAppState.transcriptionResult] = $0
                }

                $isTrascriptButtonPressed.sink{
                    appState[\.drawingViewAppState.isTrascriptButtonPressed] = $0
                }

                $capturedImage.sink{
                    appState[\.drawingViewAppState.capturedImage] = $0
                }

                $isTranscriptionFinished.sink{
                    appState[\.drawingViewAppState.isTranscriptionFinished] = $0
                }



                appState.map(\.drawingViewAppState.transcriptionResult)
                    .removeDuplicates()
                    .weakAssign(to: \.transcript, on: self)

                appState.map(\.drawingViewAppState.isTrascriptButtonPressed)
                    .removeDuplicates()
                    .weakAssign(to: \.isTrascriptButtonPressed, on: self)

                appState.map(\.drawingViewAppState.capturedImage)
                    .removeDuplicates()
                    .weakAssign(to: \.capturedImage, on: self)

                appState.map(\.drawingViewAppState.isTranscriptionFinished)
                    .removeDuplicates()
                    .weakAssign(to: \.isTranscriptionFinished, on: self)


            }
        }

        func setTranscirptString(result: String) {
            container.services.drawingViewService.setTranscirptString(result: result)
        }

        func setCaptureImage(image: UIImage) {
            capturedImage = image
        }

        func changeisTranscriptionFinished() {
            container.services.drawingViewService.setisTranscriptionFinished(to: true)
        }

    }
}
