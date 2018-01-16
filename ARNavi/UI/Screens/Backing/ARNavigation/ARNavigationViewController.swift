//
//  ARNavigationViewController.swift
//  ARNavi
//
//  Created by Christopher Webb-Orenstein on 1/16/18.
//  Copyright © 2018 Christopher Webb-Orenstein. All rights reserved.
//

import SceneKit
import ARKit
import Mapbox
import MapKit
import CoreLocation

// Credit: https://blog.mapbox.com/compass-for-arkit-42c0692c4e51

class ARNavigationViewController: UIViewController, Controller {
    
    private var nodes: [BaseNode] = []
    private var locationService = LocationService()
    var compass : MBXCompassMapView!
    private var updateNodes: Bool = false
    internal var startingLocation: CLLocation!

    private var anchors: [ARAnchor] = []
    var type: CoordinatorType = .app
    
    var tripData: [TripLeg]! {
        didSet {
            print(tripData)
        }
    }
    
    private var locationUpdates: Int = 0 {
        didSet {
            if locationUpdates >= 4 {
                updateNodes = false
            }
        }
    }
    
    private var updatedLocations: [CLLocation] = []
    
    var configuration = ARWorldTrackingConfiguration()
    
    @IBOutlet weak var sceneView: ARNavigationView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        edgesForExtendedLayout = []
        compass = MBXCompassMapView(frame: CGRect(x: 20,
                                                  y: 20,
                                                  width: view.bounds.width / 3,
                                                  height: view.bounds.width / 3),
                                    styleURL: URL(string: "mapbox://styles/chriswebb/cjchzr3z56ayd2snpbdzakeh1"))
        
        compass.isMapInteractive = false
        compass.tintColor = .black
        compass.delegate = self
        view.addSubview(compass)
        
       
        sceneView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.insertSubview(compass, aboveSubview: sceneView)
       // view.insertSubview(sceneView, belowSubview: compass)
         setConstraints()
        sceneView.delegate = self
        // Shows attribution and telemetry opt-in. For more information about Mapbox attribution, see https://www.mapbox.com/help/how-attribution-works/#mapbox-ios-sdk
   
        
        locationService.startUpdatingLocation(locationManager: locationService.locationManager!)
        locationService.delegate = self
        navigationController?.setNavigationBarHidden(true, animated: false)
        edgesForExtendedLayout = []
        sceneView.delegate = self
        sceneView.session.delegate = self
        runSession()
        let button = compass.attributionButton
        button.isHidden = false
        button.frame = CGRect(x: 10, y: 20, width: compass.attributionButton.frame.width, height: compass.attributionButton.frame.height)
        view.addSubview(button)
    }
    
    func setConstraints() {
        compass.translatesAutoresizingMaskIntoConstraints = false
        self.compass.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20).isActive = true
        compass.topAnchor.constraint(equalTo: view.topAnchor, constant: 20).isActive = true
        
        if UIDevice.current.orientation == .portrait {
            compass.heightAnchor.constraint(
                equalTo: view.widthAnchor,
                multiplier: 0.33).isActive = true
            compass.widthAnchor.constraint(
                equalTo: view.widthAnchor,
                multiplier: 0.33).isActive = true
        } else {
            compass.heightAnchor.constraint(
                equalTo: view.heightAnchor,
                multiplier: 0.33).isActive = true
            compass.widthAnchor.constraint(
                equalTo: view.heightAnchor,
                multiplier: 0.33).isActive = true
        }
    }
    
    func mapView(_ mapView: MGLMapView, didFinishLoading style: MGLStyle) {
        if let source = style.source(withIdentifier: "composite") {
            let poiCircles = MGLCircleStyleLayer(identifier: "poi-circles", source: source)
            poiCircles.sourceLayerIdentifier = "poi_label"
            poiCircles.circleColor = MGLStyleValue(rawValue: .white)
            poiCircles.circleRadius = MGLStyleValue(rawValue: 4)
            style.addLayer(poiCircles)
        }
    }
    
    func runSession() {
        configuration.planeDetection = .horizontal
        configuration.worldAlignment = .gravityAndHeading
        configuration.isLightEstimationEnabled = true
        sceneView.session.run(configuration)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    private func updateNodePosition() {
        if updateNodes {
            locationUpdates += 1
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.5
            if updatedLocations.count > 0 {
                startingLocation = CLLocation.bestLocationEstimate(locations: updatedLocations)
                for baseNode in nodes {
                    let translation = MatrixHelper.transformMatrix(for: matrix_identity_float4x4, originLocation: startingLocation, location: baseNode.location)
                    let position = SCNVector3.positionFromTransform(translation)
                    let distance = baseNode.location.distance(from: startingLocation)
                    DispatchQueue.main.async {
                        let scale = 100 / Float(distance)
                        baseNode.scale = SCNVector3(x: scale, y: scale, z: scale)
                        baseNode.anchor = ARAnchor(transform: translation)
                        baseNode.position = position
                    }
                }
            }
            SCNTransaction.commit()
        }
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        updateNodes = true
        if updatedLocations.count > 0 {
            startingLocation = CLLocation.bestLocationEstimate(locations: updatedLocations)
            if startingLocation != nil  {
                DispatchQueue.main.async {
                    self.addAnchors(steps: self.tripData)
                }
            }
        }
    }
}

extension ARNavigationViewController: ARSCNViewDelegate {
    
    private func addSphere(for step: MKRouteStep) {
        let stepLocation = step.getLocation()
        let locationTransform = MatrixHelper.transformMatrix(for: matrix_identity_float4x4, originLocation: startingLocation, location: stepLocation)
        let stepAnchor = ARAnchor(transform: locationTransform)
        let sphere = BaseNode(title: step.instructions, location: stepLocation)
        anchors.append(stepAnchor)
        sphere.addNode(with: 0.3, and: .green, and: step.instructions)
        sphere.location = stepLocation
        sphere.anchor = stepAnchor
        sceneView.session.add(anchor: stepAnchor)
        sceneView.scene.rootNode.addChildNode(sphere)
        nodes.append(sphere)
    }
    
    private func addSphere(for step: TripLeg) {
        let stepLocation = CLLocation(latitude: step.coordinates[0].latitude, longitude: step.coordinates[0].longitude)
        let locationTransform = MatrixHelper.transformMatrix(for: matrix_identity_float4x4, originLocation: startingLocation, location: stepLocation)
        let stepAnchor = ARAnchor(transform: locationTransform)
        let sphere = BaseNode(title: step.directions, location: stepLocation)
        anchors.append(stepAnchor)
        sphere.addNode(with: 0.3, and: .green, and: step.directions)
        sphere.location = stepLocation
        sphere.anchor = stepAnchor
        sphere.addPulse()
        sceneView.session.add(anchor: stepAnchor)
        sceneView.scene.rootNode.addChildNode(sphere)
        nodes.append(sphere)
    }
    
    // For intermediary locations - CLLocation - add sphere
    
    private func addSphere(for location: CLLocation) {
        let locationTransform = MatrixHelper.transformMatrix(for: matrix_identity_float4x4, originLocation: startingLocation, location: location)
        let stepAnchor = ARAnchor(transform: locationTransform)
        let sphere = BaseNode(title: "Title", location: location)
        sphere.addSphere(with: 0.25, and: .blue)
        anchors.append(stepAnchor)
        sphere.location = location
        sceneView.session.add(anchor: stepAnchor)
        sceneView.scene.rootNode.addChildNode(sphere)
        sphere.anchor = stepAnchor
        nodes.append(sphere)
    }
}

extension ARNavigationViewController: ARSessionDelegate {
    
    private func addAnchors(steps: [TripLeg]) {
        guard startingLocation != nil && steps.count > 0 else { return }
        
        for (_, leg) in tripData.enumerated() {
            for (count, location) in leg.coordinates.enumerated() {
                if count == 0 {
                    addSphere(for: leg)
                } else {
                    let location = CLLocation(latitude: location.latitude, longitude: location.longitude)
                    addSphere(for: location)
                }
            }
        }
    }
}

extension ARNavigationViewController: LocationServiceDelegate, MessagePresenting {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print(status)
    }
    
    func trackingLocation(for currentLocation: CLLocation) {
        if currentLocation.horizontalAccuracy <= 80.0 {
            updatedLocations.append(currentLocation)
            updateNodePosition()
        }
    }
    
    func trackingLocationDidFail(with error: Error) {
        presentMessage(title: "Error", message: error.localizedDescription)
    }
}

extension ARNavigationViewController:  MGLMapViewDelegate {
    
}
