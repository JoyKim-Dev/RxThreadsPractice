//
//  ShoppingListViewController.swift
//  SeSACRxThreads
//
//  Created by Joy Kim on 8/4/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class ShoppingListViewController: UIViewController {
    
    let list = Shopping.shoppingList
    
    let shoppingTableView = UITableView()
    let searchBar = UISearchBar()
    let textField = UITextField()
    let addButton = UIButton()
    
    let viewModel = ShoppingListViewModel()
    let disposeBag = DisposeBag()
    let shoppingListSubject = BehaviorSubject<[String]>(value: [])
    let filteredListSubject = BehaviorSubject<[String]>(value: [])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationController?.title = "쇼핑"
        shoppingListSubject.onNext(list)
        filteredListSubject.onNext(list)
        configHierarchy()
        configLayout()
        configUI()
        bind()
    }
    
    func bind() {
        
        let input = ShoppingListViewModel.Input(
                   addItem: addButton.rx.tap
                       .withLatestFrom(textField.rx.text.orEmpty)
                       .filter { !$0.isEmpty }
                       .asObservable(),
                   searchQuery: searchBar.rx.text.orEmpty
                       .debounce(.seconds(1), scheduler: MainScheduler.instance)
                       .distinctUntilChanged()
                       .asObservable(),
                   itemSelected: shoppingTableView.rx.itemSelected.asObservable()
               )
               
               let output = viewModel.transform(input: input)
               
             
               output.filteredList
                   .bind(to: shoppingTableView.rx.items(cellIdentifier: ShoppingListTableViewCell.identifier, cellType: ShoppingListTableViewCell.self)) { row, element, cell in
                       cell.configUI(data: element)
                   }
                   .disposed(by: disposeBag)
               
        
               output.selectedItem
                   .subscribe(onNext: { [weak self] selectedItem in
                       guard let self = self else { return }
                       let detailVC = DetailListViewController()
                       detailVC.navigationItem.title = selectedItem
                       self.navigationController?.pushViewController(detailVC, animated: true)
                   })
                   .disposed(by: disposeBag)
           }
    
}

extension ShoppingListViewController {
    
    func configHierarchy() {
        view.addSubview(searchBar)
        view.addSubview(textField)
        view.addSubview(shoppingTableView)
        view.addSubview(addButton)
        
        
    }
    
    func configLayout() {
        searchBar.snp.makeConstraints { make in
            make.top.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(10)
        }
        textField.snp.makeConstraints { make in
            make.top.equalTo(searchBar.snp.bottom).offset(10)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(10)
            make.height.equalTo(100)
        }
        addButton.snp.makeConstraints { make in
            make.verticalEdges.equalTo(textField).inset(5)
            make.width.equalTo(50)
            make.height.equalTo(30)
            make.trailing.equalTo(textField).inset(5)
        }
        shoppingTableView.snp.makeConstraints { make in
            make.top.equalTo(textField.snp.bottom).offset(20)
            make.horizontalEdges.bottom.equalTo(view.safeAreaLayoutGuide).inset(10)
        }
        
    }
    
    func configUI() {
        addButton.setTitle("추가", for: .normal)
        addButton.backgroundColor = .lightGray.withAlphaComponent(0.4)
        addButton.setTitleColor(.black, for: .normal)
        addButton.clipsToBounds = true
        addButton.layer.cornerRadius = 10
        
        textField.borderStyle = .roundedRect
        textField.backgroundColor = .lightGray.withAlphaComponent(0.2)
        textField.placeholder = "무엇을 구매하실 건가요?"
        
        shoppingTableView.register(ShoppingListTableViewCell.self, forCellReuseIdentifier: ShoppingListTableViewCell.identifier)
        
    }

   
}

