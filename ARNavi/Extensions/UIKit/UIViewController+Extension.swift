//
//  UIViewController+Extension.swift
//  ARNavi
//
//  Created by Christopher Webb-Orenstein on 1/16/18.
//  Copyright © 2018 Christopher Webb-Orenstein. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func embedChild(controller: UIViewController, in view: UIView) {
        self.addChildViewController(controller)
        controller.view.constrain(to: view)
        controller.didMove(toParentViewController: self)
    }
    
    func removeChild(controller: UIViewController) {
        controller.willMove(toParentViewController: nil)
        controller.view.removeFromSuperview()
        controller.removeFromParentViewController()
    }
}
