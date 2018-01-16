//
//  NavigationService.swift
//  ARNavi
//
//  Created by Christopher Webb-Orenstein on 1/16/18.
//  Copyright © 2018 Christopher Webb-Orenstein. All rights reserved.
//

import MapKit
import CoreLocation

struct NavigationService {
    
    typealias routeCompletion = ([MKRouteStep]) -> Void
    
    func getDirections(destination: CLLocationCoordinate2D, request: MKDirectionsRequest, completion: @escaping routeCompletion) {
        
        var steps: [MKRouteStep] = []
      
        let placeMark = MKPlacemark(coordinate: destination)
        
        request.destination = MKMapItem.init(placemark: placeMark)
        request.source = MKMapItem.forCurrentLocation()
        request.requestsAlternateRoutes = false
        request.transportType = .walking
        
        let directions = MKDirections(request: request)
        
        directions.calculate { response, error in
            if error != nil {
                print("Error getting directions")
            } else {
                guard let response = response else { return }
                for route in response.routes {
                    steps.append(contentsOf: route.steps)
                }
                completion(steps)
            }
        }
    }
}

protocol NavigatorDelegate: class {
    func updateTrip(with legs: [TripLeg])
}

class Navigator {
    
    weak var delegate: NavigatorDelegate?
    
    private var currentTripLegs: [[CLLocationCoordinate2D]] = []
    
    var newLegs: [TripLeg] = []
    
    internal var annotations: [POIAnnotation] = []
    
    private var locations: [CLLocation] = []
    
    private var steps: [MKRouteStep] = []
    
    var startingLocation: CLLocation!
    
    var navigationService: NavigationService = NavigationService()
    
    var destinationLocation: CLLocationCoordinate2D! {
        didSet {
            setupNavigation()
        }
    }
    
    private func setupNavigation() {
        
        let group = DispatchGroup()
        group.enter()
        
        DispatchQueue.global(qos: .default).async {
            
            if self.destinationLocation != nil {
                self.navigationService.getDirections(destination: self.destinationLocation, request: MKDirectionsRequest()) { steps in
                    for step in steps {
                        self.annotations.append(POIAnnotation(coordinate: step.getLocation().coordinate, name: "N " + step.instructions))
                    }
                    self.steps.append(contentsOf: steps)
                    group.leave()
                }
            }
            
            // All steps must be added before moving to next step
            group.wait()
            
            self.getLocationData()
            self.delegate?.updateTrip(with: self.newLegs)
        }
    }
    
    private func getLocationData() {
        for (index, step) in steps.enumerated() {
            setTripLegFromStep(step, and: index)
        }
        
        for leg in newLegs {
            update(intermediary: leg.coordinates)
        }
        
//        for leg in currentTripLegs {
//            update(intermediary: leg)
//        }
//
    }
    
    // Gets coordinates between two locations at set intervals
    private func setLeg(from previous: CLLocation, to next: CLLocation) -> [CLLocationCoordinate2D] {
        return CLLocationCoordinate2D.getIntermediaryLocations(currentLocation: previous, destinationLocation: next)
    }
    
    // Adds calculated distances to annotations and locations arrays
    private func update(intermediary locations: [CLLocationCoordinate2D]) {
        
        for intermediaryLocation in locations {
            
            annotations.append(POIAnnotation(coordinate: intermediaryLocation, name: String(describing:intermediaryLocation)))
            
            self.locations.append(CLLocation(latitude: intermediaryLocation.latitude, longitude: intermediaryLocation.longitude))
            
        }
    }
    
    // Determines whether leg is first leg or not and routes logic accordingly
    private func setTripLegFromStep(_ tripStep: MKRouteStep, and index: Int) {
        if index > 0 {
            getTripLeg(for: index, and: tripStep)
        } else {
            getInitialLeg(for: tripStep)
        }
    }
    
    // Calculates intermediary coordinates for route step that is not first
    private func getTripLeg(for index: Int, and tripStep: MKRouteStep) {
        let previousIndex = index - 1
        let previousStep = steps[previousIndex]
        let previousLocation = CLLocation(latitude: previousStep.polyline.coordinate.latitude, longitude: previousStep.polyline.coordinate.longitude)
        let nextLocation = CLLocation(latitude: tripStep.polyline.coordinate.latitude, longitude: tripStep.polyline.coordinate.longitude)
        let intermediarySteps = CLLocationCoordinate2D.getIntermediaryLocations(currentLocation: previousLocation, destinationLocation: nextLocation)
        currentTripLegs.append(intermediarySteps)
        let tripLeg = TripLeg(coordinates: intermediarySteps, directions: tripStep.instructions)
        if !newLegs.contains(tripLeg) {
            newLegs.append(tripLeg)
        }
    }
    
    // Calculates intermediary coordinates for first route step
    private func getInitialLeg(for tripStep: MKRouteStep) {
        let nextLocation = CLLocation(latitude: tripStep.polyline.coordinate.latitude, longitude: tripStep.polyline.coordinate.longitude)
        let intermediaries = CLLocationCoordinate2D.getIntermediaryLocations(currentLocation: startingLocation, destinationLocation: nextLocation)
        currentTripLegs.append(intermediaries)
        let tripLeg = TripLeg(coordinates: intermediaries, directions: tripStep.instructions)
        if !newLegs.contains(tripLeg) {
            newLegs.append(tripLeg)
        }
    }
}
