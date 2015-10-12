//
//  Budget.swift
//  BeGoodToYourself
//
//  Created by George Potosky on 10/11/15.
//  Copyright (c) 2015 GeoWorld. All rights reserved.
//

import UIKit
import CoreData

@objc(Budget)


class Budget : NSManagedObject {
    
    @NSManaged var itemBudgetText: String?
    @NSManaged var priceBudgetText: String?
    @NSManaged var events: Events?
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(itemBudgetText: String?, priceBudgetText: String?, context: NSManagedObjectContext) {
        
        let entity =  NSEntityDescription.entityForName("Budget", inManagedObjectContext: context)!
        super.init(entity: entity,insertIntoManagedObjectContext: context)
        
        self.itemBudgetText = itemBudgetText
        self.priceBudgetText = priceBudgetText
        
    }
    
}
