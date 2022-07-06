//
//  Screen+Helper.swift
//  MultiPeer
//
//  Created by 핏투비 iOS on 2022/05/11.
//

import CoreData
import UIKit


extension Screen: RemovableProtocol {}

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
    
    public var isFinished: Bool {
        get {
            return self.isFinished_
        }
        set {
            self.isFinished_ = newValue
        }
    }
    
    public var screenIndex: Int64 {
        get {
            return self.screenIndex_
        }
        set {
            self.screenIndex_ = newValue
        }
    }
    
//    public var positionTitleCores: Set<PositionTitleCore> {
//        get {
////            return self.positionTitleCores_ as! Set<PositionTitleCore>
//            return self.positionTitleCores_ as? Set<PositionTitleCore> ?? []
//        }
//        set {
//            self.positionTitleCores_ = newValue as NSSet
//        }
//    }
    
    public var trialCores: Set<TrialCore> {
        get {
//            return self.positionTitleCores_ as! Set<PositionTitleCore>
            return self.trialCores_ as? Set<TrialCore> ?? []
        }
        set {
            self.trialCores_ = newValue as NSSet
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
        // 이게 맞을듯 .. ?
        let numOfScreens = subject.screens.count
        validScreen.parentSubject = subject // 이거 빼고 모두 같음 .
        let currentDate = Date()
        let randomUUID = UUID()
        

        validScreen.setValue(currentDate, forKey: .ScreenStr.date)
        validScreen.setValue(randomUUID, forKey: "id_")
        validScreen.setValue(0, forKey: .ScreenStr.totalScore)
        validScreen.setValue(numOfScreens, forKey: .ScreenStr.screenIndex)
        
        TrialCore.saveBundle(belongTo: validScreen)
        
        do {
            try managedContext.save()
            print("successfully saved screen  : \(validScreen.trialCores.count)")
            print("validScreen id : \(validScreen.id)")
            return validScreen
        } catch let error as NSError {
            fatalError("failed to save screen ! error : \(error.localizedDescription)")
        }
    }
    
    @discardableResult
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
        
//        validScreen.parentSubject = subject // 이거 빼고 모두 같음 .
        let currentDate = Date()
        let randomUUID = UUID()
        
        validScreen.setValue(currentDate, forKey: .ScreenStr.date)
        validScreen.setValue(randomUUID, forKey: "id_")
        validScreen.setValue(0, forKey: .ScreenStr.totalScore)
        
        TrialCore.saveBundle(belongTo: validScreen)
        
        do {
            try managedContext.save()
            print("successfully saved screen  : \(validScreen.trialCores.count)")
            print("validScreen id : \(validScreen.id)")
            return validScreen
        } catch let error as NSError {
            fatalError("failed to save screen ! error : \(error.localizedDescription)")
        }
    }
    
}





extension NSManagedObjectContext {
    func saveCoreData() { // save to coreData
        DispatchQueue.main.async {
            do {
                try self.save()
            } catch {
                fatalError("fatal error during saving coreDate: \(error.localizedDescription)")
            }
        }
    }
}
