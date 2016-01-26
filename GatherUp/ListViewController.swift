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
    
    var database = Firebase(url: "https://dazzling-inferno-9963.firebaseio.com/event/")
    var numberOfEntries:UInt?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.dataSource = self
        tableView.delegate = self
        
        /*database.observeEventType(.Value, withBlock: { snapshot in
            if snapshot.value is NSNull {
                
            } else {
                let events = [snapshot.value]
                print(events)
            }
        })*/
        
        var count:UInt = 0
        // Retrieve new posts as they are added to the database
        database.observeEventType(.ChildAdded, withBlock: { snapshot in
            count++
            let events = snapshot.value as! NSObject
            print("added -> \(snapshot.value)")
        })
        // snapshot.childrenCount will always equal count since snapshot.value will include every FEventTypeChildAdded event
        // triggered before this point.
        database.observeEventType(.Value, withBlock: { snapshot in
            self.numberOfEntries = snapshot.childrenCount
            print(2)
            print("initial data loaded! \(count == snapshot.childrenCount)")
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reusableCell", forIndexPath: indexPath) as! TableViewCell
        
        
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
