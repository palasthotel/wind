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
    
    class Component: Singleton,SimpleResolver,AutomaticDependencyHandling {
        typealias DependencyToken = Dependency
        public var dependencies: [String : [Wind.Component]] = [:];
        
        required init() {
            
        }
    }
    
    class FirstImpl:VisibleComponent,Singleton,IndirectResolver,AutomaticDependencyHandling {
        typealias DependencyToken = Dependency;
        typealias PublicInterface = VisibleComponent;
        
        public var dependencies: [String : [Wind.Component]] = [:];
        
        required init() {
            
        }
    }
    
    class SecondImpl:VisibleComponent,Singleton,IndirectResolver,AutomaticDependencyHandling {
        typealias DependencyToken = Dependency
        typealias PublicInterface = VisibleComponent
        
        public var dependencies: [String : [Wind.Component]] = [:];
        
        required init() {
            
        }
    }
    
    class WeakObject:ForeignInstantiable,SimpleResolver,AutomaticDependencyHandling {
        typealias DependencyToken = Dependency
        var dependencies: [String : [Wind.Component]] = [:];
        
        init() {
            
        }
    }
    
    class Consumer: Singleton,DirectResolver,AutomaticWeakDependencyHandling,Dependency {
        var dependencies: [String : [Wind.Component]] = [:];
        var weakDependencies: [String : [WeakReference]] = [:];
        
        required init() {
            
        }
        
        var Instances:[VisibleComponent] { get { return components(); } }
    }
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testEnsureSingleResolutionOnSingletons() {
        let cnt=Container();
        Component.register(in: cnt);
        Consumer.register(in: cnt);
        try! cnt.bootstrap();
        
        var consumer:Consumer = cnt.resolve();
        XCTAssertEqual(consumer.dependencies[String(describing:Component.self)]!.count, 1);
        consumer = cnt.resolve();
        XCTAssertEqual(consumer.dependencies[String(describing:Component.self)]!.count, 1);
    }
    
    func testMultipleDependencies() {
        let cnt = Container();
        
        FirstImpl.register(in: cnt);
        SecondImpl.register(in: cnt);
        Consumer.register(in: cnt);
        try! cnt.bootstrap();
        
        let consumer:Consumer = cnt.resolve();
        XCTAssertEqual(consumer.Instances.count, 2);
    }
    
    func testEnsureSingleResolutionOnForeignSingletons() {
        let cnt = Container();
        WeakObject.register(in: cnt);
        Consumer.register(in: cnt);
        
        try! cnt.bootstrap();
        
        let consumer:Consumer = cnt.resolve();
        var instance = WeakObject();
        instance.resolveMe(in: cnt);
        XCTAssertEqual(consumer.weakDependencies[String(describing:WeakObject.self)]!.count, 1);
        instance = WeakObject();
        instance.resolveMe(in: cnt);
        XCTAssertEqual((consumer.weakComponents() as [WeakObject]).count, 1);
    }
    
    func testMultipleWeakDependencies() {
        let cnt = Container();
        WeakObject.register(in: cnt);
        Consumer.register(in: cnt);
        
        try! cnt.bootstrap();
        
        let consumer:Consumer = cnt.resolve();
        XCTAssertEqual((consumer.weakComponents() as [WeakObject]).count, 0);
        let instance1 = WeakObject();
        instance1.resolveMe(in: cnt);
        XCTAssertEqual(consumer.weakDependencies[String(describing:WeakObject.self)]!.count, 1);
        let instance2 = WeakObject();
        instance2.resolveMe(in: cnt);
        XCTAssertEqual((consumer.weakComponents() as [WeakObject]).count, 2);
    }
}
