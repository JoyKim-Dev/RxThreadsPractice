//
//  ShoppingListViewModel.swift
//  SeSACRxThreads
//
//  Created by Joy Kim on 8/6/24.
//

import Foundation
import RxSwift
import RxCocoa

class ShoppingListViewModel {
    
   let shoppingListSubject = BehaviorSubject<[String]>(value: Shopping.shoppingList)
    
    private let disposeBag = DisposeBag()
    
    struct Input {
        let addItem: Observable<String>
        let searchQuery: Observable<String>
        let itemSelected: Observable<IndexPath>
    }
    
    struct Output {
        let shoppingList: Observable<[String]>
        let filteredList: Observable<[String]>
        let selectedItem: Observable<String>
    }
    
    func transform(input: Input) -> Output {
        
        input.addItem
            .withLatestFrom(shoppingListSubject) { ($0, $1) }
            .map { newItem, currentList in
                var updatedList = currentList
                updatedList.append(newItem)
                return updatedList
            }
            .bind(to: shoppingListSubject)
            .disposed(by: disposeBag)
        
      
        let filteredListSubject = BehaviorSubject<[String]>(value: Shopping.shoppingList)
        input.searchQuery
            .withLatestFrom(shoppingListSubject) { query, list in
                query.isEmpty ? list : list.filter { $0.contains(query) }
            }
            .bind(to: filteredListSubject)
            .disposed(by: disposeBag)
        
       
        let selectedItem = input.itemSelected
            .withLatestFrom(filteredListSubject) { $1[$0.row] }
        
        return Output(
            shoppingList: shoppingListSubject.asObservable(),
            filteredList: filteredListSubject.asObservable(),
            selectedItem: selectedItem.asObservable()
        )
    }
}
