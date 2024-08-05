//
//  PasswordViewController.swift
//  SeSACRxThreads
//
//  Created by jack on 2023/10/30.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class PasswordViewController: UIViewController {
   
    let passwordTextField = SignTextField(placeholderText: "비밀번호를 입력해주세요")
    let nextButton = PointButton(title: "다음")
    let descriptionLabel = UILabel()
    
    let viewModel = PasswordViewModel()
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = Color.white
    
    
        
        configureLayout()
        bind()
    }
    
    func bind() {
        
        let input = PasswordViewModel.Input(tap: nextButton.rx.tap, text: passwordTextField.rx.text)
        
        let output = viewModel.transform(input: input)
        
        // 유효성검사결과 text & status라벨과 연결
        output.validText
            .bind(to: descriptionLabel.rx.text)
            .disposed(by: disposeBag)
        
//        // 유효성 검사 조건
//        let validation = passwordTextField
//            .rx.text.orEmpty.map { $0.count >= 8 }
        
        // 유효성 검사 결과에 따라 다음 버튼 활성화 & status라벨 숨기기
        output.validation
            .bind(to: nextButton.rx.isEnabled, descriptionLabel.rx.isHidden)
            .disposed(by: disposeBag)
        
        // 유효성 검사 결과에 따른 버튼색 결정 연결
        output.validation
            .bind(with: self) { owner, value in
                let color: UIColor = value ? .systemPink : .lightGray
                owner.nextButton.backgroundColor = color
            }.disposed(by: disposeBag)
        
        // addTarget 대신 버튼 탭 액션 연결
        output.tap.bind(with: self) { owner, _ in
                owner.navigationController?.pushViewController(PhoneViewController(), animated: true)
            }.disposed(by: disposeBag)
    }
    
    func configureLayout() {
        view.addSubview(passwordTextField)
        view.addSubview(nextButton)
        view.addSubview(descriptionLabel)
         
        passwordTextField.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(200)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(passwordTextField.snp.bottom).offset(10)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
        
        nextButton.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.top.equalTo(passwordTextField.snp.bottom).offset(30)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
        
    }

}
