//
//  Store.swift
//  MetaverseCompetition
//
//  Created by HayeonKim on 2022/08/18.
//  Copyright © 2022 Apple. All rights reserved.
//

import Combine
import SwiftUI

typealias Store<State> = CurrentValueSubject<State, Never>

/// newValue값이 바뀌었을 때만 넣으려고 정의
extension Store {
  subscript<T>(keyPath: WritableKeyPath<Output, T>) -> T where T: Equatable {
    get { value[keyPath: keyPath] }
    set {
      var value = self.value
      if value[keyPath: keyPath] != newValue {
        value[keyPath: keyPath] = newValue
        self.value = value
      }
    }
  }

  // ??
  func bulkUpdate(_ update: (inout Output) -> Void) {
    var value = self.value
    update(&value)
    self.value = value
  }

  // keyPath를 publisher로 바꾸어주고 return 하는 역할
  func updates<Value>(for keyPath: KeyPath<Output, Value>) ->
    AnyPublisher<Value, Failure> where Value: Equatable
  {
    return map(keyPath).removeDuplicates().eraseToAnyPublisher()
  }
}


extension Binding where Value: Equatable {
  typealias ValueClosure = (Value) -> Void

  /// 넣어준 값이 다를때만 set 해주는 함수
  func onSet(_ perform: @escaping ValueClosure) -> Self {
    return .init(get: { () -> Value in
      self.wrappedValue
    }, set: { value in
      if self.wrappedValue != value {
        self.wrappedValue = value
      }
      perform(value)
    })
  }
}

