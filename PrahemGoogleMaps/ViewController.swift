//
//  ViewController.swift
//  PrahemGoogleMaps
//
//  Created by Mallikarjuna on 26/12/20.
//  Copyright © 2020 Mallikarjuna. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import Alamofire
import SwiftyJSON
import CoreLocation

class ViewController: UIViewController,UITextFieldDelegate,GMSAutocompleteViewControllerDelegate,CLLocationManagerDelegate {
    
    
    @IBOutlet weak var sourceTF: UITextField!
    
    
    @IBOutlet weak var destinationTF: UITextField!
    
    
    @IBOutlet weak var mapView: GMSMapView!
    
    let manager = CLLocationManager()
    
    var acvc = GMSAutocompleteViewController()
    
    var sourceLoc = CLLocation()
    var destinationLoc = CLLocation()
    
    
    var selectedTF:String = ""

    var marker = GMSMarker()
    var marker2 = GMSMarker()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sourceTF.delegate = self
        destinationTF.delegate = self
        acvc.delegate = self
        
        let camera = GMSCameraPosition.camera(withLatitude: 17.3850, longitude: 78.4867, zoom: 10.0)
        self.mapView.delegate = self
        mapView.camera = camera
        
        mapView.isMyLocationEnabled = true
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
        
        

        // Creates a marker in the center of the map.
//        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: 17.3850, longitude: 78.4867)
        marker.title = "Hyderabad"
        marker.snippet = "India"
        marker.isDraggable = true
        
        marker.map = mapView
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.delegate = self
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }
    
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        if(textField == sourceTF)
        {
            selectedTF = "source"
        }else if(textField == destinationTF)
        {
            selectedTF = "destination"
        }
        
        present(acvc, animated: true, completion: nil)
        
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        
        print("auto complete success")
        
        if(selectedTF == "source")
        {
            sourceTF.text = place.name
            sourceLoc = CLLocation(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
            
        }else if(selectedTF == "destination")
        {
            destinationTF.text = place.name
            destinationLoc = CLLocation(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
        }
        
        dismiss(animated: true, completion: nil)
        
    }
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        print("auto complete failed")
        
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        
        print("auto complete cancelled")
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onGoBtnTap(_ sender: Any) {
        
        drawPath(startLocation: sourceLoc, endLocation: destinationLoc)
        
    }
    
    func drawPath(startLocation: CLLocation, endLocation: CLLocation)
    {
        mapView.clear()
        
        let marker1 = GMSMarker()
        
        marker1.position = CLLocationCoordinate2D(latitude: startLocation.coordinate.latitude, longitude: startLocation.coordinate.longitude)
        marker1.title = sourceTF.text!
        marker1.snippet = sourceTF.text!
        
        
        marker1.map = mapView
        
        
        
        marker2.position = CLLocationCoordinate2D(latitude: endLocation.coordinate.latitude, longitude: endLocation.coordinate.longitude)
        marker2.title = destinationTF.text!
        marker2.snippet = destinationTF.text!
//        marker2.isDraggable = true
        marker2.map = mapView
        
        
        
        
        
        let origin = "\(startLocation.coordinate.latitude),\(startLocation.coordinate.longitude)"
        let destination = "\(endLocation.coordinate.latitude),\(endLocation.coordinate.longitude)"
        
        
        
        let url = "https://maps.googleapis.com/maps/api/directions/json?origin=\(origin)&destination=\(destination)&mode=driving&key=AIzaSyDuBvXGuYzrnh51qC3brdG0OQCsXFHCNLU"
        
        
        print(url)
        
        AF.request(url).responseJSON { response in
            
            print(response.request as Any)  // original URL request
            print(response.response as Any) // HTTP URL response
            print(response.data as Any)     // server data
            print(response.result as Any)   // result of response serialization
            do{
            let json = try JSON(data: response.data!)
            let routes = json["routes"].arrayValue
            
            // print route using Polyline
            for route in routes
            {
                let routeOverviewPolyline = route["overview_polyline"].dictionary
                let points = routeOverviewPolyline?["points"]?.stringValue
                let path = GMSPath.init(fromEncodedPath: points!)
                let polyline = GMSPolyline.init(path: path)
                polyline.strokeWidth = 4
                polyline.strokeColor = UIColor.red
                polyline.map = self.mapView
            }
                
                let camera = GMSCameraPosition.camera(withLatitude: self.sourceLoc.coordinate.latitude, longitude: self.sourceLoc.coordinate.longitude, zoom: 10.0
            )
                
                self.mapView.camera = camera
            }catch
            {
                print("unable to create route")
            }
            
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        print("Location has changed")
    }

    
}
extension ViewController:GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        print("clicked on marked")
    }
    
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        let view = UIView(frame: CGRect.init(x: 0, y: 0, width: 200, height: 100))
        view.backgroundColor = UIColor.white
        view.layer.cornerRadius = 6
        let title = UILabel(frame: CGRect.init(x: 8, y: 8, width: view.frame.width - 16, height: 15))
        title.text = "hi there"
        view.addSubview(title)
        return view
    }
    
    func mapView(_ mapView: GMSMapView, didBeginDragging marker: GMSMarker) {
        print("didBeginDragging")
    }
    func mapView(_ mapView: GMSMapView, didDrag marker: GMSMarker) {
        print("didDrag")
    }
    func mapView(_ mapView: GMSMapView, didEndDragging marker: GMSMarker) {
        print("didEndDragging")
    }
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        marker.position = coordinate
    }
    func mapView(_ mapView: GMSMapView, didTapMyLocation location: CLLocationCoordinate2D) {
        print("didTapMyLocation")
        marker.position = location
    }
    
}
