//
//  ImagePredictor.swift
//  CoreML+ARKit+Reformatting
//
//  Created by HayeonKim on 2022/07/28.
//

import Vision
import UIKit

class ImagePredictor {
    static func createImageClassifier() -> VNCoreMLModel {
        // import mlmodel and create classifier
        let defaultConfig = MLModelConfiguration()

        let imageClassifierWrapper = try? MobileNetV2(configuration: defaultConfig)

        guard let imageClassifier = imageClassifierWrapper else {
            // error
            fatalError("App failed to create an image classifier model instance.")
        }

        // get the model instance
        let imageClassifierModel = imageClassifier.model

        /// create vision model instance using `VNCoreMLModel` function
        guard let imageClassifierVisionModel = try? VNCoreMLModel(for: imageClassifierModel) else {
            fatalError("App failed to create a `VNCoreMLModel` instance.")
        }

        return imageClassifierVisionModel
    }

    /// Share on ``VNCoreMLModel`` intances for each Core ML Model across the app
    private static let imageClassifier = createImageClassifier()

    /// Store the prediction result into one class
    struct Prediction {
        let classification: String

        let confidencePercentage: String
    }

    typealias ImagePredictionHandler = (_ prediction: [Prediction]?) -> Void

    // dictionary of prediction handler function
    private var predictionHandlers = [VNRequest: ImagePredictionHandler]()

    // generate requests
    private func createImageClassificationRequest() -> VNImageBasedRequest {
        let imageClassificationRequest = VNCoreMLRequest(model: ImagePredictor.imageClassifier, completionHandler: visionRequestHandler)

        imageClassificationRequest.imageCropAndScaleOption = .centerCrop
        return imageClassificationRequest
    }

    func makePredictions(for uiImage: UIImage, completionHandler: @escaping ImagePredictionHandler) throws {

        let orientation = CGImagePropertyOrientation(uiImage.imageOrientation)


        let imageClassificationRequest = createImageClassificationRequest()
        predictionHandlers[imageClassificationRequest] = completionHandler

        let handler = VNImageRequestHandler(data: uiImage.pngData()!, orientation: orientation)

        let requests: [VNRequest] = [imageClassificationRequest]

        // start the image classification request
        try handler.perform(requests)

    }


    /// This completion handler methods that Vision calls when it completes the requests
    ///
    private func visionRequestHandler(_ request: VNRequest, error: Error?) {
        // Remove the caller's handler from the dictionary and keep reference of it using predictionHandler
        guard let predictionHandler = predictionHandlers.removeValue(forKey: request) else {
            fatalError("Every request must have a prediction handler.")
        }

        var predictions : [Prediction]? = nil

        // call the client's completionHandler after return the value
        defer {
            predictionHandler(predictions)
        }

        if let error = error {
            print("Vision image classification error...\n\n\(error.localizedDescription)")
            return
        }

        if request.results == nil {
            print("Vision request had no results.")
            return
        }

        guard let observations = request.results as? [VNClassificationObservation] else {
            print("VNRequest produced the wrong result type: \(type(of: request.results)).")
            return
        }

        predictions = observations.map { observation in
            Prediction(classification: observation.identifier, confidencePercentage: observation.confidencePercentageString)
        }
    }

}


