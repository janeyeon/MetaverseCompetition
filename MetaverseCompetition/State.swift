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
    case none, handleExistingModel, handleImportedModel
}
