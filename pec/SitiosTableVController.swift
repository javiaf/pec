//
//  SitiosTableVController.swift
//  practica2
//
//  Created by Javier Arguello on 28/5/16.
//  Copyright © 2016 uoc. All rights reserved.
//

import UIKit

class SitiosTableVController: UITableViewController, NewSiteViewControllerDelegate, SitioViewControllerDelegate {
    var rowNo : Int = 0;
        private var indicador: UIActivityIndicatorView = UIActivityIndicatorView()
    var sitiosList : [Sitio] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "subtitleCell")
        self.indicador.center = self.view.center
        self.indicador.autoresizingMask = [.FlexibleBottomMargin, .FlexibleLeftMargin, .FlexibleWidth, .FlexibleRightMargin, .FlexibleTopMargin, .FlexibleHeight, .FlexibleBottomMargin]
        self.indicador.hidesWhenStopped = true
        self.indicador.activityIndicatorViewStyle = .WhiteLarge
        self.indicador.color = UIColor.blueColor()
        self.view.addSubview(self.indicador)
       loadSitios()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    func reloadSites(sitio: Sitio){
        self.sitiosList += [sitio]
        self.tableView.reloadData()
    }
    
    func modifiedSites(){
        loadSitios()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
 
        return self.sitiosList.count
    }
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Listado de Sitios"
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //let cell = tableView.dequeueReusableCellWithIdentifier("TableCell", forIndexPath: indexPath)
   let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "subtitleCell")
        cell.textLabel?.text = "\(self.sitiosList[indexPath.row].nombre!)"
        cell.detailTextLabel?.text = "\(self.sitiosList[indexPath.row].descripcion!)"

        if(self.sitiosList[indexPath.row].fotos.count != 0)
        {
            if let imageUrl = self.sitiosList[indexPath.row].fotos[0].image{
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        // loadSitios()
        if let destinationVC = segue.destinationViewController as? SitioViewController{
            let sitio = self.sitiosList[rowNo]
            destinationVC.sitio = sitio
            destinationVC.delegate = self
            
        }
        if let destinationVC = segue.destinationViewController as? NewSiteViewController{
            destinationVC.delegate = self
        }
        
    }
    

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        rowNo = indexPath.row;
        self.performSegueWithIdentifier("GoToSite", sender: self)
    }
    func loadSitios()
    {
        self.sitiosList = []
        let dataStore = Global.backendless.data.of(Sitio.ofClass())
        var error: Fault?
        let result = dataStore.findFault(&error)
        if error == nil {
            let sitios = result.getCurrentPage()
            for obj in sitios {
                //let dictSitio : NSDictionary = obj as! NSDictionary
               /* let sitio: Sitio = Sitio()
                sitio.objectId = dictSitio["objectId"] as! String
                sitio.nombre = dictSitio["nombre"] as! String
                sitio.descripcion = dictSitio["descripcion"] as! String
                sitio.longitude = dictSitio["longitude"] as! Double
                sitio.latitude = dictSitio["latitude"] as! Double
                sitio.fotos = []
                let fotosDict = dictSitio["fotos"] as! [NSDictionary]
                for f in fotosDict{
                    
                    if let fotoUrl = f["image"]{
                        let foto : Foto = Foto()
                        foto.objectId = f["objectId"] as! String
                        foto.image = fotoUrl as! String
                 
                        sitio.fotos += [foto]
                    }
                }*/
                let sitio = obj as! Sitio
                if sitio.ownerId == Global.backendless.userService.currentUser.objectId{
                    self.sitiosList += [obj as! Sitio]
                    print("\(obj)")
                }
                
            }
            self.tableView.reloadData()
            self.indicador.stopAnimating()
        }
        else {
            print("Server reported an error: \(error)")
        }
       /* dataStore.find(
            
            { (result: BackendlessCollection!) -> Void in
                self.indicador.startAnimating()
                let sitios = result.getCurrentPage()
                User.sitiosList = []
                for obj in sitios {
                    let dictSitio : NSDictionary = obj as! NSDictionary
                    let sitio: Sitio = Sitio()
                    sitio.objectId = dictSitio["objectId"] as! String
                    sitio.nombre = dictSitio["nombre"] as! String
                    sitio.descripcion = dictSitio["descripcion"] as! String
                    sitio.longitude = dictSitio["longitude"] as! Double
                    sitio.latitude = dictSitio["latitude"] as! Double
                    sitio.fotos = []
                    let fotosDict = dictSitio["fotos"] as! [NSDictionary]
                    for f in fotosDict{
                        
                        if let fotoUrl = f["image"]{
                            let foto : Foto = Foto()
                            foto.objectId = f["objectId"] as! String
                            foto.image = fotoUrl as! String
                            
                            sitio.fotos += [foto]
                        }
                    }
                    User.sitiosList += [sitio]
                    print("\(obj)")
                }
                self.tableView.reloadData()
                self.indicador.stopAnimating()
            },
            error: { (fault: Fault!) -> Void in
                print("Server reported an error: \(fault)")
        })
        self.tableView.reloadData()*/
    }
    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}