# RxSwift
RxSwift에 대한 학습


*비동기 작업을 간결하게*




- [RxSwift와 Combine 차이](https://qussk.github.io/2020/11/11/RxSwift%EC%99%80-Combin%EC%9D%98-%EC%B0%A8%EC%9D%B4)
- 유사 라이브러리 
  - [PromiseKit](#)



**[문법 보기]**
- [observable](#observable)




**학습 활동**
## RxSwift 4시간에 끝내기
  - [머리말](#RxSwiftIn4Hours)
  - [왜쓰냐?](#일반적인비동기방식)
  - [step1](#step1)



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


### **dispose()사용**
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
