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
        self.classifyImage(position: position)
    }

    private func cropImage(uiImage: UIImage) -> UIImage {

        let h = UIScreen.main.bounds.size.height / 3 * UIScreen.main.scale
        let w = UIScreen.main.bounds.size.width / 3 * UIScreen.main.scale
        let cgImage = uiImage.cgImage

        let croppedCGImage = cgImage?.cropping(to: CGRect(x: w, y: h, width: w, height: h))
        return UIImage(cgImage: croppedCGImage!)
    }


    private func classifyImage(position: SIMD3<Float>) {


        arView.snapshot(saveToHDR: true) { image in


            let resizedImage = self.cropImage(uiImage: image!)

            DispatchQueue.main.async {
                self.mainViewVM.caputredImage = resizedImage
            }
            do {
                try self.imagePredictor.makePredictions(for: resizedImage) { [weak self] predictions in
                    self?.imagePredictorHandler(predictions)
                    let anchorEntity = AnchorEntity(world: position)

                    let sphereEntity = (self?.generateSphereEntity(position: SIMD3<Float>(0, 0, 0), modelName: self!.latestPrediction))!

                    let textEntity = (self?.generateExistTextEntity(position: position, modelName: self!.latestPrediction))!

                    anchorEntity.addChild(sphereEntity)
                    anchorEntity.addChild(textEntity)

                    DispatchQueue.main.async {
                    self?.arView.scene.addAnchor(anchorEntity)
                    }
                }
            } catch {
                print("Vision was unable to make a prediction...\n\n\(error.localizedDescription)")
            }
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
