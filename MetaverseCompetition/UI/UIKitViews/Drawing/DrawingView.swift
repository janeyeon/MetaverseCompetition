//
//  File.swift
//  MetaverseCompetition
//
//  Created by HayeonKim on 2022/08/10.
//  Copyright © 2022 Apple. All rights reserved.
//

import Combine
import PencilKit
import UIKit
import Vision

class DrawingViewController: UIViewController, PKCanvasViewDelegate, PKToolPickerObserver {

    let canvasView = PKCanvasView()
    let drawing = PKDrawing()
    let toolPicker = PKToolPicker()
    var viewModel: DrawingViewControllerRepresentable.ViewModel?

    // for scanninn & recognizing
    var resultsViewController: (UIViewController & RecognizedTextDataSource)?
    var textRecognitionRequest = VNRecognizeTextRequest()
    private var textRecognitionCancellable: AnyCancellable?

    // MARK: Initializer
    init(viewModel: DrawingViewControllerRepresentable.ViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)

        textRecognitionCancellable = viewModel.$isTrascriptButtonPressed
            .receive(on: RunLoop.main)
            .sink(receiveValue: { [weak self] isTranscriptButtonPressed in

                print("DEBUG: isTranscriptButtonPressed \(isTranscriptButtonPressed)")
                // start recognizing
                guard let capturedImage = self?.takeCapture() else { return }

                viewModel.setCaptureImage(image: capturedImage)

                self?.processImage(image: capturedImage)

            })
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        canvasView.backgroundColor = .clear
        canvasView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(canvasView)
        NSLayoutConstraint.activate([
            canvasView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            canvasView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            canvasView.topAnchor.constraint(equalTo: view.topAnchor),
            canvasView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        canvasView.drawing = drawing
        canvasView.alwaysBounceVertical = true
        canvasView.drawingPolicy = .anyInput

        toolPicker.setVisible(true, forFirstResponder: canvasView)
        toolPicker.addObserver(canvasView)
        canvasView.becomeFirstResponder()

        // for scanning & recognizing
        textRecognitionRequest = VNRecognizeTextRequest(completionHandler: { [weak self] (request, error) in

            if let results = request.results, !results.isEmpty {
                if let requestResults = request.results as? [VNRecognizedTextObservation] {
                    DispatchQueue.main.async {
                        print("DEBUG: text \(requestResults)")
                        self?.addRecognizedText(recognizedText: requestResults)
                    }
                }
            }
        })

        textRecognitionRequest.recognitionLevel = .accurate
        textRecognitionRequest.usesLanguageCorrection = true
    }

}


extension DrawingViewController: RecognizedTextDataSource {
    func addRecognizedText(recognizedText: [VNRecognizedTextObservation]) {
        let maxCandidates = 1
        for observation in recognizedText {
            guard let candidate = observation.topCandidates(maxCandidates).first else { continue }

            viewModel!.addTranscirptString(result: candidate.string)
        }
    }

    func processImage(image: UIImage) {
        guard let cgImage = image.cgImage else {
            print("Failed to get cgimage from input image")
            return
        }

        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        do {
            try handler.perform([textRecognitionRequest])
        } catch {
            print(error)
        }
    }

    func takeCapture() -> UIImage? {

        canvasView.backgroundColor = UIColor.white
        UIGraphicsBeginImageContextWithOptions(canvasView.bounds.size, canvasView.isOpaque, 0)
                defer { UIGraphicsEndImageContext() }
        canvasView.drawHierarchy(in: canvasView.bounds, afterScreenUpdates: true)

        canvasView.backgroundColor = UIColor.clear
                return UIGraphicsGetImageFromCurrentImageContext() 

    }

}


