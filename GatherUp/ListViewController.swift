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
        
        // Retrieve events after current date as they are added to the database
        
        let currentDate = Date()
        
        database?.queryOrdered(byChild: "dateID").observe(.value, with: { snapshot in
            if let snapshots = snapshot?.children.allObjects as? [FDataSnapshot] {
                self.events = []
                for snap in snapshots {
                    if let eventDict = snap.value as? Dictionary<String, AnyObject> {
                        let key = snap.key
                        let event = databaseEntries(eventKey: key!, dict: eventDict)
                        
                        let eventDate = Date(timeIntervalSince1970: event.dateID)
                        
                        let timeInterval = eventDate.timeIntervalSince(currentDate) + 259200
                        
                        if timeInterval >= 0 {
                            self.events.append(event)
                        }
                    }
                }
            }
            self.tableView.reloadData()
        })
        
        self.navigationItem.hidesBackButton = true
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(ListViewController.logout(_:)))
        
        let infoButton = UIButton(type: .infoLight)
        infoButton.addTarget(self, action: #selector(ListViewController.aboutPage(_:)), for: .touchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: infoButton)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reusableCell", for: indexPath) as! TableViewCell
        
        cell.titleLabel.text = self.events[indexPath.row].name
        cell.descriptionLabel.text = self.events[indexPath.row].description
        
        let eventDate = Date(timeIntervalSince1970: self.events[indexPath.row].dateID)
        
        let dateFormatter = DateFormatter()
        
        let theDateFormat = DateFormatter.Style.short
        let theTimeFormat = DateFormatter.Style.short
        
        dateFormatter.dateStyle = theDateFormat
        dateFormatter.timeStyle = theTimeFormat
        
        cell.dateLabel.text = dateFormatter.string(from: eventDate)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        UserDefaults.standard.setValue(self.events[indexPath.row].key, forKey: "selectedEvent")
        print("THE KEY IS \(self.events[indexPath.row].key)")
        UserDefaults.standard.setValue(self.events[indexPath.row].name, forKey: "selectedEventName")
    }
    
    func aboutPage(_ sender: UIButton) {
        self.performSegue(withIdentifier: "toSettingsPage", sender: self)
    }
    
    func logout(_ sender: UIBarButtonItem) {
        UserDefaults.standard.setValue(nil, forKey: "accountUID")
        self.navigationController?.popViewController(animated: true)
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
