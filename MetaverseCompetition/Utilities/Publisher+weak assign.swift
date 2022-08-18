//
//  Publisher+weak assign.swift
//  MetaverseCompetition
//
//  Created by HayeonKim on 2022/08/18.
//  Copyright © 2022 Apple. All rights reserved.
//

import Combine
import Foundation

/// object 에 value를 넣은 subscriber 를 return 하는 함수
extension Publisher where Failure == Never {
  func weakAssign<T: AnyObject>(
    to keyPath: ReferenceWritableKeyPath<T, Output>,
    on object: T
  ) -> AnyCancellable {
    sink { [weak object] value in
      object?[keyPath: keyPath] = value
    }
  }
}
