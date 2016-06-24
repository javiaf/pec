//
//  MapaTableViewController.swift
//  pec
//
//  Created by Javier Arguello on 19/6/16.
//  Copyright © 2016 uoc. All rights reserved.
//

import UIKit

class MapaTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    
    // Data model: These strings will be the data for the table view cells
    // cell reuse id (cells that scroll out of view can be reused)
    let cellReuseIdentifier = "cell"
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "sitesHandler:", name: "SitesSearched", object: nil)
        // Register the table view cell class and its reuse id
        
        // This view controller itself will provide the delegate methods and row data for the table view.
        tableView.delegate = self
        tableView.dataSource = self
        // Do any additional setup after loading the view.
    }
    @IBOutlet weak var tableView: UITableView!
    func sitesHandler(notif: NSNotification) {
        print("MyNotification was handled")
        print(Global.sitios);
        print(Global.totalkms)
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
    /*func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        //
        return nil
    }*/
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
        
        return cell
    }
    
    // method to run when table view cell is tapped
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("You tapped cell number \(indexPath.row).")
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
