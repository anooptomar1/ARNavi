//
//  Double+Extension.swift
//  ARNavi
//
//  Created by Christopher Webb-Orenstein on 1/16/18.
//  Copyright © 2018 Christopher Webb-Orenstein. All rights reserved.
//

import Foundation

extension Double {
    
    func metersToLatitude() -> Double {
        return self / (6373000.0)
    }
    
    func metersToLongitude() -> Double {
        return self / (5602900.0)
    }
    
    func toRadians() -> Double {
        return self * .pi / 180.0
    }
    
    func toDegrees() -> Double {
        return self * 180.0 / .pi
    }
}
