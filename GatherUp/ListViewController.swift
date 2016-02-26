//
//  ListViewController.swift
//  GatherUp
//
//  Created by Nikhil Nandkumar on 1/24/16.
//  Copyright © 2016 Nikhil Nandkumar. All rights reserved.
//

import UIKit
import Firebase

class ListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    @IBOutlet weak var tableView: UITableView!
    var events = [databaseEntries]()
    
    var database = Firebase(url: "https://dazzling-inferno-9963.firebaseio.com/event")
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.dataSource = self
        tableView.delegate = self
        
        // Retrieve new posts as they are added to the database
        database.observeEventType(.Value, withBlock: { snapshot in
            if let snapshots = snapshot.children.allObjects as? [FDataSnapshot] {
                self.events = []
                for snap in snapshots {
                    if let eventDict = snap.value as? Dictionary<String, AnyObject> {
                        let key = snap.key
                        let event = databaseEntries(eventKey: key, dict: eventDict)
                        self.events.append(event)
                    }
                }
            }
            self.tableView.reloadData()
        })
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reusableCell", forIndexPath: indexPath) as! TableViewCell
        
        cell.titleLabel.text = self.events[indexPath.row].name
        cell.descriptionLabel.text = self.events[indexPath.row].description
        
        return cell
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
