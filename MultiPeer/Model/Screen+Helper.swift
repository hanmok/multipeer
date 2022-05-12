//
//  Screen+Helper.swift
//  MultiPeer
//
//  Created by 핏투비 iOS on 2022/05/11.
//

import Foundation
import CoreData
import UIKit

extension Screen {
    public var id: UUID {
        get {
            if let validId = self.id_ {
                return validId
            } else {
                let uuid = UUID()
                self.id_ = uuid
                return uuid
            }
        }
        set {
            self.id_ = newValue
        }
    }
    
    public var date: Date {
        get {
            return self.date_ ?? Date()
        }
        set {
            self.date_ = newValue
        }
    }
    
    public func save(belongTo subject: Subject) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let entity = NSEntityDescription.entity(forEntityName: "Screen", in: managedContext)!
        let screen = NSManagedObject(entity: entity, insertInto: managedContext)
        
        guard let validScreen = screen as? Screen else {
            fatalError("screen downcasting has failed!")
        }
        
        validScreen.belongTo = subject
        let currentDate = Date()
        let randomUUID = UUID()
        
        validScreen.setValue(currentDate, forKey: .Screen.date)
        validScreen.setValue(randomUUID, forKey: "id_")
        
        do {
            try managedContext.save()
            print("successfully saved screen  : \(screen)")
        } catch let error as NSError {
            print("Could not save, \(error), \(error.userInfo)")
        }
    }
}


extension Screen {
    static let date = "date_"
    
}


extension String {
    struct Screen {
        static let date = "date_"
        static let id = "id_"
        static let isFinished = "isFinished"
        static let screenIndex = "screenIndex"
        static let totalScore = "totalScore"
    }
}
