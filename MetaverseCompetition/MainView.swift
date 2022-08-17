//
//  MainView.swift
//  CoreML+ARKit+Reformatting
//
//  Created by HayeonKim on 2022/08/03.
//

import Foundation
import SwiftUI

extension MainView {
    class ViewModel: ObservableObject {
        @Published var currentState: MainViewState = .addModelState
        @Published var arViewState: ARViewState = .handleExistingModel
        // 뭘 선택할건지
        @Published var modelConfirmedForPlacement: String?
        @Published var isPlacementEnabled: Bool = false

        @Published var selectedModel: String?

        @Published var transcript: String = ""
        @Published var isTrascriptButtonPressed: Bool = false
        @Published var caputredImage: UIImage? {
            willSet {
                print("DEBUG: Set captured Image!")
                print("DEBUG: captured Image size : \(newValue!.size)")
            }
        }

        static var possibleImportedModel: [String] = {
            let fileManager = FileManager.default

            guard let path = Bundle.main.resourcePath,
                    let files = try? fileManager.contentsOfDirectory(atPath: path) else {
                assertionFailure()
                return []
            }

            var fileNames: [String] = []
            for file in files where file.hasSuffix("usdz"){
                let modelName = file.replacingOccurrences(of: ".usdz", with: "")
                fileNames.append(modelName)
            }
            assert(!fileNames.isEmpty)
            return fileNames
        }()

        func changeMainViewState(to state: MainViewState) {
            currentState = state
        }

        func changeARViewState(to state: ARViewState) {
            arViewState = state
        }

        func resetPlacementParameters() {
            isPlacementEnabled = false
            selectedModel = nil
        }
    }
}


struct MainView: View {

    @StateObject var viewModel: MainView.ViewModel = ViewModel()

    var body: some View {
        // 항상 보여주는 화면
//        MyARViewControllerRepresentable(mainViewVM: viewModel)

        // addModelState -> classification state 에서 focus view 표시

        // State, button등을 표시하는 화면

        // text 창을 표시하는 화면

        // popup view를 표시하는 화면

        switch viewModel.currentState {
        case .addModelState:
            mainView
        case .practiceState:
            arView
        case .testState:
            drawingView
        }

    }


    var drawingView: some View {
        ZStack {
            VStack {
                // put drawing View in here
                DrawingViewControllerRepresentable(mainViewVM: viewModel)
            }
            VStack {
                Text(viewModel.transcript)
                    .foregroundColor(Color.yellow)
                HStack {
                    Spacer()
                    Button("Home") {
                        viewModel.changeMainViewState(to: .addModelState)
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 10))
                    .foregroundColor(Color.white)
                    .opacity(0.7)

                    Spacer()
                    Button("Transcript") {
                        viewModel.isTrascriptButtonPressed.toggle()
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 10))
                    .foregroundColor(Color.white)
                    .opacity(0.7)
                }
                Image(uiImage: viewModel.caputredImage ?? UIImage())
                    .resizable()
                    .scaledToFit()
                    .frame(width: UIScreen.main.bounds.width * 0.3, alignment: .center)
            }

            .padding(.bottom, 40)
        }
    }

    var arView: some View {
        ZStack {
            MyARViewControllerRepresentable(mainViewVM: viewModel)

            VStack {
                Spacer()

                Image(uiImage: viewModel.caputredImage ?? UIImage())
                    .resizable()
                    .scaledToFit()
                    .frame(height: UIScreen.main.bounds.height * 0.3, alignment: .center)
                    .border(.yellow, width: 3)

                if viewModel.arViewState == .handleImportedModel  {
                    if viewModel.isPlacementEnabled {
                        // placement button
                        placementButtonsView
                    } else {
                        // picker
                        modelPickerView
                    }
                }
                HStack {
                    // go to home
                    Button("Home") {
                        viewModel.changeMainViewState(to: .addModelState)
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 10))
                    .foregroundColor(Color.white)
                    .opacity(0.7)

                    // change arview mode

                    Button("change to Import State") {
                        viewModel.changeARViewState(to: .handleImportedModel)
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 10))
                    .foregroundColor(Color.white)
                    .opacity(0.7)

                    Button("change to Exist State") {
                        viewModel.changeARViewState(to: .handleExistingModel)
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 10))
                    .foregroundColor(Color.white)
                    .opacity(0.7)

                    Button("change to Selecting State") {
                        viewModel.changeARViewState(to: .selectModels)
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 10))
                    .foregroundColor(Color.white)
                    .opacity(0.7)

                }


            }
        }
    }

    var placementButtonsView: some View {
        HStack {
            // Cancel button
            Button(action: {
                print("DEBUG: press cancel button")
                viewModel.modelConfirmedForPlacement = nil
                viewModel.resetPlacementParameters()
            }) {
                Image(systemName: "xmark")
                    .frame(width: 60, height: 60)
                    .font(.title)
                    .background(Color.white.opacity(0.75))
                    .cornerRadius(30)
                    .padding(20)
            }

            // confirm button
            Button {
                print("DEBUG: press confirm button")
                viewModel.modelConfirmedForPlacement = viewModel.selectedModel
                viewModel.resetPlacementParameters()
            } label: {
                Image(systemName: "checkmark")
                    .frame(width: 60, height: 60)
                    .font(.title)
                    .background(Color.white.opacity(0.75))
                    .cornerRadius(30)
                    .padding(20)
            }
        }
    }

    var modelPickerView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 30) {
                ForEach(ViewModel.possibleImportedModel, id: \.self) { name in
                    Button {
                        print("press button named: \(name)")

                        viewModel.selectedModel = name
                        // placement
                        viewModel.isPlacementEnabled = true
                    } label: {
                        Image(uiImage: UIImage(named: name)!)
                            .resizable()
                            .frame(height: 80)
                            .aspectRatio(1/1, contentMode: .fit)
                            .background(.white)
                            .cornerRadius(12)
                    }
                    .buttonStyle(.plain)

                }
            }
            .padding(20)
            .background(Color.black.opacity(0.5))
        }
    }


    var mainView: some View {
        VStack {
            Button("Switch to ARView") {
                viewModel.changeMainViewState(to: .arView)
            }
            .padding(.bottom, 20)

            Button("Switch to DrawingView") {
                viewModel.changeMainViewState(to: .drawing)
            }
        }

    }
}
