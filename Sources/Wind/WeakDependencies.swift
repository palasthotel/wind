//
//  WeakDependencies.swift
//  Wind
//
//  Created by Enno Welbers on 09.06.17.
//  Copyright © 2017 Palasthotel. All rights reserved.
//

import Foundation


/// If your component depends on a foreign instantiated object,
/// it needs to be aware of weak dependencies.
/// If you don't want to think about it, simply conform to AutomaticWeakDependencyHandling.
public protocol WeakDependencyAware: WindComponent {
	/// Components handed in via this function are not allowed to be
	/// strongly referenced.
	func fill(dependency: Any.Type, weaklyWith object: WindComponent) -> Void
}

/// WeakReference is used to store weak references to foreign instantiated components.
/// you should almost never use it directly.
public class WeakReference {
	public weak var instance: WindComponent?
	
	public init(pointingAt component: WindComponent) {
		self.instance = component
	}
}

public protocol AutomaticWeakDependencyHandling:AutomaticDependencyHandling,WeakDependencyAware {
	var weakDependencies: [String: [WeakReference]] { get set }
}

public extension AutomaticWeakDependencyHandling {
	func fill(dependency: Any.Type, weaklyWith object: WindComponent) -> Void {
		let key = String(describing: dependency)
				
		if weakDependencies[key] == nil {
			weakDependencies[key] = []
		}
		
		weakDependencies[key]?.append(WeakReference(pointingAt: object))
	}
	
	func weakComponent<T>() -> T? {
		let options = weakDependencies[String(describing: T.self)]
		
		guard let possibleoptions = options else {
			return nil
		}
		
		return possibleoptions.filter {
			$0.instance != nil
		}.first?.instance as? T
	}
	
	func weakComponents<T>() -> [T] {
		let options = weakDependencies[String(describing: T.self)]
		
		guard let possibleoptions = options else {
			return []
		}
		
		let living = possibleoptions.filter {
			$0.instance != nil
		}.map {
			$0.instance! as! T
		}
		
		return living
	}
}

