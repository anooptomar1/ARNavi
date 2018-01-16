//
//  BackingCoordinator.swift
//  ARNavi
//
//  Created by Christopher Webb-Orenstein on 1/16/18.
//  Copyright © 2018 Christopher Webb-Orenstein. All rights reserved.
//

import UIKit

final class BackingControllerCoordinator: ControllerCoordinator {
    
    var window: UIWindow
    
    var rootController: RootController!
    
    weak var delegate: ControllerCoordinatorDelegate?
    
    private var navigationController: UINavigationController {
        return UINavigationController(rootViewController: rootController)
    }
    
    var type: CoordinatorType {
        didSet {
            if let storyboard = try? UIStoryboard(.backing) {
                if let viewController: BackingViewController = try? storyboard.instantiateViewController() {
                  //  viewController.delegate = self
                    rootController = viewController
                }
            }
        }
    }
    
    init(window: UIWindow) {
        self.window = window
        type = .backing
    }
    
    func start() {
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    }
}


