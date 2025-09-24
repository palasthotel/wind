//
//  SingletonTests.swift
//  Wind
//
//  Created by Enno Welbers on 12.06.17.
//  Copyright © 2017 Palasthotel. All rights reserved.
//

import XCTest
@testable import Wind




class SingletonTests: XCTestCase {
	
	override func setUp() {
		super.setUp()
	}
	
	override func tearDown() {
		super.tearDown()
	}
	
	class IndirectImplementation: VisibleComponent, AutomaticDependencyHandling, Singleton, IndirectResolver {
		typealias DependencyToken = Dependency
		typealias PublicInterface = VisibleComponent
		
		var dependencies: [String : [Component]] = [:]
		
		required init() { }
	}
	
	class Consumer: Singleton, AutomaticDependencyHandling, DirectResolver, Dependency {
		var dependencies: [String : [Component]] = [:]
		
		required init() { }
		
		var found: VisibleComponent! { get { return component() } }
		var notFound: IndirectImplementation! { get { return component() } }
	}
	
	class SimpleComponent: Singleton, AutomaticDependencyHandling, DirectResolver {
		var dependencies: [String : [Component]] = [:]
		
		required init() { }
	}
	
	class ReallySimpleComponent: Singleton, AutomaticDependencyHandling, SimpleResolver {
		var dependencies: [String : [Component]] = [:]
		typealias DependencyToken = Dependency
		
		required init() { }
	}
	
	func testIndirectManualResolutionOnSingletons() {
		let container = Container()
		IndirectImplementation.register(in: container)
		try! container.bootstrap()
		
		let found:VisibleComponent! = container.resolve()
		XCTAssertNotNil(found)
		let notFound:IndirectImplementation! = container.resolve()
		XCTAssertNil(notFound)
	}
	
	func testIndirectAutoResolutionOnSingletons() {
		let container = Container()
		IndirectImplementation.register(in: container)
		Consumer.register(in: container)
		try! container.bootstrap()
		
		let result: Consumer! = container.resolve()
		XCTAssertNotNil(result)
		XCTAssertNotNil(result.found)
		XCTAssertNil(result.notFound)
	}
	
	func testDirectManualResolutionOnSingletons() {
		let container = Container()
		SimpleComponent.register(in: container)
		try! container.bootstrap()
		
		let result: SimpleComponent! = container.resolve()
		XCTAssertNotNil(result)
		let notFound: Consumer! = container.resolve()
		XCTAssertNil(notFound)
	}
	
	func testSimpleManualResolutionOnSingletons() {
		let container = Container()
		ReallySimpleComponent.register(in: container)
		try! container.bootstrap()
		
		let result: ReallySimpleComponent! = container.resolve()
		XCTAssertNotNil(result)
	}
	
	
}
