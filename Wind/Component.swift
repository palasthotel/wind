//
//  Component.swift
//  Wind
//
//  Created by Enno Welbers on 06.06.17.
//  Copyright © 2017 Palasthotel. All rights reserved.
//

import Foundation

public protocol Component:class {
    
    /// This Function will be used to provide your component
    /// with all dependencies we found.
    /// There is no need to implement it as we're providing a very
    /// valuable default.
    func fill(dependency:Any.Type, with object:Component) -> Void
}

/// ForeignSingleton classes get created outside of the container.
/// Use this feature to blend in UIKit Components like FileManager and UserDefaults.
public protocol ForeignSingleton : Component {
    static func getForeignInstance() -> Component;
}

/// This specialised Subprotocol is telling Wind that your Component
/// is meant to be used as a Singleton.
public protocol Singleton: Component {

    /// As Wind will construct everything there needs to be a way to do so.
    init()
    
}

/// This specialised Subprotocol is telling Wind that your Component
/// is meant to be instantiated anew for every dependency.
/// The buildFactory() method will be autoimplemented on a few occassions.
/// Most of the time there is nothing you need to do.
public protocol Instantiable: Component {
    static func buildFactory() -> Resolver;

    /// As Wind will construct everything there needs to be a way to do so.
    init()
}

public protocol ForeignInstantiable : Component {

}

/// Use this protocol if you'd like to handle your dependencies automatically instead of implementing fill() on your own.
public protocol AutomaticDependencyHandling:Component {
    /// This Variable will hold all your dependencies.
    /// However there is no need to directly interact with it.
    /// Instead: use the function component() provided.
    var dependencies:[String:Component] {get set}
    
}


public extension AutomaticDependencyHandling {
    func fill(dependency:Any.Type, with:Component) -> Void {
        dependencies[String(describing: dependency)] = with
    }
    func component<T>() -> T! {
        return dependencies[String(describing:T.self)] as? T
    }
}

public extension Component where Self:Instantiable {
    static func register(in container:Container) -> Void {
        let resolver = Self.buildFactory();
        if(resolver is Component) {
            container.register(component: resolver as! Component);
        }
        container.register(resolver:resolver);
    }
}

public extension Component where Self:ForeignInstantiable & SimpleResolver {
    func resolveMe(in container:Container) -> Void {
        let resolver:ForeignSimpleResolver<DependencyToken,Self> = container.resolve();
        resolver.component = self;
        for component in container.components {
            if(resolver.resolutionPossible(on: component)) {
                resolver.resolve(on: component);
            }
        }
    }
    
    static func register(in container:Container) -> Void {
        let resolver = ForeignSimpleResolver<DependencyToken,Self>();
        container.register(resolver: resolver);
    }
}

public extension Component where Self:ForeignInstantiable & IndirectResolver {
    func resolveMe(in container:Container) -> Void {
        let resolver:ForeignIndirectResolver<DependencyToken,PublicInterface,Self> = container.resolve();
        resolver.component = self;
        for component in container.components {
            if(resolver.resolutionPossible(on: component)) {
                resolver.resolve(on: component);
            }
        }
    }
    
    static func register(in container:Container) -> Void {
        let resolver = ForeignIndirectResolver<DependencyToken,PublicInterface,Self>();
        container.register(resolver: resolver);
    }
}

public extension Component where Self:Singleton {
    static func register(in container:Container) -> Void {
        let instance=Self();
        container.register(component: instance);
        if(instance is Resolver) {
            container.register(resolver:instance as! Resolver);
        }
    }
}

public extension Component where Self:ForeignSingleton {
    static func register(in container:Container) -> Void {
        let instance=self.getForeignInstance();
        container.register(component: instance);
        if(instance is Resolver) {
            container.register(resolver: instance as! Resolver);
        }
    }
}
