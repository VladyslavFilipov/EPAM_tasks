//
//  CamculatorViewController.swift
//  Calculator
//
//  Created by Vladislav Filipov on 09.04.18.
//  Copyright © 2018 Vladislav Filipov. All rights reserved.
//

import UIKit

struct CalculatorsData {
    var previousValue: Double = 0
    var valueOnScreen: Double = 0
    var valueDischarge: Double = 0
    var binaryOperationWhichIsPerforming: BinaryOperation.RawValue = ""
    var unaryOperationWhichIsPerforming: UnaryOperation.RawValue = ""
    var previousValueMutated: Bool = false
    var operationIsPerforming: Bool = false
    var dotIsInTheNumber: Bool = false
}

enum BinaryOperation: String {
    case add = "+"
    case substract = "-"
    case multiply = "*"
    case divide = "/"
    case percent = "%"
    case xPowToY = "xʸ"
}

enum UnaryOperation: String {
    case invert = "+/-"
    case xPowTo2 = "x²"
    case xPowTo3 = "x³"
    case ePowToX = "eˣ"
    case sin = "sin"
    case cos = "cos"
    case tg = "tg"
    case ctg = "ctg"
}

class CalculatorViewController: UIViewController {
    var calculator = CalculatorsData()
    var binaryOperation = BinaryOperation.self
    var unaryOperation = UnaryOperation.self
    
    @IBOutlet weak var screenWithNumbersLabel: UILabel!
    @IBOutlet weak var screenWithOperationsLabel: UILabel!
    
    @IBAction func numberButtonTapped(_ sender: UIButton) {
        if !calculator.operationIsPerforming {
            if calculator.valueOnScreen != 0 {
                if !calculator.dotIsInTheNumber {
                    numberInputIfContinueInputing(sender.tag)
                    print("3")
                } else {
                    numberInputIfDotIsInTheNumber(sender.tag)
                    print("4")
                }
            } else {
                numberInputIfStartInputing(sender.tag)
            }
        } else if calculator.operationIsPerforming && !calculator.dotIsInTheNumber {
            resetCalculatorsLogic()
            numberInputIfStartInputing(sender.tag)
            print("1")
        } else if calculator.operationIsPerforming && calculator.dotIsInTheNumber{
            resetCalculatorsLogic()
            calculator.valueDischarge = 1
            numberInputIfDotIsInTheNumber(sender.tag)
            calculator.dotIsInTheNumber = true
            print("2")
        }
    }
    
    private func numberInputIfContinueInputing(_ numberText: Int) {
        calculator.valueOnScreen = calculator.valueOnScreen * 10 + Double(numberText)
        calculator.valueDischarge += 1
        cutZeroIfNeededIn(calculator.valueOnScreen)
    }
    
    private func numberInputIfDotIsInTheNumber(_ numberText: Int) {
        calculator.valueOnScreen = calculator.valueOnScreen + Double(numberText) / pow(10, calculator.valueDischarge)
        calculator.valueDischarge += 1
        cutZeroIfNeededIn(calculator.valueOnScreen)
    }
    
    private func numberInputIfStartInputing(_ numberText: Int) {
        calculator.valueOnScreen = Double(numberText)
        cutZeroIfNeededIn(calculator.valueOnScreen)
        calculator.operationIsPerforming = false
    }
    
    @IBAction func binaryOperationButtonTapped(_ sender: UIButton) {
        guard let operation = sender.titleLabel?.text else { return }
        equality()
        calculator.operationIsPerforming = true
        calculator.previousValueMutated = true
        calculator.dotIsInTheNumber = false
        calculator.binaryOperationWhichIsPerforming = operation
    }
    
    @IBAction func unaryOperationButtonTapped(_ sender: UIButton) {
        guard let numberButtonTitleLabelText = sender.titleLabel?.text else { return }
        guard let unaryOperation = UnaryOperation(rawValue: numberButtonTitleLabelText) else { return }
    
        var result = Double()
        
        switch unaryOperation {
        case .sin:
            result = sin(calculator.valueOnScreen)
        case .cos:
            result = cos(calculator.valueOnScreen)
        case .tg:
            result = tan(calculator.valueOnScreen)
        case .ctg:
            result = pow(tan(calculator.valueOnScreen), -1)
        case .xPowTo2:
            result = pow(calculator.valueOnScreen, 2)
        case .xPowTo3:
            result = pow(calculator.valueOnScreen, 3)
        case .ePowToX:
            result = pow(2.781, calculator.valueOnScreen)
        case .invert:
            if calculator.valueOnScreen != 0  {
                result = calculator.valueOnScreen * (-1)
            } else {
                result = 0
            }
        }
        cutZeroIfNeededIn(result)
        calculator.valueOnScreen = result
    }
    
    @IBAction func equilButtonTapped(_ sender: UIButton) {
        equality()
        calculator.operationIsPerforming = false
        calculator.previousValueMutated = false
        calculator.binaryOperationWhichIsPerforming = ""
    }
    
    private func equality() {
        var result = calculator.valueOnScreen
        if !calculator.operationIsPerforming && calculator.previousValueMutated {
            print(binaryOperationPerforming())
            result = binaryOperationPerforming()
            cutZeroIfNeededIn(result)
            calculator.valueOnScreen = result
        }
        calculator.previousValue = result
        calculator.valueDischarge = 0
    }
    
    private func binaryOperationPerforming() -> Double {
        guard let binaryOperation = BinaryOperation(rawValue: calculator.binaryOperationWhichIsPerforming) else { return 0 }
        
        var result = Double()
        
        switch binaryOperation {
        case .add:
            result = calculator.previousValue + calculator.valueOnScreen
        case .substract:
            result = calculator.previousValue - calculator.valueOnScreen
        case .multiply:
            result = calculator.previousValue * calculator.valueOnScreen
        case .divide:
            result = calculator.previousValue / calculator.valueOnScreen
        case .percent:
            result = (calculator.previousValue / calculator.valueOnScreen) * 100
        case .xPowToY:
            result = pow(calculator.previousValue, calculator.valueOnScreen)
        }
        
        return result
    }
    
    private func cutZeroIfNeededIn(_ value: Double) {
        screenWithNumbersLabel.text = value.truncatingRemainder(dividingBy: 1.0) == 0 ? String(format: "%g", value) :
        String(value)
    }
    
    @IBAction func dotInputButtonTapped(_ sender: UIButton) {
        calculator.dotIsInTheNumber = true
        if !calculator.operationIsPerforming {
            screenWithNumbersLabel.text = String(calculator.valueOnScreen)
        } else {
            calculator.valueOnScreen = 0
            screenWithNumbersLabel.text = String(calculator.valueOnScreen)
        }
    }
    
    @IBAction func resetCalculatorButtonTapped(_ sender: UIButton) {
        clearScreen()
        resetCalculatorsValues()
        resetCalculatorsLogic()
    }
    
    private func resetCalculatorsLogic() {
        calculator.operationIsPerforming = false
        calculator.dotIsInTheNumber = false
    }
    
    private func resetCalculatorsValues() {
        calculator.previousValue = 0
        calculator.valueOnScreen = 0
        calculator.valueDischarge = 0
        calculator.binaryOperationWhichIsPerforming = ""
    }
    
    private func clearScreen() {
        screenWithNumbersLabel.text = "0"
        screenWithOperationsLabel.text = ""
    }
}
