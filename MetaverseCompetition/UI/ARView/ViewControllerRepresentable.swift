//
//  ViewControllerRepresentable.swift
//  MetaverseCompetition
//
//  Created by HayeonKim on 2022/08/08.
//  Copyright © 2022 Apple. All rights reserved.
//

import SwiftUI

struct MyARViewControllerRepresentable: UIViewControllerRepresentable {
    @ObservedObject var mainViewVM: MainView.ViewModel

    func makeUIViewController(context: Context) -> ARViewController {
        ARViewController(mainViewVM: mainViewVM)
    }

    func updateUIViewController(_ uiViewController: ARViewController, context: Context) {
    }
}
