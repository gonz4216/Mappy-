//
//  ViewController.swift
//  Tasky
//
//  Created by Ethan Gonsalves on 2023-01-05.
//

import UIKit
import MapKit
class ViewController: UIViewController {
    private var places: [PlaceAnnotation] = []
    var locationManager: CLLocationManager?
    
    lazy var mapView: MKMapView = {
       let map = MKMapView()
        map.delegate = self
        map.showsUserLocation = true
        map.translatesAutoresizingMaskIntoConstraints = false
        return map
    }()
    
    lazy var searchTextField: UITextField = {
       let searchTextField = UITextField()
        
        searchTextField.layer.cornerRadius = 10
        searchTextField.delegate = self
        searchTextField.clipsToBounds = true
        searchTextField.backgroundColor = UIColor.white
        searchTextField.placeholder = "search"
        searchTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 0))
        searchTextField.leftViewMode = .always
        searchTextField.translatesAutoresizingMaskIntoConstraints = false
        return searchTextField
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        
        locationManager?.requestAlwaysAuthorization()
        locationManager?.requestLocation()
        
        setupUI()
    }
    
    private func setupUI() {
        view.addSubview(searchTextField)
        view.addSubview(mapView)
        view.bringSubviewToFront(searchTextField)
        NSLayoutConstraint.activate([
            searchTextField.heightAnchor.constraint(equalToConstant: 44),
            searchTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            searchTextField.widthAnchor.constraint(equalToConstant: view.bounds.size.width/1.2),
            searchTextField.topAnchor.constraint(equalTo: view.topAnchor, constant: 60)
          
        ])
        searchTextField.returnKeyType = .go
        NSLayoutConstraint.activate([
            mapView.widthAnchor.constraint(equalTo: view.widthAnchor),
            mapView.heightAnchor.constraint(equalTo: view.heightAnchor),
            mapView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            mapView.centerXAnchor.constraint(equalTo: view.centerXAnchor)


        ])
        
    }
    
    private func checkLocationAuth() {
        guard let locationManager = locationManager,
              let location = locationManager.location else {return}
        switch locationManager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 750, longitudinalMeters: 750)
            mapView.setRegion(region, animated: true)
        
        case .denied:
            print("Location serviced has been denaied.")
        case .notDetermined, .restricted:
            print("Locaiton cannot be determinded")
        @unknown default:
            print("unknown err, unable to get location.")
        }
    }
    
    private func presentPlacesSheet(places: [PlaceAnnotation]) {
        guard let locationManager = locationManager,
              let Userlocation = locationManager.location else {return}
        
        let placesTVC = PlacesTableVC(userLocation: Userlocation , places: places)
        placesTVC.modalPresentationStyle = .pageSheet
        if let sheet = placesTVC.sheetPresentationController {
            sheet.prefersGrabberVisible = true
            sheet.detents = [.medium(), .large()]
            present(placesTVC, animated: true)
        }
    }
    
    
    private func findNearbyPlaced(by query: String) {
        // clear all anotations
        mapView.removeAnnotations(mapView.annotations)
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.region = mapView.region
        
        let search = MKLocalSearch(request: request)
        search.start { [weak self] response, error in
            guard let response = response, error == nil else { return }
            
            self?.places = response.mapItems.map(PlaceAnnotation.init)
            self?.places.forEach { place in
                self?.mapView.addAnnotation(place)
            }
            if let places = self?.places {
                self?.presentPlacesSheet(places: places)

            }
        }
      
        
    }
  

}
extension ViewController: MKMapViewDelegate {
    
    
    private func clearAllSelections() {
        self.places = self.places.map {
            place in place.isSelected = false
            return place
        }
    }
    
    func mapView(_ mapView: MKMapView, didSelect annotation: MKAnnotation) {
        guard let selectionAnnotation = annotation as? PlaceAnnotation else { return }
        let placeAnnotation = self.places.first(where: { $0.id == selectionAnnotation.id })
        placeAnnotation?.isSelected = true
        clearAllSelections()
        presentPlacesSheet(places: self.places)
        
        
    }
    
}

extension ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let text =  textField.text ?? ""
        if !text.isEmpty {
            textField.resignFirstResponder()
           findNearbyPlaced(by: text)
        }
        return true
    }
}

extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    
    }
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuth()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}
