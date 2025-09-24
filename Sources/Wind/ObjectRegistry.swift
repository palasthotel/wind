//
//  ObjectRegistry.swift
//  Wind
//
//  Created by Enno Welbers on 16.08.18.
//  Copyright © 2018 Palasthotel. All rights reserved.
//

import Foundation

class ObjectRegistry {
	class Entry {
		public weak var object: Component?
		public weak var container: Container?
		
		init(object: Component, container: Container) {
			self.object = object;
			self.container = container;
		}
	}
	
	nonisolated(unsafe) private static var objects: [Entry] = []
	
	public static func container(for object: Component) -> Container? {
		objects = objects.filter { (entry) -> Bool in
			entry.object != nil && entry.container != nil
		}
		
		return objects.first { (entry) -> Bool in
			entry.object === object
		}?.container
	}
	
	public static func register(object: Component, for container: Container ) -> Void {
		objects.append(Entry(object: object, container: container))
	}
}
