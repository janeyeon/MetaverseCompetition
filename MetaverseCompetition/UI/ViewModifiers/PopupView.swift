//
//  PopupView.swift
//  MetaverseCompetition
//
//  Created by HayeonKim on 2022/08/19.
//  Copyright © 2022 Apple. All rights reserved.
//

import Foundation
import SwiftUI

struct PopupView<Content: View>: View {
    let confirmAction: () -> Void
    let cancelAction: () -> Void

    let confirmText: String
    let cancelText: String
    let isCancelButtonExist: Bool
    let isXmarkExist: Bool
    let maxWidth: CGFloat
    var partyBackground: Bool = false

    let content: () -> Content


    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color.inside.backgroundColor)
                .background(.ultraThinMaterial)
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)

            if partyBackground {
                // 폭죽 효과
                PartyView()
            }

            HStack {
                Spacer()
                VStack {
                    content()

                    if isCancelButtonExist {
                        HStack {
                            cancelButton
                            confirmButton
                        }
                        .padding()

                    } else {
                        confirmButton
                            .padding()
                    }

                }
                .background(RoundedRectangle(cornerRadius: 20).foregroundColor(Color.inside.backgroundColor))
                .frame(maxWidth: maxWidth)
                Spacer()
            }
        }
    }

    var cancelButton: some View {
        FeatureButton {
            cancelAction()
        } label: {
            HStack {
                Spacer()
                Text(cancelText)
                    .font(.popupTextSize)
                    .foregroundColor(Color.white)
                Spacer()
            }
                .padding()
                .background(RoundedRectangle(cornerRadius: 20).foregroundColor(Color.inside.backgroundColor))
                .padding(.trailing, 5)
        }


    }

    var confirmButton: some View {
        FeatureButton {
            confirmAction()
        } label: {
            HStack {
                Spacer()
                Text(confirmText)
                    .font(.popupTextSize)
                    .foregroundColor(Color.black)
                Spacer()
            }
                .padding()
                .background(RoundedRectangle(cornerRadius: 20).foregroundColor(Color.inside.primaryColor))
        }


    }
}
