//
//  MapaViewController.swift
//  practica1
//
//  Created by Javier Arguello on 15/4/16.
//  Copyright © 2016 uoc. All rights reserved.
//

import UIKit

class MapaViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var mapOutlet: MKMapView!
  
    @IBAction func buscarSitios(sender: AnyObject) {
        searchingDataObjectByDistance();
        Global.totalkms = Int(stepper.value)
        reloadSites()
        NSNotificationCenter.defaultCenter().postNotificationName("SitesSearched", object: nil);
        
    }
    func getValoracionMedia(sitio: Sitio) -> Float{
        var valoracion: Float = 0.0;
        let totalValoraciones = sitio.valoraciones.count
        if (totalValoraciones > 0) {
            for valo in sitio.valoraciones
            {
                valoracion += valo.valoracion
            }
            valoracion = valoracion/Float(totalValoraciones)
        }
        return valoracion
    }
    func reloadSites(){
        if Global.sitios.count > 0{
            removeAllPinsButUserLocation()
            var i = 0;
            for sitio in Global.sitios{
                if let coordinates = sitio.coordinates{
                    let pinLoc = CLLocationCoordinate2D(latitude: Double(coordinates.latitude), longitude: Double(coordinates.longitude))
                    let annotationPoint = PinAnnotation()
                    annotationPoint.title = sitio.nombre!
                    annotationPoint.subtitle = "Valoracion: \(getValoracionMedia(sitio))"
                    annotationPoint.setCoordinate(pinLoc)
                    annotationPoint.number = i;
                    self.mapOutlet.addAnnotation(annotationPoint)
                    i+=1;
                }
            }
        }

    }
    func removeAllPinsButUserLocation()
    {
        let annotationsToRemove = mapOutlet.annotations.filter { $0 !== mapOutlet.userLocation }
        mapOutlet.removeAnnotations( annotationsToRemove )
    }
    

    @IBOutlet weak var distField: UITextField!
    @IBOutlet weak var stepper: UIStepper!
    let locationManager = CLLocationManager()
    var isUpdatingLocation = false
    var lastLocationError: NSError?
    let authStatus = CLLocationManager.authorizationStatus()
    var location: CLLocation?
    var pinLocation = CLLocationCoordinate2D(latitude: 51.51, longitude: -0.15)
    var currentSite : Sitio?
    @IBAction func distChanged(sender: AnyObject) {
        distField.text = "\(Int(stepper.value))";
        centerMapOnLocation(location!,kilometers: Int(stepper.value));
        
    }
    
    func searchingDataObjectByDistance() {
        
        Types.tryblock({ () -> Void in
            Global.sitios = []
            let queryOptions = QueryOptions()
            queryOptions.relationsDepth = 1;
            
            let dataQuery = BackendlessDataQuery()
            dataQuery.queryOptions = queryOptions;
            dataQuery.whereClause = "distance( \(self.location!.coordinate.latitude), \(self.location!.coordinate.longitude), coordinates.latitude, coordinates.longitude ) <= km(\(Int(self.stepper.value)))"
            
            let sitios = Global.backendless.persistenceService.find(Sitio.ofClass(),
                dataQuery:dataQuery) as BackendlessCollection
            
            for sitio in sitios.data as! [Sitio] {
                Global.sitios += [sitio]
            }
            
            },
                       catchblock: { (exception) -> Void in
                        print("searchingDataObjectByDistance (FAULT): \(exception as! Fault)")
        })
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mapOutlet.delegate = self
        distField.enabled = false;
        distField.text = "\(Int(stepper.value))";
        if authStatus == .NotDetermined {
            locationManager.requestWhenInUseAuthorization()
            return
        }
        if authStatus == .Denied || authStatus == .Restricted {
            let alert = UIAlertController(title: "Location Services Disabled", message: "Please enable location services for this app in Settings.", preferredStyle: .Alert)
            let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            alert.addAction(okAction)
            presentViewController(alert, animated: true, completion: nil)
            return
        }
        startLocationManager()
        // Do any additional setup after loading the view.
    }

    func startLocationManager() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
            isUpdatingLocation = true
        }
    }
    
    func stopLocationManager() {
        if isUpdatingLocation {
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            isUpdatingLocation = false
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        let newLocation = locations.last!
        print("didUpdateLocations \(newLocation)")
        if newLocation.timestamp.timeIntervalSinceNow < -5 {
            return
        }
        if newLocation.horizontalAccuracy < 0 {
            return
        }
        if location == nil || location!.horizontalAccuracy > newLocation.horizontalAccuracy {
            lastLocationError = nil
            location = newLocation
        }
        if newLocation.horizontalAccuracy <= locationManager.desiredAccuracy {
            print("Got the desired accuracy")
            mapOutlet.showsUserLocation = true;
            self.pinLocation = location!.coordinate;
            centerMapOnLocation(location!,kilometers: 1);
            stopLocationManager();
        }
    }
    
    
    func centerMapOnLocation(location: CLLocation, kilometers: Int) {
        let regionRadius: CLLocationDistance = 1000 * Double(kilometers);
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
                                                                  regionRadius * 2.0, regionRadius * 2.0)
        mapOutlet.setRegion(coordinateRegion, animated: true)
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("didFailWithError \(error)")
        if error.code == CLError.LocationUnknown.rawValue {
            return
        }
        lastLocationError = error
        stopLocationManager()
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is PinAnnotation {
            let pinAnnotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "myPin")
            pinAnnotationView.draggable = false
            pinAnnotationView.canShowCallout = true
            pinAnnotationView.animatesDrop = true
            
            let goButton = UIButton(type: UIButtonType.Custom)
            goButton.frame.size.width = 40
            goButton.frame.size.height = 40
            goButton.setImage(UIImage(named: "arrow"), forState: .Normal)
            
            pinAnnotationView.leftCalloutAccessoryView = goButton
            
            return pinAnnotationView
        }
        
        return nil
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, didChangeDragState newState: MKAnnotationViewDragState, fromOldState oldState: MKAnnotationViewDragState) {
        switch (newState) {
        case .Ending, .Canceling:
            
            if view.annotation is PinAnnotation {
                let coords = view.annotation?.coordinate;
                pinLocation = coords!;
                print("Latitude: \(coords?.latitude) Longitude: \(coords?.longitude)")
            }
            view.dragState = .None
        default: break
        }
    }
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if let annotation = view.annotation as? PinAnnotation {
            currentSite = Global.sitios[annotation.number!]
            self.performSegueWithIdentifier("SegueSitioGlobal", sender: self)

        }
    }
    
    //MARK:- update Not Get
    
    func mapView(mapView: MKMapView,
                 didFailToLocateUserWithError error: NSError)
    {
        // AppHelper.showALertWithTag(121, title: APP_NAME, message: "Failed to get location. Please check Location setting", delegate: nil, cancelButtonTitle: "Ok", otherButtonTitle: nil)
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let destinationVC = segue.destinationViewController as? SitioGlobalViewController{
            destinationVC.sitio = currentSite
            //destinationVC.delegate = self
            
        }
    }

}
