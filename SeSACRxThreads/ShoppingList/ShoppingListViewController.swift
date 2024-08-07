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
    
    let tableView = UITableView()
    lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout())
    let searchBar = UISearchBar()
    let textField = UITextField()
    let addButton = UIButton()
    
    let viewModel = ShoppingListViewModel()
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configHierarchy()
        configLayout()
        configUI()
        bind()
    }
    
    func bind() {
        
        let addItem = PublishSubject<String>()
        
        textField.rx.controlEvent(.editingDidEndOnExit)
            .withLatestFrom(textField.rx.text.orEmpty)
            .subscribe(with: self) { owner, value in
                addItem.onNext(value)
                owner.textField.text = ""
            }
            .disposed(by: disposeBag)
        
        addButton.rx.tap
            .withLatestFrom(textField.rx.text.orEmpty)
            .subscribe(with: self) { owner, value in
                addItem.onNext(value)
                owner.textField.text = ""
            }
            .disposed(by: disposeBag)
        
        Observable.zip(collectionView.rx.modelSelected(String.self), collectionView.rx.itemSelected)
            .debug()
            .map {$0.0}
            .subscribe(with: self) { owner, value in
                addItem.onNext(value)
            }
            .disposed(by: disposeBag)
        
        let input = ShoppingListViewModel.Input(addItem: addItem, searchQuery: searchBar.rx.text.orEmpty, itemSelected: tableView.rx.itemSelected)
        
        let output = viewModel.transform(input: input)
      
        output.filteredList
            .bind(to: tableView.rx.items(cellIdentifier: ShoppingListTableViewCell.identifier, cellType: ShoppingListTableViewCell.self)) { row, element, cell in
                cell.configUI(data: element)
            }
            .disposed(by: disposeBag)
        
        output.recommendItemList
            .bind(to: collectionView.rx.items(cellIdentifier: RecommendItemCollectionViewCell.identifier, cellType: RecommendItemCollectionViewCell.self)) {
                (row, element, cell) in
                cell.label.text = element
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
    func layout() -> UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 80, height: 40)
        layout.scrollDirection = .horizontal
        return layout
    }
}

extension ShoppingListViewController {
    
    func configHierarchy() {
        view.addSubview(searchBar)
        view.addSubview(collectionView)
        view.addSubview(textField)
        view.addSubview(tableView)
        view.addSubview(addButton)
    }
    
    func configLayout() {
        textField.snp.makeConstraints { make in
            make.top.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(10)
            make.height.equalTo(100)
        }
        addButton.snp.makeConstraints { make in
            make.verticalEdges.equalTo(textField).inset(5)
            make.width.equalTo(50)
            make.height.equalTo(30)
            make.trailing.equalTo(textField).inset(5)
        }
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(textField.snp.bottom).offset(20)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(10)
            make.height.equalTo(50)
        }
        tableView.snp.makeConstraints { make in
            make.top.equalTo(collectionView.snp.bottom).offset(20)
            make.horizontalEdges.bottom.equalTo(view.safeAreaLayoutGuide).inset(10)
        }
        
    }
    
    func configUI() {
        view.backgroundColor = .white
        navigationItem.titleView = searchBar
        
        addButton.setTitle("추가", for: .normal)
        addButton.backgroundColor = .lightGray.withAlphaComponent(0.4)
        addButton.setTitleColor(.black, for: .normal)
        addButton.clipsToBounds = true
        addButton.layer.cornerRadius = 10
        
        textField.borderStyle = .roundedRect
        textField.backgroundColor = .lightGray.withAlphaComponent(0.2)
        textField.placeholder = "무엇을 구매하실 건가요?"
        
        tableView.register(ShoppingListTableViewCell.self, forCellReuseIdentifier: ShoppingListTableViewCell.identifier)
        collectionView.register(RecommendItemCollectionViewCell.self, forCellWithReuseIdentifier: RecommendItemCollectionViewCell.identifier)
    }
    
}

