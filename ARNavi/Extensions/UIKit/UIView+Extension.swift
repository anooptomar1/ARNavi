//
//  UIView+Extension.swift
//  ARNavi
//
//  Created by Christopher Webb-Orenstein on 1/16/18.
//  Copyright © 2018 Christopher Webb-Orenstein. All rights reserved.
//

import UIKit

extension UIView {
    
    func add(_ subviews: UIView...) {
        subviews.forEach(addSubview)
    }
    
    func constrain(to view: UIView) {
        self.translatesAutoresizingMaskIntoConstraints = false
        view.add(self)
        self.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        self.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        self.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        self.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }
}
