//
//  Resolver.swift
//  Wind
//
//  Created by Enno Welbers on 06.06.17.
//  Copyright © 2017 Palasthotel. All rights reserved.
//

import Foundation

/// Resolver's are capable of resolving Dependencies.
/// There are two modes: automatic and direct.
/// In automatic mode the resolver examines a component and
/// Fills in all dependencies it is capable of.
/// In direct mode it tries to meet a single dependency directly.

public protocol Resolver: AnyObject {
	func resolve(on consumer: WindComponent) -> Void
	func resolutionPossible(on consumer: WindComponent) -> Bool
	func resolveDirectly<T>()->T?
	
}
