//
//  Item+CoreDataClass.swift
//  DreamLister
//
//  Created by Nick Birch on 2017-03-30.
//  Copyright © 2017 Nick Birch. All rights reserved.
//

import Foundation
import CoreData


public class Item: NSManagedObject {

    public override func awakeFromInsert() {
        
        super.awakeFromInsert()
        self.created = NSDate()
        
    }

}
