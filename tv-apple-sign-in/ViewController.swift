//
//  ViewController.swift
//  tv-apple-sign-in
//
//  Created by Ting, Lareina a on 19/10/20.
//

import UIKit

class ViewController: UIViewController {

  override var preferredFocusEnvironments: [UIFocusEnvironment] {
    return [self]
  }

  private lazy var continueWithAppleButton: UIButton = {
    let button = UIButton()
    button.translatesAutoresizingMaskIntoConstraints = false
    button.setTitle("Continue with apple sign in", for: .normal)
    button.addTarget(self, action: #selector(continueWithApple), for: .primaryActionTriggered)
    button.setTitleColor(.blue, for: .focused)
    button.setTitleColor(.white, for: .normal)
    return button
  }()
  

  @objc private func continueWithApple() {
    let appleSignIn = AppleGateway.shared
    appleSignIn.login(from: self, delegate: self)
    print("Did tap continueWithApple")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    view.addSubview(continueWithAppleButton)
    NSLayoutConstraint.activate([
      continueWithAppleButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
      continueWithAppleButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
    ])
  }
}

extension ViewController: AppleGatewayDelegate {
  func appleGatewayDidSucceed(_ appleGateway: AppleGateway) {
    let alert = UIAlertController(title: "Sign in", message: "Succeed", preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
    present(alert, animated: true, completion: nil)
  }

  func appleGatewayDidFail(_ appleGateway: AppleGateway, error: Error) {
    let alert = UIAlertController(title: "Sign in", message: "Failure", preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
    present(alert, animated: true, completion: nil)
  }

  func appleGatewayDidStartSessionAuthentication(_ appleGateway: AppleGateway) {
    print("Apple Gateway Did Start Session Authentication")
  }
}

