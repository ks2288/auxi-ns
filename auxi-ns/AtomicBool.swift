//
//  AtomicBool.swift
//  auxi-ns
//
//

import Foundation

/// A simple AtomicBool implementation
struct AtomicBool: Equatable {
    
    /// A synchronized queue to ensure, atomicity when getting/setting values
    private let lockQueue = DispatchQueue(label: "com.atomicbool.lockQueue")
    
    /// The inializing value
    private var _initialValue = false
    
    /// The current actual Bool value
    private var _value = false
    
    /// The value with get/set in atomic fashion
    var value: Bool {
        get {
            var currentValue = _initialValue
            lockQueue.sync {
                currentValue = _value
            }
            return currentValue
        }
        set {
            lockQueue.sync {
                self._value = newValue
            }
        }
    }
    
    /// Init with an initial Bool value,
    ///
    /// - Parameter initialValue: Leave off for the default of false, otherwise specifies an initial value that will be used.
    init(_ initialValue: Bool = false) {
        lockQueue.sync {
            self._initialValue = initialValue
        }
        self.value = initialValue
    }
    
    // MARK: - Equatable
    
    static func == (lhs: AtomicBool, rhs: AtomicBool) -> Bool {
        return lhs.value == rhs.value
    }
}
