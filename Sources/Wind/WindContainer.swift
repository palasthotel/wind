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


public class WindContainer: WindComponent, AutomaticDependencyHandling, SimpleResolver {
	
	public enum ResolutionError: Error {
		case cycleDetected([WindComponent])
	}
	
	public var dependencies: [String : [WindComponent]] = [:]
	
	public typealias DependencyToken = ContainerDependency
	var components: [WindComponent] = []
	var resolvers: [Resolver] = []
	var readyResolvers: [Resolver] = []
	
	public required init() {
		resolvers.append(self)
		readyResolvers.append(self)
	}
	
	public func register(component: WindComponent) -> Void {
		components.append(component)
	}
	
	public func register(resolver: Resolver) -> Void {
		resolvers.append(resolver)
		if !(resolver is WindComponent) {
			readyResolvers.append(resolver)
		}
	}
	
	public func bootstrap() throws {
		for comp in resolvers.filter( { $0 is WindComponent } ).map( { $0 as! WindComponent }) {
			try resolve(for: comp)
		}
	}
	
	func resolverIsReady(_ resolver: Resolver) -> Bool {
		if resolver is WindComponent {
			return readyResolvers.contains(where: { $0 === resolver } )
		}
		
		return true
	}
	
	private func resolve(for consumer: WindComponent, alreadyResolving: [WindComponent]) throws -> Void {
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
				try resolve(for: resolver as! WindComponent, alreadyResolving: alreadyResolving + [consumer])
			}
			
			resolver.resolve(on: consumer)
		}
		
		if consumer is Resolver && !(consumer is ForeignInstantiable) {
			readyResolvers.append(consumer as! Resolver)
		}
		
		ObjectRegistry.register(object: consumer, for: self)
		consumer.dependenciesFullfilled()
	}
	
	public func resolve(for consumer: WindComponent) throws -> Void {
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
