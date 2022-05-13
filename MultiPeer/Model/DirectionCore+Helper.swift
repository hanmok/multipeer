//
//  DirectionCoreExt+.swift
//  MultiPeer
//
//  Created by 핏투비 iOS on 2022/05/13.
//


import UIKit
import CoreData


extension DirectionCore {
    
    @discardableResult
    static func save(belongTo parent: PositionTitleCore) -> [DirectionCore] {
        print("directionCore save has called")
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("fail to case to appDelegate")
        }

        let managedContext = appDelegate.persistentContainer.viewContext

        let entity = NSEntityDescription.entity(forEntityName: .CoreEntities.directionCore, in: managedContext)!
        let managedObject = NSManagedObject(entity: entity, insertInto: managedContext)

        var directionCores: [DirectionCore] = []

        guard let positionTitle = parent.title,
              let positionFromList = PositionList(rawValue: positionTitle),
              let numOfDirections = Dummy.numOfDirections[positionFromList],
              let directions = Dummy.directionName[numOfDirections] else { fatalError("") }


        for direction in directions {
    
            guard let directionCore = managedObject as? DirectionCore else {
                fatalError("downcasting has failed! ")
            }
            directionCore.setValue(direction, forKey: .DirectionCore.direction)
            directionCore.setValue(parent, forKey: .DirectionCore.parentPositionTitle)
            do {
                try managedContext.save()
                print("successfully saved ! \(directionCore.direction)")
                directionCores.append(directionCore)
            } catch let error as NSError {
                print("Could not save, \(error), \(error.userInfo)")
                fatalError("faield to save !")
            }
        }
      
        return directionCores
    }
}
