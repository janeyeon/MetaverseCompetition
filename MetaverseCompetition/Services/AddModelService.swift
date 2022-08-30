//
//  AddModelService.swift
//  MetaverseCompetition
//
//  Created by HayeonKim on 2022/08/18.
//  Copyright © 2022 Apple. All rights reserved.
//

import Foundation
import UIKit

protocol AddModelService {
    func changeAddModelState(to state: AddModelState)
    func modelPlacementConfirmButton(selectedModel: String)
    func modelPlacementCancelButton()
    func setCapturedImage(capturedImage: SelectedCapturedImage?)
    func setisClassificationRight(to value: Bool)
    func setModelConfirmentForCancel()
    func finishedRemoveModel()
    func setSelectedModelForCancel(selectedModel: String?)
}



final class RealAddModelService: AddModelService {
    private let appState: Store<AppState>

    init(appState: Store<AppState>) {
      self.appState = appState
    }

    /// 모델 삭제하기가 다 끝나고 해줘야할 일들을 명시
    func finishedRemoveModel() {
        // modelConfirmentForCancel를 없애준다
        appState.value.addModelAppState.modelConfirmentForCancel = nil
    }

    func setModelConfirmentForCancel() {
        // 먼저 modelConfirmentForCancel를 설정해준다음
        appState.value.addModelAppState.modelConfirmentForCancel = appState.value.addModelAppState.selectedModelForCancel

        // 얘를 초기화 해준다
        appState.value.addModelAppState.selectedModelForCancel = nil

        print("DEBUG: - modelConfirmentForCancel \(appState.value.addModelAppState.modelConfirmentForCancel) ")
    }

    func setSelectedModelForCancel(selectedModel: String?) {
        appState.value.addModelAppState.selectedModelForCancel = selectedModel
    }


    func changeAddModelState(to state: AddModelState) {
        appState.value.addModelAppState.addModelState = state
    }

    func modelPlacementCancelButton() {
        appState.value.addModelAppState.modelConfirmedForPlacement = nil
    }

    func modelPlacementConfirmButton(selectedModel: String) {
        appState.value.addModelAppState.modelConfirmedForPlacement = selectedModel
    }

    func setCapturedImage(capturedImage: SelectedCapturedImage?) {
        appState.value.addModelAppState.capturedImage = capturedImage
    }

    func setisClassificationRight(to value: Bool) {
        appState.value.addModelAppState.isClassificationRight = value
    }
}
