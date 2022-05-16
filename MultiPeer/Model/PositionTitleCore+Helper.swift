//
//  PositionDetail+Helper.swift
//  MultiPeer
//
//  Created by 핏투비 iOS on 2022/05/11.
//

import CoreData
import UIKit


extension PositionTitleCore {
    
    
    public var title: String {
        get {
            return self.title_ ?? "N/D"
        }
        set {
            self.title_ = newValue
        }
    }
    
    
    @discardableResult
    static func save(name: String, belongTo parentScreen: Screen) -> PositionTitleCore {
        print("PositionTitleCore save has called")
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("fail to case to appDelegate")
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let entity = NSEntityDescription.entity(forEntityName: .CoreEntitiesStr.positionTitleCore, in: managedContext)!
        let positionTitleCore = NSManagedObject(entity: entity, insertInto: managedContext)
        
        guard let positionTitleCore = positionTitleCore as? PositionTitleCore else {
            fatalError("screen downcasting has failed!")
        }
        
        positionTitleCore.setValue(name, forKey: .PositionTitleCoreStr.title)
        // make corresponding direction Cores along with positionTitleCore
        TrialCore.save(belongTo: positionTitleCore)
        
        
        do {
            try managedContext.save()
            print("successfully saved PositionTitleCore  : \(String(describing: positionTitleCore.title))")
            return positionTitleCore
        } catch let error as NSError {
            print("Could not save, \(error), \(error.userInfo)")
            fatalError("faield to save screen !")
        }
    }
}

extension PositionTitleCore {
    static func createBasicPositions(screen: Screen) {
        for position in PositionList.allCases {
            let positionTitle = position.rawValue
            PositionTitleCore.save(name: positionTitle, belongTo: screen)
        }
    }
}
