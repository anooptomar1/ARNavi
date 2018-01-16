//
//  ARSessionManager.swift
//  ARNavi
//
//  Created by Christopher Webb-Orenstein on 1/16/18.
//  Copyright © 2018 Christopher Webb-Orenstein. All rights reserved.
//

import UIKit
import ARKit
import CoreLocation
import SceneKit

class ARSessionManager: NSObject {
    
    weak var delegate: ARSessionManagerDelegate?
    
    override init() {
        super.init()
    }
}

extension ARSessionManager: ARSCNViewDelegate {
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        DispatchQueue.main.async {
            if let planeAnchor = anchor as? ARPlaneAnchor {
                let newNode = PlaneGenerator.getPlane(from: planeAnchor)
                node.addChildNode(newNode)
                self.delegate?.planeNode(is: true, planeAnchor: planeAnchor)
            }
        }
    }
}

extension ARSessionManager: ARSessionDelegate {
    
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        switch camera.trackingState {
        case .notAvailable:
            delegate?.update(current: "Tracking unavailable")
        case .normal:
            delegate?.update(current: "Tracking normal")
        case .limited(.excessiveMotion):
            delegate?.update(current: "Tracking limited - Too much camera movement")
        case .limited(.insufficientFeatures):
            delegate?.update(current: "Tracking limited - Not enough surface detail")
        case .limited(.initializing):
            delegate?.update(current: "Tracking limited - Too much camera movement")
        }
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        print("did fail \(error.localizedDescription)")
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        print("interrupted")
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        print("interruption ended")
    }
}
