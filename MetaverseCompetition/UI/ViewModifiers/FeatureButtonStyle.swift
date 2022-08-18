//
//  NormalButtonStyle.swift
//  MetaverseCompetition
//
//  Created by HayeonKim on 2022/08/18.
//  Copyright © 2022 Apple. All rights reserved.
//

import Foundation
import SwiftUI


struct FeatureButton<Content: View>: View {
    let action: () -> Void
    let label: () -> Content

    init(action: @escaping () -> Void, @ViewBuilder label: @escaping () -> Content) {
      self.action = action
      self.label = label
    }

    var body: some View {
      Button(action: action, label: label)
        .buttonStyle(FeatureButtonStyle())
    }
}

struct FeatureButtonStyle: ButtonStyle {
  func makeBody(configuration: Self.Configuration) -> some View {
    configuration.label
      .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
      .opacity(configuration.isPressed ? 0.95: 1.0)
  }
}

struct FeatureButtonView: View {
    var buttonLabel: String
    var buttonIcon: Image

    var body: some View {
        ZStack {
            // background
            Rectangle()
                .frame(width: 115, height: 133, alignment: .center)
                .foregroundColor(Color.gray)
            VStack {
                // icon
                ZStack {
                    Circle()
                        .frame(width: 74, height: 74)
                        .foregroundColor(Color.black)
                    // buttonIcon
                    buttonIcon
                        .resizable()
                        .scaledToFit()
                        .frame(width: 68, height: 68)
                }
                .frame(alignment: .center)

                // text
                Text(buttonLabel)
                    .font(.defaultTextSize)
            }
        }
    }
}


struct TemporalButtonView: View {
    var label: String
    var action: () -> Void
    var body: some View {
        Button {
            action()
        } label: {
            Text(label)
                .foregroundColor(Color.white)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 10)    .foregroundColor(Color.black))
        .opacity(0.7)
    }
}