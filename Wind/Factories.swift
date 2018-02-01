//
//  Factories.swift
//  Wind
//
//  Created by Enno Welbers on 06.06.17.
//  Copyright © 2017 Palasthotel. All rights reserved.
//

import Foundation

internal protocol Factory {
    func getChildren() -> [Component];
}

/// This Factory can only resolve directly by instantiating and resolving a single component.
internal class DirectComponentFactory<Item,PublicInterface>:Component,AutomaticDependencyHandling,Resolver,ContainerDependency,Factory where Item:Instantiable {
    
    class WeakReference {
        weak var Instance:Item?;
        
        init(_ instance:Item) {
            Instance = instance;
        }
    }
    
    required init() {
        
    }
    lazy var Container:Container! = self.component()
    var dependencies: [String : [Component]] = [:]
    var children:[WeakReference] = [];
    
    func getChildren() -> [Component] {
        return children.filter({$0.Instance != nil}).map({$0.Instance!});
    }
    
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
        children.append(WeakReference(instance));
        try! Container.resolve(for: instance);
        return instance as? T
    }
}

/// This Factory is capable of detecting dependencies by using a dependency type hint.
internal class IndirectComponentFactory<Item,PublicInterface,DependencyDetection>:DirectComponentFactory<Item,PublicInterface> where Item:Instantiable{
    required init() {
        
    }
    override func resolve(on consumer: Component) {
        if (consumer is DependencyDetection) {
            let instance = Item()
            children.append(WeakReference(instance));
            try! Container.resolve(for:instance)
            consumer.fill(dependency: PublicInterface.self, with: instance)
        }
    }
    
    override func resolutionPossible(on consumer: Component) -> Bool {
        return consumer is DependencyDetection;
    }
}

public extension Instantiable where Self:DirectResolver {
    static func buildFactory() -> Resolver {
        return DirectComponentFactory<Self,Self>();
    }
}

public extension Instantiable where Self:SimpleResolver {
    static func buildFactory() -> Resolver {
        let factory:IndirectComponentFactory<Self,Self,DependencyToken> = IndirectComponentFactory();
        return factory;
    }
}

public extension Instantiable where Self:IndirectResolver {
    static func buildFactory() -> Resolver {
        return IndirectComponentFactory<Self,PublicInterface,DependencyToken>();
    }
}
