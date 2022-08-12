//
//  RecognizedTextDataSource.swift
//  MetaverseCompetition
//
//  Created by HayeonKim on 2022/08/11.
//  Copyright © 2022 Apple. All rights reserved.
//

import UIKit
import Vision

protocol RecognizedTextDataSource: AnyObject {
    func addRecognizedText(recognizedText: [VNRecognizedTextObservation])
    func processImage(image: UIImage)
    func takeCapture() -> UIImage
}
