//
//  DataManager.swift
//  Tinkoff Chat
//
//  Created by Mikhail Gilmutdinov on 04.04.17.
//  Copyright © 2017 Mikhail Gilmutdinov. All rights reserved.
//

import Foundation

protocol DataManager {
    func save(data: [String:Any], toFile fileName: String, completion: ((Bool) -> Void)? )
}

class GCDDataManager: DataManager {
    func save(data: [String:Any], toFile fileName: String, completion: ((Bool) -> Void)? ) {
        let globalQueue = DispatchQueue.global(qos: .userInitiated)
        globalQueue.async {
            var path = ""
            do {
                try path = FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("data.dat").path
            } catch {
                DispatchQueue.main.async { completion?(false) }
                return
            }
            let saved = NSKeyedArchiver.archiveRootObject(data, toFile: path)
            DispatchQueue.main.async { completion?(saved) }
        }
    }
    func load(fromFile fileName: String, completion: @escaping (([String:Any]?) -> Void)) {
        let globalQueue = DispatchQueue.global(qos: .userInitiated)
        globalQueue.async {
            var path = ""
            do {
                try path = FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("data.dat").path
            } catch {
                DispatchQueue.main.async { completion(nil) }
                return
            }
            DispatchQueue.main.async {
                completion(NSKeyedUnarchiver.unarchiveObject(withFile: path) as? [String:Any])
            }
        }
    }
}

class SaveOperation: Operation {
    private var data: [String:Any]
    private var fileName: String
    private var completion: ((Bool) -> Void)?
    init(data: [String:Any], fileName: String, completion: ((Bool) -> Void)? ) {
        self.data = data
        self.fileName = fileName
        self.completion = completion
    }
    override func main() {
        var path = ""
        do {
            try path = FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("data.dat").path
        } catch {
            OperationQueue.main.addOperation { self.completion?(false) }
        }
        let saved = NSKeyedArchiver.archiveRootObject(data, toFile: path)
        OperationQueue.main.addOperation { self.completion?(saved) }
    }
}

class OperationDataManager: DataManager {
    func save(data: [String:Any], toFile fileName: String, completion: ((Bool) -> Void)? ) {
        let operation = SaveOperation.init(data: data, fileName: fileName, completion: completion)
        let operationQueue = OperationQueue()
        operationQueue.qualityOfService = .userInitiated
        operationQueue.addOperation(operation)
    }
}
