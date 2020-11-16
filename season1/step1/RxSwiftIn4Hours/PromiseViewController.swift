//
//  PromiseViewController.swift
//  RxSwiftIn4Hours
//
//  Created by iamchiwon on 21/12/2018.
//  Copyright © 2018 n.code. All rights reserved.
//

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
