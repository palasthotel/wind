//
//  ViewController.swift
//  WindSample
//
//  Created by Enno Welbers on 09.06.17.
//  Copyright © 2017 Palasthotel. All rights reserved.
//

import UIKit
import Wind

class ViewController: UIViewController,AutomaticDependencyHandling,DirectResolver,AppDelegateDependency {

    var dependencies: [String : [Component]] = [:]
    
    @IBOutlet weak var label: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        label.text=self.appDelegate.message()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

