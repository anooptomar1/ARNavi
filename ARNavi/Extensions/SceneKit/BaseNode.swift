//
//  BaseNode.swift
//  ARNavi
//
//  Created by Christopher Webb-Orenstein on 1/16/18.
//  Copyright © 2018 Christopher Webb-Orenstein. All rights reserved.
//

import ARKit
import SceneKit
import CoreLocation

class BaseNode: SCNNode {
    
    let title: String
    var anchor: ARAnchor?
    var location: CLLocation!
    
    init(title: String, location: CLLocation) {
        self.title = title
        super.init()
        let billboardConstraint = SCNBillboardConstraint()
        billboardConstraint.freeAxes = SCNBillboardAxis.Y
        constraints = [billboardConstraint]
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createSphereNode(with radius: CGFloat, color: UIColor) -> SCNNode {
        let geometry = SCNSphere(radius: radius)
        geometry.firstMaterial?.diffuse.contents = color
        let sphereNode = SCNNode(geometry: geometry)
        return sphereNode
    }
    
    func addSphere(with radius: CGFloat, and color: UIColor) {
        let sphereNode = createSphereNode(with: radius, color: color)
        addChildNode(sphereNode)
    }
    
    func addNode(with radius: CGFloat, and color: UIColor, and text: String) {
        let sphereNode = createSphereNode(with: radius, color: color)
        let newText = SCNText(string: title, extrusionDepth: 0.05)
        newText.font = UIFont (name: "AvenirNext-Medium", size: 1)
        newText.firstMaterial?.diffuse.contents = UIColor.red
        let _textNode = SCNNode(geometry: newText)
        let annotationNode = SCNNode()
        annotationNode.addChildNode(_textNode)
        annotationNode.position = sphereNode.position
        addChildNode(sphereNode)
        addChildNode(annotationNode)
    }
    
    func addPulse() {
        let pulseSize:CGFloat = 5.0
        let pulsePlane = SCNPlane(width: pulseSize, height: pulseSize)
        pulsePlane.firstMaterial?.isDoubleSided = true
        pulsePlane.firstMaterial?.diffuse.contents = UIColor.blue
        let pulseNode = SCNNode(geometry: pulsePlane)
        
        let pulseShaderModifier =
            "#pragma transparent; \n" +
                "vec4 originalColour = _surface.diffuse; \n" +
                "vec4 transformed_position = u_inverseModelTransform * u_inverseViewTransform * vec4(_surface.position, 1.0); \n" +
                "vec2 xy = vec2(transformed_position.x, transformed_position.y); \n" +
                "float xyLength = length(xy); \n" +
                "float xyLengthNormalised = xyLength/" + String(describing: pulseSize / 2) + "; \n" +
                "float speedFactor = 1.5; \n" +
                "float maxDist = fmod(u_time, speedFactor) / speedFactor; \n" +
                "float distbasedalpha = step(maxDist, xyLengthNormalised); \n" +
                "distbasedalpha = max(distbasedalpha, maxDist); \n" +
        "_surface.diffuse = mix(originalColour, vec4(0.0), distbasedalpha);"
        
        pulsePlane.firstMaterial?.shaderModifiers = [SCNShaderModifierEntryPoint.surface:pulseShaderModifier]
        addChildNode(pulseNode)
    }
}
