//
//  RemovableProtocol.swift
//  MultiPeer
//
//  Created by 핏투비 iOS on 2022/05/18.
//

import Foundation
import CoreData

protocol RemovableProtocol: AnyObject {
    static func deleteSelf(_ target: NSManagedObject)
}

extension RemovableProtocol {
    static func deleteSelf(_ target: NSManagedObject) {
        
        if let context = target.managedObjectContext {
            context.delete(target)
            context.saveCoreData()
        }
    }
}


