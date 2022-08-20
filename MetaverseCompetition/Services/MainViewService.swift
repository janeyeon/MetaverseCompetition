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

    func setSelectedModelForStudy(selectedModel: SelectedWordModel?)

    func setSelectedModelForStudyOldValue()

    func setSelectedModelForTest(selectedModel: SelectedWordModel?)

    func addNewWordModel(word: String)

    func checkWorldModelIsStudyFinished(word: String)
}


final class RealMainViewService: MainViewService {
    private let appState: Store<AppState>

    init(appState: Store<AppState>) {
      self.appState = appState
    }

    func changeMainViewState(to state: MainViewState) {
        appState.value.mainViewAppState.mainViewState = state
    }

    func setSelectedModelForStudy(selectedModel: SelectedWordModel?) {
        // nil이전의 값을 넣어준다
        if selectedModel == nil {
            appState.value.mainViewAppState.selectedModelForStudyOldValue = appState.value.mainViewAppState.selectedModelForStudy
        }
        appState.value.mainViewAppState.selectedModelForStudy = selectedModel
    }

    func setSelectedModelForStudyOldValue() {
        // 다시 oldValue변수를 nil로 만들어준다
        appState.value.mainViewAppState.selectedModelForStudyOldValue = nil
    }

    func setSelectedModelForTest(selectedModel: SelectedWordModel?) {
        appState.value.mainViewAppState.selectedModelForTest = selectedModel
    }

    func addNewWordModel(word: String) {
        appState.value.mainViewAppState.wordModels.append(WordModel(word: word))
        print("DEBUG: addModel: \(word)")
        print("DEBUG: total wordModels: \(appState.value.mainViewAppState.wordModels.map { $0.word } )")
    }

    /// wordmodels에 있는 이름을 가진 model의 isStudyFinished를 true로 바꿔준다
    func checkWorldModelIsStudyFinished(word: String) {

        for index in  0..<appState.value.mainViewAppState.wordModels.count {

            if appState.value.mainViewAppState.wordModels[index].word == word {
                appState.value.mainViewAppState.wordModels[index].isStudyFinished = true
            }

        }


    }

}
