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
    func generateSphereEntity(position: SIMD3<Float>, modelName: String) -> ModelEntity

    func generateExistTextEntity(position: SIMD3<Float>, modelName: String) -> ModelEntity

    func generateTextEntity(position: SIMD3<Float>, modelName: String) -> ModelEntity

    func generateExistTextEntityWithMaterial(position: SIMD3<Float>, modelName: String) -> ModelEntity

}


class RealGenerateTextSphereEntity : GenerateTextSphereEntity {

    var arView: CustomARView

    init(arView: CustomARView) {
        self.arView = arView
    }

    func generateTextModel(text: String) -> ModelEntity {
        let lineHeight: CGFloat = 0.05
        let font = MeshResource.Font.systemFont(ofSize: lineHeight)
        let textMesh = MeshResource.generateText(text, extrusionDepth: Float(lineHeight * 0.1), font: font)

        let textMeterial = SimpleMaterial(color: UIColor.orange, isMetallic: true)

        let model = ModelEntity(mesh: textMesh, materials: [textMeterial])

        model.position.x -= model.visualBounds(relativeTo: nil).extents.x / 2
        model.position.y += 0.015
        model.position.x += Float(text.count) * 0.005

        return model
    }

    func generateSphereEntity(position: SIMD3<Float>, modelName: String) -> ModelEntity {

        let radius: Float = 0.01
        let color: UIColor = UIColor.green

        let sphere = ModelEntity(mesh: .generateSphere(radius: radius), materials: [SimpleMaterial(color: color, isMetallic: false)])

        // move sphere slightly up
        sphere.position = position
        sphere.position.y += radius

        sphere.physicsBody?.mode = .dynamic
        sphere.collision = CollisionComponent(shapes: [ShapeResource.generateSphere(radius: 0.05)])
        sphere.name = "\(modelName)_sphere"

        // 맘대로 움직일 수 있음, 다만 anchor위치는 안변하는듯?
//        arView.installGestures(.all, for: sphere)

        return sphere
    }

    func generateExistTextEntity(position: SIMD3<Float>, modelName: String) -> ModelEntity {
        let textEntity = self.generateTextModel(text: modelName)

        let raycastDistance = distance(position, self.arView.cameraTransform.translation)

        print("DEBUG: - first anchor position : \(position)")

        textEntity.scale = .one * raycastDistance

        var resultWithCameraOrientation = self.arView.cameraTransform
          resultWithCameraOrientation.translation = position

          textEntity.orientation = simd_quatf(resultWithCameraOrientation.matrix)
        textEntity.name = "\(modelName)_text"

        return textEntity

    }

    func generateExistTextEntityWithMaterial(position: SIMD3<Float>, modelName: String) -> ModelEntity {

        let lineHeight: CGFloat = 0.05
        let font = MeshResource.Font.systemFont(ofSize: lineHeight)
        let textMesh = MeshResource.generateText(modelName, extrusionDepth: Float(lineHeight * 0.1), font: font)

        // video material을 넣어주는 코드
        guard let url = Bundle.main.url(forResource: "glowing1", withExtension: ".mp4") else {
            return ModelEntity()
        }

        let player = AVPlayer(url: url)
        let material = VideoMaterial(avPlayer: player)
        material.controller.audioInputMode = .spatial

        let model = ModelEntity(mesh: textMesh, materials: [material])

        player.play()

        model.position.x -= model.visualBounds(relativeTo: nil).extents.x / 2
        model.position.y += 0.015
        model.position.x += Float(modelName.count) * 0.005

        let raycastDistance = distance(position, self.arView.cameraTransform.translation)


        model.scale = .one * raycastDistance

        var resultWithCameraOrientation = self.arView.cameraTransform
          resultWithCameraOrientation.translation = position

        model.orientation = simd_quatf(resultWithCameraOrientation.matrix)
        model.name = "\(modelName)_text"

        return model

    }

    func generateTextEntity(position: SIMD3<Float>, modelName: String) -> ModelEntity {

//        let rayDirection = normalize(position - self.arView.cameraTransform.translation)

//        let textPositionInWorldCoordinates = position - (rayDirection * 0.1)

//        let textPositionInWorldCoordinates = position

        // 5. Create a 3D text to visualize the classification result
        let textEntity = self.generateTextModel(text: modelName)

        // 6. Scale the text depending on the distance
        let raycastDistance = distance(position, self.arView.cameraTransform.translation)

        textEntity.scale = .one * raycastDistance * 2


//        // 7. Place the text facing the camera
//        var resultWithCameraOrientation = self.arView.cameraTransform
////
//        resultWithCameraOrientation.translation = position
//
//        textEntity.orientation = simd_quatf(resultWithCameraOrientation.matrix)
        textEntity.position += position
        textEntity.name = "\(modelName)_text"
//        textEntity.scale

        return textEntity
    }

    private func getCamVector() -> (position: SIMD3<Float>, direciton: SIMD3<Float>) {

        let cameraTransform = arView.cameraTransform

        let camDir = cameraTransform.matrix.columns.2
        return (cameraTransform.translation, -[camDir.x, camDir.y, camDir.z])
    }

}


//    private func camRayCast() -> ARRaycastResult {
//        let (camPos, camDir) = getCamVector()
//
//        let rcQuery = ARRaycastQuery(origin: camPos, direction: camDir, allowing: arView.focusSquare.allowedRaycast, alignment: .any)
//
//        let results = arView.session.raycast(rcQuery)
//        return results.first!
//    }

