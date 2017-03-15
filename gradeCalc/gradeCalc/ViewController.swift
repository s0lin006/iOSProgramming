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

    @IBOutlet var actualGrade1: UITextField!
    @IBOutlet var actualGrade2: UITextField!
    @IBOutlet var actualGrade3: UITextField!
    @IBOutlet var actualGrade4: UITextField!
    @IBOutlet var actualGrade5: UITextField!

    var temp: Double = 0.0

    @IBAction func buttonPress(sender: UIButton)
    {
        temp = (Double(actualGrade1.text!)! * (Double(gradeWorth1.text!)! / 100)) +
            (Double(actualGrade2.text!)! * (Double(gradeWorth2.text!)! / 100)) +
            (Double(actualGrade3.text!)! * (Double(gradeWorth3.text!)! / 100)) +
            (Double(actualGrade4.text!)! * (Double(gradeWorth4.text!)! / 100)) +
            (Double(actualGrade5.text!)! * (Double(gradeWorth5.text!)! / 100))

        finalGradeLabel.text = String(temp)
    }

    @IBAction func dismissKeyboard(sender: AnyObject)
    {
        actualGrade1.resignFirstResponder()
    }
}

