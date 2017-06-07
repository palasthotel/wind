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
    
    enum ResolutionError:Error {
        case cycleDetected([Component])
    }
    
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
        if(!(resolver is Component)) {
            readyResolvers.append(resolver);
        }
    }
    
    func bootstrap() throws {
        for comp in resolvers.filter({$0 is Component}).map({$0 as! Component}) {
            try resolve(for: comp);
        }
    }
    
    func ResolverIsReady(_ resolver:Resolver) -> Bool {
        if(resolver is Component) {
            return readyResolvers.contains(where: {$0 === resolver});
        }
        return true;
    }
    
    private func resolve(for consumer:Component, alreadyResolving:[Component]) throws -> Void {
        if(alreadyResolving.contains(where: {$0 === consumer})) {
            //TODO: throw exception.
            throw ResolutionError.cycleDetected(alreadyResolving);
        }
        for resolver in resolvers {
            if(resolver === consumer) {
                continue;
            }
            if(!resolver.resolutionPossible(on: consumer)) {
                continue;
            }
            if(!ResolverIsReady(resolver)) {
                try resolve(for:resolver as! Component,alreadyResolving:alreadyResolving+[consumer]);
            }
            resolver.resolve(on: consumer)
        }
        if(consumer is Resolver) {
            readyResolvers.append(consumer as! Resolver);
        }

    }
    
    func resolve(for consumer:Component) throws -> Void {
        try resolve(for:consumer, alreadyResolving:[]);
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
