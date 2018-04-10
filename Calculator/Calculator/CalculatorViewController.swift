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
    var binaryOperationWhichIsPerforming: BinaryOperation.RawValue = ""
    var unaryOperationWhichIsPerforming: UnaryOperation.RawValue = ""
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
        guard let numberButtonLabelText =  sender.titleLabel?.text else { return }
        if !calculator.operationIsPerforming {
            if screenWithNumbersLabel.text != "0" {
                numberInput(numberButtonLabelText)
            } else {
                screenWithNumbersLabel.text = numberButtonLabelText
            }
            
            guard let screenLabelText = screenWithNumbersLabel.text else { return }
            if let neededNumber = Double(screenLabelText) {
                calculator.valueOnScreen = neededNumber
            } else { return }
            
        } else {
            resetCalculatorsLogic()
            screenWithNumbersLabel.text = numberButtonLabelText
        }
    }
    
    private func numberInput(_ numberText: String) {
        guard let screenLabelText = screenWithNumbersLabel.text else { return }
        screenWithNumbersLabel.text = screenLabelText + numberText
        calculator.valueOnScreen = Double(screenLabelText)!
    }
    
    @IBAction func binaryOperationButtonTapped(_ sender: UIButton) {
        guard let numberButtonLabelText = sender.titleLabel?.text else { return }
        if !calculator.operationIsPerforming {
            let result = binaryOperationPerforming()
            cutZeroIfNeededIn(result)
        }
        resetCalculatorsLogic()
        
        guard let screenLabelText = screenWithNumbersLabel.text else { return }
        if let neededNumber = Double(screenLabelText) {
            calculator.valueOnScreen = neededNumber
        } else { return }
        
        calculator.binaryOperationWhichIsPerforming = numberButtonLabelText
        calculator.operationIsPerforming = true
    }
    
    @IBAction func unaryOperationButtonTapped(_ sender: UIButton) {
        guard let screenLabelText = screenWithNumbersLabel.text else { return }
        guard let numberButtonTitleLabelText = sender.titleLabel?.text else { return }
        
        if let neededNumber = Double(screenLabelText) {
            calculator.valueOnScreen = neededNumber
        } else { return }
        
        var result = Double()
        
        guard let unaryOperation = UnaryOperation(rawValue: numberButtonTitleLabelText) else { return }
        
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
            if screenLabelText != "0"  {
                result = calculator.valueOnScreen * (-1)
            } else {
                result = 0
            }
        }
        cutZeroIfNeededIn(result)
    }
    
    @IBAction func equilButtonTapped(_ sender: UIButton) {
        let result = binaryOperationPerforming()
        cutZeroIfNeededIn(result)
        resetCalculatorsValues()
        calculator.operationIsPerforming = true
    }
    
    private func binaryOperationPerforming() -> Double {
        guard let screenLabelText = screenWithNumbersLabel.text else { return 0 }
        if let neededNumber = Double(screenLabelText) {
            calculator.valueOnScreen = neededNumber
        } else { return 0 }
        
        var result = Double()
        
        guard let binaryOperation = BinaryOperation(rawValue: calculator.binaryOperationWhichIsPerforming) else { return 0}
        
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
    
    private func cutZeroIfNeededIn(_ result: Double) {
        screenWithNumbersLabel.text = result.truncatingRemainder(dividingBy: 1.0) == 0 ? String(format: "%.0f", result) :
            String(result)
            calculator.dotIsInTheNumber = true
    }
    
    @IBAction func dotInputButtonTapped(_ sender: UIButton) {
        guard let screenLabelText = screenWithNumbersLabel.text else { return }
        if calculator.operationIsPerforming {
            screenWithNumbersLabel.text = "0."
        } else {
            screenWithNumbersLabel.text = screenLabelText + "."
        }
        calculator.valueOnScreen = Double(screenLabelText + "0")!
        calculator.dotIsInTheNumber = true
        calculator.operationIsPerforming = false
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
        calculator.binaryOperationWhichIsPerforming = ""
    }
    
    private func clearScreen() {
        screenWithNumbersLabel.text = "0"
        screenWithOperationsLabel.text = ""
    }
}
