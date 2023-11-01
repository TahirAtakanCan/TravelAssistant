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
    
    var selectedTitle = ""
    var selectedTitleId : UUID?
    
    
    var annotationTitle = ""
    var annotationSubtitle = ""
    var annotationLatitude = Double()
    var annotationLongitude = Double()
    
    
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
        
        
        //ekran geçişleri
        if selectedTitle != ""{
            //CoreData
            /*let stringUUID = selectedTitleId!.uuidString
            print(stringUUID)
            */
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Places")
            let idString = selectedTitleId!.uuidString
            // filtre
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString)
            fetchRequest.returnsObjectsAsFaults = false
            
            do{
                let results = try context.fetch(fetchRequest)
                if results.count > 0 {
                    for result in results as! [NSManagedObject]{
                        
                        if let title = result.value(forKey: "title") as? String{
                            annotationTitle = title
                            
                            if let subtitle = result.value(forKey: "subtitle") as? String{
                                annotationSubtitle = subtitle
                                
                                if let latitude = result.value(forKey: "latitude") as? Double{
                                    annotationLatitude = latitude
                                    
                                    if let latitude = result.value(forKey: "latitude") as? Double{
                                        annotationLatitude = latitude
                                        
                                        if let longitude = result.value(forKey: "longitude") as? Double{
                                            annotationLongitude = longitude
                                            
                                            let annotation = MKPointAnnotation()
                                            annotation.title = annotationTitle
                                            annotation.subtitle = annotationSubtitle
                                            let coordinate = CLLocationCoordinate2D(latitude: annotationLatitude, longitude: annotationLongitude)
                                            annotation.coordinate = coordinate
                                            
                                            mapView.addAnnotation(annotation)
                                            nameText.text = annotationTitle
                                            commentText.text = annotationSubtitle
                                            
                                            locationManager.stopUpdatingLocation()
                                            
                                            let span = MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
                                            let region = MKCoordinateRegion(center: coordinate, span: span)
                                            mapView.setRegion(region, animated: true)
                                        
                                            
                                            
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }catch{
                print("error")
            }
            
            
            
            
            
        }else{
            //Add New Data
            
            
            
        }
        
        
        
        
        
        
        
        
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
        if selectedTitle == "" {
            let location = CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.latitude)
            let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
            let region = MKCoordinateRegion(center: location, span: span)
            mapView.setRegion(region, animated: true)
        }else {
            //
        }
        
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation {
            return nil
        }
        
        let reuseId = "myAnnotation"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKMarkerAnnotationView // MKPinAnnotationView kaldırıldı
        
        if pinView == nil {
            pinView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView?.canShowCallout = true  // ektra bilgi
            pinView?.tintColor = UIColor.black
            
            let button = UIButton(type: UIButton.ButtonType.detailDisclosure)
            pinView?.rightCalloutAccessoryView = button
        }else{
            pinView?.annotation = annotation
        }
        
        return pinView
    }
    //navigasyon
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if selectedTitle != ""{
                
            let requestLocation = CLLocation(latitude: annotationLatitude, longitude: annotationLongitude)
            
            CLGeocoder().reverseGeocodeLocation(requestLocation) { placemarks, error in
                // closure
                if let placemark = placemarks { //*
                    if placemark.count > 0 {
                        
                        let newPlacemark = MKPlacemark(placemark: placemark[0])
                        let item = MKMapItem(placemark: newPlacemark) //*
                        item.name = self.annotationTitle    // closure içinde self kullanmak zorundayım
                        
                        let launchOptions = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving]
                        item.openInMaps(launchOptions : launchOptions)
                        
                    }
                }
                
            }
        }
        
        
        
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
        
        // mesaj yolla ve gönder
        NotificationCenter.default.post(name: NSNotification.Name("newPlace"), object: nil)
        navigationController?.popViewController(animated: true)
        
        
        
    }
    

}

// delete
// save butonunu göster
// klavyeyi kapatma
