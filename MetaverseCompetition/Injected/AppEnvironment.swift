//
//  AppEnvironment.swift
//  MetaverseCompetition
//
//  Created by HayeonKim on 2022/08/18.
//  Copyright © 2022 Apple. All rights reserved.
//

import Foundation

struct AppEnvironment {
    let container: DIContainer

    /// 가장 처음 모든 repo등의 변수들을 생성하는 함수
    /// 맨 처음 단 한번만 불리며, 여기서 생성된 변수들은 더이상 init되지 않는다
    /// 사실상 앱이 켜있을 때 항상 켜있어야 하는 변수들이 선언되는 구간
    static func bootstrap() -> AppEnvironment {
      let appState = Store<AppState>(AppState())
      let services = configuredServices(appState: appState)
      let diContainer = DIContainer(appState: appState, services: services)
      return AppEnvironment(container: diContainer)
    }

    ///  services를 처음으로 생성하는 장소
    private static func configuredServices(appState: Store<AppState>) -> DIContainer.Services {
        // 여기에서 각 service를 생성
        // Services의 init을 return한다
        return .init()
    }
}


