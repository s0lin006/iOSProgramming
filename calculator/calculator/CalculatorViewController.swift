//
//  ViewController.swift
//  calculator
//
//  Created by Shan Lin on 2/5/17.
//  Copyright © 2017 Shan Lin. All rights reserved.
//

/********************************************************
TODO:
    - clear and delete
    - multiple operations before equal sign pressed
    - mem
    - multi-line?
    - decimal capability (needs more testing)
    - negative only works for first digit (needs more testing)
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

    let numberFormatter: NumberFormatter =
    {
        let nf = NumberFormatter()
        nf.numberStyle = .decimal
        nf.minimumFractionDigits = 0
        nf.maximumFractionDigits = 4
        return nf
    }()
    
    var inputStr1: String = ""
    var inputStr2: String = ""
    var outputStr: String = "0"

    var readyToCalc: Bool = false
    var secondInput: Bool = false

    // Flag: 0=nothing, 1=add, 2=sub, 3=mul, 4=div, 5=neg, 6=dec, 7=eq, 8=clr
    var operationFlag: integer_t = 0

    // process input
    @IBAction func buttonPress(sender: UIButton)
    {
        // if button is number, process digit
        if(sender == button0 || sender == button1 || sender == button2 ||
            sender == button3 || sender == button4 || sender == button5 ||
            sender == button6 || sender == button7 || sender == button8 ||
            sender == button9)
        {
            processDigit(sender: sender)
        }
        else // else, process symbols
        {
            if(sender == buttonClear)
            {
                inputStr1 = ""
                inputStr2 = ""
                outputStr = "0"
                operationFlag = 0
                showOutput(output: outputStr)
            }
            else if(sender == buttonEqual && readyToCalc == true)
            {
                outputStr = String(calculate(input1: inputStr1, input2: inputStr2, flag: operationFlag))
                showOutput(output: outputStr)
            }
            else if(sender == buttonNegative)
            {
                inputStr1 = "-" + inputStr1
            }
            else if(sender == buttonDecimal)
            {
                inputStr1 = inputStr1 + "."
            }
            else
            {
                processOperation(sender: sender)
            }
        }
    }

    func processDigit(sender: UIButton)
    {
        inputStr1 = inputStr1 + String(sender.currentTitle!)
        printNumber(number: inputStr1)

        if(secondInput == true)
        {
            readyToCalc = true
        }
    }

    // Flag: 0=nothing, 1=add, 2=sub, 3=mul, 4=div, 5=neg, 6=dec, 7=eq, 8=clr
    func processOperation(sender: UIButton)
    {
        inputStr2 = inputStr1
        inputStr1 = ""

        if(sender == buttonPlus)
        {
            operationFlag = 1
        }
        else if(sender == buttonSubtract)
        {
            operationFlag = 2
        }
        else if(sender == buttonMultiply)
        {
            operationFlag = 3
        }
        else if(sender == buttonDivide)
        {
            operationFlag = 4
        }

        secondInput = true
    }

    func calculate(input1: String, input2: String, flag: integer_t) -> Double
    {
        if(flag == 1)
        {
            return Double(input2)! + Double(input1)!
        }
        else if(flag == 2)
        {
            return Double(input2)! - Double(input1)!
        }
        else if(flag == 3)
        {
            return Double(input2)! * Double(input1)!
        }
        else if(flag == 4)
        {
            return Double(input2)! / Double(input1)!
        }
        else
        {
            return 9999 // temp. 
        }
    }
    
    //func calculate(input1: Double, input2: Double) -> Double

    func printNumber(number: String)
    {
        outputLabel.text = String(number)
    }
    
    func showOutput(output: String)
    {
        outputLabel.text = output
    }
    
}

