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
    
    
    private let disposeBag = DisposeBag()
    let shoppingList = BehaviorSubject<[String]>(value: [])
    
    struct Input {
  
        let addItem: PublishSubject<String>
        let searchQuery: ControlProperty<String>
        let itemSelected: ControlEvent<IndexPath>
    }
    
    struct Output {
        let shoppingList: BehaviorSubject<[String]>
        let filteredList: BehaviorSubject<[String]>
        let recommendItemList: Observable<[String]>
        let selectedItem: Observable<String>
        let duplicateItemAlert: Observable<String>
    }
    
    func transform(input: Input) -> Output {
        
      
        let filteredList = BehaviorSubject<[String]>(value: [])
        let recommendItemList = Observable.just(Shopping.recommendItemList)
        let duplicateItemAlert = PublishSubject<String>()
        
        input.addItem
            .withLatestFrom(shoppingList) { ($0, $1) }
            .map { newItem, currentList in
                if currentList.contains(newItem) {
                    duplicateItemAlert.onNext("\(newItem): 이미 추가됨😎")
                    return currentList
                } else {
                    var updatedList = currentList
                    updatedList.append(newItem)
                    return updatedList
                }
            }
            .bind(to: shoppingList)
            .disposed(by: disposeBag)
        
        
        input.searchQuery
            .debounce(.microseconds(50), scheduler: MainScheduler())
                   .distinctUntilChanged()
            .withLatestFrom(shoppingList) { query, list in
                query.isEmpty ? list : list.filter { $0.contains(query) }
            }
            .bind(to: filteredList)
            .disposed(by: disposeBag)
        
        shoppingList
            .bind(to: filteredList)
            .disposed(by: disposeBag)
        
        let selectedItem = input.itemSelected
            .withLatestFrom(shoppingList) { $1[$0.row] }
        
        return Output(
            shoppingList: shoppingList,
            filteredList: filteredList, recommendItemList: recommendItemList,
            selectedItem: selectedItem, duplicateItemAlert: duplicateItemAlert
        )
    }
    
    func deleteItem(index: Int) {
        do {
            var currentList = try shoppingList.value()
            currentList.remove(at: index)
            shoppingList.onNext(currentList)
        } catch {
            print("Error deleting item: \(error)")
        }
    }
}
