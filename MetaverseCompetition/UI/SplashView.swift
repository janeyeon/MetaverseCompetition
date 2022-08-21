//
//  SplashView.swift
//  MetaverseCompetition
//
//  Created by HayeonKim on 2022/08/21.
//  Copyright © 2022 Apple. All rights reserved.
//

import Foundation
import SwiftUI
import LottieUI

public struct SplashView: View {

    let state1 = LUStateData(type: .loadedFrom(URL(string: "https://assets5.lottiefiles.com/packages/lf20_rjgikbck.json")!), speed: 1.0, loopMode: .loop)
    let state2 = LUStateData(type: .loadedFrom(URL(string: "https://assets10.lottiefiles.com/packages/lf20_wdqlqkhq.json")!), speed: 1.1, loopMode: .loop)
    let state3 = LUStateData(type: .loadedFrom(URL(string: "https://assets2.lottiefiles.com/packages/lf20_agu7b2gf.json")!), speed: 0.95, loopMode: .autoReverse)

    public init() {}
    public var body: some View {
        ZStack {

            ZStack {
                ForEach(0...1, id: \.self) { index in
                    LottieView(state: state1)
                        .blendMode(.screen)
                        .rotationEffect(Angle(degrees: CGFloat.random(in: -360...360)))
                        .scaleEffect(CGFloat.random(in: 0.7...1.0))
                }
            }

            // Logo Image
            Image("vocAR")
                .resizable()
                .scaledToFit()
                .frame(width: 400)
        }
    }
}


