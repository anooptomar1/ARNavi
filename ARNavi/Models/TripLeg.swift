//
//  TripLeg.swift
//  ARNavi
//
//  Created by Christopher Webb-Orenstein on 1/16/18.
//  Copyright © 2018 Christopher Webb-Orenstein. All rights reserved.
//

import Foundation
import CoreLocation

struct TripLeg {
    var coordinates: [CLLocationCoordinate2D]
    var directions: String
}

extension TripLeg: Equatable {
    static func ==(lhs: TripLeg, rhs: TripLeg) -> Bool {
        return lhs.directions == rhs.directions
    }
}
