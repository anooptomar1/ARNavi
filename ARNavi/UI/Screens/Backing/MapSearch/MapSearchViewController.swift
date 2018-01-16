//
//  MapSearchViewController.swift
//  ARNavi
//
//  Created by Christopher Webb-Orenstein on 1/16/18.
//  Copyright © 2018 Christopher Webb-Orenstein. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

protocol MapSearchViewControllerDelegate: class {
    func navigateInAR(data: [TripLeg])
}

class MapSearchViewController: UIViewController, Controller {
    
    var type: CoordinatorType = .start
    
    private var annotationColor = UIColor.blue
    
    weak var delegate: MapSearchViewControllerDelegate?
    
    var navigator = Navigator()
    var annotations: [POIAnnotation] = []
    var locationService = LocationService()
    
    var startingLocation: CLLocation! {
        didSet {
            navigator.startingLocation = startingLocation
            navigator.destinationLocation = CLLocationCoordinate2D(latitude: 40.737600, longitude: -73.980752)
            self.centerMapInInitialCoordinates()
            locationService.locationManager?.stopUpdatingLocation()
        }
    }
    
    var tripData: [TripLeg]!
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationService.requestAuthorization(locationManager: locationService.locationManager!)
        locationService.delegate = self
        edgesForExtendedLayout = []
        navigator.delegate = self
        mapView.delegate = self
    }
    
    @IBAction func ARTapped(_ sender: Any) {
        if tripData != nil {
            delegate?.navigateInAR(data: self.tripData)
        }
       // delegate?.navigateInAR()
    }
    
}

extension MapSearchViewController: NavigatorDelegate {
    
    func updateTrip(with legs: [TripLeg]) {
        tripData = legs
        for (index, leg) in legs.enumerated() {
            if index == 0 {
                if leg.coordinates.count == 0 {
                    DispatchQueue.main.async {
                        self.annotations.append(POIAnnotation(coordinate: self.startingLocation.coordinate, name: "N" + leg.directions))
                    }
                }
            }
            for coord in leg.coordinates {
                DispatchQueue.main.async {
                    self.annotations.append(POIAnnotation(coordinate: coord, name: String(describing: coord)))
                }
                
            }
        }
        
        showPointsOfInterestInMap(currentTripLegs: legs)
        addMapAnnotations()
        
    }
    
    private func showPointsOfInterestInMap(currentTripLegs: [TripLeg]) {
        DispatchQueue.main.async {
            self.mapView.removeAnnotations(self.mapView.annotations)
        }
        for tripLeg in currentTripLegs {
            for coordinate in tripLeg.coordinates {
                DispatchQueue.main.async {
                    let poi = POIAnnotation(coordinate: coordinate, name: String(describing: coordinate))
                    self.mapView.addAnnotation(poi)
                }
            }
        }
    }
    
    
    
    private func addMapAnnotations() {
        
        annotations.forEach { annotation in
            
            // Step annotations are green, intermediary are blue
            
            DispatchQueue.main.async {
                if let title = annotation.title, title.hasPrefix("N") {
                    self.annotationColor = .green
                } else {
                    self.annotationColor = .blue
                }
                self.mapView?.addAnnotation(annotation)
                self.mapView.add(MKCircle(center: annotation.coordinate, radius: 0.2))
            }
        }
    }
}

extension MapSearchViewController: LocationServiceDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            print("authorization")
        case .denied, .restricted, .notDetermined:
            print("denied")
        }
    }
    
    func trackingLocation(for currentLocation: CLLocation) {
        self.startingLocation = currentLocation
    }
    
    func trackingLocationDidFail(with error: Error) {
        print(error)
    }
    
    func centerMapInInitialCoordinates() {
        if startingLocation != nil {
            DispatchQueue.main.async {
                self.mapView.setCenter(self.startingLocation.coordinate, animated: true)
                let latDelta: CLLocationDegrees = 0.004
                let lonDelta: CLLocationDegrees = 0.004
                let span = MKCoordinateSpanMake(latDelta, lonDelta)
                let region = MKCoordinateRegionMake(self.startingLocation.coordinate, span)
                self.mapView.setRegion(region, animated: false)
            }
        }
    }
}

extension MapSearchViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "annotationView") ?? MKAnnotationView()
        annotationView.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        annotationView.canShowCallout = true
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKCircle {
            let renderer = MKCircleRenderer(overlay: overlay)
            DispatchQueue.main.async {
                renderer.fillColor = UIColor.black.withAlphaComponent(0.1)
                renderer.strokeColor = self.annotationColor
                renderer.lineWidth = 2
            }
            return renderer
        }
        return MKOverlayRenderer()
    }
}
