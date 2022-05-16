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
    
//    public func save(name: String) {
//        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
//
//        let managedContext = appDelegate.persistentContainer.viewContext
//        let entity = NSEntityDescription.entity(forEntityName: "Subject", in: managedContext)!
//        let subject = NSManagedObject(entity: entity, insertInto: managedContext)
//        subject.setValue(name, forKey: "name")
//
//        do {
//            try managedContext.save()
//        } catch let error as NSError {
//            print("Could not save, \(error), \(error.userInfo)")
//        }
//    }
    
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
    
    
//    @discardableResult
//    convenience init(name: String, phoneNumber: String, isMale: Bool, birthday: Date, context: NSManagedObjectContext) {
//        self.init(context: context)
//        self.name = name
//        self.phoneNumber = phoneNumber
//        self.isMale = isMale
//        self.birthday = birthday
//        DispatchQueue.global().async {
//            do {
//                try context.save()
//                print("saved Data: \(name), \(phoneNumber), \(isMale), \(birthday)")
//            } catch {
//                fatalError("Fatal Error occurred during saving Subject CoreData!")
//            }
//        }
//    }//        let subject = Subject(name: <#T##String#>, phoneNumber: <#T##String#>, isMale: <#T##Bool#>, birthday: <#T##Date#>, context: <#T##NSManagedObjectContext#>)
    
//    convenience init(name: String, phoneNumber: String, isMale: Bool, birthday: Date) {
//
//        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
//
//        let managedContext = appDelegate.persistentContainer.viewContext
//
//        self.init(name: name, phoneNumber: phoneNumber, isMale: isMale, birthday: birthday, context: managedContext)
////        super.init(context: managedContext)
////        self.init(context: managedContext)
////        self.init()
////        self.i
//    }
}


extension Subject {
    
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
    func provideInitialScreen() {
        self.screens.update(with: Screen.save())
    }
}
