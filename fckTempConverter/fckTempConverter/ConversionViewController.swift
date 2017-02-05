//
//  ConversionViewController.swift
//  WorldTrotter
//
//  Created by Shan Lin on 1/22/17.
//  Copyright © 2017 Big Nerd Ranch. All rights reserved.
//

import UIKit

class ConversionViewController: UIViewController, UITextFieldDelegate
{
    @IBOutlet var celsiusLabel: UILabel!
    @IBOutlet var kelvinLabel: UILabel!
    @IBOutlet var textField: UITextField!
    
    let numberFormatter: NumberFormatter =
    {
        let nf = NumberFormatter()
        nf.numberStyle = .decimal
        nf.minimumFractionDigits = 0
        nf.maximumFractionDigits = 2
        return nf
    }()
    
    var fahrenheitValue: Double?
    {
        didSet
        {
            updateCelsiusLabel()
            updateKelvinValue()
        }
    }
    
    var celsiusValue: Double?
    {
        if let value = fahrenheitValue
        {
            return (value - 32) * (5/9)
        }
        else
        {
            return nil
        }
    }
    
    var kelvinValue: Double?
    {
        if let value = fahrenheitValue
        {
            return (value - 32) * (5/9) + 273.15
        }
        else
        {
            return nil
        }
    }
    
    func updateCelsiusLabel()
    {
        if let value = celsiusValue
        {
            celsiusLabel.text = numberFormatter.string(from: NSNumber(value: value))
        }
        else
        {
            celsiusLabel.text = "---"
        }
    }
    
    func updateKelvinValue()
    {
        if let value = kelvinValue
        {
            kelvinLabel.text = numberFormatter.string(from: NSNumber(value: value))
        }
        else
        {
            kelvinLabel.text = "---"
        }
    }
    
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool
    {
        let existingTextHasDecimalSeparator = textField.text?.range(of: ".")
        let replacementTextHasDecimalSeparator = string.range(of: ".")
        
        if existingTextHasDecimalSeparator != nil && replacementTextHasDecimalSeparator != nil
        {
            return false
        }
        else
        {
            return true
        }
    }
    
    @IBAction func fahrennheitFieldEditingChanged(textField: UITextField)
    {
        if let text = textField.text, let value = Double(text)
        {
            fahrenheitValue = value
        }
        else
        {
            fahrenheitValue = nil
        }
    }
    
    @IBAction func dismissKeyboard(sender: AnyObject)
    {
        textField.resignFirstResponder()
    }
}
