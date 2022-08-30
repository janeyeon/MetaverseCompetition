//
//  AppState.swift
//  MetaverseCompetition
//
//  Created by HayeonKim on 2022/08/18.
//  Copyright © 2022 Apple. All rights reserved.
//

import UIKit
import RealityKit


/// 우리가 관찰해야하는 변수들을 담고 있는 State 의 모음
/// Publish를 하지 않고 직접 combine 으로 연결하여 관찰한다
struct AppState {
    var addModelAppState = AddModelAppState()
    var mainViewAppState = MainViewAppState()
    var drawingViewAppState = DrawingViewAppState()
    var studyAppState = StudyAppState()
    var testAppState = TestAppState()

    
    struct AddModelAppState: Equatable {
        var modelConfirmedForPlacement: String?
        // 삭제를 위해 선택된 wordModel
        var modelConfirmentForCancel: String?
        // 선택만 하는 wordModel
        var selectedModelForCancel: String?
        var addModelState: AddModelState = .home
        var capturedImage: SelectedCapturedImage?
        var isClassificationRight: Bool = false
    }

    struct StudyAppState: Equatable {
        var studyState: StudyState = .home
    }

    struct TestAppState: Equatable {
        var testState: TestState = .home

        var anchorEntities: [AnchorEntity] = []
    }

    struct MainViewAppState: Equatable {
        var mainViewState: MainViewState = .addModelState

        // 불러온 모든 모델들
        var wordModels: [WordModel] = []

        // study state에서 선택된 wordModel
        var selectedModelForStudy: SelectedWordModel?

        // selectedModelForStudy를 다시 nil로 바꿀때 이전의 값을 넣어주는 함수
        var selectedModelForStudyOldValue: SelectedWordModel?

        var selectedModelForTestOldValue: SelectedWordModel?

        // text state에서 선택된 wordModel
        var selectedModelForTest: SelectedWordModel?


    }

    struct DrawingViewAppState: Equatable {
        var transcriptionResult: String = ""
        // view에 관련된 변수지만 DrawingViewControllerRepresentable에서도 필요하므로 넣어준다
        var isTrascriptButtonPressed: Bool = false
        var isTranscriptionFinished: Bool = false

        var capturedImage: UIImage = UIImage()
    }
}
