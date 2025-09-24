//
//  Component.swift
//  Wind
//
//  Created by Enno Welbers on 06.06.17.
//  Copyright © 2017 Palasthotel. All rights reserved.
//

import Foundation


public protocol WindComponent: AnyObject {
	/// This Function will be used to provide your component
	/// with all dependencies we found.
	/// There is no need to implement it as we're providing a very
	/// valuable default.
	func fill(dependency: Any.Type, with object: WindComponent) -> Void
	
	/// This Function will be called when all dependencies has been provided
	/// You don't have to implement it, a default implementation will be provided.
	func dependenciesFullfilled() -> Void
}


/// ForeignSingleton classes get created outside of the container.
/// Use this feature to blend in UIKit Components like FileManager and UserDefaults.
public protocol ForeignSingleton: WindComponent {
	static func getForeignInstance() -> WindComponent
}


/// This specialised Subprotocol is telling Wind that your Component
/// is meant to be used as a Singleton.
public protocol Singleton: WindComponent {
	/// As Wind will construct everything there needs to be a way to do so.
	init()
}

/// This specialised Subprotocol is telling Wind that your Component
/// is meant to be instantiated anew for every dependency.
/// The buildFactory() method will be autoimplemented on a few occassions.
/// Most of the time there is nothing you need to do.
public protocol Instantiable: WindComponent {
	static func buildFactory() -> Resolver
	
	/// As Wind will construct everything there needs to be a way to do so.
	init()
}

/// This specialised Subprotocol is telling Wind that your Component
/// is meant to be instantiated, but: not from within the container.
/// If you have parts of your dependencies inside of storyboards or
/// if Foundation instantiates your class, this is the way to go to.
///
/// Beware: if your component is instantiable and will be instantiated
/// outside of the container, it needs to have it's own lifecycle.
/// As Wind doesn't want to leak, ForeignInstantiable Components
/// are only weakly referenced everywhere.
/// So: if you use this, beware that the lifecycle will be kept as-is.
///
/// Important: as Wind needs to "see" new instances, an extension provides your implementation
/// with a new method `resolveMe(in container:Container)`
/// You have to call this method after initialization is complete.
/// It will trigger a complete roundtrip through all known objects and instances and
/// will try to resolve all problems.
public protocol ForeignInstantiable: WindComponent {
}

/// Use this protocol if you'd like to handle your dependencies automatically instead of implementing fill() on your own.
public protocol AutomaticDependencyHandling: WindComponent {
	/// This Variable will hold all your dependencies.
	/// However there is no need to directly interact with it.
	/// Instead: use the function component() provided.
	var dependencies: [String: [WindComponent]] { get set }
}


public extension AutomaticDependencyHandling {
	func fill(dependency: Any.Type, with: WindComponent) -> Void {
		let key = String(describing: dependency)
		
		if dependencies[key] == nil {
			dependencies[key] = []
		}
		
		dependencies[String(describing: dependency)]?.append(with)
	}
	
	func component<T>() -> T! {
		let key = String(describing: T.self)
		
		if let component = dependencies[key]?.first as? T {
			return component
		} else {
			print("Key \"\(key)\" not found in dependencies for consumer \"\(type(of: self))\". It only has:\n\(self.dependenciesDescription())")
			
			let result = containerHasDependencyForType(T.self)
			
			if result == false {
				print("Type \(T.self) not found in container")
			}
			
			return nil
		}
	}
	
	func components<T>() -> [T] {
		return dependencies[String(describing: T.self)] as! [T]
	}
}

public extension WindComponent {
	func dependenciesFullfilled() -> Void { }
}

public extension WindComponent where Self: Instantiable {
	static func register(in container: WindContainer) -> Void {
		let resolver = Self.buildFactory()
		
		if resolver is WindComponent {
			container.register(component: resolver as! WindComponent)
		}
		
		container.register(resolver: resolver)
	}
}

public extension WindComponent where Self: ForeignInstantiable & SimpleResolver {
	func resolveMe(in container: WindContainer) -> Void {
		try! container.resolve(for: self)
		
		let resolver: ForeignSimpleResolver<DependencyToken, Self> = container.resolve()
		resolver.component = self
		
		for component in container.components {
			if component is WindFactory {
				for instance in (component as! WindFactory).getChildren() where resolver.resolutionPossible(on: instance) {
					resolver.resolve(on: instance)
				}
			}
			
			if resolver.resolutionPossible(on: component) {
				resolver.resolve(on: component)
			}
		}
	}
	
	static func register(in container: WindContainer) -> Void {
		let resolver = ForeignSimpleResolver<DependencyToken, Self>()
		container.register(resolver: resolver as! Resolver)
	}
}

public extension WindComponent where Self: ForeignInstantiable & IndirectResolver {
	func resolveMe(in container: WindContainer) -> Void {
		try! container.resolve(for: self)
		
		let resolver: ForeignIndirectResolver<DependencyToken, PublicInterface, Self> = container.resolve()
		resolver.component = self
		
		for component in container.components {
			if component is WindFactory {
				for instance in (component as! WindFactory).getChildren() where resolver.resolutionPossible(on: instance) {
					resolver.resolve(on: instance)
				}
			}
			
			if resolver.resolutionPossible(on: component) {
				resolver.resolve(on: component)
			}
		}
	}
	
	static func register(in container: WindContainer) -> Void {
		let resolver = ForeignIndirectResolver<DependencyToken, PublicInterface, Self>()
		container.register(resolver: resolver as! Resolver)
	}
}

public extension WindComponent where Self: Singleton {
	static func register(in container: WindContainer) -> Void {
		let instance = Self()
		container.register(component: instance)
		
		if instance is Resolver {
			container.register(resolver: instance as! Resolver)
		}
	}
}

public extension WindComponent where Self: ForeignSingleton {
	static func register(in container: WindContainer) -> Void {
		let instance = self.getForeignInstance()
		container.register(component: instance)
		
		if instance is Resolver {
			container.register(resolver: instance as! Resolver)
		}
	}
}

private extension WindComponent where Self: AutomaticDependencyHandling {
	func containerHasDependencyForType<T>(_ type: T.Type) -> Bool? {
		guard let components = ObjectRegistry.container(for: self)?.components else {
			print("Unable to find responsible container")
			return nil
		}
		
		var componentFound = false
		for component in components where component is T {
			componentFound = true
		}
		
		return componentFound
	}
	
	func dependenciesDescription() -> String {
		return dependencies.map { (key, value) in
			return "\(key) -> \(type(of: value.first!))"
		}.joined(separator: "\n")
	}
}
