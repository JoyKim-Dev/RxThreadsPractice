//
//  BirthdayViewController.swift
//  SeSACRxThreads
//
//  Created by jack on 2023/10/30.
//
 
import UIKit
import SnapKit
import RxSwift
import RxCocoa

class BirthdayViewController: UIViewController {
    
    let birthDayPicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .wheels
        picker.locale = Locale(identifier: "ko-KR")
        picker.maximumDate = Date()
        return picker
    }()
    
    let infoLabel: UILabel = {
       let label = UILabel()
        label.textColor = Color.black
        label.text = "만 17세 이상만 가입 가능합니다."
        return label
    }()
    
    let containerStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .equalSpacing
        stack.spacing = 10 
        return stack
    }()
    
    let yearLabel: UILabel = {
       let label = UILabel()
        label.text = "2023년"
        label.textColor = Color.black
        label.snp.makeConstraints {
            $0.width.equalTo(100)
        }
        return label
    }()
    
    let monthLabel: UILabel = {
       let label = UILabel()
        label.text = "33월"
        label.textColor = Color.black
        label.snp.makeConstraints {
            $0.width.equalTo(100)
        }
        return label
    }()
    
    let dayLabel: UILabel = {
       let label = UILabel()
        label.text = "99일"
        label.textColor = Color.black
        label.snp.makeConstraints {
            $0.width.equalTo(100)
        }
        return label
    }()
  
    let nextButton = PointButton(title: "가입하기")
    let year = BehaviorRelay(value: 2024)
    let month = BehaviorRelay(value: 8)
    let day = BehaviorRelay(value: 3)
    
    let disposeBag = DisposeBag()
    

    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = Color.white
        
        configureLayout()
        bind()
        
    }

    func bind() {
        
        let selectedDate = birthDayPicker.rx.date.share(replay: 1)

               selectedDate
                   .map { Calendar.current.dateComponents([.year, .month, .day], from: $0) }
                   .subscribe(onNext: { [weak self] components in
                       guard let year = components.year, let month = components.month, let day = components.day else { return }
                       self?.year.accept(year)
                       self?.month.accept(month)
                       self?.day.accept(day)
                   })
                   .disposed(by: disposeBag)
               
               year
                   .map { "\($0)년" }
                   .bind(to: yearLabel.rx.text)
                   .disposed(by: disposeBag)
               
               month
                   .map { "\($0)월" }
                   .bind(to: monthLabel.rx.text)
                   .disposed(by: disposeBag)
               
               day
                   .map { "\($0)일" }
                   .bind(to: dayLabel.rx.text)
                   .disposed(by: disposeBag)
               
               let ageValid = selectedDate
                   .map { date -> Bool in
                       let now = Date()
                       let calendar = Calendar.current
                       let ageComponents = calendar.dateComponents([.year], from: date, to: now)
                       guard let age = ageComponents.year else { return false }
                       return age >= 17
                   }
                   .share(replay: 1)
               
               ageValid
                   .bind(to: nextButton.rx.isEnabled)
                   .disposed(by: disposeBag)

               ageValid
                   .subscribe(onNext: { [weak self] isValid in
                       if isValid {
                           self?.infoLabel.text = "가입 가능한 나이입니다."
                           self?.infoLabel.textColor = .blue
                           self?.nextButton.backgroundColor = .blue
                       } else {
                           self?.infoLabel.text = "만 17세 이상만 가입 가능합니다."
                           self?.infoLabel.textColor = .red
                           self?.nextButton.backgroundColor = .gray
                       }
                   })
                   .disposed(by: disposeBag)
        
              
        
        nextButton.rx.tap.bind(with: self) { owner, _ in 
            let alert = UIAlertController(title: "완료", message: "가입이 완료되었습니다.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "확인", style: .default, handler: { _ in
                owner.navigationController?.pushViewController(SearchViewController(), animated: true)
            }))
            owner.present(alert, animated: true, completion: nil)
        }
        .disposed(by: disposeBag)
  
        
    }
    func configureLayout() {
        view.addSubview(infoLabel)
        view.addSubview(containerStackView)
        view.addSubview(birthDayPicker)
        view.addSubview(nextButton)
 
        infoLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(150)
            $0.centerX.equalToSuperview()
        }
        
        containerStackView.snp.makeConstraints {
            $0.top.equalTo(infoLabel.snp.bottom).offset(30)
            $0.centerX.equalToSuperview()
        }
        
        [yearLabel, monthLabel, dayLabel].forEach {
            containerStackView.addArrangedSubview($0)
        }
        
        birthDayPicker.snp.makeConstraints {
            $0.top.equalTo(containerStackView.snp.bottom)
            $0.centerX.equalToSuperview()
        }
   
        nextButton.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.top.equalTo(birthDayPicker.snp.bottom).offset(30)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
    }

}
