//
//  Common.swift
//  RxSwiftIn4Hours
//
//  Created by iamchiwon on 21/12/2018.
//  Copyright © 2018 n.code. All rights reserved.
//

import UIKit

let LARGE_IMAGE_URL = "https://picsum.photos/1024/768/?random"
let LARGER_IMAGE_URL = "https://picsum.photos/1280/720/?random"
let LARGEST_IMAGE_URL = "https://picsum.photos/2560/1440/?random"

func syncLoadImage(from imageUrl: String) -> UIImage? {
    guard let url = URL(string: imageUrl) else { return nil }
    guard let data = try? Data(contentsOf: url) else { return nil }

    let image = UIImage(data: data)
    return image
}

func asyncLoadImage(from imageUrl: String, completed: @escaping (UIImage?) -> Void) {
    DispatchQueue.global().async {
      
        let image = syncLoadImage(from: imageUrl)
        completed(image)
    }
}


/*만약에 DispatchQueue으로 코딩을하고 있다면, 취소를 어떻게 할 수 있을까?
- 1. 오퍼레이션 큐
- 2. 캔슬 플러그하나두고, 켜도, 처리되는 내내 온오프 확인하는 그런 작업..
 ==> 이런 귀찮은 작업을 안하기 위해 RxSwift씀
 */
