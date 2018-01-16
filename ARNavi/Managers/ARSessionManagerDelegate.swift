//
//  ARSessionManagerDelegate.swift
//  ARNavi
//
//  Created by Christopher Webb-Orenstein on 1/16/18.
//  Copyright © 2018 Christopher Webb-Orenstein. All rights reserved.
//

import UIKit
import ARKit
import SceneKit

protocol ARSessionManagerDelegate: class {
    func update(current trackingState: String)
    func planeNode(is inPlace: Bool, planeAnchor: ARPlaneAnchor)
}

