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
    func pressTrascriptionButton()
}


final class RealDrawingViewService: DrawingViewService {

    private let appState: Store<AppState>

    init(appState: Store<AppState>) {
      self.appState = appState
    }

    func addTranscirptString(result: String) {
        appState.value.drawingViewAppState.transcriptionResult += result
        appState.value.drawingViewAppState.transcriptionResult += "\n"
    }

    /// transcription 시작
    func pressTrascriptionButton() {
        appState.value.drawingViewAppState.isTrascriptButtonPressed.toggle()
    }

}
