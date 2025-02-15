//
//  ShoppingListTableViewCell.swift
//  SeSACRxThreads
//
//  Created by Joy Kim on 8/4/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class ShoppingListTableViewCell: UITableViewCell {
    
    static let identifier = "ShoppingListTableViewCell"
    
    let checkBox = UIImageView()
    let lable = UILabel()
    let favorite = UIImageView()
    
    private let disposeBag = DisposeBag()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configHierarchy()
        configLayout()
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configHierarchy() {
        contentView.addSubview(checkBox)
        contentView.addSubview(lable)
        contentView.addSubview(favorite)
    }
    
    func configLayout() {
        checkBox.snp.makeConstraints { make in
            make.leading.equalTo(contentView.safeAreaLayoutGuide).inset(30)
            make.centerY.equalTo(contentView)
            make.width.height.equalTo(30)
        }
        favorite.snp.makeConstraints { make in
            make.width.height.equalTo(30)
            make.centerY.equalTo(contentView)
            make.trailing.equalTo(contentView.safeAreaLayoutGuide).inset(30)
        }
        
        lable.snp.makeConstraints { make in
            make.centerY.equalTo(contentView)
            make.leading.equalTo(checkBox.snp.trailing).offset(60)
            make.trailing.equalTo(favorite.snp.leading).offset(-30)
        }
        
    }
    
    func configUI(data:String) {
        let isChecked = UserDefaultManager.shared.isItemChecked(data)
        let isFavorite = UserDefaultManager.shared.isItemFavorite(data)
        
        checkBox.image = isChecked ? UIImage(systemName: "checkmark.square.fill") : UIImage(systemName: "checkmark.square")
        checkBox.tintColor = .black
        favorite.image = isFavorite ? UIImage(systemName: "star.fill") : UIImage(systemName: "star")
        favorite.tintColor = .black
        lable.text = data
        lable.textColor = .black
        bind(data: data)
    }
    
    func bind(data: String) {
        
        let checkBoxTapGesture = UITapGestureRecognizer()
        checkBox.addGestureRecognizer(checkBoxTapGesture)
        checkBox.isUserInteractionEnabled = true
        checkBoxTapGesture.rx.event
            .bind { [weak self] _ in
                guard let self = self else { return }
                let isChecked = !UserDefaultManager.shared.isItemChecked(data)
                               UserDefaultManager.shared.setItemChecked(data, checked: isChecked)
                               self.checkBox.image = isChecked ? UIImage(systemName: "checkmark.square.fill") : UIImage(systemName: "checkmark.square")
            }
            .disposed(by: disposeBag)
        
        
        let favoriteTapGesture = UITapGestureRecognizer()
        favorite.addGestureRecognizer(favoriteTapGesture)
        favorite.isUserInteractionEnabled = true
        favoriteTapGesture.rx.event
            .bind { [weak self] _ in
                guard let self = self else { return }
                let isFavorite = !UserDefaultManager.shared.isItemFavorite(data)
                UserDefaultManager.shared.setItemFavorite(data, favorite: isFavorite)
                                self.favorite.image = isFavorite ? UIImage(systemName: "star.fill") : UIImage(systemName: "star")
            }
            .disposed(by: disposeBag)
    }
    
    
}
