//
//  MapaTableViewController.swift
//  pec
//
//  Created by Javier Arguello on 19/6/16.
//  Copyright © 2016 uoc. All rights reserved.
//

import UIKit

class MapaTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate {

    
    // Data model: These strings will be the data for the table view cells
    // cell reuse id (cells that scroll out of view can be reused)
    var rowNo : Int = 0;
    let locationManager = CLLocationManager()
    var isUpdatingLocation = false
    var lastLocationError: NSError?
    let authStatus = CLLocationManager.authorizationStatus()
    var location: CLLocation?
    override func viewDidLoad() {
        super.viewDidLoad()
        distanciaTF.text = "\(Global.totalkms)"
        distStep.value = Double(Global.totalkms)
        distanciaTF.enabled = false;
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "sitesHandler:", name: "SitesSearched", object: nil)
        // Register the table view cell class and its reuse id
        
        // This view controller itself will provide the delegate methods and row data for the table view.
        tableView.delegate = self
        tableView.dataSource = self
        startLocationManager()
        // Do any additional setup after loading the view.
    }
    @IBOutlet weak var distanciaTF: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var distStep: UIStepper!
    @IBAction func distChanged(sender: AnyObject) {
        distanciaTF.text = "\(Int(distStep.value))"
        Global.totalkms = Int(distStep.value)

    }
    
    @IBAction func buscaSitios(sender: AnyObject) {
        searchingDataObjectByDistance();
        tableView.reloadData()
        NSNotificationCenter.defaultCenter().postNotificationName("SitesTSearched", object: nil);
    }

    func searchingDataObjectByDistance() {
        
        Types.tryblock({ () -> Void in
            Global.sitios = []
            let queryOptions = QueryOptions()
            queryOptions.relationsDepth = 1;
            
            let dataQuery = BackendlessDataQuery()
            dataQuery.queryOptions = queryOptions;
            dataQuery.whereClause = "distance( \(self.location!.coordinate.latitude), \(self.location!.coordinate.longitude), coordinates.latitude, coordinates.longitude ) <= km(\(Int(self.distStep.value)))"
            
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
    func sitesHandler(notif: NSNotification) {
        distStep.value = Double(Global.totalkms)
        distanciaTF.text = "\(Global.totalkms)"
        self.tableView.reloadData()
    }
    // number of rows in table view
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Global.sitios.count
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Listado de Sitios"
    }
    // create a cell for each table view row
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "subtitleCell")
        cell.textLabel?.text = "\(Global.sitios[indexPath.row].nombre!)"
        cell.detailTextLabel?.text = "\(Global.sitios[indexPath.row].descripcion!)"
        if(Global.sitios[indexPath.row].fotos.count != 0)
        {
            if let imageUrl = Global.sitios[indexPath.row].fotos[0].image{
                print(imageUrl)
                let url = NSURL(string: imageUrl)
                let data = NSData(contentsOfURL:url!)
                if (data != nil) {
                    cell.imageView?.image = UIImage(data:data!)
                    
                }
            }
        }
        return cell
        
    }
    
    // method to run when table view cell is tapped
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        rowNo = indexPath.row;
        self.performSegueWithIdentifier("GoToSite", sender: self)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

        if let destinationVC = segue.destinationViewController as? SitioGlobalViewController{
            let sitio = Global.sitios[rowNo]
            destinationVC.sitio = sitio

        }
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
            stopLocationManager();
        }
    }
    
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("didFailWithError \(error)")
        if error.code == CLError.LocationUnknown.rawValue {
            return
        }
        lastLocationError = error
        stopLocationManager()
    }

}
