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
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    class IndirectImplementation : VisibleComponent,AutomaticDependencyHandling,Singleton,IndirectResolver {
        typealias DependencyToken = Dependency
        typealias PublicInterface = VisibleComponent
        
        var dependencies: [String : [Component]] = [:];
        
        required init() {
            
        }
    }
    
    
    class Consumer : Singleton,AutomaticDependencyHandling,DirectResolver,Dependency {
        var dependencies: [String : [Component]] = [:];
        
        required init() {
            
        }
        
        var Found:VisibleComponent! { get { return component();}}
        var NotFound:IndirectImplementation! { get { return component();}}
        
    }
    
    class SimpleComponent: Singleton,AutomaticDependencyHandling,DirectResolver {
        var dependencies: [String : [Component]] = [:];
        
        required init() {
            
        }
        
    }
    
    class ReallySimpleComponent: Singleton,AutomaticDependencyHandling,SimpleResolver {
        var dependencies: [String : [Component]] = [:];
        typealias DependencyToken = Dependency
        
        required init() {
            
        }
        
    }
    
    func testIndirectManualResolutionOnSingletons() {
        let cnt=Container();
        IndirectImplementation.register(in:cnt);
        try! cnt.bootstrap();
        
        let found:VisibleComponent! = cnt.resolve();
        XCTAssertNotNil(found);
        let notFound:IndirectImplementation! = cnt.resolve();
        XCTAssertNil(notFound);
    }
    
    func testIndirectAutoResolutionOnSingletons() {
        let cnt=Container();
        IndirectImplementation.register(in:cnt);
        Consumer.register(in: cnt);
        try! cnt.bootstrap();
        
        let result:Consumer! = cnt.resolve();
        XCTAssertNotNil(result);
        XCTAssertNotNil(result.Found);
        XCTAssertNotNil(result.NotFound);
    }
    
    func testDirectManualResolutionOnSingletons() {
        let cnt=Container();
        SimpleComponent.register(in: cnt);
        try! cnt.bootstrap();
        
        let result:SimpleComponent! = cnt.resolve();
        XCTAssertNotNil(result);
        let notFound:Consumer! = cnt.resolve();
        XCTAssertNil(notFound);
    }
    
    func testSimpleManualResolutionOnSingletons() {
        let cnt=Container();
        ReallySimpleComponent.register(in: cnt);
        try! cnt.bootstrap();
        
        let result:ReallySimpleComponent! = cnt.resolve();
        XCTAssertNotNil(result)
    }

    
}
