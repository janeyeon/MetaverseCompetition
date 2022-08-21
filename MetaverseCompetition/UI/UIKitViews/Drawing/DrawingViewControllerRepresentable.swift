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
        @Published var transcriptionResult: String
        @Published var isTrascriptButtonPressed: Bool
        @Published var capturedImage: UIImage

        @Published var isTranscriptionFinished: Bool
        @Published var selectedModelForTest: SelectedWordModel?



        let container: DIContainer
        private var cancelBag = CancelBag()

        init(container: DIContainer) {
            self.container = container
            let appState = container.appState

            _transcriptionResult = .init(initialValue: appState.value.drawingViewAppState.transcriptionResult)
            _isTrascriptButtonPressed = .init(initialValue: appState.value.drawingViewAppState.isTrascriptButtonPressed)
            _capturedImage = .init(initialValue: appState.value.drawingViewAppState.capturedImage)

            _isTranscriptionFinished = .init(initialValue: appState.value.drawingViewAppState.isTranscriptionFinished)

            _selectedModelForTest = .init(initialValue: appState.value.mainViewAppState.selectedModelForTest)


            cancelBag.collect{

                appState.map(\.drawingViewAppState.transcriptionResult)
                    .removeDuplicates()
                    .weakAssign(to: \.transcriptionResult, on: self)

                appState.map(\.drawingViewAppState.isTrascriptButtonPressed)
                    .removeDuplicates()
                    .weakAssign(to: \.isTrascriptButtonPressed, on: self)

                appState.map(\.drawingViewAppState.capturedImage)
                    .removeDuplicates()
                    .weakAssign(to: \.capturedImage, on: self)

                appState.map(\.drawingViewAppState.isTranscriptionFinished)
                    .removeDuplicates()
                    .weakAssign(to: \.isTranscriptionFinished, on: self)

                appState.map(\.mainViewAppState.selectedModelForTest)
                    .removeDuplicates()
                    .weakAssign(to: \.selectedModelForTest, on: self)


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

        func judgingResult() {
            // 여기에서 두개의 결과를 채점한다
            let answer = selectedModelForTest!.word
            let myAnswer = transcriptionResult

            // 둘다 띄어쓰기를 없애준다
            var noSpaceAnswer = answer.removeWhitespace()
            var noSpaceMyAnswer = myAnswer.removeWhitespace()

            // 둘다 대문자를 없애준다
            noSpaceAnswer = noSpaceAnswer.lowercased()
            noSpaceMyAnswer = noSpaceMyAnswer.lowercased()

            // 만약 맞으면 selectedModelForTest의 isRight의 값을 true 로 바꾸어준다
            if noSpaceAnswer == noSpaceMyAnswer {
                container.services.mainViewService.isMemorizedFinished(word: answer)
            }

            // MARK: - count값을 1씩 증가
            container.services.mainViewService.increaseCount(word: selectedModelForTest!.word)


        }

    }
}
