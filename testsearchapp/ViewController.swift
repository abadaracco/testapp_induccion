//
//  ViewController.swift
//  testsearchapp
//
//  Created by Alvaro Badaracco on 4/7/20.
//  Copyright © 2020 Mercado Libre. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var searchInput: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == "search" {
            guard let listVC = segue.destination as? ListViewController else {
                return
            }
            
            listVC.query = searchInput.text!
        } else if segue.identifier == "history" {
            guard let listVC = segue.destination as? ListViewController else {
                return
            }
            listVC.mode = .history
        }
        
    }

}

