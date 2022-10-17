//
//  LikeButtonEffect.swift
//  MetaverseCompetition
//
//  Created by HayeonKim on 2022/08/21.
//  Copyright © 2022 Apple. All rights reserved.
//

import Foundation
import SwiftUI
import LottieUI


struct PartyView: View {
    let state = LUStateData(type: .loadedFrom(URL(string: "https://assets8.lottiefiles.com/packages/lf20_ky24lkyk.json")!), speed: 1.0, loopMode: .playOnce)


    var body: some View {
        ZStack {
            ForEach(0...1, id: \.self) { index in
                LottieView(state: state)
                    .scaleEffect(CGFloat.random(in: 0.7...1.0))
            }
        }
    }
}


struct HeartView: View {
    let state = LUStateData(type: .loadedFrom(URL(string: "https://assets9.lottiefiles.com/packages/lf20_b6cz19m8.json")!), speed: 2.0, loopMode: .playOnce)

    var body: some View {
        ZStack {
            ForEach(0...1, id: \.self) { index in
                LottieView(state: state)
            }
        }
    }

}

struct SelectFirework: View {
    let state = LUStateData(type: .loadedFrom(URL(string: "https://assets10.lottiefiles.com/packages/lf20_n9juuqmm.json")!), speed: 2.0, loopMode: .playOnce)

    var body: some View {
        ZStack {
            ForEach(0...1, id: \.self) { index in
                LottieView(state: state)
            }
        }
    }
}

