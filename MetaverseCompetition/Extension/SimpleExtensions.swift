/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Helper functions and convenience extensions for system types.
*/

import ARKit
import RealityKit
import UIKit
import Vision

extension simd_float4x4 {
    var position: SIMD3<Float> {
        return SIMD3<Float>(columns.3.x, columns.3.y, columns.3.z)
    }
}


extension VNRecognizedObjectObservation {
    var label: String? {
        return self.labels.first?.identifier
    }
}

extension CGRect {
    func toString(digit: Int) -> String {
        let xStr = String(format: "%.\(digit)f", origin.x)
        let yStr = String(format: "%.\(digit)f", origin.y)
        let wStr = String(format: "%.\(digit)f", width)
        let hStr = String(format: "%.\(digit)f", height)
        return "(\(xStr), \(yStr), \(wStr), \(hStr))"
    }
}




extension TimeInterval{
        func stringFromTimeInterval() -> String {

            let time = -NSInteger(self)

            let ms = -Int((self.truncatingRemainder(dividingBy: 1)) * 10)
            let seconds = time % 60
            let minutes = (time / 60) % 60

            return String(format: "%02d:%02d:%01d",minutes,seconds,ms)

        }
    }
