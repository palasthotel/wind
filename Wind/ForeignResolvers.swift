//
//  ForeignResolvers.swift
//  Wind
//
//  Created by Enno Welbers on 09.06.17.
//  Copyright © 2017 Palasthotel. All rights reserved.
//

import Foundation


public class ForeignSimpleResolver<DependencyToken,Type>:Resolver {
    weak var component:Component?;
    
    public func resolve(on consumer:Component) -> Void {
        if(consumer is DependencyToken) {
            (consumer as? WeakDependencyAware)?.fill(dependency: Type.self, weaklyWith: component!);
        }
    }
    
    public func resolutionPossible(on consumer:Component) -> Bool {
        return consumer is DependencyToken && consumer is WeakDependencyAware && component != nil;
    }
    
    public func resolveDirectly<T>()->T? {
        if(T.self == type(of:self)) {
            return self as? T;
        }
        return nil;
    }
}

public class ForeignIndirectResolver<DependencyToken,PublicInterface,Type>:Resolver {
    weak var component:Component?;
    
    public func resolve(on consumer: Component) {
        if(consumer is DependencyToken) {
            (consumer as? WeakDependencyAware)?.fill(dependency: Type.self, weaklyWith: component!);
        }
    }
    
    public func resolutionPossible(on consumer: Component) -> Bool {
        return consumer is DependencyToken && consumer is WeakDependencyAware && component != nil;
    }
    
    public func resolveDirectly<T>() -> T? {
        if(T.self == type(of:self)) {
            return self as? T;
        }
        return nil;
    }
}
