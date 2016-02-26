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

class AttendanceViewController: UIViewController {
    
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
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onClickSwipe (sender: UIButton!) {
        
    }
    
    func uniMagConnected(notification: NSNotification) {
        uniMagViewController.swipeCard()
    }
    
    func swipeReceived(notification: NSNotification) {
        var data = notification.object as! NSData
        // parse and do stuff with the swipe information
        print("Card Data: \(data)")
        uniMagViewController.swipeCard()
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
