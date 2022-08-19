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
          .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
      .opacity(configuration.isPressed ? 0.95: 1.0)
  }
}

struct FeatureButtonView: View {
    var buttonLabel: String
    var buttonIcon: Image
    var isSelected: Bool

    var body: some View {
            VStack {
                // icon
                ZStack {
                    Circle()
                        .frame(width: 74, height: 74)
                        .foregroundColor(isSelected ? Color.inside.activeColor2  : Color.inside.backgroundColor)
                    // buttonIcon
                    buttonIcon
                        .resizable()
                        .scaledToFit()
                        .frame(width: 44, height: 44)
                        .foregroundColor( isSelected ? Color.white : Color.inside.primaryColor)
                }
                .frame(alignment: .center)

                // text
                Text(buttonLabel)
                    .font(.defaultTextSize)
                    .foregroundColor(isSelected ? Color.inside.secondaryTextColor : Color.white)
            }
            .background(
                RoundedRectangle(cornerRadius: 10 )
                    .foregroundColor(isSelected ? Color.inside.activeColor1 : Color.inside.backgroundColor)
                    .frame(width: 100, height: 133)
            )
            .frame(width: 100, height: 133)
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
        .background(RoundedRectangle(cornerRadius: 10).foregroundColor(Color.inside.darkerBackgroundColor))
        .opacity(0.7)
    }
}


struct ChangeStateButtonView: View {
    var buttonLabel: String
    var buttonIcon: Image

    var body: some View {
            HStack {
                // text
                Text(buttonLabel)
                    .font(.system(size: 30, weight: .heavy))
                    .foregroundColor(Color.black)

                // icon
                ZStack {
                    Circle()
                        .frame(width: 44, height: 44)
                        .foregroundColor(Color.inside.activeColor2)
                    // buttonIcon
                    buttonIcon
                        .resizable()
                        .scaledToFit()
                        .frame(width: 25, height: 25)
                        .foregroundColor(Color.white)
                }
                .frame(alignment: .center)
                .padding(.leading)
            }
            .padding()
            .padding(.horizontal)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .foregroundColor(Color.inside.activeColor1)
            )
        }

}
