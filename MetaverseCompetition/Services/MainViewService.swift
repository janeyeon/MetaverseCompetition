//
//  MainViewService.swift
//  MetaverseCompetition
//
//  Created by HayeonKim on 2022/08/18.
//  Copyright © 2022 Apple. All rights reserved.
//
import ARKit
import Foundation

protocol MainViewService {
    func changeMainViewState(to state: MainViewState)

    // ------- for add model state view --------

    func addNewWordModel(word: String, rayCastResult: ARRaycastResult)

    // ------- for study state view --------

    func setSelectedModelForStudy(selectedModel: SelectedWordModel?)

    func setSelectedModelForStudyOldValue()

    func checkWordModelIsStudyFinished(word: String)

    // ------- for test state view --------

    func setSelectedModelForTest(selectedModel: SelectedWordModel?)

    func setSelectedModelForTestOldValue()

    func isMemorizedFinished(word: String)

    func increaseCount(word: String)

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

        // nil이전의 값을 넣어준다
        if selectedModel == nil {
            appState.value.mainViewAppState.selectedModelForTestOldValue = appState.value.mainViewAppState.selectedModelForTest
        }

        appState.value.mainViewAppState.selectedModelForTest = selectedModel
    }

    func setSelectedModelForTestOldValue() {
        // 다시 oldValue변수를 nil로 만들어준다
        appState.value.mainViewAppState.selectedModelForTestOldValue = nil
    }

    func addNewWordModel(word: String, rayCastResult: ARRaycastResult) {
        appState.value.mainViewAppState.wordModels.append(WordModel(word: word, rayTracingResult: rayCastResult))
        print("DEBUG: addModel: \(word)")
        print("DEBUG: total wordModels: \(appState.value.mainViewAppState.wordModels.map { $0.word } )")
    }

    /// wordmodels에 있는 이름을 가진 model의 isStudyFinished를 true로 바꿔준다
    func checkWordModelIsStudyFinished(word: String) {

        for index in  0..<appState.value.mainViewAppState.wordModels.count {

            if appState.value.mainViewAppState.wordModels[index].word == word {
                appState.value.mainViewAppState.wordModels[index].isStudyFinished = true
            }

        }
    }

    /// 단어에 해당하는 count를 하나씩 늘린다
    func increaseCount(word: String) {
        for index in 0..<appState.value.mainViewAppState.wordModels.count {
            if word == appState.value.mainViewAppState.wordModels[index].word {
                appState.value.mainViewAppState.wordModels[index].count += 1
            }
        }
    }


    func isMemorizedFinished(word: String) {
        // 선택한 모델의 isRight을 바꿔줌
        appState.value.mainViewAppState.selectedModelForTest?.isRight = true

        // wordModels에서도 isMemorizedFinished를 true로 바꿔줌
        for index in  0..<appState.value.mainViewAppState.wordModels.count {

            if appState.value.mainViewAppState.wordModels[index].word == word {
                appState.value.mainViewAppState.wordModels[index].isMemorizedFinished = true
            }

        }
    }

}
