//
//  CounterViewModel.swift
//  MVVMRxSwiftTest
//
//  Created by Qussk_MAC on 2020/11/23.
//

import Foundation
import RxSwift
import RxCocoa

protocol ViewModelType: class {
    associatedtype Input
    associatedtype Output
    func transform(input: Input) -> Output
}


final class CounterViewModel: ViewModelType {

    //tap Observable을 구독하기 위해 받아줌
    struct Input {
      var plusAction: Observable<Void>
      var subtractAction: Observable<Void>
    }

    //현재 계수값 전달
    struct Output {
      var countedValue: Driver<Int>
    }
  
      let disposeBag = DisposeBag()
  
      //input을 output으로 변환
      func transform(input: Input) -> Output {
              let countedValue = BehaviorRelay(value: 0)

              input.plusAction
              .subscribe(onNext: { _ in
                  countedValue.accept(countedValue.value + 1)
              })
                .disposed(by: disposeBag)

              input.subtractAction
                      .subscribe(onNext: { _ in
                              countedValue.accept(countedValue.value - 1)
                      })
                .disposed(by: disposeBag)

              return Output(countedValue: countedValue.asDriver(onErrorJustReturn: 0))
      }
}
