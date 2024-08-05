//
//  BirthdayViewModel.swift
//  SeSACRxThreads
//
//  Created by Joy Kim on 8/5/24.
//

import Foundation
import RxSwift
import RxCocoa

class BirthdayViewModel {
    
    
    struct Input {
            let date: Observable<Date>
            let tap: Observable<Void>
        }
        
        struct Output {
            let yearText: Observable<String>
            let monthText: Observable<String>
            let dayText: Observable<String>
            let ageValid: Observable<Bool>
            let tap: Observable<Void>
        }
        
        func transform(input: Input) -> Output {
            let dateComponents = input.date
                .map { Calendar.current.dateComponents([.year, .month, .day], from: $0) }
                .share(replay: 1)
            
            let yearText = dateComponents
                .map { "\($0.year ?? 0)년" }
            
            let monthText = dateComponents
                .map { "\($0.month ?? 0)월" }
            
            let dayText = dateComponents
                .map { "\($0.day ?? 0)일" }
            
            let ageValid = input.date
                .map { date -> Bool in
                    let now = Date()
                    let calendar = Calendar.current
                    let ageComponents = calendar.dateComponents([.year], from: date, to: now)
                    guard let age = ageComponents.year else { return false }
                    return age >= 17
                }
                .share(replay: 1)
            
            return Output(
                yearText: yearText,
                monthText: monthText,
                dayText: dayText,
                ageValid: ageValid,
                tap: input.tap
            )
        }
    }

