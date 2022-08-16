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
    var mainViewVM: MainView.ViewModel

    // for scanninn & recognizing
    var resultsViewController: (UIViewController & RecognizedTextDataSource)?
    var textRecognitionRequest = VNRecognizeTextRequest()
    private var textRecognitionCancellable: AnyCancellable?

    // MARK: Initializer
    init(mainViewVM: MainView.ViewModel) {
        self.mainViewVM = mainViewVM
        super.init(nibName: nil, bundle: nil)

        textRecognitionCancellable = mainViewVM.$isTrascriptButtonPressed
            .receive(on: RunLoop.main)
            .sink(receiveValue: { [weak self] isTranscriptButtonPressed in

                print("DEBUG: isTranscriptButtonPressed \(isTranscriptButtonPressed)")
                if isTranscriptButtonPressed {
                    // start recognizing
                    guard let capturedImage = self?.takeCapture() else { return }
                    self?.processImage(image: capturedImage)
                    mainViewVM.isTrascriptButtonPressed = false
                }
            })
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
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

            mainViewVM.transcript += candidate.string
            mainViewVM.transcript += "\n"
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

    func takeCapture() -> UIImage {
        var image: UIImage?

        let currentLayer = UIApplication
           .shared
           .connectedScenes
           .flatMap { ($0 as? UIWindowScene)?.windows ?? [] }
           .first { $0.isKeyWindow }?
           .layer


        guard let currentLayer = currentLayer else {
            return UIImage()
        }

        let currentScale = UIScreen.main.scale
        // 1/3 부분만 돌리기 성공~
        let frameSize = CGSize(width: currentLayer.frame.size.width, height: currentLayer.frame.size.height / 3)

        // 현재 화면을 캡쳐하는 부분
        // MARK: - 나중에 사이즈를 조정해야 함
        UIGraphicsBeginImageContextWithOptions(frameSize, false, currentScale)
        guard let currentContext = UIGraphicsGetCurrentContext() else { return UIImage() }
        currentLayer.render(in: currentContext)
        image = UIGraphicsGetImageFromCurrentImageContext()

        UIGraphicsEndImageContext()

        return image ?? UIImage()
    }

}


