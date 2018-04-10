//
//  ViewController.swift
//  Calculator
//
//  Created by Vladislav Filipov on 03.04.18.
//  Copyright © 2018 Vladislav Filipov. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var screen: UILabel! // fix screenLabel
    @IBOutlet weak var operationPointer: UILabel!
    
    var currentValue: Double = 0
    var previousNumber: Double = 0
    var operation = 0
    var operationInAction = false // fix one var + change name
    var operationDone = false
    var dotButtonPressed = false //fix
    
    @IBAction func deleteButtonPushed(_ sender: Any) { // fix
        previousNumber = 0
        currentValue = 0
        operation = 0
        operationPointer.text = ""
        delete()
    }
    
    @IBAction func binaryOperationButtonPushed(_ sender: UIButton) {
        if screen.text != "" {
            operationPointer.text = sender.titleLabel?.text
            if !operationInAction {
                equilButtonPushed(sender)
            }
            print(sender.tag)
            operation = sender.tag
            guardedScreenText()
            dotButtonPressed = false
            operationInAction = true
        }
    }
    
    @IBAction func equilButtonPushed(_ sender: UIButton) {
        print("operation = \(operation)")
        if operation != 0 {
            operationPointer.text = sender.titleLabel?.text
            let result = operationDoing(sender.tag)
            doubleAndIntEquality(result)
            previousNumber = 0
            currentValue = 0
            operation = 0
            operationDone = true
            dotButtonPressed = false
            operationInAction = false
        }
    }
    
    @IBAction func dotButtonPushed(_ sender: UIButton) {
        if operationDone {
            screen.text = "0"
            dotOnScreen() // FIXME: - HGHH
            dotButtonPressed = true
        } else if operationInAction == false {
            if dotButtonPressed == false {
                if screen.text != "" {
                    dotOnScreen()
                } else {
                    screen.text = "0"
                    dotOnScreen()
                }
            }
        } else {
            screen.text = "0"
            dotOnScreen()
            dotButtonPressed = true
        }
    }
    
    @IBAction func convertButtonPushed(_ sender: UIButton) {
        if Double(screen.text!) != nil {
            operationPointer.text = sender.titleLabel?.text
            operationInAction = true
            let result = Double(screen.text!)! * (-1)
            doubleAndIntEquality(result)
            operationInAction = true
        }
    }
    
    @IBAction func numberButtonPushed(_ sender: UIButton) {
        if operationDone == false {
            numberInsertChanging(sender.tag)
        } else {
            operationDone = false
            dotButtonPressed = false
            operationInAction = true
            numberInsertChanging(sender.tag)
        }
    }
    
    @IBAction func unaryOperationsButtonPushed(_ sender: UIButton) { // FIXME: ENUM
        var result = Double()
        switch sender.tag {
        case 107:
            result = sin(Double(screen.text!)!)
        case 108:
            result = cos(Double(screen.text!)!)
        case 109:
            result = tan(Double(screen.text!)!)
        case 110:
            result = pow(tan(Double(screen.text!)!), -1)
        case 111:
            currentValue = 2
            result = pow(Double(screen.text!)!, currentValue)
        case 112:
            previousNumber = 3
            result = pow(Double(screen.text!)!, previousNumber)
        case 114:
            result = pow(2.718, Double(screen.text!)!)
        default:
            break
        }
        operationPointer.text = sender.titleLabel?.text
        currentValue = result
        operationDone = true
        doubleAndIntEquality(result)
    }
    
    private func delete() { // rename
        screen.text = "0"
        dotButtonPressed = false
        operationDone = false
        operationInAction = false
    }
    
    private func doubleAndIntEquality(_ result: Double) {
        screen.text = result.truncatingRemainder(dividingBy: 1.0) == 0 ? String(format: "%.0f", result) : String(result)
    }
    
    private func dotOnScreen() { // FIXME: RENAME
        if let value = Double(screen.text!) {
            if value - Double(Int(value)) == 0 {
                screen.text = screen.text! + "."
                currentValue = Double(screen.text! + "0")!
                dotButtonPressed = true
            } else if operationInAction == true || operationDone == true {
                screen.text = "0."
                currentValue = Double(screen.text! + "0")!
                dotButtonPressed = true
            }
        }
    }
    
    private func guardedScreenText() {
        if let number = Double(screen.text!) { // fixed
            previousNumber = number
        } else {}
    }
    
    private func operationDoing(_ operetion: Int) -> Double {
        var result = Double()
        switch operation {
        case 101:
            result = (previousNumber / currentValue) * 100
        case 102:
            result = previousNumber / currentValue
        case 103:
            result = previousNumber * currentValue
        case 104:
            result = previousNumber - currentValue
        case 105:
            result = previousNumber + currentValue
        case 113:
            result = pow(previousNumber, currentValue)
        default:
            break
        }
        if result == Double.infinity {
            result = Double.infinity
        }
        print(result)
        return result
    }
    
    private func numberInsertChanging(_ sender: Int) {
        if operationInAction == true && screen.text != "0." {
            screen.text = String(sender - 10)
            currentValue = Double(screen.text!)!
            operationInAction = false
        } else if operationInAction == true && screen.text == "0."{
            screen.text = screen.text! + String(sender - 10)
            currentValue = Double(screen.text!)!
            operationInAction = false
        } else if operationInAction == false && screen.text! == "0" {
            screen.text = String(sender - 10)
            currentValue = Double(screen.text!)!
        } else if operationInAction == false && screen.text! == "0." {
            screen.text = screen.text! + String(sender - 10)
            currentValue = Double(screen.text!)!
        } else if operationInAction == false && screen.text! != "0"{
            screen.text = screen.text! + String(sender - 10)
            currentValue = Double(screen.text!)!
        } else {
            screen.text = screen.text! + String(sender - 10)
            currentValue = Double(screen.text!)!
        }
    }
}

