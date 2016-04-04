//
//  RecintosViewController.swift
//  Pakua
//
//  Created by Leonardo Iacovini on 2/14/15.
//  Copyright (c) 2015 Leonardo Iacovini. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class RecintosViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet var mapView: MKMapView!
    let locationManager = CLLocationManager()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        
        // Get User Location
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        // Request Auth
        locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() && CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedWhenInUse && Reachability.isConnectedToNetwork() {
            locationManager.startUpdatingLocation()
        }
        
        // Setup map annotations
        for recintoAnnotation in createMapLocations() {
            mapView.addAnnotation(recintoAnnotation)
        }
    }
    
    
    
    func createMapLocations() -> [MKPointAnnotation] {
        
        struct Recinto {
            let name: String
            let address: String
            let location: CLLocationCoordinate2D
            init(_ name: String, _ address: String, _ location: CLLocationCoordinate2D) {
                self.name = name
                self.address = address
                self.location = location
            }
        }
        
        let recintos: [Recinto] = [Recinto("Jardins", "Rua Augusta, 1959 Sobreloja", CLLocationCoordinate2D(latitude: -23.559750, longitude: -46.661656)),
                                   Recinto("Guarulhos", "Av. Brig. Faria Lima, 1122 Sobreloja", CLLocationCoordinate2D(latitude: -23.445424, longitude: -46.520984)),
                                   Recinto("Tatuapé", "Rua Martim Pescador, 161", CLLocationCoordinate2D(latitude: -23.551419, longitude: -46.563296)),
                                   Recinto("Saude", "Av. Miguel Estefano, 496", CLLocationCoordinate2D(latitude: -23.620926, longitude: -46.634592))]

        var locationsPins: [MKPointAnnotation] = []
        for recinto in recintos{
            let recintoLocation = MKPointAnnotation()
            recintoLocation.coordinate = recinto.location
            recintoLocation.title = recinto.name
            recintoLocation.subtitle = recinto.address
            locationsPins.append(recintoLocation)
        }
        
        return locationsPins
    }
    
    override func viewDidAppear(animated: Bool) {
        
        // Cheks if there is internet connection
        Reachability.checkAndAlertIfNoConnection(self)
        
        // Setting Initial Position Based on Current Location
        mapView.showsUserLocation = true
        
        if CLLocationManager.locationServicesEnabled() && CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedWhenInUse && Reachability.isConnectedToNetwork() {
            let userLocation = locationManager.location!.coordinate
            let userRegi = MKCoordinateRegion(center: userLocation, span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5))
            mapView.setCenterCoordinate(userLocation, animated: true)
            mapView.setRegion(userRegi, animated: true)
        }

    }
    
    override func viewDidDisappear(animated: Bool) {
        locationManager.stopUpdatingLocation()
    }
    
    // Location Manager Delegate
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if CLLocationManager.locationServicesEnabled() && CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedWhenInUse && Reachability.isConnectedToNetwork() {
            locationManager.startUpdatingLocation()
            let userLocation = locationManager.location!.coordinate
            
            let userRegi = MKCoordinateRegion(center: userLocation, span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5))
            mapView.setCenterCoordinate(userLocation, animated: true)
            mapView.setRegion(userRegi, animated: true)
        }
    }
    
    // MapView Delegate

    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if !annotation.isKindOfClass(MKUserLocation) {
            let pointView = mapView.dequeueReusableAnnotationViewWithIdentifier("recinto")
            if pointView == nil {
                let recintoView = MKRecintoAnnotationView(annotation: annotation, reuseIdentifier: "recinto") as MKRecintoAnnotationView
                recintoView.setDetails()
                return recintoView
            } else {
                let recintoView = pointView as! MKRecintoAnnotationView
                return recintoView
            }
        } else {
            return nil
        }
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let recinto = view as! MKRecintoAnnotationView
        let openInAlert = UIAlertController(title: "Abrir no aplicativo", message: "Escolha em qual aplicativo deseja abrir a localização", preferredStyle: UIAlertControllerStyle.Alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
        let appleMaps = UIAlertAction(title: "Apple Maps", style: UIAlertActionStyle.Default) { (action) -> Void in
            let placeMark = MKPlacemark(coordinate: recinto.annotation!.coordinate, addressDictionary: nil)
            let mapItem = MKMapItem(placemark: placeMark)
            mapItem.name = recinto.annotation!.subtitle!
            mapItem.openInMapsWithLaunchOptions(nil)
        }
        openInAlert.addAction(cancelAction)
        openInAlert.addAction(appleMaps)
        // Checks for Google Maps on user device and add options if yes
        if (UIApplication.sharedApplication().canOpenURL(NSURL(string:"comgooglemaps://")!)) {
            let googleMaps = UIAlertAction(title: "Google Maps", style: UIAlertActionStyle.Default) { (alert) -> Void in
                UIApplication.sharedApplication().openURL(self.GetGMapsString(view.annotation!))
            }
            openInAlert.addAction(googleMaps)
        }
        presentViewController(openInAlert, animated: true, completion: nil)
    }
    
    private func GetGMapsString(annotation: MKAnnotation) -> NSURL {
        let latitude = annotation.coordinate.latitude
        let longitude = annotation.coordinate.longitude
        let address = annotation.subtitle!! as String
        let newAddress = address.stringByReplacingOccurrencesOfString(" ", withString: "+") // Remove spaces and puts + for GMaps Syntax
        return NSURL(string: "comgooglemaps://?q=\(newAddress)&center=\(latitude),\(longitude)")!
    }
}



// Custom MKAnnotationView Class for Recintos

class MKRecintoAnnotationView: MKAnnotationView {
    
    var recintoData: String!
    
    func setDetails() {
        self.image = UIImage(named: "recinto")
        self.recintoData = annotation!.title!
        self.rightCalloutAccessoryView = UIButton(type: UIButtonType.DetailDisclosure)
        self.canShowCallout = true
    }
    
}
