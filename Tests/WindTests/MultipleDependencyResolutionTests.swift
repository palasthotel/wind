//
//  MultipleDependencyResolutionTests.swift
//  Wind
//
//  Created by Enno Welbers on 14.06.17.
//  Copyright © 2017 Palasthotel. All rights reserved.
//

import XCTest
@testable import Wind

class MultipleDependencyResolutionTests: XCTestCase {
    
    class Component: Singleton, SimpleResolver, AutomaticDependencyHandling {
        typealias DependencyToken = Dependency
        public var dependencies: [String : [Wind.Component]] = [:]
        
        required init() { }
    }
    
    class FirstImpl: VisibleComponent, Singleton, IndirectResolver, AutomaticDependencyHandling {
        typealias DependencyToken = Dependency
        typealias PublicInterface = VisibleComponent
        
        public var dependencies: [String : [Wind.Component]] = [:]
        
        required init() { }
    }
    
    class SecondImpl: VisibleComponent, Singleton, IndirectResolver, AutomaticDependencyHandling {
        typealias DependencyToken = Dependency
        typealias PublicInterface = VisibleComponent
        
        public var dependencies: [String : [Wind.Component]] = [:]
        
        required init() { }
    }
    
    class WeakObject: ForeignInstantiable, SimpleResolver, AutomaticDependencyHandling {
        typealias DependencyToken = Dependency
        var dependencies: [String : [Wind.Component]] = [:]
        
        init() { }
    }
    
    class Consumer: Singleton, DirectResolver, AutomaticWeakDependencyHandling, Dependency {
        var dependencies: [String : [Wind.Component]] = [:]
        var weakDependencies: [String : [WeakReference]] = [:]
        
        required init() { }
        
        var Instances: [VisibleComponent] { get { return components() } }
    }
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testEnsureSingleResolutionOnSingletons() {
        let container = Container()
        Component.register(in: container)
        Consumer.register(in: container)
        try! container.bootstrap()
        
        var consumer:Consumer = container.resolve()
        XCTAssertEqual(consumer.dependencies[String(describing: Component.self)]!.count, 1)
        consumer = container.resolve()
        XCTAssertEqual(consumer.dependencies[String(describing: Component.self)]!.count, 1)
    }
    
    func testMultipleDependencies() {
        let container = Container()
        
        FirstImpl.register(in: container)
        SecondImpl.register(in: container)
        Consumer.register(in: container)
        try! container.bootstrap()
        
        let consumer: Consumer = container.resolve()
        XCTAssertEqual(consumer.Instances.count, 2)
    }
    
    func testEnsureSingleResolutionOnForeignSingletons() {
        let container = Container()
        WeakObject.register(in: container)
        Consumer.register(in: container)
        
        try! container.bootstrap()
        
        let consumer:Consumer = container.resolve()
        var instance = WeakObject()
        instance.resolveMe(in: container)
        XCTAssertEqual(consumer.weakDependencies[String(describing: WeakObject.self)]!.count, 1)
        instance = WeakObject()
        instance.resolveMe(in: container)
        XCTAssertEqual((consumer.weakComponents() as [WeakObject]).count, 1)
    }
    
    func testMultipleWeakDependencies() {
        let container = Container()
        WeakObject.register(in: container)
        Consumer.register(in: container)
        
        try! container.bootstrap()
        
        let consumer: Consumer = container.resolve()
        XCTAssertEqual((consumer.weakComponents() as [WeakObject]).count, 0)
        let instance1 = WeakObject()
        instance1.resolveMe(in: container)
        XCTAssertEqual(consumer.weakDependencies[String(describing: WeakObject.self)]!.count, 1)
        let instance2 = WeakObject()
        instance2.resolveMe(in: container)
        XCTAssertEqual((consumer.weakComponents() as [WeakObject]).count, 2)
    }
}
