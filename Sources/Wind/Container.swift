//
//  Container.swift
//  Wind
//
//  Created by Enno Welbers on 06.06.17.
//  Copyright © 2017 Palasthotel. All rights reserved.
//

import Foundation

/// If you need direct access to the container, this is your way to go.
public protocol ContainerDependency {
}


public class Container: Component, AutomaticDependencyHandling, SimpleResolver {
	
	public enum ResolutionError: Error {
		case cycleDetected([Component])
	}
	
	public var dependencies: [String : [Component]] = [:]
	
	public typealias DependencyToken = ContainerDependency
	var components: [Component] = []
	var resolvers: [DependencyResolver] = []
	var readyResolvers: [DependencyResolver] = []
	
	public required init() {
		resolvers.append(self)
		readyResolvers.append(self)
	}
	
	public func register(component: Component) -> Void {
		components.append(component)
	}
	
	public func register(resolver: DependencyResolver) -> Void {
		resolvers.append(resolver)
		if !(resolver is Component) {
			readyResolvers.append(resolver)
		}
	}
	
	public func bootstrap() throws {
		for comp in resolvers.filter( { $0 is Component } ).map( { $0 as! Component }) {
			try resolve(for: comp)
		}
	}
	
	func resolverIsReady(_ resolver: DependencyResolver) -> Bool {
		if resolver is Component {
			return readyResolvers.contains(where: { $0 === resolver } )
		}
		
		return true
	}
	
	private func resolve(for consumer: Component, alreadyResolving: [Component]) throws -> Void {
		if alreadyResolving.contains(where: { $0 === consumer }) {
			throw ResolutionError.cycleDetected(alreadyResolving)
		}
		
		for resolver in resolvers {
			if resolver === consumer {
				continue
			}
			if !resolver.resolutionPossible(on: consumer) {
				continue
			}
			
			if !resolverIsReady(resolver) {
				try resolve(for: resolver as! Component, alreadyResolving: alreadyResolving + [consumer])
			}
			
			resolver.resolve(on: consumer)
		}
		
		if consumer is DependencyResolver && !(consumer is ForeignInstantiable) {
			readyResolvers.append(consumer as! DependencyResolver)
		}
		
		ObjectRegistry.register(object: consumer, for: self)
		consumer.dependenciesFullfilled()
	}
	
	public func resolve(for consumer: Component) throws -> Void {
		try resolve(for: consumer, alreadyResolving: [])
	}
	
	public func resolve<T>() -> T! {
		for resolver in resolvers {
			let result: T? = resolver.resolveDirectly()
			
			if result != nil {
				return result
			}
		}
		
		return nil
	}
}
