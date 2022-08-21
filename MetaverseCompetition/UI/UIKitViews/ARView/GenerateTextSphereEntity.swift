//
//  GenerateTextSphereEntity.swift
//  MetaverseCompetition
//
//  Created by HayeonKim on 2022/08/19.
//  Copyright © 2022 Apple. All rights reserved.
//

import ARKit
import Foundation
import RealityKit
import UIKit
import SwiftUI

protocol GenerateTextSphereEntity {
    func generateSphereEntity(position: SIMD3<Float>, modelName: String, textModelState: TextModelState, modelHeight: Float?) -> ModelEntity

    func generateTextEntity(position: SIMD3<Float>, modelName: String, textModelState: TextModelState, modelHeight: Float?) -> ModelEntity

}


class RealGenerateTextSphereEntity : GenerateTextSphereEntity {

    var arView: CustomARView

    init(arView: CustomARView) {
        self.arView = arView
    }

    func generateTextModel(text: String, color: UIColor, customMaterial: Bool = false) -> ModelEntity {
        let lineHeight: CGFloat = 0.05
        let font = MeshResource.Font.systemFont(ofSize: lineHeight)
        let textMesh = MeshResource.generateText(text, extrusionDepth: Float(lineHeight * 0.1), font: font)


        var model: ModelEntity

        if customMaterial {
            // video material을 넣어준다

            // video material을 넣어주는 코드
            guard let url = Bundle.main.url(forResource: "glowing1", withExtension: ".mp4") else {
                return ModelEntity()
            }

            let player = AVPlayer(url: url)
            let textMaterial = VideoMaterial(avPlayer: player)
            textMaterial.controller.audioInputMode = .spatial
            model = ModelEntity(mesh: textMesh, materials: [textMaterial])
            player.play()

        } else {
            // 주어진 mateiral이 없는경우
            let textMaterial = SimpleMaterial(color: color, isMetallic: true)
            model = ModelEntity(mesh: textMesh, materials: [textMaterial])
        }

        // 설마 설마 animation이 되려나? 제발 돼라 이눔시키! 
//        typealias SampledAnimationType = SampledAnimation<Float>
//        let frameArray: [Float] = [1.0, 2.0, 3.0]
//        let interval = TimeInterval(1.0)
//        let sampleAnim = SampledAnimationType.init(
//            frames: frameArray,
//            name: "sampledAnim1",
//            frameInterval: Float(interval),
//            isAdditive: true,
//            bindTarget: .transform,
//            blendLayer: 100,
//            repeatMode: .autoReverse,
//            fillMode: .backwards,
//            trimStart: 1.0,
//            trimEnd: 10.0,
//            trimDuration: 9.0,
//            offset: 2.0,
//            delay: 1.0,
//            speed: 2.0)
//
//        do {
//            let animResource = try AnimationResource.generate(with: sampleAnim)
//            model.playAnimation(animResource)
//
//        } catch {
//            print("fail to generate animation")
//        }

        model.position.x -= model.visualBounds(relativeTo: nil).extents.x / 2
        model.position.y += 0.015
        model.position.x += Float(text.count) * 0.005

        return model
    }

    ///  imported Model의 존재유무를 확인하여 크기를 return 한다
    func checkIfImportedModelExist(modelName: String) -> Float? {

        guard let importedModel = arView.scene.findEntity(named: "\(modelName)_model") else {
            // 없다는 소리
            return nil
        }

        return  (importedModel.visualBounds(relativeTo: nil).max.y - importedModel.visualBounds(relativeTo: nil).min.y)
    }

    func generateSphereEntity(position: SIMD3<Float>, modelName: String, textModelState: TextModelState, modelHeight: Float? = nil) -> ModelEntity {

        // 얘는 거의 이거 고정
        let radius: Float = 0.01
        let color: UIColor = UIColor.green

        var realPosition = position

        // model Entity가 존재하는지 확인 -> Imported 모델인지 확인
        let realModelHeight = modelHeight ?? checkIfImportedModelExist(modelName: modelName) ?? 0

        // realModelHeight이 있다면 modelHeight의 높이만큼 더해줌
        realPosition.y += realModelHeight

        let sphere = ModelEntity(mesh: .generateSphere(radius: radius), materials: [SimpleMaterial(color: color, isMetallic: false)])

        // move sphere slightly up
        sphere.position = realPosition
        sphere.position.y += radius

        sphere.physicsBody?.mode = .dynamic
        sphere.collision = CollisionComponent(shapes: [ShapeResource.generateSphere(radius: 0.05)])
        sphere.name = "\(modelName)_sphere"

        return sphere
    }


    func generateTextEntity(position: SIMD3<Float>, modelName: String, textModelState: TextModelState, modelHeight: Float? = nil) -> ModelEntity {

        // model Entity가 존재하는지 확인 -> Imported 모델인지 확인
        let realModelHeight = modelHeight ?? checkIfImportedModelExist(modelName: modelName) ?? 0

        // 그냥 일반적인 포지션
        // 근데 imported model일 경우는 position 이 0
        var realPosition = realModelHeight != 0 ?  SIMD3<Float>(0, 0, 0) : position


        print("DEBUG: textModelState - \(textModelState), realModelHeight  - \(realModelHeight), position - \(position)")

        // realModelHeight이 있다면 modelHeight의 높이만큼 더해줌
        realPosition.y += realModelHeight

        var textEntity: ModelEntity

        switch textModelState {
        case .add:
            // 모델을 새로 더해줄때
            textEntity = self.generateTextModel(text: modelName, color: UIColor.yellow)

        case .questionMark:
            // 물음표
            textEntity = self.generateTextModel(text: "?", color: UIColor.red)

        case .finished:
            // 파란색
            textEntity = self.generateTextModel(text: modelName, color: UIColor.blue)

        case .selected:
            // 커스텀 텍스쳐
            textEntity = self.generateTextModel(text: modelName, color: UIColor.black, customMaterial: true)
        case .justReturn:
            // 선택되고 나서 그냥 돌아올때 
            textEntity = self.generateTextModel(text: modelName, color: UIColor.yellow)
        }

        let raycastDistance = distance(realPosition, self.arView.cameraTransform.translation)

        textEntity.scale = .one * raycastDistance * (realModelHeight != 0 ? 3 : 1)

        if realModelHeight != 0 {
            // imported 모델일 경우
            textEntity.position += realPosition
        } else {
            // classification일 경우
            var resultWithCameraOrientation = self.arView.cameraTransform
              resultWithCameraOrientation.translation = realPosition

              textEntity.orientation = simd_quatf(resultWithCameraOrientation.matrix)
        }

        textEntity.name = "\(modelName)_text"
        return textEntity
    }


}

//
//    private func getCamVector() -> (position: SIMD3<Float>, direciton: SIMD3<Float>) {
//
//        let cameraTransform = arView.cameraTransform
//
//        let camDir = cameraTransform.matrix.columns.2
//        return (cameraTransform.translation, -[camDir.x, camDir.y, camDir.z])
//    }

//    private func camRayCast() -> ARRaycastResult {
//        let (camPos, camDir) = getCamVector()
//
//        let rcQuery = ARRaycastQuery(origin: camPos, direction: camDir, allowing: arView.focusSquare.allowedRaycast, alignment: .any)
//
//        let results = arView.session.raycast(rcQuery)
//        return results.first!
//    }

