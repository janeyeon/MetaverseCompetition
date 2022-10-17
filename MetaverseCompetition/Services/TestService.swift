//
//  TestService.swift
//  MetaverseCompetition
//
//  Created by HayeonKim on 2022/08/20.
//  Copyright © 2022 Apple. All rights reserved.
//

import Foundation
import RealityKit

protocol TestService {
    func changeTestState(to state: TestState)

    func setAnchorEntities(anchorEntities: [AnchorEntity])
}


final class RealTestService: TestService {
    private let appState: Store<AppState>

    init(appState: Store<AppState>) {
      self.appState = appState
    }

    func changeTestState(to state: TestState) {
        appState.value.testAppState.testState = state
    }

    func setAnchorEntities(anchorEntities: [AnchorEntity]) {
        appState.value.testAppState.anchorEntities = anchorEntities
    }

}
