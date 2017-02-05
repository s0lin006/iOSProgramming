//
//  ViewController.swift
//  calculator
//
//  Created by Shan Lin on 2/5/17.
//  Copyright © 2017 Shan Lin. All rights reserved.
//

/********************************************************
TODO:
    - more operations (sub, mul, div)
    - multi-digit
    - clear and delete
    - multiple operations before equal sign pressed
    - mem
    - multi-line?
********************************************************/

import UIKit

class CalculatorViewController: UIViewController
{
    @IBOutlet var outputLabel: UILabel!
    @IBOutlet var button1: UIButton!
    @IBOutlet var button2: UIButton!
    @IBOutlet var button3: UIButton!
    @IBOutlet var button4: UIButton!
    @IBOutlet var button5: UIButton!
    @IBOutlet var button6: UIButton!
    @IBOutlet var button7: UIButton!
    @IBOutlet var button8: UIButton!
    @IBOutlet var button9: UIButton!
    @IBOutlet var button0: UIButton!
    @IBOutlet var buttonPlus: UIButton!
    @IBOutlet var buttonEqual: UIButton!
    
    var input1: Double = 0.0
    var input2: Double = 0.0
    
    // temp solution for operations
    var operationFlag = 0;
    
    @IBAction func buttonPress(sender: UIButton)
    {
        if(sender == buttonEqual) // if symbols
        {
            showOutput()
        }
        else if(sender == buttonPlus)
        {
            add()
        }
        else // else, digits
        {
            print(sender.currentTitle!)
            input1 = Double(sender.currentTitle!)!
        }
    }
    
    func add()
    {
        input2 = input1
        operationFlag = 1
    }
    
    func calculate() -> Double
    {
        if(operationFlag == 1)
        {
            return input1 + input2
        }
        else
        {
            return 1111
        }
    }
    
    @IBAction func showOutput()
    {
        outputLabel.text = String(calculate())
    }
    
}

