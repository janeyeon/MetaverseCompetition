//
//  DrawingViewService.swift
//  MetaverseCompetition
//
//  Created by HayeonKim on 2022/08/18.
//  Copyright © 2022 Apple. All rights reserved.
//

import Foundation

protocol DrawingViewService {
    func addTranscirptString(result: String)
}


final class RealDrawingViewService: DrawingViewService {

    private let appState: Store<AppState>

    init(appState: Store<AppState>) {
      self.appState = appState
    }

    func addTranscirptString(result: String) {
        appState.value.drawingViewAppState.transcript += result
        appState.value.drawingViewAppState.transcript += "\n"

    }

}
