//
//  WordModel.swift
//  MetaverseCompetition
//
//  Created by HayeonKim on 2022/08/17.
//  Copyright © 2022 Apple. All rights reserved.
//
import ARKit
import Foundation
import UIKit

struct WordModel: Identifiable, Equatable, Hashable {
    var word: String
    var id = UUID().uuidString // 꼭 필요한가 다시 확인 

    // 학습 모드에서 필요한 변수들
    // 학습이 끝난 단어인가?
    var isStudyFinished: Bool = false

    // test 모드에서 필요한 변수들
    // 다 외웠는가?
    var isMemorizedFinished: Bool = false
    // 이 단어를 맞추기까지 몇개나 걸렸는가
    var count: Int = 0

    // position 넣을까 말까
    var rayTracingResult: ARRaycastResult

    init(word: String, rayTracingResult: ARRaycastResult) {
        self.word = word
        self.rayTracingResult = rayTracingResult
    }

}


struct SelectedWordModel: Equatable {
    var word: String
    var rayCastResult: ARRaycastResult
//    var position: SIMD3<Float>
    var isRight: Bool = false

    init(word: String, rayCastResult: ARRaycastResult) {
        self.word = word
        self.rayCastResult = rayCastResult
    }
}

/// classification을 위해 캡쳐한 이미지
struct SelectedCapturedImage: Equatable {
    var capturedImage: UIImage
    var position: SIMD3<Float>
}
