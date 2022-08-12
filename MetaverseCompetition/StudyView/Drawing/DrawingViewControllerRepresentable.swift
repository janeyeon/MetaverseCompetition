//
//  DrawingViewControllerRepresentable.swift
//  MetaverseCompetition
//
//  Created by HayeonKim on 2022/08/10.
//  Copyright © 2022 Apple. All rights reserved.
//

import SwiftUI
import PencilKit
import UIKit

struct DrawingViewControllerRepresentable: UIViewControllerRepresentable {

    @ObservedObject var mainViewVM: MainView.ViewModel

    func makeUIViewController(context: Context) -> DrawingViewController {
        DrawingViewController(mainViewVM: mainViewVM)
    }

    func updateUIViewController(_ uiViewController: DrawingViewController, context: Context) {
    }
}
