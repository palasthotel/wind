//
//  WeakDependencies.swift
//  Wind
//
//  Created by Enno Welbers on 09.06.17.
//  Copyright © 2017 Palasthotel. All rights reserved.
//

import Foundation

/// If your component depends on a foreign instantiated object,
/// it needs to be aware of weak dependencies.
/// If you don't want to think about it, simply conform to AutomaticWeakDependencyHandling.
public protocol WeakDependencyAware:Component {
    /// Components handed in via this function are not allowed to be
    /// strongly referenced.
    func fill(dependency:Any.Type, weaklyWith object:Component) -> Void;
}

/// WeakReference is used to store weak references to foreign instantiated components.
/// you should almost never use it directly.
public class WeakReference {
    weak var Instance:Component?;
    
    init(pointingAt component:Component) {
        Instance = component;
    }
}

public protocol AutomaticWeakDependencyHandling:AutomaticDependencyHandling,WeakDependencyAware {
    var weakDependencies:[String:WeakReference] {get set}
}

public extension AutomaticWeakDependencyHandling {
    func fill(dependency:Any.Type, weaklyWith object:Component) -> Void {
        weakDependencies[String(describing:dependency)] = WeakReference(pointingAt:object);
    }
    
    func weakComponent<T>() -> T? {
        return weakDependencies[String(describing:T.self)]?.Instance as? T;
    }
}

