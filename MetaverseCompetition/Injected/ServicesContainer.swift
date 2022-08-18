//
//  ServicesContainer.swift
//  MetaverseCompetition
//
//  Created by HayeonKim on 2022/08/18.
//  Copyright © 2022 Apple. All rights reserved.
//

extension DIContainer {
    /// 각 view 에서 사용되는 service 들을 모은 총 집합
    struct Services {
        let addModelService: AddModelService
        let mainViewService: MainViewService
        let drawingViewService: DrawingViewService
    }
}
