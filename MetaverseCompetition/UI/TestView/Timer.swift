//
//  Timer.swift
//  MetaverseCompetition
//
//  Created by HayeonKim on 2022/08/27.
//  Copyright © 2022 Apple. All rights reserved.
//

import Foundation

class TestTimer {
    let startTime: CFAbsoluteTime
    var endTime: CFAbsoluteTime? = nil
    var timer: Timer? = nil
    var duration: Float = 0.0

    init() {
        self.startTime = CFAbsoluteTimeGetCurrent()
        self.timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            self.duration += 0.1
        }
    }

    func finishTest() -> CFAbsoluteTime {
        endTime = CFAbsoluteTimeGetCurrent()
        return CFAbsoluteTimeGetCurrent() - startTime
    }



}
