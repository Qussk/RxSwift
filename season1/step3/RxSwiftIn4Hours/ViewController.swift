//
//  ViewController.swift
//  RxSwiftIn4Hours
//
//  Created by iamchiwon on 21/12/2018.
//  Copyright © 2018 n.code. All rights reserved.
//

import RxCocoa
import RxSwift
import UIKit


class ViewController: UIViewController {
    var disposeBag = DisposeBag()
  
  var idText : BehaviorSubject<String> = BehaviorSubject(value: "")
  var pwText : BehaviorSubject<String> = BehaviorSubject(value: "")
  var idValiad : BehaviorSubject<Bool> = BehaviorSubject(value: false)
  var pwValiad : BehaviorSubject<Bool> = BehaviorSubject(value: false)

    override func viewDidLoad() {
        super.viewDidLoad()
      bindInPut()
      bindOutPut()
    }

    // MARK: - IBOutler

    @IBOutlet var idField: UITextField!
    @IBOutlet var pwField: UITextField!
    @IBOutlet var loginButton: UIButton!
    @IBOutlet var idValidView: UIView!
    @IBOutlet var pwValidView: UIView!

    // MARK: - Bind UI
    private func bindInPut() {
      
      //1. input 데이터 처리 : 아이디 입력, 패스워드 입력
      
      idField.rx.text.orEmpty
        .bind(to: idText) //1-1.bind로 idText(String)값을 받고 idText에 저장
        .disposed(by: disposeBag)
      
      idText //저장된 거에서 가져오기
      .map(checkEmailValid) //체크도하고
      .bind(to: idValiad) //1-2. idValiad(Bool)값도 받는다.
      .disposed(by: disposeBag)
      
      pwField.rx.text.orEmpty
        .bind(to: pwText)
        .disposed(by: disposeBag)
      
      pwText
        .map(checkPasswordValid)
        .bind(to: pwValiad)
        .disposed(by: disposeBag)
    }
  
  private func bindOutPut(){
    //2. 블릿, 로그인버튼
    // 저장했던 것들(input데이터)을 보게 해주는것 ==> 다른 메소드에 있어도 됨.
    idValiad.subscribe(onNext: { c in
      self.idValidView.isHidden = c
    })
    .disposed(by: disposeBag)
    
    pwValiad.subscribe(onNext: { b in
      self.pwValidView.isHidden = b
    })
    .disposed(by: disposeBag)
  
    Observable.combineLatest(idValiad, pwValiad, resultSelector: { $0 && $1 })
      .subscribe(onNext: { b in
        self.loginButton.isEnabled = b
      })
      .disposed(by: disposeBag)
  }
   
      /*
      Observable.combineLatest(idValideOb, pwValidOb, resultSelector: { $0 && $1 })
        .subscribe(onNext: { b in
          self.loginButton.isEnabled = b
        })
        .disposed(by: disposeBag)
      
   
      //rx 우리가 취급하는 것을 비동기로 받겠다! 선언
      //stream에 흘러들어감.
      idField.rx.text.orEmpty
      .map(checkEmailValid)
      .subscribe(onNext: { b in
        self.idValidView.isHidden = b
      })
      .disposed(by: disposeBag)
      
      pwField.rx.text.orEmpty
        .map(checkPasswordValid)
        .subscribe(onNext: { p in
          self.pwValidView.isHidden = p
        })
        .disposed(by: disposeBag)
      //
      Observable.combineLatest(
        idField.rx.text.orEmpty.map(checkEmailValid),
        pwField.rx.text.orEmpty.map(checkPasswordValid),
      resultSelector: { s1, s2 in s1 && s2 }
      )
      .subscribe(onNext: { b in
        self.loginButton.isEnabled = b
      })
      .disposed(by: disposeBag)
    }
*/
    // MARK: - Logic

  //email 형식 구분
    private func checkEmailValid(_ email: String) -> Bool {
        return email.contains("@") && email.contains(".")
    }
  //pw형식 구분
    private func checkPasswordValid(_ password: String) -> Bool {
        return password.count > 5
    }
}


