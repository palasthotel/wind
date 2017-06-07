//
//  WindTests.swift
//  WindTests
//
//  Created by Enno Welbers on 06.06.17.
//  Copyright © 2017 Palasthotel. All rights reserved.
//

import XCTest
@testable import Wind

protocol VisibleComponent : Component {
    
}
protocol Dependency {
    
}

class IndirectImplementation : VisibleComponent,AutomaticDependencyHandling,Singleton,IndirectResolver {
    typealias DependencyToken = Dependency
    typealias PublicInterface = VisibleComponent
    
    var dependencies: [String : Component] = [:];
    
    required init() {
        
    }
}

class Consumer : Instantiable,AutomaticDependencyHandling,DirectResolver,Dependency {
    var dependencies: [String : Component] = [:];
    
    required init() {
        
    }
    
    var Found:VisibleComponent! { get { return component();}}
    var NotFound:IndirectImplementation! { get { return component();}}
    
}

class SimpleComponent: Singleton,AutomaticDependencyHandling,DirectResolver {
    var dependencies: [String : Component] = [:];
    
    required init() {
        
    }
    
}

class ReallySimpleComponent: Singleton,AutomaticDependencyHandling,SimpleResolver {
    var dependencies: [String : Component] = [:];
    typealias DependencyToken = Dependency
    
    required init() {
        
    }

}

class DirectInstantiableComponent: Instantiable,AutomaticDependencyHandling,DirectResolver {
    var dependencies: [String : Component] = [:];
    
    required init() {
        
    }

}

class IndirectInstantiableComponent: VisibleComponent,AutomaticDependencyHandling,Instantiable,IndirectResolver {
    typealias DependencyToken = Dependency
    typealias PublicInterface = VisibleComponent
    var dependencies: [String : Component] = [:];
    
    required init() {
        
    }
}

class IndirectInstantiableConsumer: Component,AutomaticDependencyHandling,Singleton,DirectResolver,Dependency {
    var dependencies: [String : Component] = [:];
    
    required init() {
        
    }
    
    var Found:VisibleComponent! { get { return component()}}
    var NotFOund:IndirectInstantiableComponent! { get { return component()}}
}

class SimpleInstantiableComponent: Instantiable,AutomaticDependencyHandling,SimpleResolver {
    var dependencies: [String : Component] = [:];
    typealias DependencyToken = Dependency
    required init() {
        
    }
}

class SimpleInstantiableConsumer: Singleton,AutomaticDependencyHandling,DirectResolver,Dependency {
    var dependencies: [String : Component] = [:];
    
    required init() {
        
    }
    
    var Found:SimpleInstantiableComponent! { get { return component()}}
}

protocol DependencyA {
    
}

class ComponentA:Singleton,AutomaticDependencyHandling,SimpleResolver,DependencyB {
    typealias DependencyToken = DependencyA;
    
    var dependencies: [String : Component] = [:];
    
    required init() {
        
    }
}

protocol DependencyB {
    
}

class ComponentB:Singleton,AutomaticDependencyHandling,SimpleResolver,DependencyA {
    typealias DependencyToken = DependencyB;
    
    var dependencies: [String : Component] = [:];
    
    required init() {
        
    }
}


public protocol FileManagerDependency {
    
}

extension FileManager:ForeignSingleton,SimpleResolver {
    public typealias DependencyToken = FileManagerDependency
    
    public func fill(dependency: Any.Type, with: Component) {
        //we don't have any dependencies
    }
    
    public static func getForeignInstance() -> Component {
        return FileManager.default;
    }
}

class FileManagerConsumer: Instantiable,AutomaticDependencyHandling,DirectResolver,FileManagerDependency {
    
    var Found:FileManager! {get { return component()} }
    
    var dependencies: [String : Component] = [:];
    
    required init() {
        
    }
    
}

class WindTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
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
        XCTAssertNil(result.NotFound);
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
    
    func testDirectManualResolutionOnFactories() {
        let cnt=Container();
        Consumer.register(in: cnt);
        try! cnt.bootstrap();
        
        let result:Consumer! = cnt.resolve();
        XCTAssertNotNil(result);
    }
    
    func testIndirectResolutionOnFactories() {
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
    
    func testCyclicResolution() {
        let cnt = Container();
        ComponentA.register(in: cnt);
        ComponentB.register(in: cnt);
        
        var thrown = false;
        do {
            try cnt.bootstrap();
        }
        catch Container.ResolutionError.cycleDetected(_) {
            thrown=true;
        }
        catch {
            
        }
        XCTAssertTrue(thrown);
    }
    
    func testForeignSingletons() {
        let cnt = Container();
        FileManager.register(in: cnt);
        FileManagerConsumer.register(in: cnt);
        
        try! cnt.bootstrap();
        let instance:FileManagerConsumer = cnt.resolve();
        XCTAssertNotNil(instance.Found);
    }
}
