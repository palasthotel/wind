
//  CoreDataSupport.swift
//  Wind
//
//  Created by Enno Welbers on 05.12.17.
//  Copyright © 2017 Palasthotel. All rights reserved.
//

import Foundation
import CoreData


private struct AssociatedKeys {
	nonisolated(unsafe) static var container = "wind_container"
}

public extension NSManagedObjectContext {
	var container: WindContainer? {
		get {
			let myInstance = (objc_getAssociatedObject(self, &AssociatedKeys.container) as? ContainerWrapper)?.instance
			
			guard myInstance != nil else {
				return Application.shared.container
			}
			
			return myInstance
		}
		set {
			let wrapper = ContainerWrapper()
			wrapper.instance = newValue
			objc_setAssociatedObject(self, &AssociatedKeys.container, wrapper, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
		}
	}
}


open class WindManagedObject: NSManagedObject, AutomaticDependencyHandling, AutomaticWeakDependencyHandling {
	
	public var dependencies: [String: [WindComponent]] = [:]
	public var weakDependencies: [String: [WeakReference]] = [:]
	
	open override func awakeFromFetch() {
		super.awakeFromFetch()
		try! self.managedObjectContext?.container?.resolve(for: self)
	}
	
	open override func awake(fromSnapshotEvents flags: NSSnapshotEventType) {
		super.awake(fromSnapshotEvents: flags)
		try! self.managedObjectContext?.container?.resolve(for: self)
	}
	
	open override func awakeFromInsert() {
		super.awakeFromInsert()
		try! self.managedObjectContext?.container?.resolve(for: self)
	}
}
