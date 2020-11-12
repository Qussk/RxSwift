# RxSwift
RxSwift에 대한 학습


*비동기 작업을 간결하게*




- [RxSwift와 Combine 차이](https://qussk.github.io/2020/11/11/RxSwift%EC%99%80-Combin%EC%9D%98-%EC%B0%A8%EC%9D%B4)
- 유사 라이브러리 
  - PromiseKit



**[문법 보기]**
- [observable](#observable)




**학습 활동**
## RxSwift 4시간에 끝내기
  - [머리말](#RxSwiftIn4Hours)
  - [step1](#step1)



### observable

[공식사이트 보기 : http://reactivex.io/documentation/ko/observable.html](http://reactivex.io/documentation/ko/observable.html) => 한국어 지원됨 !



## RxSwiftIn4Hours
:  RxSwift 4시간에 끝내기
![](https://github.com/iamchiwon/RxSwift_In_4_Hours/raw/master/docs/rxswift_in_4_hours_logo.png)


[강좌 머리말 보기](https://github.com/iamchiwon/RxSwift_In_4_Hours/blob/master/README_s1.md)

### Step1

**Observable**
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


**dispose()**
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



**DisposeBag**
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



### Step2

