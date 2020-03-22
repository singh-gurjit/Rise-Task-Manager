//
//  Tasks.swift
//  DailyTask
//
//  Created by Gurjit Singh on 19/03/20.
//  Copyright © 2020 Gurjit Singh. All rights reserved.
//

import Foundation
import CoreData

public class Tasks:NSManagedObject, Identifiable{
    @NSManaged public var date:Date?
    
}
