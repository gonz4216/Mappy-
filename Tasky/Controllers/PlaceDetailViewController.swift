//
//  PlaceDetailViewController.swift
//  Tasky
//
//  Created by Ethan Gonsalves on 2023-01-05.
//

import Foundation
import UIKit

class PlaceDetailVC: UIViewController {
    let place: PlaceAnnotation
    init(place: PlaceAnnotation) {
        self.place = place
        super.init(nibName: nil, bundle: nil)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private func setupUI() {
        
    }
}
