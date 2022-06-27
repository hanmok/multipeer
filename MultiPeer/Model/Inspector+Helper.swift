//
//  Inspector+Helper.swift
//  MultiPeer
//
//  Created by 핏투비 on 2022/06/24.
//

import Foundation
import CoreData
import UIKit



extension Inspector {
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

    public var name: String {
        get {
            return self.name_ ?? ""
        }
        set {
            self.name_ = newValue
        }
    }

    public var phoneNumber: String {
        get {
            return self.phoneNumber_ ?? ""
        } set {
            self.phoneNumber_ = newValue
        }
    }
    
    public var subjects: Set<Subject> {
        get { subjects_ as? Set<Subject> ?? [] }
        set { subjects_ = newValue as NSSet }
    }
}


extension Inspector {
    
    static func save(name: String, phoneNumber: String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
//        let entity = NSEntityDescription.entity(forEntityName: "Subject", in: managedContext)!
        guard let entity = NSEntityDescription.entity(forEntityName: .CoreEntitiesStr.inspector, in: managedContext) else { fatalError("failed to get entity from subject ")}
        guard let inspector = NSManagedObject(entity: entity, insertInto: managedContext) as? Inspector else {
            fatalError("failed to case to Subject during saving ")
        }
        
        inspector.setValue(name, forKey: .InspectorStr.name)
        inspector.setValue(phoneNumber, forKey: .InspectorStr.phoneNumber)
        let someUUID = UUID()
        inspector.setValue(someUUID, forKey: .InspectorStr.id)
        
        do {
            try managedContext.save()
            print("savedData: \(inspector)")
        } catch let error as NSError {
            print("Could not save, \(error), \(error.userInfo)")
        }
    }
}

extension Inspector: RemovableProtocol {}


