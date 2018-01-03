//
//  CoreDataSupport.swift
//  Wind
//
//  Created by Enno Welbers on 05.12.17.
//  Copyright © 2017 Palasthotel. All rights reserved.
//

import Foundation
import CoreData
import UIKit

private struct AssociatedKeys {
    static var container = "wind_container";
}

public extension NSManagedObjectContext {
    var Container:Container? {
        get {
            let myInstance=(objc_getAssociatedObject(self, &AssociatedKeys.container) as? ContainerWrapper)?.Instance;
            guard myInstance != nil else {
                return UIApplication.shared.Container;
            }
            return myInstance;
        }
        set {
            let wrapper = ContainerWrapper();
            wrapper.Instance = newValue;
            objc_setAssociatedObject(self, &AssociatedKeys.container, wrapper, .OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
    }
}

open class WindManagedObject : NSManagedObject,AutomaticDependencyHandling,AutomaticWeakDependencyHandling {
    
    public var dependencies: [String : [Component]] = [:];
    public var weakDependencies: [String : [WeakReference]] = [:];
    
    override open func awakeFromFetch() {
        super.awakeFromFetch();
        try! self.managedObjectContext?.Container?.resolve(for:self);
    }
    
    override open func awake(fromSnapshotEvents flags: NSSnapshotEventType) {
        super.awake(fromSnapshotEvents: flags);
        try! self.managedObjectContext?.Container?.resolve(for:self);
    }
    
    override open func awakeFromInsert() {
        super.awakeFromInsert();
        try! self.managedObjectContext?.Container?.resolve(for:self);
    }
}
