//
//  AddModelService.swift
//  MetaverseCompetition
//
//  Created by HayeonKim on 2022/08/18.
//  Copyright © 2022 Apple. All rights reserved.
//

import Foundation

protocol AddModelService {
    func changeAddModelState(to state: AddModelState)
    func modelPlacementConfirmButton(selectedModel: String)
    func modelPlacementCancelButton()
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
}
