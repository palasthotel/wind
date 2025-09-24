//
//  Resolvers.swift
//  Wind
//
//  Created by Enno Welbers on 06.06.17.
//  Copyright © 2017 Palasthotel. All rights reserved.
//

import Foundation

/// The DirectResolver is only capable of resolving directly. 
/// Automatic Mode is not supported.
/// This protocol provides you with a default implementation.
public protocol DirectResolver: Resolver {
}

public extension DirectResolver where Self: WindComponent {
	func resolve(on consumer: WindComponent) {
		//not implemented
	}
	
	func resolutionPossible(on consumer: WindComponent) -> Bool {
		false
	}
	
	func resolveDirectly<T>() -> T? {
		guard T.self == type(of: self) else {
			return nil
		}
		
		return self as? T
	}
}

/// The SimpleResolver resolves in both modes the type it's applied to.
/// For automatic mode detection you need to give us a type hint.
/// If the component can be typecast into the hint, the dependency gets fullfilled.
public protocol SimpleResolver: Resolver {
	associatedtype DependencyToken
}

public extension SimpleResolver where Self: WindComponent {
	func resolve(on consumer: WindComponent) -> Void {
		guard consumer is DependencyToken else {
			return
		}
		
		consumer.fill(dependency: type(of: self), with: self)
	}
	
	func resolutionPossible(on consumer: WindComponent) -> Bool {
		return consumer is DependencyToken;
	}
	
	func resolveDirectly<T>()->T? {
		guard T.self == type(of: self) else {
			return nil
		}
		
		return self as? T
	}
}

/// The IndirectResolver is just as the SimpleResolver capable of resolving in both modes.
/// But: it casts the component into an protocol to hide the implementation.
public protocol IndirectResolver: Resolver {
	associatedtype DependencyToken
	associatedtype PublicInterface
}

public extension IndirectResolver where Self: WindComponent{
	func resolve(on consumer: WindComponent) -> Void {
		guard consumer is DependencyToken else {
			return
		}
		
		consumer.fill(dependency: PublicInterface.self, with: self)
	}
	
	func resolutionPossible(on consumer: WindComponent) -> Bool {
		consumer is DependencyToken
	}
	
	func resolveDirectly<T>() -> T? {
		guard type(of: T.self) == type(of: PublicInterface.self) else {
			return nil
		}
		
		return self as? T
	}
}
