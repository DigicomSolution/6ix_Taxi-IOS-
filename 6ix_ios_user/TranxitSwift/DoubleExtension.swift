//
//  DoubleExtension.swift
//  TranxitUser
//
//  Created by syed zia on 27/11/2021.
//  Copyright © 2021 Appoets. All rights reserved.
//

import Foundation
extension Double {
  static func equal(_ lhs: Double, _ rhs: Double, precise value: Int? = nil) -> Bool {
    guard let value = value else {
      return lhs == rhs
    }
        
    return lhs.precised(value) == rhs.precised(value)
  }

  func precised(_ value: Int = 1) -> Double {
    let offset = pow(10, Double(value))
    return (self * offset).rounded() / offset
  }
}
public extension Double {
    func greaterThan(_ value: Double, precise: Int) -> Bool {
        let denominator: Double = pow(10.0, Double(precise))
        let maxDiff: Double = 1 / denominator
        let realDiff: Double = self - value

        if fabs(realDiff) >= maxDiff, realDiff > 0 {
            return true
        } else {
            return false
        }
    }

    func greaterThanOrEqual(_ value: Double, precise: Int) -> Bool {
        let denominator: Double = pow(10.0, Double(precise))
        let maxDiff: Double = 1 / denominator
        let realDiff: Double = self - value

        if fabs(realDiff) >= maxDiff, realDiff >= 0 {
            return true
        } else if fabs(realDiff) <= maxDiff {
            return true
        } else {
            return false
        }
    }

    func lessThan(_ value: Double, precise: Int) -> Bool {
        let denominator: Double = pow(10.0, Double(precise))
        let maxDiff: Double = 1 / denominator
        let realDiff: Double = self - value

        if fabs(realDiff) >= maxDiff, realDiff < 0 {
            return true
        } else {
            return false
        }
    }

    func lessThanOrEqual(_ value: Double, precise: Int) -> Bool {
        let denominator: Double = pow(10.0, Double(precise))
        let maxDiff: Double = 1 / denominator
        let realDiff: Double = self - value

        if fabs(realDiff) >= maxDiff, realDiff <= 0 {
            return true
        } else if fabs(realDiff) <= maxDiff {
            return true
        } else {
            return false
        }
    }

    func equal(_ value: Double, precise: Int) -> Bool {
        let denominator: Double = pow(10.0, Double(precise))
        let maxDiff: Double = 1 / denominator
        let realDiff: Double = self - value

        if fabs(realDiff) <= maxDiff {
            return true
        } else {
            return false
        }
    }
}
