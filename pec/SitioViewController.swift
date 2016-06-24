//
//  SitiosViewController.swift
//  practica1
//
//  Created by Javier Arguello on 15/4/16.
//  Copyright © 2016 uoc. All rights reserved.
//

import UIKit

protocol SitioViewControllerDelegate: class {
    func modifiedSites()
}

class SitioViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UICollectionViewDataSource, UICollectionViewDelegate, PictureViewControllerDelegate{
    var sitio : Sitio?
    @IBOutlet weak var mapOutlet: MKMapView!
    @IBOutlet weak var descrtextView: UITextView!
    @IBOutlet weak var siteName: UITextField!
    weak var delegate: SitioViewControllerDelegate?
    @IBOutlet weak var collectionPics: UICollectionView!
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "NPictureSegue" {
            let viewController = segue.destinationViewController as? PictureViewController
            if let pictureViewController = viewController{
                
                pictureViewController.delegate = self
            }
            
        }
    }
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
    @IBAction func deleteSite(sender: AnyObject) {
        deleteSiteAsync()
        self.delegate?.modifiedSites()
        navigationController!.popViewControllerAnimated(true)
    }
    
    @IBAction func editSite(sender: AnyObject) {
        updateSite()
        self.delegate?.modifiedSites()
        navigationController!.popViewControllerAnimated(true)
    }
    @IBAction func updateSite() {
        
        sitio!.nombre = siteName.text!
        sitio!.descripcion = descrtextView.text!
        sitio?.coordinates = GeoPoint.geoPoint(
            GEO_POINT(latitude: pinLocation.latitude, longitude: pinLocation.longitude),
            categories: ["sitios"],
            metadata: ["sitio":sitio!.nombre!]
            ) as? GeoPoint
        var fotos: [Foto] = sitio!.fotos
        var i: Int = 0
        for image in tableImages{
            if(!existImage[i]){
                let foto : Foto = uploadAsync(image, name: sitio!.nombre!, index: i)
                fotos += [foto]
            }
            i=i+1
        }
        sitio!.fotos = fotos
        var error: Fault?
        let result = dataStore.save(sitio, fault: &error) as? Sitio
        if error == nil {
            print("Site has been updated")
        }
        else {
            print("Server reported an error: \(error)")
        }
       /* dataStore.save(
            sitio,
            response: { (result: AnyObject!) -> Void in
                print("Site has been updated")
            },
            error: { (fault: Fault!) -> Void in
                print("fServer reported an error: \(fault)")
        })*/
        
    }
    
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
    
    func uploadAsync(image: UIImage, name: String, index: Int) -> Foto{
        let foto : Foto = Foto()
        Types.tryblock({ () -> Void in
            let filename : String = name+"\(index)"+".jpg"
            let upload = Global.backendless.fileService.upload(
                filename, content: UIImageJPEGRepresentation(image, 0.8), overwrite:true)
            foto.image=upload.fileURL
            },
                       catchblock: { (exception) -> Void in
                        print("Server reported an error: \(exception as! Fault)")
        })
        return foto
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
    
    func deleteSiteAsync() {
        let dataStore = Global.backendless.data.of(Sitio.ofClass())
      /*  dataStore.remove(
            self.sitio,
            response: { (result: AnyObject!) -> Void in
                        print("Site has been deleted: \(result)")
                    },
                    error: { (fault: Fault!) -> Void in
                        print("Server reported an error (2): \(fault)")
                })*/
        var error: Fault?
        let result = dataStore.remove(self.sitio, fault: &error)
        if error == nil {
            print("Contact has been deleted: \(result)")
        }
        else {
            print("Server reported an error (2): \(error)")
        }
        
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
            
            pinAnnotationView.draggable = true
            pinAnnotationView.animatesDrop = true
            pinAnnotationView.canShowCallout = false
            
            return pinAnnotationView
        }
        
        return nil
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, didChangeDragState newState: MKAnnotationViewDragState, fromOldState oldState: MKAnnotationViewDragState) {
        switch (newState) {
        case .Ending, .Canceling:
            
            if view.annotation is MKPointAnnotation {
                let coords = view.annotation?.coordinate;
                pinLocation = coords!;
                print("Latitude: \(coords?.latitude) Longitude: \(coords?.longitude)")
            }
            view.dragState = .None
        default: break
        }
    }
    
    
    //MARK:- update Not Get
    
    func mapView(mapView: MKMapView,
                 didFailToLocateUserWithError error: NSError)
    {
        // AppHelper.showALertWithTag(121, title: APP_NAME, message: "Failed to get location. Please check Location setting", delegate: nil, cancelButtonTitle: "Ok", otherButtonTitle: nil)
        
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
