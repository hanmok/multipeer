//
//  Screen+Helper.swift
//  MultiPeer
//
//  Created by 핏투비 iOS on 2022/05/11.
//

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
    
    public var positionTitleCores: Set<PositionTitleCore> {
        get {
//            return self.positionTitleCores_ as! Set<PositionTitleCore>
            return self.positionTitleCores_ as? Set<PositionTitleCore> ?? []
        }
        set {
            self.positionTitleCores_ = newValue as NSSet
        }
    }
    
    @discardableResult
    static func save(belongTo subject: Subject) -> Screen {
        print("screen save has called")
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("fail to case to appDelegate")
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let entity = NSEntityDescription.entity(forEntityName: "Screen", in: managedContext)!
        let screen = NSManagedObject(entity: entity, insertInto: managedContext)
        
        guard let validScreen = screen as? Screen else {
            fatalError("screen downcasting has failed!")
        }
        
        validScreen.parentSubject = subject
        let currentDate = Date()
        let randomUUID = UUID()
        
        validScreen.setValue(currentDate, forKey: .ScreenStr.date)
        validScreen.setValue(randomUUID, forKey: "id_")
        validScreen.setValue(0, forKey: .ScreenStr.totalScore)
        
        PositionTitleCore.createBasicPositions(screen: validScreen)
        // PositionTitleCore 도 만들어야지
        
        do {
            try managedContext.save()
            print("successfully saved screen  : \(screen)")
            
            return validScreen
        } catch let error as NSError {
            print("could not save, \(error.localizedDescription)")
            fatalError("faield to save screen !")
        }
    }
    
    static func save() -> Screen {
        print("screen save has called")
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("fail to case to appDelegate")
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let entity = NSEntityDescription.entity(forEntityName: "Screen", in: managedContext)!
        let screen = NSManagedObject(entity: entity, insertInto: managedContext)
        
        guard let validScreen = screen as? Screen else {
            fatalError("screen downcasting has failed!")
        }
        
        let currentDate = Date()
        let randomUUID = UUID()
        
        validScreen.setValue(currentDate, forKey: .ScreenStr.date)
        validScreen.setValue(randomUUID, forKey: "id_")
        validScreen.setValue(0, forKey: .ScreenStr.totalScore)
        
        PositionTitleCore.createBasicPositions(screen: validScreen)
        // PositionTitleCore 도 만들어야지
        
        do {
            try managedContext.save()
            print("successfully saved screen  : \(screen)")
            
            return validScreen
        } catch let error as NSError {
//            print("Could not save, \(error), \(error.userInfo)")
            print("could not save, \(error.localizedDescription)")
            fatalError("faield to save screen !")
        }
    }
}
