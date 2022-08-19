//
//  StudyService.swift
//  MetaverseCompetition
//
//  Created by HayeonKim on 2022/08/19.
//  Copyright © 2022 Apple. All rights reserved.
//

import Foundation

protocol StudyService {
    func changeStudyState(to state: StudyState)
}


final class RealStudyService: StudyService {
    private let appState: Store<AppState>

    init(appState: Store<AppState>) {
      self.appState = appState
    }

    func changeStudyState(to state: StudyState) {
        appState.value.studyAppState.studyState = state
    }
}
