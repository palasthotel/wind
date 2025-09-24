//
//  Factories.swift
//  Wind
//
//  Created by Enno Welbers on 06.06.17.
//  Copyright © 2017 Palasthotel. All rights reserved.
//

import Foundation

internal protocol WindFactory {
	func getChildren() -> [WindComponent]
}

/// This Factory can only resolve directly by instantiating and resolving a single component.
protocol DirectComponentFactoryProtocols: WindComponent,
										  AutomaticDependencyHandling,
										  //Resolver,
										  ContainerDependency,
										  WindFactory { }

internal class DirectComponentFactory<Item, PublicInterface>: DirectComponentFactoryProtocols where Item: Instantiable {
	class WeakReference {
		weak var instance: Item?
		
		init(_ instance: Item) {
			self.instance = instance
		}
	}
	
	required init() { }
	
	lazy var Container: WindContainer! = self.component()
	var dependencies: [String : [WindComponent]] = [:]
	var children: [WeakReference] = []
	
	func getChildren() -> [WindComponent] {
		children.filter({$0.instance != nil}).map({$0.instance!});
	}
	
	func resolve(on consumer: WindComponent) {
		//this is not supported by this factory
	}
	
	func resolutionPossible(on consumer: WindComponent) -> Bool {
		false
	}
	
	func resolveDirectly<T>() -> T? {
		guard T.self == PublicInterface.self else {
			return nil
		}
		
		let instance = Item()
		children.append(WeakReference(instance))
		try! Container.resolve(for: instance)
		return instance as? T
	}
}

/// This Factory is capable of detecting dependencies by using a dependency type hint.
internal class IndirectComponentFactory<Item, PublicInterface, DependencyDetection>: DirectComponentFactory<Item, PublicInterface> where Item: Instantiable{
	required init() { }
	
	override func resolve(on consumer: WindComponent) {
		guard consumer is DependencyDetection else {
			return
		}
		
		let instance = Item()
		children.append(WeakReference(instance))
		try! Container.resolve(for:instance)
		consumer.fill(dependency: PublicInterface.self, with: instance)
	}
	
	override func resolutionPossible(on consumer: WindComponent) -> Bool {
		return consumer is DependencyDetection;
	}
}

public extension Instantiable where Self: DirectResolver {
	static func buildFactory() -> Resolver {
		return DirectComponentFactory<Self, Self>() as! Resolver
	}
}

public extension Instantiable where Self: SimpleResolver {
	static func buildFactory() -> Resolver {
		let factory: IndirectComponentFactory<Self, Self, DependencyToken> = IndirectComponentFactory()
		return factory as! Resolver
	}
}

public extension Instantiable where Self: IndirectResolver {
	static func buildFactory() -> Resolver {
		return IndirectComponentFactory<Self, PublicInterface, DependencyToken>() as! Resolver
	}
}
