//
//  HandleObjectTap.swift
//  MetaverseCompetition
//
//  Created by HayeonKim on 2022/08/06.
//  Copyright © 2022 Apple. All rights reserved.
//

import ARKit
import Vision
import RealityKit

extension ARViewController {

    func handleExistModel(position: SIMD3<Float>) {
        DispatchQueue.main.async {
            // 3. Classify Image - set latest prediction
            self.classifyImage(position: position)
        }
    }

    

    private func classifyImage(position: SIMD3<Float>) {
        // get image
        guard let pixbuff = arView.session.currentFrame?.capturedImage else {
            fatalError()
        }

        do {
            try imagePredictor.makePredictions(for: pixbuff) { [weak self] predictions in
                self?.imagePredictorHandler(predictions)
                let sphereAnchor = (self?.generateSphereAnchor(position: position))!
                let textAnchor = (self?.generateTextAnchor(position: position, text: self!.latestPrediction))!
                DispatchQueue.main.async {
                    self?.arView.scene.addAnchor(sphereAnchor)
                    self?.arView.scene.addAnchor(textAnchor)
                }
            }
        } catch {
            print("Vision was unable to make a prediction...\n\n\(error.localizedDescription)")
        }
    }

    /// Processing image classification
    private func imagePredictorHandler(_ predictions: [ImagePredictor.Prediction]?) {
        // update latestprediction label using prediction result
        guard let predictions = predictions else {
            updatePredictionLabel("Prediction Fail")
            return
        }

        let formattedPrediction = formatPredictions(predictions)

        let predictionString = formattedPrediction.first!
        updatePredictionLabel(predictionString)

    }

    /// Update ui-related variable in main thread
    private func updatePredictionLabel(_ message: String) {
        DispatchQueue.main.async {
            self.latestPrediction = message
        }
    }


    /// Convert prediction label to human readable strings
    private func formatPredictions(_ predictions: [ImagePredictor.Prediction]) -> [String] {
        let topPredictions: [String] = predictions.prefix(2).map { prediction in
            var name = prediction.classification
            // for classification more than one name
            if let firstComma = name.firstIndex(of: ",") {
                name = String(name.prefix(upTo: firstComma))
            }
            return "\(name)"
        }

        return topPredictions
    }
}
