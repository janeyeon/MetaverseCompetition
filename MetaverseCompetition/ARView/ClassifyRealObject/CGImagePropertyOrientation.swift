//
//  CGImageOrientation+UIImageOrientation.swift
//  CoreML+ARKit+Reformatting
//
//  Created by HayeonKim on 2022/07/28.
//

import UIKit
import ImageIO

extension CGImagePropertyOrientation {
    /// image orientation -> Core Graphic image property orientation

    init(_ orientation: UIImage.Orientation) {
        switch orientation {
            case .up: self = .up
            case .down: self = .down
            case .left: self = .left
            case .right: self = .right
            case .upMirrored: self = .upMirrored
            case .downMirrored: self = .downMirrored
            case .leftMirrored: self = .leftMirrored
            case .rightMirrored: self = .rightMirrored
            @unknown default: self = .up
        }
    }
}
