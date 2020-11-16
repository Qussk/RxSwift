//
//  ViewController.swift
//  RxSwiftIn4Hours
//
//  Created by iamchiwon on 21/12/2018.
//  Copyright © 2018 n.code. All rights reserved.
//

import RxSwift
import UIKit

class ViewController: UITableViewController {
    @IBOutlet var imageView: UIImageView!
    @IBOutlet weak var progressView: UIActivityIndicatorView!
    
    var disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
      
      
    }

    @IBAction func exJust1() {
      Observable.from(["녕","란","똥"])
        .subscribe(onNext: { n in
        print("next: \(n)")
        },
        onError: { e in
        print("err: \(e)")
        },
        onCompleted: { print("completed")
        },
        onDisposed: { print("disposed")
        })
        .disposed(by: disposeBag)
      /*
      Observable.just("Hello, World") //스트림이 나옴.
        //subscribe: 자이제 됐어, 나 이제 그 데이터 최정적으로 사용할거야. 모든 오퍼레이터 의 여정을 거친후 subscribe할거야.
      //  .subscribe()//실행만하고 결과를 신경쓰고 싶지 않을 떄
     //   .subscribe(<#T##on: (Event<String>) -> Void##(Event<String>) -> Void#>)
        .subscribe { event in
          switch event {
          case .next(let str):
            print("next: \(str)")
            break
          case .completed:
            print("completed")
            break
          case .error(let err):
            print("error: \(err.localizedDescription)")
            break
          }
          //다른 옵저버블들은 타입이 스트림임. 하지만 subscribe은 disposeble임 그래서 마지막에 bag에 넣어서 처리해야함.
        }.disposed(by: disposeBag)
 */
  //약형

      
    }

    @IBAction func exJust2() {
        Observable.just(["Hello", "World"])
            .subscribe(onNext: { arr in
                print(arr)
            })
            .disposed(by: disposeBag)
    }

  func outPut(_ str: Any) -> Void {
    print(str)
  }
  
  
    @IBAction func exFrom1() {
        Observable.from(["RxSwift", "In", 4, "Hours"]) //하나씩 줄바꿔서 내려옴
            .subscribe(onNext: { outPut in
                print(outPut)
            })
            .disposed(by: disposeBag)
    }

    @IBAction func exMap1() {
        Observable.just("Hello") //just한 것
            .map { str in "\(str) RxSwift" } //str에 "Hello"전달되지만, .map에 의해 맵핑
            .subscribe(onNext: { str in //아래 str에 "\(str) RxSwift" 가 전달
                print(str) //"\(str) RxSwift" 출력
            })
            .disposed(by: disposeBag)
    }

    @IBAction func exMap2() {
        Observable.from(["with", "곰튀김"]) //스트림부분
            .map { $0.count } //.map에 의해 인티저로 변환
            .subscribe(onNext: { str in
                print(str)
            })
            .disposed(by: disposeBag)
    }
  //4
  //3

    @IBAction func exFilter() {
        Observable.from([1, 2, 3, 4, 5, 6, 7, 8, 9, 10])
            .filter { $0 % 2 == 0 } //트루일때 내려가고 펄스일땐 내려가지 않음. (스트림)
            .subscribe(onNext: { n in
                print(n)
            })
            .disposed(by: disposeBag)
    }

    @IBAction func exMap3() {
        Observable.just("800x600")
            .map { $0.replacingOccurrences(of: "x", with: "/") } // "800/600"
            .map { "https://picsum.photos/\($0)/?random" } //https://picsum.photos/800/600/?random
            .map { URL(string: $0) } //url?로 변경
            .filter { $0 != nil } //nil인지 아닌지 -> nil이면 거짓이므로 아래로 진행 안함.
            .map { $0! } //url!
          .subscribeOn(ConcurrentDispatchQueueScheduler.init(qos: .default)) //--> 아무곳에나 있어도됨. ".subscribe 되는 순간, 선택된 스케쥴러로 모두 적용하겠다.)
            .map { try Data(contentsOf: $0) } //Data
            .map { UIImage(data: $0) } //UIImage?
            .observeOn(MainScheduler.instance)//---->main으로 돌아오기
          .do(onNext: { image in
            print(image?.size)
          })
            .subscribe(onNext: { image in //image로 전달하여
                self.imageView.image = image //코드 반영
            })
            .disposed(by: disposeBag)
    }
}
