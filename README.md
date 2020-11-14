# RxSwift
RxSwift에 대한 학습


*비동기 작업을 간결하게*

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
## RxSwift 4시간에 끝내기
  - [머리말](#RxSwiftIn4Hours)
  - [왜쓰냐?](#일반적인비동기방식)
  - [step1](#step1)
    - [Observable사용](#Observable사용)
    - [dispose사용](#dispose사용)
    - [DisposeBag사용]
      - .disposed(by: disposebag)
  - [step2](#step2)
    - [just](#just)
    - [from](#from)
    - [map](#map)
    - [filter](#filter)
    - [응용](#응용)
  - [구슬읽기](#구슬읽기)  
  - [스케쥴러](#스케쥴러)


### observable

[공식사이트 보기](http://reactivex.io/documentation/ko/observable.html) => 한국어 지원됨 !






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

> 왼쪽 : 동기 ,  오른쪽:  비동기


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
<img src = "https://github.com/Qussk/RxSwift/blob/main/image/rxg1.gif?raw=true" width="200px">
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




