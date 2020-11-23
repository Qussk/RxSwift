//
//  ViewController.swift
//  MVVMRxSwiftTest
//
//  Created by Qussk_MAC on 2020/11/23.
//

import UIKit
import RxSwift
import RxCocoa

final class CounterViewController: UIViewController {

  @IBOutlet var countLabel: UILabel!
  @IBOutlet weak var plusButton: UIButton!
  @IBOutlet weak var subtractButton: UIButton!

  
    var disposeBag = DisposeBag()
    var viewModel = CounterViewModel()

    private lazy var input = CounterViewModel.Input(plusAction: plusButton.rx.tap.asObservable(),
        subtractAction: subtractButton.rx.tap.asObservable())
    private lazy var output = viewModel.transform(input: input)

  
    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()
    }

    private func bindViewModel() {
        output.countedValue.map { String($0) }
          .drive(countLabel.rx.text).disposed(by: disposeBag)
    }
}
