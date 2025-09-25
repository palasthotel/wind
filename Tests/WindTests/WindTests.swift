//
//  WindTests.swift
//  WindTests
//
//  Created by Enno Welbers on 06.06.17.
//  Copyright © 2017 Palasthotel. All rights reserved.
//

import XCTest
@testable import Wind

protocol VisibleComponent: Component { }

protocol Dependency { }

protocol DependencyA { }

protocol DependencyB { }

public protocol FileManagerDependency { }

extension FileManager: ForeignSingleton, SimpleResolver {
	public typealias DependencyToken = FileManagerDependency
	
	public func fill(dependency: Any.Type, with: Component) { }
	
	public static func getForeignInstance() -> Component {
		FileManager.default
	}
}

class FileManagerConsumer: Instantiable, AutomaticDependencyHandling, DirectResolver, FileManagerDependency {
	var found: FileManager! { get { return component() } }
	
	var dependencies: [String : [Component]] = [:]
	
	required init() { }
}

class WindTests: XCTestCase {
	override func setUp() {
		super.setUp()
	}
	
	override func tearDown() {
		super.tearDown()
	}
	
	class ComponentA: Singleton, AutomaticDependencyHandling, SimpleResolver, DependencyB {
		typealias DependencyToken = DependencyA
		
		var dependencies: [String : [Component]] = [:]
		
		required init() { }
	}
	
	class ComponentB: Singleton, AutomaticDependencyHandling, SimpleResolver, DependencyA {
		typealias DependencyToken = DependencyB
		
		var dependencies: [String : [Component]] = [:]
		
		required init() { }
	}
	
	func testCyclicResolution() {
		let  container = Container()
		ComponentA.register(in: container)
		ComponentB.register(in: container)
		
		var thrown = false
		
		do {
			try container.bootstrap()
		} catch Container.ResolutionError.cycleDetected(_) {
			thrown = true
		} catch {
			
		}
		
		XCTAssertTrue(thrown)
	}
	
	func testForeignSingletons() {
		let container = Container()
		FileManager.register(in: container)
		FileManagerConsumer.register(in: container)
		
		try! container.bootstrap()
		let instance: FileManagerConsumer = container.resolve()
		XCTAssertNotNil(instance.found)
	}
}
