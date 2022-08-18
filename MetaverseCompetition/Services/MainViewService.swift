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
}


final class RealMainViewService: MainViewService {
    private let appState: Store<AppState>

    init(appState: Store<AppState>) {
      self.appState = appState
    }

    func changeMainViewState(to state: MainViewState) {
        appState.value.mainViewAppState.mainViewState = state
    }
}
