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
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    class ForeignSimpleInstance: ForeignInstantiable,SimpleResolver,AutomaticDependencyHandling {
        typealias DependencyToken = Dependency;
        var dependencies: [String : [Component]] = [:];
        
    }
    
    class ForeignIndirectInstance: VisibleComponent,ForeignInstantiable,IndirectResolver,AutomaticDependencyHandling {
        typealias DependencyToken = Dependency
        typealias PublicInterface = VisibleComponent
        var dependencies: [String : [Component]] = [:];
    }
    
    class ForeignConsumerSingleton: Singleton,Dependency,AutomaticDependencyHandling,AutomaticWeakDependencyHandling,DirectResolver {
        var dependencies: [String : [Component]] = [:];
        var weakDependencies: [String : [WeakReference]] = [:];
        
        var Found:ForeignSimpleInstance? { get { return weakComponent(); } }
        var FoundIndirect:VisibleComponent? { get { return weakComponent(); } }
        
        required init() {
            
        }
    }
    
    class ForeignConsumerInstance: Instantiable,Dependency,AutomaticWeakDependencyHandling,DirectResolver {
        var dependencies: [String : [Component]] = [:]
        var weakDependencies: [String : [WeakReference]] = [:]
        
        var Found:ForeignSimpleInstance? { get { return weakComponent(); } }
        var FoundIndirect:VisibleComponent? { get { return weakComponent();}}
        
        required init() {
            
        }
    }
    
    func testForeignSimpleResolutionOnSingletons() {
        let cnt=Container();
        ForeignSimpleInstance.register(in: cnt);
        ForeignConsumerSingleton.register(in: cnt);
        try! cnt.bootstrap();
        
        let consumer:ForeignConsumerSingleton = cnt.resolve();
        XCTAssertNotNil(consumer);
        XCTAssertNil(consumer.Found);
        let instance=ForeignSimpleInstance();
        instance.resolveMe(in: cnt);
        XCTAssertNotNil(consumer.Found);
    }
    
    func testForeignIndirectResolutionOnSingletons() {
        let cnt = Container();
        ForeignIndirectInstance.register(in: cnt);
        ForeignConsumerSingleton.register(in: cnt);
        try! cnt.bootstrap();
        
        let consumer:ForeignConsumerSingleton = cnt.resolve();
        XCTAssertNotNil(consumer);
        XCTAssertNil(consumer.FoundIndirect);
        let instance=ForeignIndirectInstance();
        instance.resolveMe(in: cnt);
        XCTAssertNotNil(consumer.FoundIndirect);
    }
    
    func testForeignSimpleResolutionOnInstances() {
        let cnt = Container();
        ForeignSimpleInstance.register(in: cnt);
        ForeignConsumerInstance.register(in: cnt);
        try! cnt.bootstrap();
        
        let consumer:ForeignConsumerInstance = cnt.resolve();
        XCTAssertNotNil(consumer);
        XCTAssertNil(consumer.Found);
        let instance=ForeignSimpleInstance();
        instance.resolveMe(in: cnt);
        XCTAssertNotNil(consumer.Found);
    }
    
    func testForeignIndirectResolutionOnInstances() {
        let cnt = Container();
        ForeignIndirectInstance.register(in: cnt);
        ForeignConsumerInstance.register(in: cnt);
        try! cnt.bootstrap();
        
        let consumer:ForeignConsumerInstance = cnt.resolve();
        XCTAssertNotNil(consumer);
        XCTAssertNil(consumer.FoundIndirect);
        let instance=ForeignIndirectInstance();
        instance.resolveMe(in: cnt);
        XCTAssertNotNil(consumer.FoundIndirect);

    }
    
    func testForeignLifecycleOnSingletons() {
        let cnt = Container();
        ForeignIndirectInstance.register(in: cnt);
        ForeignConsumerSingleton.register(in: cnt);
        try! cnt.bootstrap();
        
        let consumer:ForeignConsumerSingleton = cnt.resolve();
        XCTAssertNotNil(consumer);
        XCTAssertNil(consumer.FoundIndirect);
        var instance:ForeignIndirectInstance?=ForeignIndirectInstance();
        instance?.resolveMe(in: cnt);
        XCTAssertNotNil(consumer.FoundIndirect);
        instance = nil;
        XCTAssertNil(consumer.FoundIndirect);
    }
    
    func testForeignLifecycleOnInstances() {
        let cnt = Container();
        ForeignIndirectInstance.register(in: cnt);
        ForeignConsumerInstance.register(in: cnt);
        try! cnt.bootstrap();
        
        let consumer:ForeignConsumerInstance = cnt.resolve();
        XCTAssertNotNil(consumer);
        XCTAssertNil(consumer.FoundIndirect);
        var instance:ForeignIndirectInstance?=ForeignIndirectInstance();
        instance?.resolveMe(in: cnt);
        XCTAssertNotNil(consumer.FoundIndirect);
        instance = nil;
        XCTAssertNil(consumer.FoundIndirect);
    
    }
    
}
