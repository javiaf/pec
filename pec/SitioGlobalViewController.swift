//
//  SitioGlobalViewController.swift
//  pec
//
//  Created by Javier Arguello on 23/6/16.
//  Copyright © 2016 uoc. All rights reserved.
//

import UIKit

class SitioGlobalViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UIPopoverPresentationControllerDelegate, PopOverViewControllerDelegate{
    var sitio : Sitio?
    @IBOutlet weak var mapOutlet: MKMapView!
    @IBOutlet weak var descrtextView: UITextView!
    @IBOutlet weak var siteName: UITextField!
    weak var delegate: SitioViewControllerDelegate?
    @IBOutlet weak var collectionPics: UICollectionView!
    @IBAction func puntuar(sender: AnyObject) {
        
    }
    @IBOutlet weak var valoracionTF: UITextField!
    let locationManager = CLLocationManager()
    var tableImages: [UIImage] = []
    var existImage: [Bool] = []
    let authStatus = CLLocationManager.authorizationStatus()
    var isUpdatingLocation = false
    var lastLocationError: NSError?
    var location: CLLocation?
    var pinLocation = CLLocationCoordinate2D(latitude: 51.51, longitude: -0.15)
    var annotationPoint: MKPointAnnotation!
    let dataStore = Global.backendless.data.of(Sitio.ofClass());
    
    @IBOutlet weak var puntuarBtn: UIBarButtonItem!
    func loadPictures()
    {
        if(sitio!.fotos.count != 0)
        {
            for foto in sitio!.fotos{
                if let imageUrl = foto.image{
                    let url = NSURL(string: imageUrl)
                    let data = NSData(contentsOfURL:url!)
                    if (data != nil) {
                        tableImages += [UIImage(data:data!)!];
                        existImage += [true]
                    }
                }
            }
        }
    }

    func getValoracionMedia() -> Float{
        var valoracion: Float = 0.0;
        let totalValoraciones = sitio!.valoraciones.count
        if (totalValoraciones > 0) {
            for valo in (sitio?.valoraciones)!
            {
                valoracion += valo.valoracion
            }
            valoracion = valoracion/Float(totalValoraciones)
        }
        return valoracion
    }
    func isOwner() -> Bool{
        if self.sitio?.ownerId == Global.backendless.userService.currentUser.objectId{
            return true
        }
        return false
    }
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        loadPictures()
        return tableImages.count
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell: vwCell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! vwCell;
        cell.image.image = tableImages[indexPath.row]
        return cell
    }
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let myImageViewPage:ImageViewController = self.storyboard?.instantiateViewControllerWithIdentifier("ImageViewController") as! ImageViewController;
        myImageViewPage.selectedImage = self.tableImages[indexPath.row];
        self.navigationController?.pushViewController(myImageViewPage, animated: true)
    }
    func returnImage(image: UIImage){
        let index = NSIndexPath(forRow: tableImages.count,inSection: 0);
        let array: [NSIndexPath] = [index]
        tableImages += [image];
        existImage += [false];
        self.collectionPics.performBatchUpdates({
            self.collectionPics.insertItemsAtIndexPaths(array);
            }, completion: nil);
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if isOwner(){
            puntuarBtn.enabled = false
        }
        descrtextView.editable=false
        siteName.enabled = false
        valoracionTF.enabled = false
        valoracionTF.text = "\(getValoracionMedia())"
        self.mapOutlet.delegate = self
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
        siteName.text = self.sitio!.nombre!
        descrtextView.text = self.sitio!.descripcion!
        //let latitude : Double = self.sitio!.latitude
        // let longitude : Double = self.sitio!.longitude
        let latitude = Double((self.sitio!.coordinates?.latitude)!)
        let longitude = Double((self.sitio!.coordinates?.longitude)!)
        
        pinLocation = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        if(self.annotationPoint == nil)
        {
            self.annotationPoint = MKPointAnnotation()
            self.annotationPoint.title = self.sitio!.nombre!
            self.annotationPoint.subtitle = self.sitio!.nombre!
            self.annotationPoint.coordinate = pinLocation
            self.mapOutlet.addAnnotation(self.annotationPoint)
            centerMapOnLocation(pinLocation);
        }
        //  mapOutlet.addAnnotation(annotation);
        // loadPictures()
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
            // let annotation = MyAnnotation(title: "New Site", locationName:"New Site Name", discipline:"New Discipline",coordinate: location!.coordinate);
            stopLocationManager();
        }
    }
    
    
    func centerMapOnLocation(location: CLLocationCoordinate2D) {
        let regionRadius: CLLocationDistance = 1000
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(pinLocation,
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
    
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView?
    {
        if annotation is MKPointAnnotation {
            let pinAnnotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "myPin")
            
            pinAnnotationView.draggable = false
            pinAnnotationView.animatesDrop = true
            pinAnnotationView.canShowCallout = false
            
            return pinAnnotationView
        }
        
        return nil
    }
    
    func refreshValoracion() {
        valoracionTF.text = "\(getValoracionMedia())"
    }
    
    //MARK:- update Not Get
    
    func mapView(mapView: MKMapView,
                 didFailToLocateUserWithError error: NSError)
    {
        // AppHelper.showALertWithTag(121, title: APP_NAME, message: "Failed to get location. Please check Location setting", delegate: nil, cancelButtonTitle: "Ok", otherButtonTitle: nil)
        
    }
    
    
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "popoverSegue" {
            let popoverViewController = segue.destinationViewController as! PopOverViewController
            popoverViewController.modalPresentationStyle = UIModalPresentationStyle.Popover
            popoverViewController.popoverPresentationController!.delegate = self
            popoverViewController.sitio = self.sitio
            popoverViewController.delegate = self
        }
    }
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.None
    }
    
    
}