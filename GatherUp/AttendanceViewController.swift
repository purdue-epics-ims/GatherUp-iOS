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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
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
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onPressRegister(sender: UIButton!) {
        if let fName = firstNameText.text where fName != "", let lName = lastNameText.text where lName != "", let email = emailText.text where email != "" {
            
            let name = fName + " " + lName
            
            postToFirebase(name, email: email)
            
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
        
            UIView.animateWithDuration(1.0, animations: {
                self.view.backgroundColor = UIColor.greenColor()
            })
            
            UIView.animateWithDuration(1.0, animations: {
                self.view.backgroundColor = UIColor.whiteColor()
            })
            
            print("Card Data: \(parsedData)")
            
            postToFirebase(parsedData)
            
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
        let action = UIAlertAction(title: "Ok", style: .Default, handler: nil)
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func postToFirebase(name: String, email: String) {
        var newAttendee: Dictionary<String,AnyObject> = [
            "name": name,
            "email": email
        ]
        
        let selectedEvent = NSUserDefaults.standardUserDefaults().valueForKey("selectedEvent") as! String
        let database = Firebase(url: "https://dazzling-inferno-9963.firebaseio.com/event/"+selectedEvent+"/attendees").childByAutoId()
        
        database.setValue(newAttendee)
    }
    
    func postToFirebase(puid: String) {
        var newAttendee: Dictionary<String,AnyObject> = [
            "puid": puid
        ]
        
        let selectedEvent = NSUserDefaults.standardUserDefaults().valueForKey("selectedEvent") as! String
        let database = Firebase(url: "https://dazzling-inferno-9963.firebaseio.com/event/"+selectedEvent+"/attendees").childByAutoId()
        
        database.setValue(newAttendee)
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
