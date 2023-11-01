//
//  ViewController.swift
//  TravelAssistant
//
//  Created by Tahir Atakan Can on 1.11.2023.
//

import UIKit
import MapKit
import CoreLocation
import CoreData

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var nameText: UITextField!
    
    @IBOutlet weak var commentText: UITextField!
    
    
    var locationManager = CLLocationManager()
    var choosenLatitude = Double()
    var choosenLognitude = Double()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest   // noktasına kadar öğrenmek
        locationManager.requestWhenInUseAuthorization() // bir app sadece kullanırken yerini bilmek
        locationManager.startUpdatingLocation()
        
        
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(chooseLocation(gestureRecognizer: )))
        
        gestureRecognizer.minimumPressDuration = 3
        mapView.addGestureRecognizer(gestureRecognizer)
        
    }
    
    @objc func chooseLocation(gestureRecognizer : UILongPressGestureRecognizer) {
        // dokunmaya başlama
        if gestureRecognizer.state == .began {
            let touchPoint = gestureRecognizer.location(in: self.mapView)   // nereye dokunduğu
            let touchCoordinats = self.mapView.convert(touchPoint, toCoordinateFrom: self.mapView) // dokunduğu noktayı koordinata çevirme
            
            choosenLatitude = touchCoordinats.latitude
            choosenLognitude = touchCoordinats.longitude
            
        // pin oluşturma
            let annotation = MKPointAnnotation()
            annotation.coordinate = touchCoordinats
            annotation.title = nameText.text
            annotation.subtitle = commentText.text
            self.mapView.addAnnotation(annotation)
        }
        
    }
    
    
    // kullanıcı konumunu almak
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.latitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        let region = MKCoordinateRegion(center: location, span: span)
        mapView.setRegion(region, animated: true)
    }
    
    
    @IBAction func saveButton(_ sender: Any) {
        // App Delegate çağırma
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        // Core Data objesine ulaşmak
        let newPlace = NSEntityDescription.insertNewObject(forEntityName: "Places", into: context)
        // istedğim değerleri kaydettim
        newPlace.setValue(nameText.text, forKey: "title")       // if ile genişlet
        newPlace.setValue(commentText.text, forKey: "subtitle")
        newPlace.setValue(choosenLatitude, forKey: "latitude")
        newPlace.setValue(choosenLognitude, forKey: "longitude")
        newPlace.setValue(UUID(), forKey: "id")
        // context.save() do try catch içerisinde çalıştır
        do{
            try context.save()
            print("success")
        }catch{
            print("error")
        }
        
        
        
    }
    

}

