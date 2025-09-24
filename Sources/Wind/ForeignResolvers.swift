//
//  ForeignResolvers.swift
//  Wind
//
//  Created by Enno Welbers on 09.06.17.
//  Copyright © 2017 Palasthotel. All rights reserved.
//

import Foundation

internal class ForeignSimpleResolver<DependencyToken, Type>: DependencyResolver {
    weak var component: Component?
    
    public func resolve(on consumer:Component) -> Void {
		guard consumer is DependencyToken else {
			return
		}
        
		(consumer as? WeakDependencyAware)?.fill(dependency: Type.self, weaklyWith: component!)
    }
    
    public func resolutionPossible(on consumer: Component) -> Bool {
        return consumer is DependencyToken && consumer is WeakDependencyAware && component != nil
    }
    
    public func resolveDirectly<T>()->T? {
		guard T.self == type(of: self) else {
			return nil
		}
		
		return self as? T
    }
}


internal class ForeignIndirectResolver<DependencyToken, PublicInterface, Type>: DependencyResolver {
    weak var component: Component?
    
    public func resolve(on consumer: Component) {
        if consumer is DependencyToken {
            (consumer as? WeakDependencyAware)?.fill(dependency: PublicInterface.self, weaklyWith: component!)
        }
    }
    
    public func resolutionPossible(on consumer: Component) -> Bool {
        return consumer is DependencyToken && consumer is WeakDependencyAware && component != nil
    }
    
    public func resolveDirectly<T>() -> T? {
		guard T.self == type(of: self) else {
			return nil
		}
		
		return self as? T
    }
}
