//
//  TodoList.swift
//  BeGoodToYourself
//
//  Created by George Potosky on 10/1/15.
//  Copyright (c) 2015 GeoWorld. All rights reserved.
//


import UIKit
import CoreData

@objc(TodoList)


class TodoList : NSManagedObject {
    
    @NSManaged var todoListText: String?
    @NSManaged var events: Events?
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(todoListText: String?, context: NSManagedObjectContext) {
        
        let entity =  NSEntityDescription.entityForName("TodoList", inManagedObjectContext: context)!
        super.init(entity: entity,insertIntoManagedObjectContext: context)
        
        self.todoListText = todoListText
        
    }
    
}
