//
//  ViewControllerRepresentable.swift
//  MetaverseCompetition
//
//  Created by HayeonKim on 2022/08/08.
//  Copyright © 2022 Apple. All rights reserved.
//

import ARKit
import SwiftUI
import RealityKit

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
        @Published var mainViewState: MainViewState
        @Published var selectedModelForStudy: SelectedWordModel?
        @Published var selectedModelForStudyOldValue: SelectedWordModel?
        @Published var selectedModelForTest: SelectedWordModel?
        @Published var selectedModelForTestOldValue: SelectedWordModel?
        @Published var wordModels: [WordModel]
        @Published var anchorEntities: [AnchorEntity]


        let container: DIContainer
        private var cancelBag = CancelBag()

        init(container: DIContainer) {
            self.container = container
            let appState = container.appState

            // addModel의 변수들
            _modelConfirmedForPlacement = .init(initialValue: appState.value.addModelAppState.modelConfirmedForPlacement)

            _addModelState = .init(initialValue: appState.value.addModelAppState.addModelState)

            // mainvView의 변수들
            _mainViewState = .init(initialValue: appState.value.mainViewAppState.mainViewState)

            _selectedModelForStudy = .init(initialValue: appState.value.mainViewAppState.selectedModelForStudy)

            _selectedModelForStudyOldValue = .init(initialValue: appState.value.mainViewAppState.selectedModelForStudyOldValue)

            _selectedModelForTest = .init(initialValue: appState.value.mainViewAppState.selectedModelForTest)

            _selectedModelForTestOldValue = .init(initialValue: appState.value.mainViewAppState.selectedModelForTestOldValue)

            _wordModels = .init(initialValue: appState.value.mainViewAppState.wordModels)

            _anchorEntities = .init(initialValue: appState.value.testAppState.anchorEntities)


            cancelBag.collect{

                appState.map(\.addModelAppState.modelConfirmedForPlacement)
                    .removeDuplicates()
                    .weakAssign(to: \.modelConfirmedForPlacement, on: self)

                appState.map(\.addModelAppState.addModelState)
                    .removeDuplicates()
                    .weakAssign(to: \.addModelState, on: self)

                appState.map(\.mainViewAppState.mainViewState)
                    .removeDuplicates()
                    .weakAssign(to: \.mainViewState, on: self)

                appState.map(\.mainViewAppState.selectedModelForStudy)
                    .removeDuplicates()
                    .weakAssign(to: \.selectedModelForStudy, on: self)

                appState.map(\.mainViewAppState.selectedModelForStudyOldValue)
                    .removeDuplicates()
                    .weakAssign(to: \.selectedModelForStudyOldValue, on: self)

                appState.map(\.mainViewAppState.selectedModelForTestOldValue)
                    .removeDuplicates()
                    .weakAssign(to: \.selectedModelForTestOldValue, on: self)

                appState.map(\.mainViewAppState.wordModels)
                    .removeDuplicates()
                    .weakAssign(to: \.wordModels, on: self)


                appState.map(\.testAppState.anchorEntities)
                    .removeDuplicates()
                    .weakAssign(to: \.anchorEntities, on: self)
            }
        }

        func setSelectedModelForStudy(selectedModel: SelectedWordModel) {
            container.services.mainViewService.setSelectedModelForStudy(selectedModel: selectedModel)
        }

        /// SelectedModelForStudyOldValue를 다시 nil값으로
        func setSelectedModelForStudyOldValue() {
            container.services.mainViewService.setSelectedModelForStudyOldValue()
        }

        func setSelectedModelForTestOldValue() {
            container.services.mainViewService.setSelectedModelForTestOldValue()
        }

        func setSelectedModelForTest(selectedModel: SelectedWordModel) {
            container.services.mainViewService.setSelectedModelForTest(selectedModel: selectedModel)
        }

        func addNewWordModel(word: String, rayCastResult: ARRaycastResult) {
            container.services.mainViewService.addNewWordModel(word: word, rayCastResult: rayCastResult)
        }

        func setAnchorEntities(anchorEntities: [AnchorEntity]) {
            container.services.testService.setAnchorEntities(anchorEntities: anchorEntities)
        }



    }
}
