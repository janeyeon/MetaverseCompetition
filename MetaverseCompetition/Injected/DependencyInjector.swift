//
//  DependencyInjector.swift
//  MetaverseCompetition
//
//  Created by HayeonKim on 2022/08/18.
//  Copyright © 2022 Apple. All rights reserved.
//

import Combine


// MARK: - DIContainer
/// 우리가 자주 관찰해야 하는 여러 서비스들과(services), appState가 들어있는 Container
/// Dependency injection 으로 주입됨

struct DIContainer {
    let appState: Store<AppState>
    let services: Services

    /// 이 값은 밖에서 선언된 (bootstrap()) 값들을 받아서 담아옴
    init(appState: Store<AppState>, services: DIContainer.Services) {
        self.appState = appState
        self.services = services
    }

    init(appState: AppState, services: DIContainer.Services) {
        self.init(appState: Store(appState), services: services)
    }
}


