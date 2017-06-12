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

protocol DependencyA {
    
}



protocol DependencyB {
    
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

    class ComponentA:Singleton,AutomaticDependencyHandling,SimpleResolver,DependencyB {
        typealias DependencyToken = DependencyA;
        
        var dependencies: [String : Component] = [:];
        
        required init() {
            
        }
    }

    class ComponentB:Singleton,AutomaticDependencyHandling,SimpleResolver,DependencyA {
        typealias DependencyToken = DependencyB;
        
        var dependencies: [String : Component] = [:];
        
        required init() {
            
        }
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
