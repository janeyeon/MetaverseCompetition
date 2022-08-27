//
//  State.swift
//  MetaverseCompetition
//
//  Created by HayeonKim on 2022/08/08.
//  Copyright © 2022 Apple. All rights reserved.
//

import Foundation

enum MainViewState: Equatable {
    case addModelState, practiceState, testState
}

enum AddModelState: Equatable {
    case home, handleExistingModel, handleImportedModel
}

enum StudyState: Equatable {
    case home, previousState
}

enum TestState: Equatable {
    case home, previousState, finish
}


enum TextModelState: Equatable {
    case add // 그냥 import model을 하거나  classification진행할때
    case questionMark // ?로 바꿀떄 -> 빨간색
    case finished // 학습, 외우기가 완료되었을 때 -> 파란색
    case selected // 선택되었을때 -> custom mateiral
    case justReturn // 선택 되고 다시 돌아올때
}

/// 다시 초기화 시킬때 사용하는  state
enum ResetState: Equatable {
    case none // 아무것도 선택하지 않았을 때
    case testViewReset // 가장 마지막 팝업에서 전체 초기화 진행할때
//    case studyViewReset // 
}
