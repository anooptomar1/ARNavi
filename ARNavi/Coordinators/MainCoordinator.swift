//
//  MainCoordinator.swift
//  ARNavi
//
//  Created by Christopher Webb-Orenstein on 1/16/18.
//  Copyright © 2018 Christopher Webb-Orenstein. All rights reserved.
//

import UIKit
import MapKit

final class MainCoordinator: AppCoordinator {
    
    weak var delegate: ControllerCoordinatorDelegate?
    
    var childCoordinators: [ControllerCoordinator] = []
    var window: UIWindow
    
    // var locationData: LocationData!
    
    init(window: UIWindow) {
        self.window = window
        transitionCoordinator(type: .backing)
    }
    
    func addChildCoordinator(_ childCoordinator: ControllerCoordinator) {
        childCoordinator.delegate = self
        childCoordinators.append(childCoordinator)
    }
    
    func removeChildCoordinator(_ childCoordinator: Coordinator) {
        childCoordinators = childCoordinators.filter { $0 !== childCoordinator }
    }
}

extension MainCoordinator: ControllerCoordinatorDelegate {
    
    func transitionCoordinator(type: CoordinatorType) {
        
        // Remove previous application flow
        
        childCoordinators.removeAll()
        
        switch type {
            
        case .app:
            print("app")
//            let navCoordinator = NavigationControllerCoordinator(window: window)
//            // navCoordinator.locationData = locationData
//            addChildCoordinator(navCoordinator)
//            navCoordinator.type = .nav
//            navCoordinator.start()
            
        case .start:
            print("start")
//            let startCoordinator = StartControllerCoordinator(window: window)
//            addChildCoordinator(startCoordinator)
//            startCoordinator.delegate = self
//            startCoordinator.type = .start
//            startCoordinator.start()
        case .backing:
            let backingCoordinator = BackingControllerCoordinator(window: window)
            addChildCoordinator(backingCoordinator)
            backingCoordinator.delegate = self
            backingCoordinator.type = .backing
            backingCoordinator.start()
        }
    }
}

