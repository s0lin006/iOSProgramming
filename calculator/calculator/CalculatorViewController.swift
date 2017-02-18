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
    - decimal capability
********************************************************/

import UIKit

class CalculatorViewController: UIViewController
{
    @IBOutlet var outputLabel:      UILabel!
    @IBOutlet var button1:          UIButton!
    @IBOutlet var button2:          UIButton!
    @IBOutlet var button3:          UIButton!
    @IBOutlet var button4:          UIButton!
    @IBOutlet var button5:          UIButton!
    @IBOutlet var button6:          UIButton!
    @IBOutlet var button7:          UIButton!
    @IBOutlet var button8:          UIButton!
    @IBOutlet var button9:          UIButton!
    @IBOutlet var button0:          UIButton!
    @IBOutlet var buttonNegative:   UIButton!
    @IBOutlet var buttonDecimal:    UIButton!
    @IBOutlet var buttonClear:      UIButton!
    @IBOutlet var buttonDivide:     UIButton!
    @IBOutlet var buttonMultiply:   UIButton!
    @IBOutlet var buttonSubtract:   UIButton!
    @IBOutlet var buttonPlus:       UIButton!
    @IBOutlet var buttonEqual:      UIButton!
    
    var input1: Double = 0.0
    var input2: Double = 0.0
    var solution: Double = 0.0
    var count = 0
    
    // temp solution for operations
    // Flag: 1=add, 2=sub, 3=mul, 4=div, 5=neg, 6=dec, 7=clear, 8=equal
    var operationFlag = 0;
    
    // process input
    @IBAction func buttonPress(sender: UIButton)
    {
        if(sender == buttonPlus)
        {
            if(count != 0)
            {
                operationFlag = 1
                count = count + 1
                input2 = input1
                input1 = 0
                print("plus")
            }
        }
        else if(sender == buttonSubtract)
        {
            operationFlag = 2
            count = count + 1
            input2 = input1
            input1 = 0
            print("sub")
        }
        else if(sender == buttonMultiply)
        {
            operationFlag = 3
            count = count + 1
            input2 = input1
            input1 = 0
            print("mul")
        }
        else if(sender == buttonDivide)
        {
            operationFlag = 4
            count = count + 1
            input2 = input1
            input1 = 0
            print("div")
        }
        else if(sender == buttonNegative)
        {
            operationFlag = 5
            //input1 = input1 * -1
        }
        else if(sender == buttonDecimal)
        {
            operationFlag = 6
            count = count + 1
        }
        else if(sender == buttonClear)
        {
            operationFlag = 7
            input1 = 0
            input2 = 0
            count = 2
            print("clr")
        }
        else if(sender == buttonEqual) // if symbols
        {
            //operationFlag = 8
            count = 2
            print("equal")
        }
        else // else, digits
        {
            print(sender.currentTitle!)
            input1 = Double(sender.currentTitle!)!
            printDigit(number: String(sender.currentTitle!))
        }
        
        
        if(count == 2)
        {
            solution = calculate(input1: input1, input2: input2)
            showOutput(output: solution)
            count = 0
            print(solution)
            input1 = 0
            input2 = 0
            solution = 0
        }
        
        
        //print("input1: " + String(input1))
        //print("input2: " + String(input2))
        //print("solution: " + String(solution))
        //print("Operation flag: " + String(operationFlag))
    }
    
    func calculate(input1: Double, input2: Double) -> Double
    {
        if(operationFlag == 1)
        {
            return input1 + input2
        }
        else if(operationFlag == 2)
        {
            return input2 - input1
        }
        else if(operationFlag == 3)
        {
            return input1 * input2
        }
        else if(operationFlag == 4)
        {
            return input2 / input1
        }
        else if(operationFlag == 7)
        {
            return 0
        }
        else
        {
            return 999999999
        }
    }
    
    func printDigit(number: String)
    {
        outputLabel.text = String(number)
    }
    
    @IBAction func showOutput(output: Double)
    {
        outputLabel.text = String(output)
    }
    
}

