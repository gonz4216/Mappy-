//
//  PlaceTableVC.swift
//  Tasky
//
//  Created by Ethan Gonsalves on 2023-01-05.
//

import Foundation
import UIKit
import MapKit


class PlacesTableVC: UITableViewController {
    var userLocation: CLLocation
    var places: [PlaceAnnotation]
    
    init(userLocation: CLLocation, places: [PlaceAnnotation]) {
        self.userLocation = userLocation
        self.places = places
        super.init(nibName: nil, bundle: nil)
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "PlaceCell")
        self.places.swapAt(indexForSelectedRow ?? 0, 0)
    }
    private var indexForSelectedRow: Int? {
        self.places.firstIndex(where: {$0.isSelected == true})
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        places.count
    }
    
    private func calculateDistance(from: CLLocation, to: CLLocation) -> CLLocationDistance {
        from.distance(from: to)
    }
    
    private func formatDistanceForDisplay(_ distance: CLLocationDistance) -> String {
        let meters = Measurement(value: distance, unit: UnitLength.meters)
        return meters.converted(to: .miles).formatted()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlaceCell", for: indexPath)
        let place = places[indexPath.row]
        
        var content = cell.defaultContentConfiguration()
        content.text = place.name
        content.secondaryText = formatDistanceForDisplay(calculateDistance(from: userLocation, to: place.location)) 
        
        cell.contentConfiguration = content
        cell.backgroundColor = place.isSelected ? UIColor.lightGray: UIColor.clear
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let place = places[indexPath.row]
        let placeDetailVC = PlaceDetailVC(place: place)
        present(placeDetailVC, animated: true)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
