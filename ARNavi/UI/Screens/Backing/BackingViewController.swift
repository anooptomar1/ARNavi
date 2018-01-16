//
//  BackingViewController.swift
//  ARNavi
//
//  Created by Christopher Webb-Orenstein on 1/16/18.
//  Copyright © 2018 Christopher Webb-Orenstein. All rights reserved.
//

import UIKit

final class BackingViewController: UIViewController, Controller {
    
    var type: CoordinatorType = .backing
    
    // MARK: - Properties
    
    var backingView: UIView = UIView()
    
    var mapSearchViewController: MapSearchViewController!
    var arNavigationViewController: ARNavigationViewController!
    
    var currentEmbeddedVC: UIViewController {
        didSet {
            removeChild(controller: oldValue)
            embedChild(controller: currentEmbeddedVC, in: backingView)
        }
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        self.currentEmbeddedVC = UIViewController()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.currentEmbeddedVC = UIViewController()
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let storyboard = try? UIStoryboard(.mapSearch) {
            if let viewController: MapSearchViewController = try? storyboard.instantiateViewController() {
                self.mapSearchViewController = viewController
                self.mapSearchViewController.delegate = self
                currentEmbeddedVC = mapSearchViewController
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        edgesForExtendedLayout = []
        DispatchQueue.main.async {
            self.view.add(self.backingView)
            self.backingView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                self.backingView.topAnchor.constraint(equalTo: self.view.layoutMarginsGuide.topAnchor),
                self.backingView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0),
                self.backingView.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 1),
                self.backingView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 0)
                ])
            self.backingView.layoutIfNeeded()
            self.backingView.backgroundColor = .blue
        }
    }
}

extension BackingViewController: MapSearchViewControllerDelegate {
    func navigateInAR(data: [TripLeg]) {
        if let storyboard = try? UIStoryboard(.navigation) {
            if let viewController: ARNavigationViewController = try? storyboard.instantiateViewController() {
                viewController.tripData = data
                self.arNavigationViewController = viewController
                currentEmbeddedVC = arNavigationViewController
            }
        }
    }
}
