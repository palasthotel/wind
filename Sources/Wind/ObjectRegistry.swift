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
		public weak var object: WindComponent?
		public weak var container: WindContainer?
		
		init(object: WindComponent, container: WindContainer) {
			self.object = object;
			self.container = container;
		}
	}
	
	nonisolated(unsafe) private static var objects: [Entry] = []
	
	public static func container(for object: WindComponent) -> WindContainer? {
		objects = objects.filter { (entry) -> Bool in
			entry.object != nil && entry.container != nil
		}
		
		return objects.first { (entry) -> Bool in
			entry.object === object
		}?.container
	}
	
	public static func register(object: WindComponent, for container: WindContainer ) -> Void {
		objects.append(Entry(object: object, container: container))
	}
}
