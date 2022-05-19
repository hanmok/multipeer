//
//  TrialDetail+Helper.swift
//  MultiPeer
//
//  Created by 핏투비 iOS on 2022/05/16.
//

import Foundation
import UIKit
import CoreData

extension TrialDetail: RemovableProtocol {}

extension TrialDetail {
    
    @discardableResult
    static func save(belongTo trialCore: TrialCore, trialNo: Int = 0) -> TrialDetail {
        print("creating trialdetail with trialNo: \(trialNo)")
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("fail to cast to appDelegate")
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        guard let entity = NSEntityDescription.entity(forEntityName: .CoreEntitiesStr.trialDetail, in: managedContext) else { fatalError() }
        
        let managedObject = NSManagedObject(entity: entity, insertInto: managedContext)
        
        guard let trialDetail = managedObject as? TrialDetail else { fatalError() }
//        trialDetail.setValue(1, forKey: .TrialDetailStr.score)
        trialDetail.parentTrialCore = trialCore
        trialDetail.setValue(trialNo, forKey: .TrialDetailStr.trialNo)
        do {
            try managedContext.save()
            print("successfully saved trial : \(trialDetail)")
            return trialDetail
        } catch {
            fatalError("\(error.localizedDescription)")
        }
    }
    
    public var parentTrialCore: TrialCore {
        get {
            return self.parentTrialCore_!
        }
        set {
            self.parentTrialCore_ = newValue
        }
    }
    
    public var score: Int64 {
        get {
//            self.parentTrialCore.updateLatestScore()
            return self.score_
        }
        set {
            self.score_ = newValue
        }
    }
    
    public var isPainful: Int64 {
        get {
//            self.parentTrialCore.updateLatestPain()
            return self.isPainful_
        }
        set {
            self.isPainful_ = newValue
        }
    }
    
    public func saveChanges() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("fail to cast to appDelegate")
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext

        managedContext.saveCoreData()
    }
    
}

//extension NSManagedObject
