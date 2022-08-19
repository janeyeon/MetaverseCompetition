//
//  MainViewService.swift
//  MetaverseCompetition
//
//  Created by HayeonKim on 2022/08/18.
//  Copyright © 2022 Apple. All rights reserved.
//
import Foundation

protocol MainViewService {
    func changeMainViewState(to state: MainViewState)

    func setSelectedModelForStudy(selectedModel: SelectedWordModel)

    func setSelectedModelForTest(selectedModel: SelectedWordModel)

    func addNewWordModel(word: String)
}


final class RealMainViewService: MainViewService {
    private let appState: Store<AppState>

    init(appState: Store<AppState>) {
      self.appState = appState
    }

    func changeMainViewState(to state: MainViewState) {
        appState.value.mainViewAppState.mainViewState = state
    }

    func setSelectedModelForStudy(selectedModel: SelectedWordModel) {
        appState.value.mainViewAppState.selectedModelForStudy = selectedModel
    }

    func setSelectedModelForTest(selectedModel: SelectedWordModel) {
        appState.value.mainViewAppState.selectedModelForTest = selectedModel
    }

    func addNewWordModel(word: String) {
        appState.value.mainViewAppState.wordModels.append(WordModel(word: word))
        print("DEBUG: addModel: \(word)")
        print("DEBUG: total wordModels: \(appState.value.mainViewAppState.wordModels.map { $0.word } )")
    }

}
