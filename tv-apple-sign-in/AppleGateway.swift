//
//  AppleGateway.swift
//  tv-apple-sign-in
//
//  Created by Ting, Lareina a on 19/10/20.
//

import Foundation
import UIKit
import AuthenticationServices

protocol AppleGatewayDelegate: class {
  func appleGatewayDidStartSessionAuthentication(_ appleGateway: AppleGateway)
  func appleGatewayDidSucceed(_ appleGateway: AppleGateway)
  func appleGatewayDidFail(_ appleGateway: AppleGateway, error: Error)
}

class AppleGateway: NSObject {
  static let shared = AppleGateway()

  private let appleUserIdKey = "AppleUserId"
  private let fullNameIdKey = "AppleFullName"
  private var viewController: UIViewController?
  private weak var delegate: AppleGatewayDelegate?

  var appleUserId: String? {
    get { return UserDefaults.standard.object(forKey: appleUserIdKey) as? String ?? nil }
    set { UserDefaults.standard.set(newValue, forKey: appleUserIdKey) }
  }

  var fullName: String? {
    get { return UserDefaults.standard.object(forKey: fullNameIdKey) as? String ?? nil }
    set { UserDefaults.standard.set(newValue, forKey: fullNameIdKey) }
  }

  func login(from viewController: UIViewController, delegate: AppleGatewayDelegate?) {
    self.viewController = viewController
    self.delegate = delegate

    if #available(iOS 13.0, tvOS 13.0, *) {
      let request = ASAuthorizationAppleIDProvider().createRequest()
      request.requestedScopes = [.email, .fullName]

      let controller = ASAuthorizationController(authorizationRequests: [request])
      controller.delegate = self
      controller.presentationContextProvider = self
      controller.performRequests()
    }
  }

  func existingAccountLogin(from viewController: UIViewController, delegate: AppleGatewayDelegate?) {
    self.viewController = viewController
    self.delegate = delegate

    if #available(iOS 13.0, tvOS 13.0, *) {
      let requests = [ASAuthorizationAppleIDProvider().createRequest(),
                      ASAuthorizationPasswordProvider().createRequest()]

      let authorizationController = ASAuthorizationController(authorizationRequests: requests)
      authorizationController.delegate = self
      authorizationController.presentationContextProvider = self
      authorizationController.performRequests()
    }
  }

  @available(iOS 13.0, tvOS 13.0, *)
  func getCredentialState(completion: @escaping (ASAuthorizationAppleIDProvider.CredentialState, Error?) -> Void) {
    let provider = ASAuthorizationAppleIDProvider()
    guard let user = appleUserId else { return }

    provider.getCredentialState(forUserID: user) { (credentialState, error) in
      completion(credentialState, error)
    }
  }
}

extension AppleGateway: ASAuthorizationControllerDelegate {
  @available(iOS 13.0, tvOS 13.0, *)
  func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
    switch authorization.credential {
      case let credential as ASAuthorizationAppleIDCredential:
        guard let authorizationCodeData = credential.authorizationCode,
              let authorizationCode = String(data: authorizationCodeData, encoding: .utf8) else {
          return
        }

        appleUserId = credential.user

        var fullName: String = ""
        if let components = credential.fullName {
          let transformer = PersonNameComponentsFormatter()
          fullName = transformer.string(from: components)
        }

        self.fullName = fullName

        self.delegate?.appleGatewayDidSucceed(self)
      case let credential as ASPasswordCredential:
        self.delegate?.appleGatewayDidSucceed(self)
      default:
        break
    }
  }

  @available(iOS 13.0, tvOS 13.0, *)
  func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
    // todo handle error
  }
}

extension AppleGateway: ASAuthorizationControllerPresentationContextProviding {
  @available(iOS 13.0, tvOS 13.0, *)
  func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
    return viewController?.view.window ?? UIWindow()
  }
}
