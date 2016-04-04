//
//  AttendanceViewController.swift
//  GatherUp
//
//  Created by Nikhil Nandkumar on 2/23/16.
//  Copyright © 2016 Nikhil Nandkumar. All rights reserved.
//

import UIKit
import AVFoundation
import AudioToolbox
import MediaPlayer
import Firebase

class AttendanceViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var firstNameText: UITextField!
    @IBOutlet weak var lastNameText: UITextField!
    @IBOutlet weak var emailText: UITextField!
    
    
    private var uniMagObject: uniMag!
    
    var uniMagViewController: UniMagViewController = UniMagViewController()
    
    var eventAttendees = [attendees]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        //self.title = NSUserDefaults.standardUserDefaults().valueForKey("selectedEventName") as! String
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "uniMagConnected:", name: uniMagDidConnectNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "swipeReceived:", name: uniMagDidReceiveDataNotification, object: nil)
        
        uniMagViewController.umsdk_activate()
        uniMagViewController.connectReader()
        
        uniMag.enableLogging(true)
        self.uniMagObject = uniMag()
        
        uniMagObject.setAutoConnect(false)
        
        uniMagObject.setSwipeTimeoutDuration(0)
        
        uniMagObject.setAutoAdjustVolume(true)
        
        self.firstNameText.delegate = self
        self.lastNameText.delegate = self
        self.emailText.delegate = self
        
        let selectedEvent = NSUserDefaults.standardUserDefaults().valueForKey("selectedEvent") as! String
        
        let database = Firebase(url: "https://dazzling-inferno-9963.firebaseio.com/event/"+selectedEvent+"/attendees")
        
        database.observeEventType(.Value, withBlock: { snapshot in
            if let snapshots = snapshot.children.allObjects as? [FDataSnapshot] {
                self.eventAttendees = []
                for snap in snapshots {
                    if let attendeesDict = snap.value as? Dictionary<String, AnyObject> {
                        let attendee = attendees(dict: attendeesDict)
                        self.eventAttendees.append(attendee)
                    }
                }
            }
        })
        
        self.navigationItem.hidesBackButton = true
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .Plain, target: self, action: "goToList:")
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onPressRegister(sender: UIButton!) {
        if let fName = firstNameText.text where fName != "", let lName = lastNameText.text where lName != "", let email = emailText.text where email != "" {
            
            var exists = 0;
            
            for attendee in eventAttendees {
                if (lName == attendee.lastName && fName == attendee.firstName && email == attendee.email) {
                    
                    UIView.animateWithDuration(1.0, animations: {
                        self.view.backgroundColor = UIColor.yellowColor()
                    })
                    
                    UIView.animateWithDuration(1.0, animations: {
                        self.view.backgroundColor = UIColor.whiteColor()
                    })
                    
                    exists = 1
                }
            }
            
            if exists == 0 {
                self.showAlert("Registered!", msg: "You have successfully registered for the event!")
                postToFirebase(lastName: lName, firstName: fName, email: email)
            }
            
            else {
                self.showAlert("Unsuccessful!", msg: "You have already registered for the event!")
            }
            
            firstNameText.text = ""
            lastNameText.text = ""
            emailText.text = ""
            
        } else {
            self.showAlert("Required Text Fields Empty", msg: "Please fill in your first name, last name and email ID to register")
        }
    }
    
    @IBAction func onScreenTap(sender: UITapGestureRecognizer!) {
        self.firstNameText.resignFirstResponder()
        self.lastNameText.resignFirstResponder()
        self.emailText.resignFirstResponder()
    }
    
    func uniMagConnected(notification: NSNotification) {
        self.showAlert("Swiper Connected", msg: "You may begin swiping Purdue IDs")
        uniMagViewController.swipeCard()
    }
    
    func swipeReceived(notification: NSNotification) {
        let data = notification.object as! NSData
        // parse and do stuff with the swipe information
        
        var parsedData = NSString(data:data, encoding:NSUTF8StringEncoding) as! String
        //Parsed Data = ;000000000=2229=0028437472=02?
        
        //Get valid PUID digits
        
        var range = parsedData.startIndex..<parsedData.startIndex.advancedBy(16)
        parsedData.removeRange(range)
        
        range = parsedData.startIndex.advancedBy(10)..<parsedData.endIndex
        parsedData.removeRange(range)
        
        var checker = Int(parsedData)
        
        var luhn:Int = 0
        
        for tempChar in parsedData.unicodeScalars {
            if (tempChar.value < 48 || tempChar.value > 57) {
                luhn = 1
            }
        }
        
        var factor:Int = 1
        
        while checker > 0 {
            var addendum:Int = (checker! % 10) * factor
            
            if addendum >= 10 {
                var modifiedAddendum:Int = 0
                
                while addendum > 0 {
                    modifiedAddendum = modifiedAddendum + addendum % 10
                    addendum = Int(addendum / 10)
                }
                
                addendum = modifiedAddendum
            }
            
            luhn = luhn + addendum
            
            factor = factor + 1
            checker = Int(checker! / 10)
        }
        
        luhn = luhn % 10
        
        if luhn == 0 {
            
            var exists = 0;
            
            for attendee in eventAttendees {
                if parsedData == attendee.puid {
                    
                    UIView.animateWithDuration(1.0, animations: {
                        self.view.backgroundColor = UIColor.yellowColor()
                    })
                    
                    UIView.animateWithDuration(1.0, animations: {
                        self.view.backgroundColor = UIColor.whiteColor()
                    })
                    
                    exists = 1
                }
            }
            
            if exists == 0 {
            
                UIView.animateWithDuration(1.0, animations: {
                    self.view.backgroundColor = UIColor.greenColor()
                })
                
                UIView.animateWithDuration(1.0, animations: {
                    self.view.backgroundColor = UIColor.whiteColor()
                })
                
                print("Card Data: \(parsedData)")
                
                postToFirebase(puid: parsedData)
                    
            }
            
        }
        
        else {
            
            UIView.animateWithDuration(1.0, animations: {
                self.view.backgroundColor = UIColor.redColor()
            })
            
            UIView.animateWithDuration(1.0, animations: {
                self.view.backgroundColor = UIColor.whiteColor()
            })
        }
        
        uniMagViewController.swipeCard()
    }
    
    func showAlert(title: String, msg: String) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .Alert)
        let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func postToFirebase(puid puid: String = "", lastName: String = "", firstName:String = "", email: String = "") {
        let newAttendee: Dictionary<String,AnyObject> = [
            "puid": puid,
            "lastname": lastName,
            "firstname": firstName,
            "email": email
        ]
        
        let selectedEvent = NSUserDefaults.standardUserDefaults().valueForKey("selectedEvent") as! String
        
        let database = Firebase(url: "https://dazzling-inferno-9963.firebaseio.com/event/"+selectedEvent+"/attendees")
        
        database.childByAutoId().setValue(newAttendee)
    }
    
    func goToList(sender: UIBarButtonItem){
        self.navigationController?.popViewControllerAnimated(true)
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
