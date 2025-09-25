//
//  SecondViewController.swift
//  Wind
//
//  Created by Enno Welbers on 09.06.17.
//  Copyright © 2017 Palasthotel. All rights reserved.
//

import UIKit
import Wind

protocol SecondViewControllerDependency {
    
}

extension SecondViewControllerDependency where Self:AutomaticWeakDependencyHandling {
    var secondViewController:SecondViewController? { get { return weakComponent() as SecondViewController?;}}
}

class SecondViewController: UIViewController,ForeignInstantiable,SimpleResolver,AutomaticDependencyHandling {

    var dependencies: [String : [Component]] = [:];
    
    typealias DependencyToken = SecondViewControllerDependency
    override func viewDidLoad() {
        super.viewDidLoad()

        if let container = self.storyboard?.container {
            self.resolveMe(in: container);
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
