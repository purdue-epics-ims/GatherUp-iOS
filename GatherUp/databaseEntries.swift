//
//  databaseEntries.swift
//  GatherUp
//
//  Created by Nikhil Nandkumar on 2/6/16.
//  Copyright © 2016 Nikhil Nandkumar. All rights reserved.
//

import Foundation

class databaseEntries {
    private var _name: String!
    private var _description: String!
    private var _attendees: [attendees]?
    private var _eventKey: String!
    
    var name:String {
        return _name
    }
    
    var description:String {
        return _description
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
    }
    
    init(attend:attendees) {
        self._attendees?.append(attend)
    }

}
