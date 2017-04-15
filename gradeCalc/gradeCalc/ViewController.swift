//
//  ViewController.swift
//  gradeCalc
//
//  Created by Shan Lin on 3/15/17.
//  Copyright © 2017 Shan Lin. All rights reserved.
//

import UIKit


/* --------------------------------------------------
 
 TODO:
    - keyboard not toggling
    - loop, or array for grade calculation
    - pop-up menu to add new grade
    - add new class/ multi-class


 --------------------------------------------------*/

class ViewController: UIViewController
{
    @IBOutlet var finalGradeLabel: UILabel!
    @IBOutlet var className: UILabel!
    @IBOutlet var calculateButton: UIButton!

    @IBOutlet var gradeName1: UITextField!
    @IBOutlet var gradeName2: UITextField!
    @IBOutlet var gradeName3: UITextField!
    @IBOutlet var gradeName4: UITextField!
    @IBOutlet var gradeName5: UITextField!

    @IBOutlet var gradeWorth1: UITextField!
    @IBOutlet var gradeWorth2: UITextField!
    @IBOutlet var gradeWorth3: UITextField!
    @IBOutlet var gradeWorth4: UITextField!
    @IBOutlet var gradeWorth5: UITextField!

    @IBOutlet var actualGrade: [UITextField] = []

    var temp: Double = 0.0

    @IBAction func buttonPress(sender: UIButton)
    {
        temp = 0.0
        
        for i in actualGrade
        {
            temp = temp + ((Double(i.text!)!) * (0.25))
            print("temp:" + String(temp))
        }
        //temp = Double(actualGrade[0].text!)! + Double(actualGrade[1].text!)!
        finalGradeLabel.text = String(temp)
    }
}

