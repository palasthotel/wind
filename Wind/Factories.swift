//
//  Factories.swift
//  Wind
//
//  Created by Enno Welbers on 06.06.17.
//  Copyright © 2017 Palasthotel. All rights reserved.
//

import Foundation

/// This Factory can only resolve directly by instantiating and resolving a single component.
internal class DirectComponentFactory<Item:Component,PublicInterface>:Component,AutomaticDependencyHandling,Resolver,ContainerDependency where Item:Instantiable {
    
    required init() {
        
    }
    lazy var Container:Container! = self.component()
    var dependencies: [String : Component] = [:]
    func resolve(on consumer: Component) {
        //this is not supported by this factory
    }
    
    func resolutionPossible(on consumer: Component) -> Bool {
        return false;
    }
    
    func resolveDirectly<T>() -> T? {
        if(T.self != PublicInterface.self) {
            return nil;
        }
        let instance = Item()
        try! Container.resolve(for: instance);
        return instance as? T
    }
}

/// This Factory is capable of detecting dependencies by using a dependency type hint.
internal class IndirectComponentFactory<Item:Component,PublicInterface,DependencyDetection>:DirectComponentFactory<Item,PublicInterface> where Item:Instantiable{
    required init() {
        
    }
    override func resolve(on consumer: Component) {
        if (consumer is DependencyDetection) {
            let instance = Item()
            try! Container.resolve(for:instance)
            consumer.fill(dependency: PublicInterface.self, with: instance)
        }
    }
    
    override func resolutionPossible(on consumer: Component) -> Bool {
        return consumer is DependencyDetection;
    }
}

extension Instantiable where Self:DirectResolver & Component {
    static func buildFactory() -> Resolver {
        return DirectComponentFactory<Self,Self>();
    }
}

extension Instantiable where Self:SimpleResolver & Component {
    static func buildFactory() -> Resolver {
        let factory:IndirectComponentFactory<Self,Self,DependencyToken> = IndirectComponentFactory();
        return factory;
    }
}

extension Instantiable where Self:IndirectResolver & Component {
    static func buildFactory() -> Resolver {
        return IndirectComponentFactory<Self,PublicInterface,DependencyToken>();
    }
}