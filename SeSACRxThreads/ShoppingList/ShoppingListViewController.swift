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
    
    let disposeBag = DisposeBag()
    let shoppingListSubject = BehaviorSubject<[String]>(value: [])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationController?.title = "쇼핑"
        shoppingListSubject.onNext(list)
        configHierarchy()
        configLayout()
        configUI()
        setTableView()
        bind()
    }
    
    func bind() {
        
        addButton.rx.tap
            .withLatestFrom(textField.rx.text.orEmpty)
            .filter { !$0.isEmpty }
            .subscribe(onNext: { [weak self] newItem in
                guard let self = self else { return }
                var currentList = try! self.shoppingListSubject.value()
                currentList.append(newItem)
                self.shoppingListSubject.onNext(currentList)
                self.textField.text = ""
            })
            .disposed(by: disposeBag)
        
        shoppingTableView.rx.itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                guard let self = self else { return }
                let detailVC = DetailViewController()
                self.navigationController?.pushViewController(SignUpViewController(), animated: true)
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
    
    func setTableView() {
        shoppingListSubject
            .bind(to: shoppingTableView.rx.items(cellIdentifier: ShoppingListTableViewCell.identifier, cellType: ShoppingListTableViewCell.self)) { row, element, cell in
                cell.lable.text = element
                
            }
            .disposed(by: disposeBag)
    }
    
}

