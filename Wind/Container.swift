//
//  Container.swift
//  Wind
//
//  Created by Enno Welbers on 06.06.17.
//  Copyright © 2017 Palasthotel. All rights reserved.
//

import Foundation

/// If you need direct access to the container, this is your way to go.
internal protocol ContainerDependency {
}


class Container:Component,SimpleResolver {
    
    var dependencies: [String : Component] = [:]
    
    typealias DependencyToken = ContainerDependency
    var components:[Component] = []
    var resolvers:[Resolver] = []
    var readyResolvers:[Resolver] = []
    
    required init() {
        resolvers.append(self)
        readyResolvers.append(self);
    }
    
    func register(component:Component) -> Void {
        components.append(component);
    }
    func register(resolver:Resolver) -> Void {
        resolvers.append(resolver);
    }
    
    func bootstrap() {
        for comp in components {
            resolve(for: comp);
        }
    }
    
    func resolve(for consumer:Component) -> Void {
        for resolver in resolvers {
            if(resolver === consumer) {
                continue;
            }
            if(resolver is Component && !readyResolvers.contains(where: {$0 === resolver})) {
                //we need to mark the resolver as resolved beforehand
                readyResolvers.append(resolver);
                resolve(for:resolver as! Component);
            }
            resolver.resolve(on: consumer)
        }
    }
    
    func resolve<T>() -> T! {
        for resolver in resolvers {
            let result:T? = resolver.resolveDirectly();
            if result != nil {
                return result;
            }
        }
        return nil;
    }
}
