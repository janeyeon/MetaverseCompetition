//
//  WordModel.swift
//  MetaverseCompetition
//
//  Created by HayeonKim on 2022/08/17.
//  Copyright © 2022 Apple. All rights reserved.
//

import Foundation

struct WordModel: Identifiable {
    var word: String
    var id = UUID().uuidString

    // 학습 모드에서 필요한 변수들
    // 학습이 끝난 단어인가?
    var isStudyFinished: Bool = false

    // test 모드에서 필요한 변수들
    // 다 외웠는가?
    var isMemorized: Bool = false
    // 이 단어를 맞추기까지 몇개나 걸렸는가
    var count: Int = 0

    init(word: String) {
        self.word = word
    }

}
