# RxSwift
RxSwift에 대한 학습


RxSwift 란?
*비동기 작업을 간결하게*
*API다, 비동기적으로 스트림하기 위한 프로그래밍, 그리고, 옵저버블을 스트림한다.*



- [공식사이트](http://reactivex.io/)
- [Lee Campbel의 무료 튜토리얼](http://introtorx.com/)
- [깃헙](https://github.com/ReactiveX/RxSwift)
- [구슬 사이트(마블스)](https://rxmarbles.com/)


- [RxSwift와 Combine 차이](https://qussk.github.io/2020/11/11/RxSwift%EC%99%80-Combin%EC%9D%98-%EC%B0%A8%EC%9D%B4)


- 유사 라이브러리 
  - [PromiseKit](#PromiseKit)




**[문법]**
- [observable](http://reactivex.io/documentation/ko/observable.html)
- [연산자](http://reactivex.io/documentation/ko/operators.html)
-

**신속**
- [메모리누수 디버깅하기](#메모리누수)


**💁🏻‍♀️학습 활동**

## 계수기 Test(with: TDD?)

- [[보러가기]](https://github.com/Qussk/RxSwift/tree/main/MVVMRxSwiftTest)
- [참고 깃허브: https://github.com/PangMo5/MVVMRxSwiftTest](https://github.com/PangMo5/MVVMRxSwiftTest)
- 참고 블로그 : [강남언니 기술블로그](https://blog.gangnamunni.com/post/HealingPaperTV-ViewModel-Test)


## RxSwift 4시간에 끝내기
**시즌1**
  - [머리말](#RxSwiftIn4Hours)
  - [왜쓰냐?](#일반적인비동기방식)
  - [step1](#step1)
    - [Observable사용](#Observable사용)
    - [dispose사용](#dispose사용)
    - [DisposeBag사용](#DisposeBag사용)
      - .disposed(by: disposebag)
  - [step2](#step2)
    - operators
    - [just](#just)
    - [from](#from)
    - [map](#map)
    - [filter](#filter)
    - [응용](#응용)
  - [구슬읽기](#구슬읽기)  
  - [스케쥴러](#스케쥴러)
    - [observeOn](#observeOn)
    - [subscribeOn](#subscribeOn)
  - [사이드 이펙트](#사이드이펙트)
    - subscribe
    - [do](#do)
 - [step3](#step3)  
   - [orEmpty](#orEmpty) 
   - [Observables결합하기](#Observables결합하기)
     - [CombineLatest](#CombineLatest)
     - [zip](#zip)
     - [merge](#merge)
   - [Subject](#Subject)
     - [AsyncSubject](#AsyncSubject)
     - [BehaviorSubject](#BehaviorSubject)
     - [PublishSubject](#PublishSubject)
     - [ReplaySubject](#ReplaySubject)
  - 추가내용
    - driver
    
**시즌2**
- step1
 - [왜쓰냐?](#일반적인디스패치큐의경우)
 - [예제코드 RxSwift로 변경](#예제RxSwift로변경)   
 - [순환참조없이](#순환참조없이)
 - [메모리누수가 일어나는지 디버깅해보자](#디버깅해보자)
 
 
 
 시즌2의 RxSwift학습내용
 > 비동기로 생기는 데이터를 Observable로 감싸서 리턴하는 방법
 >>  Observable로 오는 데이터를 받아서 처리하는 방법
 
 
### observable

[공식사이트 보기](http://reactivex.io/documentation/ko/observable.html) => 한국어 지원됨 !




## **시즌1**
## RxSwiftIn4Hours
![](https://github.com/iamchiwon/RxSwift_In_4_Hours/raw/master/docs/rxswift_in_4_hours_logo.png)
>  RxSwift 4시간에 끝내기 


[강좌 머리말](https://github.com/iamchiwon/RxSwift_In_4_Hours/blob/master/README_s1.md)


## 일반적인비동기방식

일반적인 DispatchQueue의 방식
<div>
<img src = "https://github.com/Qussk/RxSwift/blob/main/image/syncg.gif?raw=true" width="300px">
<img src = "https://github.com/Qussk/RxSwift/blob/main/image/asyncg.gif?raw=true" width="300px">
</div>

> 왼쪽부터: 동기 , 비동기


*Code*

```swift
import UIKit

class AsyncViewController: UIViewController {
    // MARK: - Field

    var counter: Int = 0
    let IMAGE_URL = "https://picsum.photos/1280/720/?random"

    override func viewDidLoad() {
        super.viewDidLoad()
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            self.counter += 1
            self.countLabel.text = "\(self.counter)"
        }
    }

    // MARK: - IBOutlet

    @IBOutlet var imageView: UIImageView!
    @IBOutlet var countLabel: UILabel!

    // MARK: - IBAction

    @IBAction func onLoadSync(_ sender: Any) {
        let image = loadImage(from: IMAGE_URL)
        imageView.image = image
    }

  //DispatchQueue : 일반적인 비동기 처리방법
    @IBAction func onLoadAsync(_ sender: Any) {
        //global은 콘커런씨: 동시에 실행된다. 어씽크방식으로..
      DispatchQueue.global().async {
        guard let url = URL(string: self.IMAGE_URL) else { return }
        guard let data = try? Data(contentsOf: url) else { return }
        
        let image = UIImage(data: data)
        
        DispatchQueue.main.async {
          self.imageView.image = image
        }
      }
    }

    private func loadImage(from imageUrl: String) -> UIImage? {
        guard let url = URL(string: imageUrl) else { return nil }
        guard let data = try? Data(contentsOf: url) else { return nil }

        let image = UIImage(data: data)
        return image
    }
}
```
- 만약에 DispatchQueue으로 코딩을하고 있다면, 취소를 어떻게 할 수 있을까?
- 1. 오퍼레이션 큐
- 2. 캔슬 플러그하나두고, 켜도, 처리되는 내내 온오프 확인하는 그런 작업..
 
 ==> 이런 귀찮은 작업을 안하기 위해 RxSwift을 쓴다. 
 
 

## Step1

<div>
<img src = "https://github.com/Qussk/RxSwift/blob/main/image/rxg1.gif?raw=true" width="300px">
</div>

Rx의 방식 
: 비동기시 작업을 취소를 해야할때, 오퍼레이션 큐나 처리내내 확인하는 플러그 없이, 간단하게 작업 불러오는 걸 취소할 수 있다.

===> dispose()나, DisposeBag()을 새로 만드는 방식으로 



### **Observable사용**
- 처음시작할 때 `observeOn`을 해줘야한다.
- Observable이라는 타입을 갖는 함수를 만든다. 
- 받는 작업

```swift
import RxSwift
import UIKit

class RxSwiftViewController: UIViewController {
    // MARK: - Field

    var counter: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            self.counter += 1
            self.countLabel.text = "\(self.counter)"
        }
    }

    // MARK: - IBOutlet

    @IBOutlet var imageView: UIImageView!
    @IBOutlet var countLabel: UILabel!

    // MARK: - IBAction

    @IBAction func onLoadImage(_ sender: Any) {
        imageView.image = nil

        _ = rxswiftLoadImage(from: LARGER_IMAGE_URL)
            .observeOn(MainScheduler.instance)
            .subscribe({ result in //subscribe라는 곳에 결과를 받아서 처리
                switch result {
                case let .next(image):
                    self.imageView.image = image

                case let .error(err):
                    print(err.localizedDescription)

                case .completed:
                    break
                }
            })
    }

    @IBAction func onCancel(_ sender: Any) {
        // TODO: cancel image loading
    }

    // MARK: - RxSwift

    func rxswiftLoadImage(from imageUrl: String) -> Observable<UIImage?> {
        return Observable.create { seal in
            asyncLoadImage(from: imageUrl) { image in
                seal.onNext(image)
                seal.onCompleted()
            }
            return Disposables.create()
        }
    }
}
```
- `Observable<UIImage?>`라는 타입을 만들어서 반환하는 형식
- image가 받아지면, seal이라는 데에서, OnNext. '완료됐어' 하고 넘겨주는 곳.


### **dispose사용**
- 치우다.
```swift
// MARK: - IBAction

var desposable: Disposable?

@IBAction func onLoadImage(_ sender: Any) {
    imageView.image = nil
    
  desposable = rxswiftLoadImage(from: LARGER_IMAGE_URL)
        .observeOn(MainScheduler.instance)
        .subscribe({ result in //subscribe라는 곳에 결과를 받아서 처리
            switch result {
            case let .next(image):
                self.imageView.image = image

            case let .error(err):
                print(err.localizedDescription)

            case .completed:
                break
            }
        })
}

@IBAction func onCancel(_ sender: Any) {
  desposable?.dispose() //작업을 모두 취소해버릴 수 있음
  
}

// MARK: - RxSwift

func rxswiftLoadImage(from imageUrl: String) -> Observable<UIImage?> {
    return Observable.create { seal in
        asyncLoadImage(from: imageUrl) { image in
            seal.onNext(image)
            seal.onCompleted()
        }
        return Disposables.create()
    }
}
}
```
![](/image/rx2.png)
- rx를 사용하게 되면 이런 타입을 가질 수 있다.

- Disposable타입의 전역 변수를 하나 만듦. `var desposable: Disposable?`

- 취소버튼 구현부에 .을 찍어보면 해당 속성이 보인다.

![](/image/rx1.png)
- dispose을 선택하여 (cancel image loading.) 이미지 로딩을 취소한다.



### **DisposeBag사용**
- Combine에서는 배열로 쓰는 것.
- Disposable을 담는 Bag

```swift
// MARK: - IBAction


var desposableBag: DisposeBag = DisposeBag()

@IBAction func onLoadImage(_ sender: Any) {
    imageView.image = nil
    
  let desposable = rxswiftLoadImage(from: LARGER_IMAGE_URL)
        .observeOn(MainScheduler.instance)
        .subscribe({ result in //subscribe라는 곳에 결과를 받아서 처리
            switch result {
            case let .next(image):
                self.imageView.image = image

            case let .error(err):
                print(err.localizedDescription)

            case .completed:
                break
            }
        })
  desposableBag.insert(desposable)//insert로 desposableBag에 desposable을 담아줌
}

@IBAction func onCancel(_ sender: Any) {
  desposableBag = DisposeBag()
  
}

// MARK: - RxSwift

func rxswiftLoadImage(from imageUrl: String) -> Observable<UIImage?> {
    return Observable.create { seal in
        asyncLoadImage(from: imageUrl) { image in
            seal.onNext(image)
            seal.onCompleted()
        }
        return Disposables.create()
    }
}
}
```
- `desposableBag.insert(desposable)` insert로 desposableBag에 desposable을 담아줌
-  desposableBag은 dispose()을 지원하지 않음. 한꺼번에 지우는 방법은 **desposableBag을 새로 만들어주는 것**!!
-  `desposableBag.insert(desposable)` 대신 `.disposed(by: desposableBag)`을 쓸 수도 있음.(변수쓰기 귀찮을 때.)
- 그래서, `.disposed`을 사용할 땐, `let desposable = `부분을 지우고  `rxswiftLoadImage(from: LARGER_IMAGE_URL)`만 두기.





## Step2


### just

- 전달한 값이 바로 나옴
```swift
@IBAction func exJust1() {
    Observable.just("Hello World") //just :바로 인자로 전달, 전달한 값이 바로 나옴.
        .subscribe(onNext: { str in //인자의 첫번쨰 str으로 전달되어 "Hello World" 출력됨.
            print(str)
        })
        .disposed(by: disposeBag)
}
//Hello World
```
```swift
@IBAction func exJust2() {
    Observable.just(["Hello", "World"])
        .subscribe(onNext: { arr in
            print(arr)
        })
        .disposed(by: disposeBag)
}
//["Hello", "World"]
```


### from
- 요소가 하나씩 줄 바꿔서 내려옴
```swift
@IBAction func exFrom1() {
    Observable.from(["RxSwift", "In", "4", "Hours"]) //하나씩 줄바꿔서 내려옴
        .subscribe(onNext: { str in
            print(str)
        })
        .disposed(by: disposeBag)
}
//RxSwift
//In
//4
//Hours
```
- 만약 다른 타입이 끼여도 출력됨. "4"가 아니라 4(Int)여도 에러없음


### map
- just에 map을 끼게 되면 just한 내용이 map에 먼저 전달됨
```swift
@IBAction func exMap1() {
    Observable.just("Hello") //1-1."Hello"전달
        .map { str in "\(str) RxSwift" } //1-2.맵으로 인해 "\(str) RxSwift"(라고 붙은 것)이 전달 
        .subscribe(onNext: { str in //1-3.그 아래 인자 str에 전달되어
            print(str) //프린트됨//1-4. (코드실행)
        })
        .disposed(by: disposeBag)
}
//Hello RxSwift
```
- just 결과에 .map이 반영되어 내려보낸다. ===> 맵핑한다.


```swift
@IBAction func exMap2() {
    Observable.from(["with", "곰튀김"]) //1-1.with부터 내려보냄.***(stream)
        .map { $0.count } //1-1.map에 의해 인티저로 변환
        .subscribe(onNext: { str in //1-3.str는 4가됨
            print(str) //4 -> 이후 "곰튀김" 반복하게되면 3출력됨. 
        })
        .disposed(by: disposeBag)
}
//4
//3
```

### filter
- 참이면 아래로 보내고, 거짓이면 보내지 않음(스트림)
```swift
@IBAction func exFilter() {
    Observable.from([1, 2, 3, 4, 5, 6, 7, 8, 9, 10])
        .filter { $0 % 2 == 0 } //트루일때 내려가고 펄스일땐 내려가지 않음. (스트림)
        .subscribe(onNext: { n in
            print(n)
        })
        .disposed(by: disposeBag)
}
//2
//4
//6
//8
//10
```

### 응용
```swift
@IBAction func exMap3() {
    Observable.just("800x600")
        .map { $0.replacingOccurrences(of: "x", with: "/") } // "800/600"
        .map { "https://picsum.photos/\($0)/?random" } //https://picsum.photos/800/600/?random
        .map { URL(string: $0) } //url?로 변경
        .filter { $0 != nil } //nil인지 아닌지 -> nil이면 거짓이므로 아래로 진행 안함.
        .map { $0! } //url!
        .map { try Data(contentsOf: $0) } //Data
        .map { UIImage(data: $0) } //UIImage?
        .subscribe(onNext: { image in //image로 전달하여
            self.imageView.image = image //코드 반영
        })
        .disposed(by: disposeBag)
}
}
```


## PromiseKit
- 작동방식이 Rx와 유사 -> 타입을 리턴하는 것.


```swift
import PromiseKit
import UIKit

class PromiseViewController: UIViewController {
    // MARK: - Field
    
    var counter: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            self.counter += 1
            self.countLabel.text = "\(self.counter)"
        }
    }

    // MARK: - IBOutlet

    @IBOutlet var imageView: UIImageView!
    @IBOutlet var countLabel: UILabel!

    // MARK: - IBAction

    @IBAction func onLoadImage(_ sender: Any) {
        imageView.image = nil

        promiseLoadImage(from: LARGER_IMAGE_URL)
            .done { image in
                self.imageView.image = image
            }.catch { error in
                print(error.localizedDescription)
            }
    }

    // MARK: - PromiseKit
  //PromiseKit: 비동기를 쉽게 처리하는  라이브러리
  //Promise를 만들어서 리턴하는 방식
    func promiseLoadImage(from imageUrl: String) -> Promise<UIImage?> {
        return Promise<UIImage?>() { seal in //1-2.seal이라는 데가
            asyncLoadImage(from: imageUrl) { image in //1-1.image가 다운로드 완료되면

                seal.fulfill(image)//1-3. fulfill. 완료됐어, 하고 넘겨주는 곳
              
              //덴, 던, 캐치... => 나온 이후~ 어떻게 사용하겠다
            }
        }
    }
}
```


### 구슬읽기

**just**
![](/image/rx3.png)
![](http://reactivex.io/documentation/ko/operators/images/just.c.png)
- 빨간공을 넣으면 빨간공이나온다.
- | 는 스트림.(컨플릭 나는 곳) 


**from**
![](/image/rx4.png)
- array데이터를 from이라는 연산자를 이용하여 들어간 순서대로 생성
- 생성연산자이기 때문에 ->(화살표가 나옴)
- 6개 전달후 컨플릭

**map**
![](https://andreaslydemann.com/wp-content/uploads/2019/01/map-diagram.png)
- map은 처음부터 쓸수 없고, 기존 스트림이 있는 곳에 스트림을 쓰는 곳
- 화살표에서 화살표로
- x가 들어오면 10을 곱해서 내려보냄. 

**filter**
![](https://miro.medium.com/max/1400/1*C6p2EmpmmnKQjJT7XpaqEg.png)
- 10보다 큰 애들 내려보내기


**first**
![](/image/rx5.png)
- 가장 먼저있는 것 보내기(순서주의)
- 가장왼쪽에 있는 4만 내려보냄

![](/image/rx6.png)
- 공모양 중 가장 첫 번째인 것 

![](/image/rx7.png)
- 첫번째 이면서도 그게 나머지인 경우(컨플릭 시점 직전에 삽입)

**single**
![](/image/rx8.png)
- 한개의 경우

![](/image/rx9.png)
- 싱글이면서 그 나머지의 경우 주황공 생성
- 컨플릭 시점 직전에 삽입

![](/image/rx10.png)
- 튜플
- 유일한 항목을 내보내는 경우
- 좀더 이해 필요

**flatMap**
![](/image/rx11.png)
- 동그란 공 넣으면 마름모로 변경하면서 마름모 +2 개로됨
- 시점 확인 (빨간공 두개, 녹색공 넣는 순간 녹색 마름모2개 생성되는 사이에 파란공 넣어 지면서 녹파녹파 진행.) ==> 중첩
- .map은 데이터를 넣으면 데이터 타입이 나오는데 .flatmap을 넣으면 스트림이 나옴.(하나로 합쳐서 들어온 순서대로 내보내 준다.)

**concent**
![](/image/rx12.png)

- 앞에 것 종료되면 뒤에 것 시작



### 테스트
- 정상적인 구슬치기를 하기 위해서는 1.넥스트, 2.컨플릭, 3.에러 모두 처리할 수 있어야한다. 


*예제1*
- 기본타입 : **event 타입**으로 설정하기
```swift
@IBAction func exJust1() {
  Observable.just("Hello, World") //스트림이 생성.
    //subscribe: 자이제 됐어, 나 이제 그 데이터 최정적으로 사용할거야.
 //   .subscribe(<#T##on: (Event<String>) -> Void##(Event<String>) -> Void#>)
    .subscribe { event in //event타입 이름정의
      switch event { //이벤트는 
      case .next(let str): // .next(데이타 전달받음)
        break
      case .completed:     //.completed(컨플릭)
        break
      case .error(let err): // error(에러)가 있음
        break
      }
      //다른 옵저버블들은 타입이 스트림임. 하지만 subscribe은 disposeble임 그래서 마지막에 bag에 넣어서 처리해야함.
    }.disposed(by: disposeBag)
}
```
**subscribe**
- subscribe : 모든 오퍼레이터의 여정을 거친후 최종적으로 subscribe함.(마지막에 쓰는 것.)
- `.subscribe()`은 실행만하고 결과를 신경쓰고 싶지 않을 때 쓴다.
- 기본형은 `.subscribe(<#T##on: (Event<String>) -> Void##(Event<String>) -> Void#>)`이다.  ==> 이벤트타입!!!
- 스트림은 에러가 나거나 컨플릭되면 종료됨!!

*예제2*
- **():** 실행만 하기
```swift
@IBAction func exJust1() {
  Observable.from(["RxSwift", "In", "4", "Hours"]) 
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
    }.disposed(by: disposeBag)
}
//next: RxSwift
//next: In
//next: 4
//next: Hours
//completed
```
- 만약 from의 array방식이라면 next는 4번 도는 것이다. subscribe쪽에 event가 4번 호출
- **completed**은 맨 마지막에 나온다.
- 에러는 발생하지 않았다.

*에러 발생시키기*
- 예제2에 single()오퍼레이터를 추가해보자(싱글이 아니기 때문에 오류남. from은 다수고)
```
next: RxSwift
error: The operation couldn’t be completed. (RxSwift.RxError error 5.)
```

*예제3*
- **(onNext : ....) :** 원하는 것만 골라쓰기.
- ` .subscribe(onNext: <#T##((String) -> Void)?##((String) -> Void)?##(String) -> Void#>, onError: <#T##((Error) -> Void)?##((Error) -> Void)?##(Error) -> Void#>, onCompleted: <#T##(() -> Void)?##(() -> Void)?##() -> Void#>, onDisposed: <#T##(() -> Void)?##(() -> Void)?##() -> Void#>)` 이것도 있다.
- 이걸 쓰는 이유, 예제2의 event에서 swich로 처리할 경우 하나라도 안쓰면 swich가 뭐라고 하고 코드도 길다. 
- 그래서, `onNext` 하나만 할거야!!! 선언, 나머지는 옵셔널이니까. 기능을 추가하고 싶은 경우 ,(쉼표)를 사용하여 추가해나가면 됨.

```swift
@IBAction func exJust1() {
  Observable.from(["RxSwift", "In", "4", "Hours"]) 
    .subscribe(onNext: { s in 
    print(s)
    }, onCompleted: {
    print("completed")
    })
    .disposed(by: disposeBag)
}
```
- disposed는 종료됨을 의미함 , 그래서 컨플릭,에러도 디스포즈드...
- 방식 : next와 error는 이름정의 필요. onComleted와 onDisposed는 필요없음.
- 그래서, onDisposed에서 disposed가 불리는 경우는 컨플릭나거나 에러나는 경우, 디스포서블에 디스포즈드를 일부러 호출해서 취소시키는 경우.


*축약*
```swift
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
```


*예제4*
- 함수 바깥에 빼서 쓰기

```swift
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
```
- next를 정의하면 `(_ str: Any) -> Void`이런 타입임. 
- 위 형식으로 함수를 만들어서 뺸후, 정의 부분(클로저 부분)에 넣어서 써도 됨. 


### 스케쥴러


```swift
@IBAction func exMap3() {
    Observable.just("800x600")
        .map { $0.replacingOccurrences(of: "x", with: "/") } // "800/600"
        .map { "https://picsum.photos/\($0)/?random" } //https://picsum.photos/800/600/?random
        .map { URL(string: $0) } //url?로 변경
        .filter { $0 != nil } //nil인지 아닌지 -> nil이면 거짓이므로 아래로 진행 안함.
        .map { $0! } //url!
        .map { try Data(contentsOf: $0) } //Data
        .map { UIImage(data: $0) } //UIImage?
        .subscribe(onNext: { image in //image로 전달하여
            self.imageView.image = image //코드 반영
        })
        .disposed(by: disposeBag)
}
```
- 해당 코드를 실행하게 되면 사진을 불러오는동안 스크롤이 안됨 ==> 이유 : 작업이 모두 메인쓰레드에 있기 때문
- .오퍼레이터들이 모두 메인쓰레드에 직렬화로 있는 것임. 
- 그래서 **Concurrent**로 동시에 처리되도록(분산처리되도록) 해결해야함. ==> 메인쓰레드가 아닌 곳에서 실행.


**2가지 방법**

<div>
<img src = "https://github.com/Qussk/RxSwift/blob/main/image/syncg1.gif?raw=true" width="300px">
<img src = "https://github.com/Qussk/RxSwift/blob/main/image/asyncg2.gif?raw=true" width="300px">
</div>


> 왼: **동기 상태(사진 불러오는 중 화면 스크롤 안됨.)를**  오: **비동기(사진 불러오는 것과 관계없이 화면 스크롤 가능.)로...**

### observeOn
> observeOn으로 작업을 Concurrent로 분산처리한다. 
```swift
@IBAction func exMap3() {
    Observable.just("800x600")
      .observeOn(ConcurrentDispatchQueueScheduler.init(qos: .default))//--> Concurrent로 보내기(이미지 다운로드 작업)
        .map { $0.replacingOccurrences(of: "x", with: "/") } // "800/600"
        .map { "https://picsum.photos/\($0)/?random" } //https://picsum.photos/800/600/?random
        .map { URL(string: $0) } //url?로 변경
        .filter { $0 != nil } //nil인지 아닌지 -> nil이면 거짓이므로 아래로 진행 안함.
        .map { $0! } //url!
        .map { try Data(contentsOf: $0) } //Data
        .map { UIImage(data: $0) } //UIImage?
      .observeOn(MainScheduler.instance)//---->main으로 돌아오기 (이미지 표시작업)
        .subscribe(onNext: { image in //image로 전달하여
            self.imageView.image = image //코드 반영
        })
        .disposed(by: disposeBag)
  }
}
```
- `observeOn(ConcurrentDispatchQueueScheduler.init(qos: .default))` <== 애플이 제공해줌
- qos의 속성은 지정가능하다. 
- 이미지 셋팅(화면작업)은 다시 main으로 돌아와야하기 때문에 `          .observeOn(MainScheduler.instance)`을 추가해줌.
- 화면에 대한 작업은 무조건 메인쓰레드에서 진행해야함!!!
- `.observeOn` 이후 코드들에 대한 스케쥴러 변경. 이후 코드들에게 영향미침

### subscribeOn
> subscribeOn으로 작업을 Concurrent로 분산처리한다. 

```swift
@IBAction func exMap3() {
    Observable.just("800x600")
        .map { $0.replacingOccurrences(of: "x", with: "/") }
        .map { "https://picsum.photos/\($0)/?random" } 
        .map { URL(string: $0) } 
        .filter { $0 != nil }
        .map { $0! } 
      .subscribeOn(ConcurrentDispatchQueueScheduler.init(qos: .default)) //--> 아무곳에나 있어도됨. ".subscribe 되는 순간, 선택된 스케쥴러로 모두 적용하겠다.
        .map { try Data(contentsOf: $0) } 
        .map { UIImage(data: $0) } 
        .observeOn(MainScheduler.instance)//---->main으로 돌아오기
        .subscribe(onNext: { image in 
            self.imageView.image = image 
        })
        .disposed(by: disposeBag)
}
```
observeOn이랑 뭐가 달라??
- Observable의 첫번째 줄 부터 영향미치게 하고 싶다! 하면 `subscribeOn`사용.
- `subscribeOn`은 순서관계없이 아무데다가 적용해도됨. `.subscribe`될때 부터    적용하겠다!!! 라는 의미라서. 





### 사이드이펙트
- 외부의 영향을 주는 부분. 사전적의미 : 원래의 목적과 다르게 다른효과 또는 부작용.
`self` 외부에 셋팅하고 전달해줘야하기때문에, 사이드 이펙트 부분이 됨. 

- 사이드 이펙트 허용해주는 곳 : **subscribeOn***, **do**

### do
*기본형*
```swift
.do(onNext:<#T##((UIImage?) throws -> Void)?##((UIImage?) throws -> Void)?##(UIImage?) throws -> Void#>, afterNext: <#T##((UIImage?) throws -> Void)?##((UIImage?) throws -> Void)?##(UIImage?) throws -> Void#>, onError: <#T##((Error) throws -> Void)?##((Error) throws -> Void)?##(Error) throws -> Void#>, afterError: <#T##((Error) throws -> Void)?##((Error) throws -> Void)?##(Error) throws -> Void#>, onCompleted: <#T##(() throws -> Void)?##(() throws -> Void)?##() throws -> Void#>, afterCompleted: <#T##(() throws -> Void)?##(() throws -> Void)?##() throws -> Void#>, onSubscribe: <#T##(() -> Void)?##(() -> Void)?##() -> Void#>, onSubscribed(서브스크라이브하고 나서): <#T##(() -> Void)?##(() -> Void)?##() -> Void#>, onDispose: <#T##(() -> Void)?##(() -> Void)?##() -> Void#>)
```
- 위의 옵저버블 들이 지나가고, onNext에 image가 들어올때, 이것 한 번 쓱 훑어줘.

```swift
@IBAction func exMap3() {
    Observable.just("800x600")
        .map { $0.replacingOccurrences(of: "x", with: "/") }
        .map { "https://picsum.photos/\($0)/?random" } 
        .map { URL(string: $0) } 
        .filter { $0 != nil }
        .map { $0! } 
      .subscribeOn(ConcurrentDispatchQueueScheduler.init(qos: .default)) 
        .map { try Data(contentsOf: $0) } 
        .map { UIImage(data: $0) } 
        .observeOn(MainScheduler.instance)
      .do(onNext: { image in //--> 외부영향 허용 부분
        print(image?.size)
      })
        .subscribe(onNext: { image in //-> 외부영향 허용 부분
            self.imageView.image = image 
        })
        .disposed(by: disposeBag)
}
}
```
- 외부영향 끼쳐야하는 것. 외부에 이미지 셋팅, 불러오기.
- subscribe나 do에서만 하자.


### RxCocoa
- UIKit에 View다룰 때 좋을만한 extension들이 추가로 있음.
- `pod RxCocoa`


## step3   
: 실습
- 개발 목표
```
- email,pw 의 형식이 맞지 않은 경우 [빨간불] 
- 형식 맞으면 로그인 버튼 활성화
- 로그인 버튼 누르면 곰튀김 화면
==> 버튼은 (Enabled)처리되어있음.
```
- 개발 요구사항
```
// id input +--> check valid --> bullet
//          |
//          +--> button enable
//          |
// pw input +--> check valid --> bullet
```

*실습예제*

<div>
<img src = "https://github.com/Qussk/RxSwift/blob/main/image/merge3.gif?raw=true" width="200px">
<img src = "https://github.com/Qussk/RxSwift/blob/main/image/merge2.gif?raw=true" width="300px">
</div>

```swift
// MARK: - Bind UI

private func bindUI() {
  
  //rx 우리가 취급하는 것을 비동기로 받겠다! 선언
  //하나하나 stream에 흘러들어감.
  idField.rx.text.subscribe(onNext: { s in
    print(s)
  })
  .disposed(by: disposeBag)
}

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
```

### orEmpty
*map으로 checkEmailValid함수를 불러와 처리하려는 데 오류난다.*
```swift
idField.rx.text
.filter{ $0 != nil} //1-2
.map{ $0! }//1-3
.map(checkEmailValid) //1-1.에러나는 이유. checkEmailValid은 String인데 이건 옵셔널String임 위 (1-2.1-3.추가)
.subscribe(onNext: { s in
  print(s)
})
.disposed(by: disposeBag)
```
- checkEmailValid()함수는 String인데, 현재 .map의 subscribe은 옵셔널 String임
- 1-2, 1-3 으로 해결할 수 있지만, RxCocoa에서 이를 단순화하는 extension을 제공한다 .   `orEmpty`

```swift
idField.rx.text.orEmpty
.map(checkEmailValid)
.subscribe(onNext: { s in
  print(s)
})
.disposed(by: disposeBag)
```
- 그래서 위처럼 길게 쓸 필요없이 `orEmpty`만 처리해주면 알아서 옵셔널 바인딩처리됨.
- orEmpty은 컨플릭 나지 않음( UI에 대한 인풋 컨플릭 안남.)

"https://github.com/Qussk/RxSwift/blob/main/image/merge4.gif?raw=true" width="300px">

- 참, 거짓으로 처리.


### Observables결합하기


**예시코드**
<img src = "https://github.com/Qussk/RxSwift/blob/main/image/merge5.gif?raw=true" width="300px">

```swift
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
```
- Hidden 처리된 코드


### CombineLatest

<img src = "https://github.com/Qussk/RxSwift/blob/main/image/merge1.gif?raw=true" width="300px">
- 두 값을 받아 isEnabled 처리


- [CombineLatest](http://reactivex.io/documentation/operators/combinelatest.html)
: **CombineLatest** — (컴바인 레이티스트)두 개의 Observable 중 하나가 항목을 배출할 때 배출된 마지막 항목과 다른 한 Observable이 배출한 항목을 결합한 후 함수를 적용하여 실행 후 실행된 새로운 결과를 배출한다.
- id, pw 두개의 결과를 받아들이는데, 옵저버블 중 하나라도 항목을 배출할 경우 마지막으로 배출된 항목들을 결합시켜서 배출하는 것.
- (어느한 쪽이라도 바뀌면 결과를 두 개 다 볼 수 있게)

![](/image/latest.png)

```swift
Observable.combineLatest(
  idField.rx.text.orEmpty.map(checkEmailValid), //소스1 아이디 입력값.벨리드하냐안하냐
  pwField.rx.text.orEmpty.map(checkPasswordValid), //소스2 메일입력값.벨리드하냐안하냐
resultSelector: { s1, s2 in s1 && s2 }
)
.subscribe(onNext: { b in
  self.loginButton.isEnabled = b
})
.disposed(by: disposeBag)
}
```
- 두개의 결과를 모두 볼 수 있도록
- 여러개중에  소스1, 소스2, resultSelector를 선택했음. 여기서 resultSelector는 소스1,소스2 두개의 결과를 받아서 하나만 결정 해줘라!
- 둘다 변경된 상태를 보고 내가 원하는 상태로 결정하겠다. 


### zip
- [zip](http://reactivex.io/documentation/operators/zip.html)
- 명시한 함수를 통해 여러 Observable들이 배출한 항목들을 결합하고 함수의 실행 결과를 배출한다.
- 두개를 주면 둘 다 데이터가 만들어지면 그제서야 데이터 전달. 
- 만약에 한쪽의 데이터가 바뀌었다, 하지만 다른 한쪽은 유지되어있다. 그럼 나머지 하나의 nextOn 변경되지 않았기 때문에 데이터 전달이 안됨. 둘다 새로운 next가 되어야 전달됨.
- (현재 예제와 맞지않아 사용안함)

### merge
- [merge](http://reactivex.io/documentation/operators/merge.html)
- 복수 개의 Observable들이 배출하는 항목들을 머지시켜 하나의 Observable로 만든다
- 두 개의 String을 받는데, 여기 데이터나, 저기 데이터나 전달이됨, 셀렉할 수 있는게 아니라 순서대로 그냥 전달해줌.
- 밑으로 그냥 순서대로 내려 보내줌. 
- (현재 예제와 맞지않아 사용안함)



### 심화
: Observables결합 심화로 보기

- input : 아이디 입력, 비번 입력
- output : 블릿(빨간점), 로그인버튼 이네이블

```swift
private func bindUI() {
  
  let idinputOb = idField.rx.text.orEmpty.asObservable()
  let idValideOb = idinputOb.map(checkEmailValid)
  
  let pwinputOb = pwField.rx.text.orEmpty.asObservable()
  let pwValidOb = pwinputOb.map(checkPasswordValid)
  
  Observable.combineLatest(idValideOb, pwValidOb, resultSelector: { $0 && $1 })
    .subscribe(onNext: { b in
      self.loginButton.isEnabled = b
    })
    .disposed(by: disposeBag)
  
```
- 이런식으로 Observable타입으로 만들어서 변수선언하여 사용가능
(코드양 줄어듦!)


## Subject

: Subject 4가지
- AsyncSubject
- BehaviorSubject
- PublishSubject
- ReplaySubject



### AsyncSubject

![](/image/rx16.png)

- 빨간공, 녹색공, 파란공, 컨플릭 ===> 끝내기. 
- 끝이 나야 전달함. 
- 끝났을 때 시점에 subscribe한 곳에 가장 마지막 데이터를 전달.



### BehaviorSubject


![](/image/rx13.png)

- subscribe를 하면 디폴트 값(value: 핑크공)을 내려준다. stream에 data(빨,녹,파)가 발생하면 핑크공에게 전달해준다. 
- 만약, data가 발생한 이후에 다른 놈이 subscribe한다면, 그에 마지막 값인 녹색공을 내려보내주고, 그 다음부터 발생하는 값들을 또 받아 온다. 
- 그 전에 했던놈, 나중에 했던놈...이런식으로 subscribe했다면 걔네한테 받아 올 수 있다.
- 옵저버블 타입이고 스스로 데이터를 가지고 있음.==> 스스로 데이타를 발생할수 있는 놈.
- 그러므로, subscribe는 원래 데이터를 가지고 있는 놈이고, 외부에서 데이타가 발생하면 데이터를 넣어 줄 수 있는 놈.
- 즉, 데이터도 넣을 수 있고, subscribe도 할 수 있는 놈

```swift
var idValiad : BehaviorSubject<Bool> = BehaviorSubject(value: false)
var pwValiad : BehaviorSubject<Bool> = BehaviorSubject(value: false)
```

```swift
private func bindUI() {
  
  let idinputOb = idField.rx.text.orEmpty.asObservable()
  let idValideOb = idinputOb.map(checkEmailValid)

  idValideOb.subscribe(onNext: { b in
      self.idValiad.onNext(b)
    })
  
```
- 옵져버블타입이지만 데이터를 넣을 수 있음
-  `idValideOb`에서 데이터가 발생하고, 그 데이터를 `subscribe`로 받아 먹을 수 있음.
- `idValiad.onNext(b)`이렇게 데이터를 넣어 줄 수 있음
- .onNext로 subject를 이용해서 외부의 값을 받아오는 것.
- just나 from등의 오퍼레이터들은 데이터를 직접생성하였느나 subject는 통로역할을 하면서 데이터를 받아옴. 통로만 만들고 나중에 데이터만 받아오는 것.
```swift
private func bindUI() {
  
  let idinputOb = idField.rx.text.orEmpty.asObservable()
  let idValideOb = idinputOb.map(checkEmailValid)

  idValideOb.subscribe(onNext: { b in
      self.idValiad.bind(to: idValiad)
    })
```
- 이런 식으로도 사용가능. input으로 들어온 값은 밖에다가 저장.

```swift
private func bindUI() {
  
  //input 데이터 처리
  let idinputOb = idField.rx.text.orEmpty.asObservable()
  idinputOb.map(checkEmailValid)
   .bind(to: idValiad)
   .disposed(by: disposeBag)
```
- 축약으로, input에 대한 값은 이렇게 처리될 수 있다. 

> Stting값 받기(최종본)
```swift
var idText : BehaviorSubject<String> = BehaviorSubject(value: "")
var pwText : BehaviorSubject<String> = BehaviorSubject(value: "")
var idValiad : BehaviorSubject<Bool> = BehaviorSubject(value: false)
var pwValiad : BehaviorSubject<Bool> = BehaviorSubject(value: false)
```
```swift
// MARK: - Bind UI
private func bindInPut() {

  //1. input 데이터 처리 : 아이디 입력, 패스워드 입력
  idField.rx.text.orEmpty
    .bind(to: idText) //1-1.bind로 idText(String)값을 받고 idText에 저장
    .disposed(by: disposeBag)
  
  idText //저장된 거에서 가져오기
  .map(checkEmailValid) //체크도하고
  .bind(to: idValiad) //1-2. idValiad(Bool)값도 받고, idValiad에 저장
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
idValiad.subscribe(onNext: { c in //2-2. 1-2에서 받았던 idValiad 값을 가져옴.=> 가져올 수 있는건 subject를 전역 변수로 놓았기 때문. 
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
```
- 저장된 데이터를 다른 메소드에서 쓸 수 도 있음



### PublishSubject
![](/image/rx14.png)
- subscribe을 하면 아무것도 안줌
- 디폴트 값이 없음
- 아무것도 주지 않지만, 데이타가 발생하면, subscribe할때 줄게.



### ReplaySubject
![](/image/rx15.png)
- PublishSubject처럼 처음에 아무것도 주지 않음. 
- 빨간공이 발생해서 subscribe한 애한테 전달. 녹색공이 발생해서 subscribe한 애한테 전달.
- 다른 놈이 subscribe하면, 여태까지 발생했던거 모두 전달해준후 다음 것(파란공) 발생하면 다음것 넣어줌
 
 ### 추가내용
 
 ### driver


## **시즌2**
### 일반적인디스패치큐의경우

일반적인 DispatchQueue의 방식
<div>
<img src = "https://github.com/Qussk/RxSwift/blob/main/image/sync3.gif?raw=true" width="300px">
<img src = "https://github.com/Qussk/RxSwift/blob/main/image/async3.gif?raw=true" width="300px">
</div>

> 왼쪽부터: 동기 , 비동기


*예제코드(동기)*
```swift
import RxSwift
import SwiftyJSON
import UIKit

let MEMBER_LIST_URL = "https://my.api.mockaroo.com/members_with_avatar.json?key=44ce18f0"

class ViewController: UIViewController {
    @IBOutlet var timerLabel: UILabel!
    @IBOutlet var editView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.timerLabel.text = "\(Date().timeIntervalSince1970)"
        }
    }

    private func setVisibleWithAnimation(_ v: UIView?, _ s: Bool) {
        guard let v = v else { return }
        UIView.animate(withDuration: 0.3, animations: { [weak v] in
            v?.isHidden = !s
        }, completion: { [weak self] _ in
            self?.view.layoutIfNeeded()
        })
    }

    // MARK: SYNC

    @IBOutlet var activityIndicator: UIActivityIndicatorView!

    @IBAction func onLoad() {
        editView.text = ""
        setVisibleWithAnimation(activityIndicator, true)

        let url = URL(string: MEMBER_LIST_URL)!
        let data = try! Data(contentsOf: url)
        let json = String(data: data, encoding: .utf8)
        self.editView.text = json
        
        self.setVisibleWithAnimation(self.activityIndicator, false)
    }
}
```
**목표**
```
- Indicator 보이게하기
- LOAD시 json불러오는동안 타이머 멈추지 않게
```

*예제코드(비동기로 변경)*
```swift
import RxSwift
import SwiftyJSON
import UIKit

let MEMBER_LIST_URL = "https://my.api.mockaroo.com/members_with_avatar.json?key=44ce18f0"

class ViewController: UIViewController {
    @IBOutlet var timerLabel: UILabel!
    @IBOutlet var editView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.timerLabel.text = "\(Date().timeIntervalSince1970)"
        }
    }

    private func setVisibleWithAnimation(_ v: UIView?, _ s: Bool) {
        guard let v = v else { return }
        UIView.animate(withDuration: 0.3, animations: { [weak v] in
            v?.isHidden = !s
        }, completion: { [weak self] _ in
            self?.view.layoutIfNeeded()
        })
    }

    // MARK: ASYNC

    @IBOutlet var activityIndicator: UIActivityIndicatorView!

    @IBAction func onLoad() {
        editView.text = ""
      self.setVisibleWithAnimation(self.activityIndicator, true)

      DispatchQueue.global().async {
        let url = URL(string: MEMBER_LIST_URL)!
        let data = try! Data(contentsOf: url)
        let json = String(data: data, encoding: .utf8)
        
        //UI화면 작업은 main쓰레드로,
        DispatchQueue.main.async {
          self.editView.text = json
          self.setVisibleWithAnimation(self.activityIndicator, false)
        }
      }

    }
}

```

**refactoring**
- 함수 따로 만들어서 처리 1
```swift
func downloadJson(_ url: String) -> String?{
  let url = URL(string: url)!
  let data = try! Data(contentsOf: url)
  let json = String(data: data, encoding: .utf8)
  return json
}

  // MARK: ASYNC

  @IBOutlet var activityIndicator: UIActivityIndicatorView!

  @IBAction func onLoad() {
      editView.text = ""
    self.setVisibleWithAnimation(self.activityIndicator, true)

    DispatchQueue.global().async {
      let json = self.downloadJson(MEMBER_LIST_URL)
      
      //UI화면 작업은 main쓰레드로,
      DispatchQueue.main.async {
        self.editView.text = json
        self.setVisibleWithAnimation(self.activityIndicator, false)
      }
    }

  }
}

```
- 비동기작업을 함수에 따로 작업하고 싶음2 
```swift
//비동기작업만 따로 작업
func downloadJson(_ url: String) -> String?{
  DispatchQueue.global().async {
    let url = URL(string: url)!
    let data = try! Data(contentsOf: url)
    let json = String(data: data, encoding: .utf8)
    return json
  }
}
```
DispatchQueue는 리턴할 수 없으므로 complation으로 클로저 이용하여 처리
```swift
//비동기작업만 따로 작업
func downloadJson(_ url: String, _ complecation: @escaping (String?) -> Void) {
  DispatchQueue.global().async {
    let url = URL(string: url)!
    let data = try! Data(contentsOf: url)
    let json = String(data: data, encoding: .utf8)
  
    DispatchQueue.main.async {
      complecation(json) //결과값 전달
    }
  }
}
/*
tips
_ complecation: ((String?) -> Void)?)인 경우<complecation이 옵셔널인 경우> @escaping생략가능
*/

// MARK: ASYNC
@IBOutlet var activityIndicator: UIActivityIndicatorView!

@IBAction func onLoad() {
  editView.text = ""
  setVisibleWithAnimation(self.activityIndicator, true)
  
  downloadJson(MEMBER_LIST_URL) { json in
    self.editView.text = json
    self.setVisibleWithAnimation(self.activityIndicator, false)
  }
 }
}

```
- 4번 호출? 33(만약 비동기 해야할 작업이 많다면..)
<div>
<img src = "https://github.com/Qussk/RxSwift/blob/main/image/async4.gif?raw=true" width="300px">
</div>

```swift
// MARK: ASYNC
@IBOutlet var activityIndicator: UIActivityIndicatorView!

@IBAction func onLoad() {
  editView.text = ""
  setVisibleWithAnimation(self.activityIndicator, true)
  
  downloadJson(MEMBER_LIST_URL) { json in
    self.editView.text = json
    self.setVisibleWithAnimation(self.activityIndicator, false)
    
    self.downloadJson(MEMBER_LIST_URL) { json in
      self.editView.text = json
      self.setVisibleWithAnimation(self.activityIndicator, false)
      
      self.downloadJson(MEMBER_LIST_URL) { json in
        self.editView.text = json
        self.setVisibleWithAnimation(self.activityIndicator, false)
        
        self.downloadJson(MEMBER_LIST_URL) { json in
          self.editView.text = json
          self.setVisibleWithAnimation(self.activityIndicator, false)
        }
      }
    }
  }
}
}
```
**디스패치 문제점**
- 4번의 호출경우, 중간에 에러시 작업등의 코드삽입시 코드 복잡해짐. 
- 비동기 작업하는 함수에서 escaping처리안하고, 그냥 return하면 안돼?? 그럼 훨씬 간결해질텐데..... =>에서 출발(유틸리티등장). 리턴만 하게 되면 메인쓰레드 코드가 아래처럼 간결해짐. 
```swift
let json = downloadJson(MEMBER_LIST_URL)
editView.text = json
setVisibleWithAnimation(activityIndicator, false)
```

**그래서 등장한 것(나중에 생기는 데이터로 감싸기)**
- completion: @escaping 쓰기않고 리턴하기. 
```swift
import RxSwift
import SwiftyJSON
import UIKit

let MEMBER_LIST_URL = "https://my.api.mockaroo.com/members_with_avatar.json?key=44ce18f0"

class 나중에생기는데이터<T> {
private let task: (@escaping (T)-> Void) -> Void

init(task: @escaping (@escaping (T) -> Void) -> Void) {
self.task = task
 }
 
func 나중에오면(_ f: @escaping (T) -> Void) {
task(f)
 }
}

class ViewController: UIViewController {
  @IBOutlet var timerLabel: UILabel!
  @IBOutlet var editView: UITextView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
      self?.timerLabel.text = "\(Date().timeIntervalSince1970)"
    }
  }
  
  private func setVisibleWithAnimation(_ v: UIView?, _ s: Bool) {
    guard let v = v else { return }
    UIView.animate(withDuration: 0.3, animations: { [weak v] in
      v?.isHidden = !s
    }, completion: { [weak self] _ in
      self?.view.layoutIfNeeded()
    })
  }
  
  //비동기작업만 따로 작업
  func downloadJson(_ url: String) -> 나중에생기는데이터<String?> {
  return 나중에생기는데이터(){ f in //리턴등장
  DispatchQueue.global().async {
    let url = URL(string: url)!
    let data = try! Data(contentsOf: url)
    let json = String(data: data, encoding: .utf8)

    DispatchQueue.main.async {
      f(json) //결과값 전달
    }
  }
   
    }
  }

  // MARK: ASYNC
  @IBOutlet var activityIndicator: UIActivityIndicatorView!

  @IBAction func onLoad() {
    editView.text = ""
    setVisibleWithAnimation(self.activityIndicator, true)
    
    let json: 나중에생기는데이터<String?> = downloadJson(MEMBER_LIST_URL)
    
    json.나중에오면 { json in
      self.editView.text = json
      self.setVisibleWithAnimation(self.activityIndicator, false)
    }
   }
  }
```
- 이런식으로 표현 가능
- 이러한 유틸리티등장1: PromiseKit (아래코드 참고), Bolt, RxSwift
```swift
// MARK: ASYNC
@IBOutlet var activityIndicator: UIActivityIndicatorView!
@IBAction func onLoad() {
  editView.text = ""
  setVisibleWithAnimation(self.activityIndicator, true)
  
  downloadJson(MEMBER_LIST_URL)
  .then { json in
    self.editView.text = json
    self.setVisibleWithAnimation(self.activityIndicator, false)
  }
 }
}
```
### 예제RxSwift로변경

위의 나중에 생기는데이터 ==> 옵져버블
위의 나중에오면 ==> 서브스크라이브
```swift
import RxSwift
import SwiftyJSON
import UIKit

let MEMBER_LIST_URL = "https://my.api.mockaroo.com/members_with_avatar.json?key=44ce18f0"

class Observable<T> {
private let task: (@escaping (T)-> Void) -> Void

init(task: @escaping (@escaping (T) -> Void) -> Void) {
self.task = task
 }
 
func subscribe(_ f: @escaping (T) -> Void) {
task(f)
 }
}
...(중략)

//비동기작업만 따로 작업
func downloadJson(_ url: String) -> Observable<String?> {
return Observable.create { f in //create를 통해 생성(리턴의 기능)
DispatchQueue.global().async {
  let url = URL(string: url)!
  let data = try! Data(contentsOf: url)
  let json = String(data: data, encoding: .utf8)

  DispatchQueue.main.async {
    f.onNext(json) //결과값 전달
  }
}
 return Disposables.create()
  }
}

// MARK: ASYNC
@IBOutlet var activityIndicator: UIActivityIndicatorView!
@IBAction func onLoad() {
  editView.text = ""
  setVisibleWithAnimation(self.activityIndicator, true)
  
  downloadJson(MEMBER_LIST_URL)
  .subscribe { event in
    switch event {
    case.next(let json):
    self.editView.text = json
    self.setVisibleWithAnimation(self.activityIndicator, false)
    
    case .completed:
     break
    case .error:
     break
     }
  }
 }
}
```
- RxSwift는 complation으로 전달하는게 아니라, 리턴값으로 전달하기 위해 등장. 
- 옵져버블 형태로 감싸서 리턴하면, 이는 나중에 생기는 데이터(Observable)다.
- 나중에 생기는 데이터를 사용할때는 나중에 오면(subscribe)를 호출하면된다.
- 거기(subscribe)엔 이벤트(event)가 오는데 종류는 3가지다. .next, .completed, error. (몇개 더 있긴함)
- 그리고, 데이터가 전달될 때는 Next로 온다.

### 순환참조없이

위 코드는 순환참조 생기는 문제가 있음
(클로저가 self를 캡처하면서 레퍼런스카운트가 증가하면 순환참조가 생김. )
**1. 순환참조적용**
```swift
// MARK: ASYNC
@IBOutlet var activityIndicator: UIActivityIndicatorView!
@IBAction func onLoad() {
  editView.text = ""
  setVisibleWithAnimation(self.activityIndicator, true)
  
  downloadJson(MEMBER_LIST_URL)
    .subscribe { [weak self] event in
      switch event {
      case.next(let json):
        self?.editView.text = json
        self?.setVisibleWithAnimation(self?.activityIndicator, false)
        
      case .completed:
        break
      case .error:
        break
      }
    }
}
}

```

**2. (다른 방법)레퍼런스 카운트를 감소시켜주면된다.**

- 클로저가 없어지면 레퍼런스카운트도 없어짐. 
- 언제없어지냐 ? **.completed, .error**에서
- completed시키면 역할이 다했다는 의미로 레퍼런스카운트가 없어짐.
- 클로저 범위까지만 수행하고 클로저 사라짐. ==> 클로저 자체가 사라지니까 RC도 자연스럽게 감소(없어지는)하는 것;;

```swift
//비동기작업만 따로 작업
func downloadJson(_ url: String) -> Observable<String?> {
  return Observable.create { f in //create를 통해 생성(리턴의 기능)
    DispatchQueue.global().async {
      let url = URL(string: url)!
      let data = try! Data(contentsOf: url)
      let json = String(data: data, encoding: .utf8)
      
      DispatchQueue.main.async {
        f.onNext(json) //결과값 전달
        f.onCompleted() //결과 끝났어(RC 낮추기) <--이것만 추가하면 됨;;
      }
    }
    return Disposables.create()
  }
}

// MARK: ASYNC
@IBOutlet var activityIndicator: UIActivityIndicatorView!
@IBAction func onLoad() {
  editView.text = ""
  setVisibleWithAnimation(self.activityIndicator, true)
  
  downloadJson(MEMBER_LIST_URL)
    .subscribe { event in
      switch event {
      case.next(let json):
        self.editView.text = json
        self.setVisibleWithAnimation(self.activityIndicator, false)
        
      case .completed:
        break
      case .error:
        break
      }
    }
}
}

```

### 디버깅해보자

위의 `f.onCompleted()` 를 추가하고 정말 메모리누수가 일어나지 않았는지 확인...! 디버깅해보자. 

<div>
<img src = "https://github.com/Qussk/RxSwift/blob/main/image/t1.png?raw=true" width="800px">

워크스페이스 빌더 >  Edit scheme...

들어가면 위의 창이 나옴. 해당 체크하고 close.... 빌드환경?내용??을 바꾼것!

<img src = "https://github.com/Qussk/RxSwift/blob/main/image/t2.png?raw=true" width="800px">
콘솔 누름

<img src = "https://github.com/Qussk/RxSwift/blob/main/image/t3.png?raw=true" width="800px">
좌측 하단 느낌표 누름

<img src = "https://github.com/Qussk/RxSwift/blob/main/image/t4.png?raw=true" width="800px">
위와 같은 그림이면 메모리 누수 일어나지 않음!! 



```
시즌2의 RxSwift학습내용
1. 비동기로 생기는 데이터를 Observable로 감싸서 리턴하는 방법
2. Observable로 오는 데이터를 받아서 처리하는 방법
```


### 메모리누수

: 메모리누수 디버깅하기
```swift
/* 아래 함수에 해당 코드를 추가
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil)
  */
  
  _ = Observable<Int>.interval(1, scheduler: MainScheduler.instance)
      .subscribe(onNext: { _ in
          print("Resource count \(RxSwift.Resources.total)")
      })
```
메모리 누수를 테스트하기 위한 여러가지
- 원하는 화면으로 가서 작동한다
- 뒤로 돌아간다
- 초기 자원 갯수를 관찰한다
- 다시 그 화면으로 돌아가서 같은 작업을 한다
- 뒤로 돌아간다
- 마지막 자원 갯수를 관찰한다

> 처음과 끝의 자원 객수가 다르다면, 어디선가 메모리 누수가 발생하고 있다는 뜻!!
> 네비게이션을 하나가 아닌 둘로 확인하는 것을 추천하는 이유는 첫번째 네비게이션은 자원을 게으르게 불러오도록 강요하기 때문입니다.??




