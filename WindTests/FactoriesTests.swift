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

    class Consumer : Singleton,AutomaticDependencyHandling,DirectResolver {
        var dependencies: [String : [Component]] = [:];
        
        required init() {
            
        }
        
    }
    
    class DirectInstantiableComponent: Instantiable,AutomaticDependencyHandling,DirectResolver {
        var dependencies: [String : [Component]] = [:];
        
        required init() {
            
        }
        
    }

    class IndirectInstantiableComponent: VisibleComponent,AutomaticDependencyHandling,Instantiable,IndirectResolver {
        typealias DependencyToken = Dependency
        typealias PublicInterface = VisibleComponent
        var dependencies: [String : [Component]] = [:];
        
        required init() {
            
        }
    }
    
    class IndirectInstantiableConsumer: Component,AutomaticDependencyHandling,Singleton,DirectResolver,Dependency {
        var dependencies: [String : [Component]] = [:];
        
        required init() {
            
        }
        
        var Found:VisibleComponent! { get { return component()}}
        var NotFOund:IndirectInstantiableComponent! { get { return component()}}
    }

    class SimpleInstantiableComponent: Instantiable,AutomaticDependencyHandling,SimpleResolver {
        var dependencies: [String : [Component]] = [:];
        typealias DependencyToken = Dependency
        required init() {
            
        }
    }
    
    class SimpleInstantiableConsumer: Singleton,AutomaticDependencyHandling,DirectResolver,Dependency {
        var dependencies: [String : [Component]] = [:];
        
        required init() {
            
        }
        
        var Found:SimpleInstantiableComponent! { get { return component()}}
    }
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testDirectManualResolutionOnFactories() {
        let cnt=Container();
        Consumer.register(in: cnt);
        try! cnt.bootstrap();
        
        let result:Consumer! = cnt.resolve();
        XCTAssertNotNil(result);
    }
 
    func testDirectResolutionOnFactories() {
        let cnt=Container();
        DirectInstantiableComponent.register(in: cnt);
        try! cnt.bootstrap();
        
        let result:DirectInstantiableComponent! = cnt.resolve();
        XCTAssertNotNil(result)
        let notFound:Consumer! = cnt.resolve();
        XCTAssertNil(notFound);
    }
    
    func testIndirectAutoResolutionOnFactories() {
        let cnt = Container();
        IndirectInstantiableComponent.register(in: cnt);
        IndirectInstantiableConsumer.register(in: cnt);
        try! cnt.bootstrap();
        
        let item:IndirectInstantiableConsumer! = cnt.resolve();
        XCTAssertNotNil(item);
        XCTAssertNotNil(item.Found);
        XCTAssertNil(item.NotFOund);
    }
    
    func testIndirectSimpleResolutionOnFactories() {
        let cnt = Container();
        SimpleInstantiableConsumer.register(in: cnt);
        SimpleInstantiableComponent.register(in: cnt);
        try! cnt.bootstrap();
        
        let item:SimpleInstantiableConsumer! = cnt.resolve();
        XCTAssertNotNil(item);
        XCTAssertNotNil(item.Found);
    }

    
}
