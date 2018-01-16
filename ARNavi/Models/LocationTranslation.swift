//
//  LocationTranslation.swift
//  ARNavi
//
//  Created by Christopher Webb-Orenstein on 1/16/18.
//  Copyright © 2018 Christopher Webb-Orenstein. All rights reserved.
//

import Foundation

struct LocationTranslation {
    
    var latitudeTranslation: Double
    var longitudeTranslation: Double
    var altitudeTranslation: Double
    
    init(latitudeTranslation: Double, longitudeTranslation: Double, altitudeTranslation: Double) {
        
        self.latitudeTranslation = latitudeTranslation
        self.longitudeTranslation = longitudeTranslation
        self.altitudeTranslation = altitudeTranslation
    }
}
