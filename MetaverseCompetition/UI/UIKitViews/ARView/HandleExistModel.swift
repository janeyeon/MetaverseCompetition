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

protocol Classification {
    func handleExistModel(position: SIMD3<Float>)
}

class RealClassification: Classification {

    let imagePredictor = ImagePredictor()
    var latestPrediction: String = "hello"

    var arView: CustomARView

    var generateTextSphereEntity: GenerateTextSphereEntity

    var viewModel: MyARViewControllerRepresentable.ViewModel

    init(arView: CustomARView, generateTextSphereEntity: GenerateTextSphereEntity, viewModel: MyARViewControllerRepresentable.ViewModel) {
        self.arView = arView
        self.generateTextSphereEntity = generateTextSphereEntity
        self.viewModel = viewModel
    }

    func handleExistModel(position: SIMD3<Float>) {
        self.classifyImage(position: position)
    }

    private func classifyImage(position: SIMD3<Float>) {

        // TODO: - snapshot시에 생성된 text model 들은 없애고 캡쳐하는 방법 있을까?
        self.arView.snapshot(saveToHDR: true) { image in
            let resizedImage = self.cropImage(uiImage: image!)

            do {
                try self.imagePredictor.makePredictions(for: resizedImage) { [weak self] predictions in
                    // 반드시 mainview의 latestPrediction을 넣어주고 밑의 부분이 실행되어야 함
                    self?.imagePredictorHandler(predictions) { [self] in
                        // entity를 넣어주는 부분
                        // TODO: - 나중에 이부분을 다른 model entity생성하는 부분과 합치기
                        let anchorEntity = AnchorEntity(world: position)

                        let sphereEntity = (self?.generateTextSphereEntity.generateSphereEntity(position: SIMD3<Float>(0, 0, 0), modelName: self!.latestPrediction, textModelState: .add, modelHeight: nil))!

                        let textEntity = (self?.generateTextSphereEntity.generateTextEntity(position: position, modelName: self!.latestPrediction, textModelState: .add, modelHeight: nil))!

                        anchorEntity.addChild(sphereEntity)
                        anchorEntity.addChild(textEntity)
                        anchorEntity.name = "\(self!.latestPrediction)_anchor"

                        guard let result = self?.arView.raycast(from: CGPoint(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2), allowing: .estimatedPlane, alignment: .any).first else {
                            return
                        }

                        DispatchQueue.main.async {
                            self?.arView.scene.addAnchor(anchorEntity)
                            self?.viewModel.addNewWordModel(word: self!.latestPrediction, rayCastResult: result)
                        }
                    }
                }
            } catch {
                print("Vision was unable to make a prediction...\n\n\(error.localizedDescription)")
            }
        }
    }

    /// crop uiImage in the center of the screen
    private func cropImage(uiImage: UIImage) -> UIImage {
        let h = UIScreen.main.bounds.size.height / 3 * UIScreen.main.scale
        let w = UIScreen.main.bounds.size.width / 3 * UIScreen.main.scale
        let cgImage = uiImage.cgImage

        let croppedCGImage = cgImage?.cropping(to: CGRect(x: w, y: h, width: w, height: h))
        return UIImage(cgImage: croppedCGImage!)
    }

    /// Processing image classification
    private func imagePredictorHandler(_ predictions: [ImagePredictor.Prediction]?, completionHandler: @escaping () -> Void ) {
        // update latestprediction label using prediction result
        guard let predictions = predictions else {
            return
        }

        let formattedPrediction = formatPredictions(predictions)
        let predictionString = formattedPrediction.first!

        // Update ui-related variable in main thread
        DispatchQueue.main.async {
            self.latestPrediction = predictionString
            // send completion handler result
            completionHandler()
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
