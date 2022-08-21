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
}



final class RealAddModelService: AddModelService {
    private let appState: Store<AppState>

    init(appState: Store<AppState>) {
      self.appState = appState
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
