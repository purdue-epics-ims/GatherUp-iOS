//
//  databaseEntries.swift
//  GatherUp
//
//  Created by Nikhil Nandkumar on 2/6/16.
//  Copyright © 2016 Nikhil Nandkumar. All rights reserved.
//

import Foundation

class databaseEntries {
    fileprivate var _name: String!
    fileprivate var _description: String!
    fileprivate var _dateID: TimeInterval!
    fileprivate var _attendees: [attendees]?
    fileprivate var _eventKey: String!
    
    var name:String! {
        return _name
    }
    
    var description:String! {
        return _description
    }
    
    var key:String! {
        return _eventKey
    }
    
    var dateID:TimeInterval! {
        return _dateID
    }
    
    init(name:String, description:String) {
        self._name = name
        self._description = description
    }
    
    init(eventKey:String, dict:Dictionary<String, AnyObject>) {
        self._eventKey = eventKey
        if let name = dict["name"] as? String {
            self._name = name
        }
        if let description = dict["description"] as? String {
            self._description = description
        }
        if let dateID = dict["dateID"] as? TimeInterval {
            self._dateID = dateID
        }
    }
    
    init(attend:attendees) {
        self._attendees?.append(attend)
    }

}
