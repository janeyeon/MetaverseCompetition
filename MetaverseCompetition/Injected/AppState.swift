//
//  AppState.swift
//  MetaverseCompetition
//
//  Created by HayeonKim on 2022/08/18.
//  Copyright © 2022 Apple. All rights reserved.
//


/// 우리가 관찰해야하는 변수들을 담고 있는 State 의 모음
/// Publish를 하지 않고 직접 combine 으로 연결하여 관찰한다
struct AppState {
    var addModelAppState = AddModelAppState()
    var mainViewAppState = MainViewAppState()
    var drawingViewAppState = DrawingViewAppState()
    var studyAppState = StudyAppState()

    struct AddModelAppState: Equatable {
        var modelConfirmedForPlacement: String?
        var addModelState: AddModelState = .home
    }

    struct StudyAppState: Equatable {
        var studyState: StudyState = .home
    }

    struct MainViewAppState: Equatable {
        var mainViewState: MainViewState = .addModelState

        // 불러온 모든 모델들
        var wordModels: [WordModel] = []

        // study state에서 선택된 wordModel
        var selectedModelForStudy: SelectedWordModel?

        // text state에서 선택된 wordModel
        var selectedModelForTest: SelectedWordModel?
    }

    struct DrawingViewAppState: Equatable {
        var transcript: String = ""
        // view에 관련된 변수지만 DrawingViewControllerRepresentable에서도 필요하므로 넣어준다
        var isTrascriptButtonPressed: Bool = false


    }
}
