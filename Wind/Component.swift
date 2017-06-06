//
//  Component.swift
//  Wind
//
//  Created by Enno Welbers on 06.06.17.
//  Copyright © 2017 Palasthotel. All rights reserved.
//

import Foundation

protocol Component:class {
    /// This Variable will hold all your dependencies.
    /// However there is no need to directly interact with it.
    /// Instead: use the function component() provided.
    var dependencies:[String:Component] {get set}
    
    /// This Function will be used to provide your component
    /// with all dependencies we found.
    /// There is no need to implement it as we're providing a very
    /// valuable default.
    func fill(dependency:Any.Type, with object:Component) -> Void
    
    /// As Wind will construct everything there needs to be a way to do so.
    init()
}

/// This specialised Subprotocol is telling Wind that your Component
/// is meant to be used as a Singleton.
protocol Singleton: Component {
    
}

/// This specialised Subprotocol is telling Wind that your Component
/// is meant to be instantiated anew for every dependency.
/// The buildFactory() method will be autoimplemented on a few occassions.
/// Most of the time there is nothing you need to do.
protocol Instantiable: Component {
    static func buildFactory() -> Resolver;
}

extension Component {
    func fill(dependency:Any.Type, with:Component) -> Void {
        dependencies[String(describing: dependency)] = with
    }
    func component<T>() -> T! {
        return dependencies[String(describing:T.self)] as? T
    }
}

extension Component where Self:Instantiable {
    static func register(in container:Container) -> Void {
        let resolver = Self.buildFactory();
        if(resolver is Component) {
            container.register(component: resolver as! Component);
        }
        container.register(resolver:resolver);
    }
}

extension Component where Self:Singleton {
    static func register(in container:Container) -> Void {
        let instance=Self();
        container.register(component: instance);
        if(instance is Resolver) {
            container.register(resolver:instance as! Resolver);
        }
    }
}
