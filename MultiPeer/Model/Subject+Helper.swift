//
//  Subject+Helper.swift
//  MultiPeer
//
//  Created by 핏투비 iOS on 2022/05/11.
//

import Foundation
import CoreData
import UIKit

extension Subject {
    
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
    
    public var birthday: Date {
        get {
            return birthday_ ?? Date()
        } set {
            birthday_ = newValue
        }
    }
    
    public var phoneNumber: String {
        get {
            return phoneNumber_ ?? ""
        } set {
            phoneNumber_ = newValue
        }
    }
    
    public var screens: Set<Screen> {
        get { screens_ as? Set<Screen> ?? []}
        set { screens_ = newValue as NSSet}
    }
    
    
}

extension Subject {
    
    static func save(name: String, phoneNumber: String, isMale: Bool, birthday: Date) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Subject", in: managedContext)!
        guard let subject = NSManagedObject(entity: entity, insertInto: managedContext) as? Subject else {
            fatalError()
        }
        
        subject.setValue(name, forKey: "name_")
        subject.setValue(phoneNumber, forKey: "phoneNumber_")
        subject.setValue(isMale, forKey: "isMale")
        subject.setValue(birthday, forKey: "birthday_")
        
        subject.provideInitialScreen()
        
        do {
            try managedContext.save()
            print("savedData: \(subject)")
        } catch let error as NSError {
            print("Could not save, \(error), \(error.userInfo)")
        }
    }
}


extension Subject: RemovableProtocol {}

extension Subject {
    func provideInitialScreen() {
        Screen.save(belongTo: self)
    }
}
