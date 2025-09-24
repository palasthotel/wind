//
//  SampleEntity.swift
//  CoreDataSample
//
//  Created by Enno Welbers on 05.12.17.
//  Copyright © 2017 Palasthotel. All rights reserved.
//

import Foundation
import Wind
import CoreData

public class SampleEntity: WindManagedObject,DependsOnDateFormatting {
    
    public var formattedDate: String {
        get {
            //this line is important as it ensures that this object is no longer a fault and has resolved dependencies
            let date = self.date!;
            let fmt:DateFormatter = component();
            return fmt.string(from: date);
        }
    }
    
}
