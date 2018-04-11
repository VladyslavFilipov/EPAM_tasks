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

enum CalculatorError: Error {
    case operationHaveNoSense
    case divideOn0
    case wrongTgValue
    case wrongCtgValue
    case infinityValue
    
    var localizedDescription: String {
        switch self {
        case .operationHaveNoSense:
            return "Operations with inf will give you inf"
        case .divideOn0:
            return "Error: divide on 0"
        case .wrongTgValue:
            return "Error: tg haven`t such values"
        case .wrongCtgValue:
            return "Error: ctg haven`t such values"
        case .infinityValue:
            return "Error: your`s value goes to inf"
        }
    }
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
                    do {
                        try numberInputIfContinueInputing(sender.tag)
                    } catch CalculatorError.infinityValue {
                        screenWithNumbersLabel.text = CalculatorError.infinityValue.localizedDescription
                        resetCalculatorsLogic()
                        resetCalculatorsValues()
                    } catch {
                        screenWithNumbersLabel.text = "Unexpected error"
                        resetCalculatorsLogic()
                        resetCalculatorsValues()
                    }
                } else {
                    numberInputIfDotIsInTheNumber(sender.tag)
                }
            } else {
                numberInputIfStartInputing(sender.tag)
            }
        } else if calculator.operationIsPerforming && !calculator.dotIsInTheNumber {
            resetCalculatorsLogic()
            numberInputIfStartInputing(sender.tag)
        } else if calculator.operationIsPerforming && calculator.dotIsInTheNumber{
            resetCalculatorsLogic()
            calculator.valueDischarge = 1
            numberInputIfDotIsInTheNumber(sender.tag)
            calculator.dotIsInTheNumber = true
        }
    }
    
    private func numberInputIfContinueInputing(_ numberText: Int) throws {
        calculator.valueOnScreen = calculator.valueOnScreen * 10 + Double(numberText)
        calculator.valueDischarge += 1
        if calculator.valueOnScreen == Double.infinity {
            throw CalculatorError.infinityValue
        } else {
            cutZeroIfNeededIn(calculator.valueOnScreen)
        }
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
    
    @IBAction func unaryOperationButtonTapped(_ sender: UIButton)  {
        do {
            var result = Double()
            try result = unaryOperationPerforming(sender.titleLabel?.text)
            cutZeroIfNeededIn(result)
            calculator.valueOnScreen = result
        } catch CalculatorError.operationHaveNoSense {
            screenWithNumbersLabel.text = CalculatorError.operationHaveNoSense.localizedDescription
            resetCalculatorsLogic()
            resetCalculatorsValues()
        } catch CalculatorError.wrongTgValue {
            screenWithNumbersLabel.text = CalculatorError.wrongTgValue.localizedDescription
            resetCalculatorsValues()
            resetCalculatorsLogic()
        } catch CalculatorError.wrongCtgValue {
            screenWithNumbersLabel.text = CalculatorError.wrongCtgValue.localizedDescription
            resetCalculatorsValues()
            resetCalculatorsLogic()
        } catch CalculatorError.infinityValue {
            screenWithNumbersLabel.text = CalculatorError.infinityValue.localizedDescription
            resetCalculatorsLogic()
            resetCalculatorsValues()
        } catch {
            screenWithNumbersLabel.text = "Unexpected error"
            resetCalculatorsLogic()
            resetCalculatorsValues()
        }
    }
    
    private func unaryOperationPerforming(_ operationButtonTitleText: String?) throws -> Double{
        guard let numberButtonTitleLabelText = operationButtonTitleText else { return 0 }
        guard let unaryOperation = UnaryOperation(rawValue: numberButtonTitleLabelText) else { return 0 }
        
        var result = Double()
        
        if calculator.valueOnScreen == Double.infinity {
            throw CalculatorError.operationHaveNoSense
        } else {
            switch unaryOperation {
            case .sin:
                result = sin(calculator.valueOnScreen)
            case .cos:
                result = cos(calculator.valueOnScreen)
            case .tg:
                if calculator.valueOnScreen != 90 || calculator.valueOnScreen != 270 {
                    result = tan(calculator.valueOnScreen)
                } else {
                    throw CalculatorError.wrongTgValue
                }
            case .ctg:
                if calculator.valueOnScreen != 0 || calculator.valueOnScreen != 180 || calculator.valueOnScreen != 360 {
                    result = pow(tan(calculator.valueOnScreen), -1)
                } else {
                    throw CalculatorError.wrongCtgValue
                }
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
        }
        
        if result == Double.infinity {
            throw CalculatorError.infinityValue
        } else {
            return result
        }
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
            
            do {
                try result = binaryOperationPerforming()
                cutZeroIfNeededIn(result)
                calculator.valueOnScreen = result
            } catch CalculatorError.operationHaveNoSense {
                screenWithNumbersLabel.text = CalculatorError.operationHaveNoSense.localizedDescription
                resetCalculatorsLogic()
                resetCalculatorsValues()
            } catch CalculatorError.divideOn0 {
                screenWithNumbersLabel.text = CalculatorError.divideOn0.localizedDescription
                resetCalculatorsLogic()
                resetCalculatorsValues()
            } catch CalculatorError.infinityValue {
                screenWithNumbersLabel.text = CalculatorError.infinityValue.localizedDescription
                resetCalculatorsLogic()
                resetCalculatorsValues()
            } catch {
                screenWithNumbersLabel.text = "Unexpected error"
                resetCalculatorsLogic()
                resetCalculatorsValues()
            }
        }
        calculator.previousValue = result
        calculator.valueDischarge = 0
    }
    
    private func binaryOperationPerforming() throws -> Double {
        guard let binaryOperation = BinaryOperation(rawValue: calculator.binaryOperationWhichIsPerforming) else { return 0 }
        
        var result = Double()
        
        if calculator.previousValue == Double.infinity {
            throw CalculatorError.operationHaveNoSense
        } else {
            switch binaryOperation {
            case .add:
                result = calculator.previousValue + calculator.valueOnScreen
            case .substract:
                result = calculator.previousValue - calculator.valueOnScreen
            case .multiply:
                result = calculator.previousValue * calculator.valueOnScreen
            case .divide:
                if calculator.valueOnScreen != 0 {
                    result = calculator.previousValue / calculator.valueOnScreen
                } else {
                    throw CalculatorError.divideOn0
                }
            case .percent:
                result = (calculator.previousValue / calculator.valueOnScreen) * 100
            case .xPowToY:
                result = pow(calculator.previousValue, calculator.valueOnScreen)
            }
        }
        
        if result == Double.infinity {
            throw CalculatorError.infinityValue
        } else {
            return result
        }
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
    
    func resetCalculatorsLogic() {
        calculator.operationIsPerforming = false
        calculator.dotIsInTheNumber = false
    }
    
    func resetCalculatorsValues() {
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
