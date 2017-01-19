//
//  SearchHistory.swift
//  Fetch
//
//  Created by Stephen Radford on 08/08/2015.
//  Copyright (c) 2015 Cocoon Development Ltd. All rights reserved.
//

import UIKit
import RealmSwift

public class SearchHistory: Object {
    
    public dynamic var term: String = ""
    public dynamic var updatedAt: Float64 = 0
    
    override public static func primaryKey() -> String? {
        return "term"
    }
    
}