//
//  CancelBag.swift
//  MetaverseCompetition
//
//  Created by HayeonKim on 2022/08/18.
//  Copyright © 2022 Apple. All rights reserved.
//

import Combine

/// subscription 이 중간에 cancel 되었을 때 해야할 일들을 선언하는 곳
final class CancelBag {
  fileprivate(set) var subscriptions = Set<AnyCancellable>()

  func cancel() {
    subscriptions.removeAll()
  }

  func collect(@Builder _ cancellables: () -> [AnyCancellable]) {
    subscriptions.formUnion(cancellables())
  }

  @resultBuilder
  enum Builder {
    static func buildBlock(_ cancellables: AnyCancellable...) -> [AnyCancellable] {
      return cancellables
    }
  }
}

extension AnyCancellable {
  func store(in cancelBag: CancelBag) {
    cancelBag.subscriptions.insert(self)
  }
}

