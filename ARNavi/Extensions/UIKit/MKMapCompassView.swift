//
//  MapKitCompassMap.swift
//  ARNavi
//
//  Created by Christopher Webb-Orenstein on 1/16/18.
//  Copyright © 2018 Christopher Webb-Orenstein. All rights reserved.
//

// Credit to Jordan Kiley & Mapbox for MBXCompassMapView.swift - https://blog.mapbox.com/compass-for-arkit-42c0692c4e51

import MapKit

class MKMapCompassView: MKMapView {
    
    var isMapInteractive : Bool = true {
        didSet {
            
            // Disable individually, then add custom gesture recognizers as needed.
            self.isZoomEnabled = false
            self.isScrollEnabled = false
            self.isPitchEnabled = false
            self.isRotateEnabled = false
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.alpha = 0.8
        setUserTrackingMode(.followWithHeading, animated: true)
        hideMapSubviews()
    }
    
    init() {
        super.init(frame: CGRect.zero)
        setUserTrackingMode(.followWithHeading, animated: true)
    }
    
    override func layoutSubviews() {
        self.layer.cornerRadius = self.frame.width / 2
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func mapViewWillStartLoadingMap(_ mapView: MKMapView) {
        self.userTrackingMode = .followWithHeading
    }
    
    private func hideMapSubviews() {
        showsCompass = false 
    }
}
