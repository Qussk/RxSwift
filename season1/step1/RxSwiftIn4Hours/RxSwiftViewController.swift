//
//  RxSwiftViewController.swift
//  RxSwiftIn4Hours
//
//  Created by iamchiwon on 21/12/2018.
//  Copyright © 2018 n.code. All rights reserved.
//

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
  
  
  var desposableBag: DisposeBag = DisposeBag()

    @IBAction func onLoadImage(_ sender: Any) {
        imageView.image = nil
        
      rxswiftLoadImage(from: LARGER_IMAGE_URL)
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
        .disposed(by: desposableBag)
     // desposableBag.insert(desposable)
    }

    @IBAction func onCancel(_ sender: Any) {
        // TODO: cancel image loading
   //   desposable?.dispose() //작업을 모두 취소해버릴 수 있음
      desposableBag = DisposeBag()
      
      /*
       desposableBag은 dispose()을 지원하지 않음. 한꺼번에 지우는 방법은 desposableBag을 새로 만들어주는 것!!
       */
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
