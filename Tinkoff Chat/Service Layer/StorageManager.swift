//
//  StorageManager.swift
//  Tinkoff Chat
//
//  Created by Mikhail Gilmutdinov on 02.05.17.
//  Copyright © 2017 Mikhail Gilmutdinov. All rights reserved.
//

import Foundation

class StorageManager {
    private var coreDataStack = CoreDataStack()
    
    public func getAppUser() -> AppUser? {
        return AppUser.findOrInsertAppUser(in: coreDataStack.masterContext!)
    }
    
    public func save() {
        coreDataStack.performSave(context: coreDataStack.masterContext!, completionHandler: nil)
    }
}
