//
//  WrongInterfaceTests.swift
//  WindTests
//
//  Created by Benni on 20.04.18.
//  Copyright © 2018 Palasthotel. All rights reserved.
//

import Foundation
import XCTest
@testable import Wind

protocol TestDependency {}
protocol DependsOnTestDependency {}
extension DependsOnTestDependency where Self: AutomaticDependencyHandling {
	var dependency: TestDependency? {
		return component()
	}
}

protocol TestConsumer {
	func dependency() -> TestDependency?
}
protocol DependsOnTestConsumer {}
extension DependsOnTestConsumer where Self: AutomaticDependencyHandling {
	var dependency: TestConsumer {
		return component()
	}
}

class TestDependencyImplementation: AutomaticDependencyHandling, Singleton, IndirectResolver, TestDependency {
	typealias PublicInterface = Protocol
	typealias DependencyToken = DependsOnTestDependency
	var dependencies: [String : [Component]] = [:]
	required init() { }
}

class TestConsumerImplementation: AutomaticDependencyHandling, Singleton, IndirectResolver, TestConsumer, DependsOnTestDependency {
	typealias PublicInterface = TestConsumer
	typealias DependencyToken = DependsOnTestConsumer
	var dependencies: [String : [Component]] = [:]
	required init() { }
	
	func dependency() -> TestDependency? {
		return dependency
	}
}


class WrongInterfaceTests: XCTestCase {
	var testConsumer: TestConsumer!
	
	override func setUp() {
		super.setUp()
		
		let container = Container()
		TestDependencyImplementation.register(in: container)
		TestConsumerImplementation.register(in: container)
		try! container.bootstrap()
		
		testConsumer = container.resolve()
	}
	
	func testInterface() {
		XCTAssertNotNil(testConsumer)
		
		XCTAssertTrue(testConsumer is DependsOnTestDependency)
		XCTAssertNil(testConsumer.dependency())
	}
}
