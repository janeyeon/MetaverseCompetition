//
//  VNClassificationObservation+confidenceString.swift
//  CoreML+ARKit+Reformatting
//
//  Created by HayeonKim on 2022/07/28.
//

import Vision

extension VNClassificationObservation {
    var confidencePercentageString: String {
        let percentage = confidence * 100

        switch percentage {
        case 100.0...:
            return "100%"
        case 10.0..<100.0:
            return String(format: "%2.1f", percentage)
        case 1.0..<10.0:
            return String(format: "%2.1f", percentage)
        case ..<1.0:
            return String(format: "%1.2f", percentage)
        default:
            return String(format: "%2.1f", percentage)
        }
    }
}
