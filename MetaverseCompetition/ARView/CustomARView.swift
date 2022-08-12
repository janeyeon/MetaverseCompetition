//
//  CustomARView.swift
//  MetaverseCompetition
//
//  Created by HayeonKim on 2022/08/09.
//  Copyright © 2022 Apple. All rights reserved.
//

import ARKit
import FocusEntity
import RealityKit
import UIKit

class CustomARView: ARView {
    var focusSquare: FocusEntity!

    required init(frame frameRect: CGRect) {
        super.init(frame: frameRect)
        setUpARView()
    }

    @objc required dynamic init?(coder decoder: NSCoder) {
        fatalError("init(coder: ) has not been implemented")
    }

    private func setUpARView() {
        // set up configurations
        let configuration = ARWorldTrackingConfiguration()
        configuration.sceneReconstruction = .mesh
        configuration.environmentTexturing = .automatic
        configuration.planeDetection = [.horizontal]

        self.session.run(configuration)
    }

    func setFocusSquare(isCreateNeeded: Bool) {
        if isCreateNeeded {
            focusSquare = FocusEntity(on: self, style: .classic(color: .yellow))
        } else {
            focusSquare = nil
        }
    }

}


extension CustomARView: FocusEntityDelegate {
    func toTrackingState() {
        print("tracking")
    }

    func toInitializingState() {
        print("initializing")
    }
}
