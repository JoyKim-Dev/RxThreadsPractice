//
//  PhoneViewModel.swift
//  SeSACRxThreads
//
//  Created by Joy Kim on 8/5/24.
//

import Foundation
import RxSwift
import RxCocoa

enum phoneNumberValidation {
    case tooShort
    case tooLong
    case notANumber
    case valid
    
    var text:String {
        switch self {
        case .tooShort:
            "10자리를 입력해주세요"
        case .tooLong:
            "너무 깁니다. 전화번호를 다시 확인해주세요."
        case .notANumber:
            "숫자가 아닌 입력값입니다. 다시 확인해주세요"
        case .valid:
            "유효한 전화번호입니다."
        }
    }
}

class PhoneViewModel {
    
    struct Input {
        let tap: ControlEvent<Void> // nextButton.rx.tap
        let text: ControlProperty<String?> // phoneTextField.rx.text
        
    }
    
    struct Output {
        let tap: ControlEvent<Void>
        let validText: Observable<String>
        let validation: Observable<phoneNumberValidation?>
        let isValid: Observable<Bool>
        
    }
    
    func transform(input: Input) -> Output {
        let validation = input.text.orEmpty.map {  text -> phoneNumberValidation? in
            if text.rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) != nil {
                return .notANumber
            } else if text.count < 10 {
                return .tooShort
            } else if text.count > 11 {
                return .tooLong
            } else {
                return .valid
            }
        }
        let validText = validation.map { $0?.text ?? "" }
        
        let isValid = validation.map { $0 == .valid }
        
        return Output(
            tap: input.tap,
            validText: validText,
            validation: validation,
            isValid: isValid
        )
    }
}

