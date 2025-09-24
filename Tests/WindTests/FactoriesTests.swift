//
//  FactoriesTests.swift
//  Wind
//
//  Created by Enno Welbers on 12.06.17.
//  Copyright © 2017 Palasthotel. All rights reserved.
//

import XCTest
@testable import Wind


class FactoriesTests: XCTestCase {
	class Consumer: Singleton, AutomaticDependencyHandling, DirectResolver {
		var dependencies: [String : [Component]] = [:]
		
		required init() { }
	}
	
	class DirectInstantiableComponent: Instantiable, AutomaticDependencyHandling, DirectResolver {
		var dependencies: [String : [Component]] = [:]
		
		required init() { }
	}
	
	class IndirectInstantiableComponent: VisibleComponent, AutomaticDependencyHandling, Instantiable, IndirectResolver {
		typealias DependencyToken = Dependency
		typealias PublicInterface = VisibleComponent
		var dependencies: [String : [Component]] = [:]
		
		required init() { }
	}
	
	class IndirectInstantiableConsumer: Component, AutomaticDependencyHandling, Singleton, DirectResolver, Dependency {
		var dependencies: [String : [Component]] = [:];
		
		required init() { }
		
		var found: VisibleComponent! { get { return component() } }
		var notFound: IndirectInstantiableComponent! { get { return component() } }
	}
	
	class SimpleInstantiableComponent: Instantiable, AutomaticDependencyHandling, SimpleResolver {
		var dependencies: [String : [Component]] = [:]
		typealias DependencyToken = Dependency
		
		required init() { }
	}
	
	class SimpleInstantiableConsumer: Singleton, AutomaticDependencyHandling, DirectResolver, Dependency {
		var dependencies: [String : [Component]] = [:]
		
		required init() { }
		
		var found: SimpleInstantiableComponent! { get { return component() } }
	}
	
	override func setUp() {
		super.setUp()
	}
	
	override func tearDown() {
		super.tearDown()
	}
	
	func testDirectManualResolutionOnFactories() {
		let container = Container()
		Consumer.register(in: container)
		try! container.bootstrap()
		
		let result: Consumer! = container.resolve()
		XCTAssertNotNil(result)
	}
	
	func testDirectResolutionOnFactories() {
		let container = Container()
		DirectInstantiableComponent.register(in: container)
		try! container.bootstrap()
		
		let result: DirectInstantiableComponent! = container.resolve()
		XCTAssertNotNil(result)
		
		let notFound: Consumer! = container.resolve()
		XCTAssertNil(notFound)
	}
	
	func testIndirectAutoResolutionOnFactories() {
		let container = Container()
		IndirectInstantiableComponent.register(in: container)
		IndirectInstantiableConsumer.register(in: container)
		try! container.bootstrap()
		
		let item: IndirectInstantiableConsumer! = container.resolve()
		XCTAssertNotNil(item)
		XCTAssertNotNil(item.found)
		XCTAssertNil(item.notFound)
	}
	
	func testIndirectSimpleResolutionOnFactories() {
		let container = Container()
		SimpleInstantiableConsumer.register(in: container)
		SimpleInstantiableComponent.register(in: container)
		try! container.bootstrap()
		
		let item: SimpleInstantiableConsumer! = container.resolve()
		XCTAssertNotNil(item)
		XCTAssertNotNil(item.found)
	}
}
