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
    static func save(belongTo direction: TrialCore) -> TrialDetail {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("fail to cast to appDelegate")
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        guard let entity = NSEntityDescription.entity(forEntityName: .CoreEntitiesStr.trialDetail, in: managedContext) else { fatalError() }
        
        let managedObject = NSManagedObject(entity: entity, insertInto: managedContext)
        
        guard let trialDetail = managedObject as? TrialDetail else { fatalError() }
        trialDetail.setValue(1, forKey: .TrialDetailStr.score)
        trialDetail.parentDirection = direction
        
        do {
            try managedContext.save()
            print("successfully saved trial : \(trialDetail)")
            return trialDetail
        } catch {
            print("error : \(error.localizedDescription)")
            fatalError()
        }
    }
    
    public var parentDirection: TrialCore {
        get {
            return self.parentDirection_!
        }
        set {
            self.parentDirection_ = newValue
        }
    }
    
    public var score: Int64 {
        get {
            self.parentDirection.updateLatestScore()
            return self.score_
        }
        set {
            self.score_ = newValue
        }
    }
    
    public var isPainful: Int64 {
        get {
            self.parentDirection.updateLatestPain()
            return self.isPainful_
        }
        set {
            self.isPainful_ = newValue
        }
    }
}
