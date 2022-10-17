//
//  DrawingViewService.swift
//  MetaverseCompetition
//
//  Created by HayeonKim on 2022/08/18.
//  Copyright © 2022 Apple. All rights reserved.
//

import Foundation

protocol DrawingViewService {
    func setTranscirptString(result: String)
    func pressTrascriptionButton()
    func setisTranscriptionFinished(to value: Bool)
}


final class RealDrawingViewService: DrawingViewService {

    private let appState: Store<AppState>

    init(appState: Store<AppState>) {
      self.appState = appState
    }

    func setTranscirptString(result: String) {
        appState.value.drawingViewAppState.transcriptionResult += result
        appState.value.drawingViewAppState.transcriptionResult += " "
//        } else {
//            // nil이 들어갔으면 result 초기화
//            appState.value.drawingViewAppState.transcriptionResult = ""
//        }
    }

    /// transcription 시작
    func pressTrascriptionButton() {
        appState.value.drawingViewAppState.isTrascriptButtonPressed.toggle()
    }

    /// trascription이 끝나면 transcriptioinResult도 초기화 되어야함
    func setisTranscriptionFinished(to value: Bool) {
        appState.value.drawingViewAppState.isTranscriptionFinished = value
        if !value {
            appState.value.drawingViewAppState.transcriptionResult = ""
        }
    }
}
