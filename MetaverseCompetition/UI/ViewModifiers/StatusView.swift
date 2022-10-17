//
//  StatusView.swift
//  MetaverseCompetition
//
//  Created by HayeonKim on 2022/08/19.
//  Copyright © 2022 Apple. All rights reserved.
//

import Foundation
import SwiftUI

struct StatusView<Content: View>: View {
    let content: () -> Content

    var body: some View {
        VStack {
            HStack {
                ZStack {
                    LinearGradient(colors: [Color.inside.darkerBackgroundColor, Color.clear], startPoint: .leading, endPoint: .trailing)
                    VStack(alignment: .leading) {
                        Spacer()
                        content()
                        Spacer()
                    }
                }
                .frame(maxWidth: 400 ,maxHeight: 200)
                .padding(.leading, -30)
                Spacer()
            }
            Spacer()
        }
    }
}
