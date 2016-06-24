//
//  NewSiteViewController.swift
//  practica2
//
//  Created by Javier Arguello on 17/5/16.
//  Copyright © 2016 uoc. All rights reserved.
//

import UIKit

protocol NewSiteViewControllerDelegate: class {
    func reloadSites(sitio: Sitio)
}

class NewSiteViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UICollectionViewDataSource, UICollectionViewDelegate, PictureViewControllerDelegate{
    weak var delegate: NewSiteViewControllerDelegate?
    @IBOutlet weak var imageTest: UIImageView!
    @IBOutlet weak var mapOutlet: MKMapView!
    @IBOutlet weak var descrtextView: UITextView!
    @IBOutlet weak var siteName: UITextField!
 private var indicador: UIActivityIndicatorView = UIActivityIndicatorView()
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
    let authStatus = CLLocationManager.authorizationStatus()
    var isUpdatingLocation = false
    var lastLocationError: NSError?
    var location: CLLocation?
    var pinLocation = CLLocationCoordinate2D(latitude: 51.51, longitude: -0.15)
    var annotationPoint: MKPointAnnotation!
    let dataStore = Global.backendless.data.of(Sitio.ofClass());
    
    @IBAction func addSite(sender: UIButton) {
        self.indicador.startAnimating()
        
        let sitio = Sitio();
        sitio.nombre = siteName.text!
        sitio.descripcion = descrtextView.text!
       /* sitio.latitude = pinLocation.latitude
        sitio.longitude = pinLocation.longitude*/
        sitio.coordinates = GeoPoint.geoPoint(
            GEO_POINT(latitude: pinLocation.latitude, longitude: pinLocation.longitude),
            categories: ["sitios"],
            metadata: ["sitio":sitio.nombre!]
            ) as? GeoPoint
        var fotos: [Foto] = []
        var i: Int = 0
        for image in tableImages{
            let foto : Foto = uploadAsync(image, name: sitio.nombre!, index: i)
            if (foto.image != "error"){
                fotos += [foto]
                i=i+1
            }
        }
        sitio.fotos = fotos
        dataStore.save(
            sitio,
            response: { (result: AnyObject!) -> Void in
                print("Site has been saved")
                //self.showAlert("Sitio guardado", message: "Sitio guardado correctamente")
              
            },
            error: { (fault: Fault!) -> Void in
                print("fServer reported an error: \(fault)")
                self.showAlert("Error guardado", message: "fServer reported an error: \(fault)")
        })
        
        self.delegate?.reloadSites(sitio)
        self.indicador.stopAnimating()
        self.navigationController!.popViewControllerAnimated(true)
       // navigationController!.popViewControllerAnimated(true)
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
                        self.showAlert("Error imagen", message: "Server reported an error: \(exception as! Fault)")
                        foto.image = "error"
        })
        return foto
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
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
        self.collectionPics.performBatchUpdates({
            self.collectionPics.insertItemsAtIndexPaths(array);
            }, completion: nil);
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.indicador.center = self.view.center
        self.indicador.autoresizingMask = [.FlexibleBottomMargin, .FlexibleLeftMargin, .FlexibleWidth, .FlexibleRightMargin, .FlexibleTopMargin, .FlexibleHeight, .FlexibleBottomMargin]
        self.indicador.hidesWhenStopped = true
        self.indicador.activityIndicatorViewStyle = .WhiteLarge
        self.indicador.color = UIColor.clearColor()
        self.view.addSubview(self.indicador)
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
            if(self.annotationPoint == nil)
            {
                self.annotationPoint = MKPointAnnotation()
                self.annotationPoint.title = "New Site"
                self.annotationPoint.subtitle = "New Site"
                self.annotationPoint.coordinate = location!.coordinate
                self.mapOutlet.addAnnotation(self.annotationPoint)
                
            }
            self.pinLocation = location!.coordinate
          //  mapOutlet.addAnnotation(annotation);
            centerMapOnLocation(location!);
            stopLocationManager();
        }
    }
    

    func centerMapOnLocation(location: CLLocation) {
        let regionRadius: CLLocationDistance = 1000
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
    
    func showAlert(title: String,message: String) {
        let alertController = UIAlertController(title: title, message:
            message, preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "Aceptar", style: UIAlertActionStyle.Default,handler: nil))
        
        self.presentViewController(alertController, animated: true, completion: nil)
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

