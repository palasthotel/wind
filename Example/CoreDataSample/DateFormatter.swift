//
//  DateFormatter.swift
//  CoreDataSample
//
//  Created by Enno Welbers on 05.12.17.
//  Copyright © 2017 Palasthotel. All rights reserved.
//

import Foundation
import Wind

public protocol DependsOnDateFormatting { }

extension DateFormatter : Component, ForeignSingleton, SimpleResolver {
    public func fill(dependency: Any.Type, with object: Component) {
        
    }
    
    public static func getForeignInstance() -> Component {
        let fmt = DateFormatter();
        fmt.dateStyle = .short;
        fmt.timeStyle = .none;
        return fmt;
    }
    
    public typealias DependencyToken = DependsOnDateFormatting
    
    
    
}
