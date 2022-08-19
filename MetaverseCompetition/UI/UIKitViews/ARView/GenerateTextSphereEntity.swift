//
//  GenerateTextSphereEntity.swift
//  MetaverseCompetition
//
//  Created by HayeonKim on 2022/08/19.
//  Copyright © 2022 Apple. All rights reserved.
//

import Foundation

protocol GenerateTextSphereEntity {
    func someFunc()
}


class RealGenerateTextSphereEntity : GenerateTextSphereEntity {
    func someFunc() {

    }
}


class MainClass {
    let generateTextSphereEntity = RealGenerateTextSphereEntity()
}
