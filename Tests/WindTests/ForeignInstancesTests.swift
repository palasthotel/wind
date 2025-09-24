//
//  ForeignInstancesTests.swift
//  Wind
//
//  Created by Enno Welbers on 12.06.17.
//  Copyright © 2017 Palasthotel. All rights reserved.
//

import XCTest
@testable import Wind

class ForeignInstancesTests: XCTestCase {
	override func setUp() {
		super.setUp()
	}
	
	override func tearDown() {
		super.tearDown()
	}
	
	class ForeignSimpleInstance: ForeignInstantiable, SimpleResolver, AutomaticDependencyHandling {
		typealias DependencyToken = Dependency
		
		var dependencies: [String : [Component]] = [:]
	}
	
	class ForeignIndirectInstance: VisibleComponent, ForeignInstantiable, IndirectResolver, AutomaticDependencyHandling {
		typealias DependencyToken = Dependency
		typealias PublicInterface = VisibleComponent
		
		var dependencies: [String : [Component]] = [:]
	}
	
	class ForeignConsumerSingleton: Singleton, Dependency, AutomaticDependencyHandling, AutomaticWeakDependencyHandling, DirectResolver {
		var dependencies: [String : [Component]] = [:]
		var weakDependencies: [String : [WeakReference]] = [:]
		
		var found: ForeignSimpleInstance? { get { return weakComponent() } }
		var foundIndirect: VisibleComponent? { get { return weakComponent() } }
		
		required init() { }
	}
	
	class ForeignConsumerInstance: Instantiable, Dependency, AutomaticWeakDependencyHandling, DirectResolver {
		var dependencies: [String : [Component]] = [:]
		var weakDependencies: [String : [WeakReference]] = [:]
		
		var found: ForeignSimpleInstance? { get { return weakComponent() } }
		var foundIndirect: VisibleComponent? { get { return weakComponent()}}
		
		required init() { }
	}
	
	func testForeignSimpleResolutionOnSingletons() {
		let container = Container()
		ForeignSimpleInstance.register(in: container)
		ForeignConsumerSingleton.register(in: container)
		try! container.bootstrap()
		
		let consumer: ForeignConsumerSingleton = container.resolve()
		XCTAssertNotNil(consumer)
		XCTAssertNil(consumer.found)
		let instance = ForeignSimpleInstance()
		instance.resolveMe(in: container)
		XCTAssertNotNil(consumer.found)
	}
	
	func testForeignIndirectResolutionOnSingletons() {
		let container = Container()
		ForeignIndirectInstance.register(in: container)
		ForeignConsumerSingleton.register(in: container)
		try! container.bootstrap()
		
		let consumer: ForeignConsumerSingleton = container.resolve()
		XCTAssertNotNil(consumer)
		XCTAssertNil(consumer.foundIndirect)
		let instance = ForeignIndirectInstance()
		instance.resolveMe(in: container)
		XCTAssertNotNil(consumer.foundIndirect)
	}
	
	func testForeignSimpleResolutionOnInstances() {
		let container = Container()
		ForeignSimpleInstance.register(in: container)
		ForeignConsumerInstance.register(in: container)
		try! container.bootstrap()
		
		let consumer: ForeignConsumerInstance = container.resolve()
		XCTAssertNotNil(consumer)
		XCTAssertNil(consumer.found)
		let instance = ForeignSimpleInstance()
		instance.resolveMe(in: container)
		XCTAssertNotNil(consumer.found)
	}
	
	func testForeignIndirectResolutionOnInstances() {
		let container = Container()
		ForeignIndirectInstance.register(in: container)
		ForeignConsumerInstance.register(in: container)
		try! container.bootstrap()
		
		let consumer: ForeignConsumerInstance = container.resolve()
		XCTAssertNotNil(consumer)
		XCTAssertNil(consumer.foundIndirect)
		let instance = ForeignIndirectInstance()
		instance.resolveMe(in: container)
		XCTAssertNotNil(consumer.foundIndirect)
	}
	
	func testForeignLifecycleOnSingletons() {
		let container = Container()
		ForeignIndirectInstance.register(in: container)
		ForeignConsumerSingleton.register(in: container)
		try! container.bootstrap()
		
		let consumer: ForeignConsumerSingleton = container.resolve()
		XCTAssertNotNil(consumer)
		XCTAssertNil(consumer.foundIndirect)
		var instance: ForeignIndirectInstance? = ForeignIndirectInstance()
		instance?.resolveMe(in: container)
		XCTAssertNotNil(consumer.foundIndirect)
		instance = nil
		XCTAssertNil(consumer.foundIndirect)
	}
	
	func testForeignLifecycleOnInstances() {
		let container = Container()
		ForeignIndirectInstance.register(in: container)
		ForeignConsumerInstance.register(in: container)
		try! container.bootstrap()
		
		let consumer: ForeignConsumerInstance = container.resolve()
		XCTAssertNotNil(consumer)
		XCTAssertNil(consumer.foundIndirect)
		var instance: ForeignIndirectInstance? = ForeignIndirectInstance()
		instance?.resolveMe(in: container)
		XCTAssertNotNil(consumer.foundIndirect)
		instance = nil
		XCTAssertNil(consumer.foundIndirect)		
	}
	
}
