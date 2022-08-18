//
//  AddModelState.swift
//  MetaverseCompetition
//
//  Created by HayeonKim on 2022/08/18.
//  Copyright © 2022 Apple. All rights reserved.
//

import Foundation
import SwiftUI

extension AddModelStateView {
    class ViewModel : ObservableObject {
        // 뭘 선택할건지
        @Published var modelConfirmedForPlacement: String?
        @Published var isPlacementEnabled: Bool = false
        @Published var caputredImage: UIImage?
        @Published var selectedModel: String?


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

        func resetPlacementParameters() {
            isPlacementEnabled = false
            selectedModel = nil
        }
    }
}

struct AddModelStateView: View {
    @StateObject var viewModel =  AddModelStateView.ViewModel()
    @ObservedObject var mainViewModel: MainView.ViewModel

    var body: some View {
        // addModelState -> classification state 에서 focus view 표시

        // State, button등을 표시하는 화면
        buttonView

        // import할 모델을 검색하는 화면
        importModelView

        // popup view를 표시하는 화면
    }

    var buttonView: some View {
        ZStack {
            // state button
            // normal buttons
            featureButtons

            // study button
        }
    }

    var featureButtons: some View {
        HStack {
            Spacer()
            VStack(alignment: .trailing) {
                TemporalButtonView(label: "다시 하기") {
                    print("DEBUG: - press 다시하기 버튼 ")
                }
                TemporalButtonView(label: "추가 하기") {
                    print("DEBUG: - press 추가하기 버튼 ")
                    // add change state button
                    mainViewModel.changeAddModelState(to: .handleImportedModel)
                }
                TemporalButtonView(label: "인식 하기") {
                    print("DEBUG: - press 인식하기 버튼 ")
                    mainViewModel.changeAddModelState(to: .handleExistingModel)
                }
                Spacer()
            }
            .padding()
        }

    }

    var importModelView: some View {
        VStack {
        if mainViewModel.addModelState == .handleImportedModel  {
                if viewModel.isPlacementEnabled {
                    // placement button
                    placementButtonsView
                } else {
                    // picker
                    modelPickerView
                }
            }
        }
    }

    var modelPickerView: some View {
        VStack {
            Spacer()
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

    }

    var placementButtonsView: some View {
        VStack {
            Spacer()
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

        }

}
