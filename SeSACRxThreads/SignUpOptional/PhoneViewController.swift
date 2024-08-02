//
//  PhoneViewController.swift
//  SeSACRxThreads
//
//  Created by jack on 2023/10/30.
//
 
import UIKit
import SnapKit
import RxSwift
import RxCocoa


class PhoneViewController: UIViewController {
    enum phoneNumberValidation {
        case tooShort
        case tooLong
        case notANumber
        case valid
        
        var text:String {
            switch self {
            case .tooShort:
                "10자리 이상 입력해주세요"
            case .tooLong:
                "너무 깁니다. 전화번호를 다시 확인해주세요."
            case .notANumber:
                "숫자가 아닌 입력값입니다. 다시 확인해주세요"
            case .valid:
                "유효한 전화번호입니다."
            }
        }
    }
    
    let phoneTextField = SignTextField(placeholderText: "연락처를 입력하세요")
    let nextButton = PointButton(title: "다음")
    let descriptionLabel = UILabel()
    
    let validText = Observable.just(phoneNumberValidation.notANumber.text)
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = Color.white
        phoneTextField.text = "010"
        descriptionLabel.textColor = .red
        
        configureLayout()
        bind()
        
    }

    func bind() {
  
        // 유효성 검사 조건
        //(입력값을 감지할 수 있도록 textField 입력값을 rx로 감싸주고, orEmpty를 활용하여 optional 처리까지해줌(빈문자열일 때 ""로 대체됨)
        let validation = phoneTextField.rx.text.orEmpty.map { text -> phoneNumberValidation? in
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
        // 유효성 검사 통과 실패 시 Status 라벨 연결
                validation
            .map { $0?.text }
                    .bind(to: descriptionLabel.rx.text)
                    .disposed(by: disposeBag)
        
        // 유효성 검사 통과 변수
        let isValid = validation.map { $0 == phoneNumberValidation.valid }
        
        // 유효성 검사 결과 통과시 다음 버튼 활성화 & status라벨 숨기기
        isValid
            .bind(to: nextButton.rx.isEnabled, descriptionLabel.rx.isHidden)
            .disposed(by: disposeBag)
        
        // 유효성 검사 결과 통과시 따른 버튼색 결정 연결
        isValid
            .bind(with: self) { owner, value in
                let color: UIColor = value ? .systemPink : .lightGray
                owner.nextButton.backgroundColor = color
            }.disposed(by: disposeBag)
        
        // 버튼 눌리면 화면 전환
        nextButton.rx.tap.bind(with: self) { owner, _ in
            owner.navigationController?.pushViewController(NicknameViewController(), animated: true)
        }.disposed(by: disposeBag)
        
    }
    func configureLayout() {
        view.addSubview(phoneTextField)
        view.addSubview(nextButton)
        view.addSubview(descriptionLabel)
         
        phoneTextField.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(200)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(phoneTextField.snp.bottom).offset(5)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
        nextButton.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.top.equalTo(descriptionLabel.snp.bottom).offset(10)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
        
        
    }

}
