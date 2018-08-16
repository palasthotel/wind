//
//  ViewController.swift
//  WindMacSample
//
//  Created by Enno Welbers on 16.08.18.
//  Copyright © 2018 Palasthotel. All rights reserved.
//

import Cocoa
import Wind_mac

protocol DependsOnViewController { }
class ViewController: NSViewController,DirectResolver,Component,AutomaticDependencyHandling,DependsOnAppDelegate,ForeignInstantiable {
    var dependencies: [String : [Component]] = [:];
    
    @objc dynamic var text:String = "WHAT"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //print(self.appDelegate.hello());
        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    func dependenciesFullFilled() {
        self.text = self.appDelegate.hello();
    }


}

