// MIT License

// Copyright (c) 2018 Manny Guerrero

// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import Foundation

// MARK: - Typealias
public typealias Listener<T> = (T) -> Void
public typealias ValueCallback<T> = () -> T
private typealias BindCallback<T> = (Listener<T>?, AnyObject) -> Void
private typealias BindAndFireCallback<T> = BindCallback<T>
private typealias UnbindCallback = (AnyObject) -> Void


// MARK: - Observer

/// A struct representing an observer and their registered listener.
struct Observer<T> {
    
    // MARK: - Public Instance Attributes
    weak var observer: AnyObject?
    var listener: Listener<T>?
}


// MARK: - SGSwiftyBindInterface

/// A struct representing public attributes and methods for a `SGSwiftyBind` instance.
public struct SGSwiftyBindInterface<T> {
    
    // MARK: - Public Instance Attributes
    
    /// The current value.
    public var value: T { return valueCallback() }
    
    
    // MARK: - Private Instance Attributes
    
    /// Callback for getting the current value.
    private let valueCallback: ValueCallback<T>
    
    /// Callback for when the value changes.
    private let bindCallback: BindCallback<T>
    
    /// Callback for when the value changes and fires immediately.
    private let bindAndFireCallback: BindAndFireCallback<T>
    
    /// Callback for when the listener is unregistered.
    private let unbindCallback: UnbindCallback
    
    
    // MARK: - Initializer
    
    /// Initializes an instance of `SGSwiftyBindInterface`.
    ///
    /// - Parameters:
    ///   - valueCallback: A `ValueCallback<T>` representing the callback for getting the set value.
    ///   - bindCallback: A `BindCallback<T>` representing the callback to invoke when the value changes.
    ///   - bindAndFireCallback: A `BindAndFireCallback<T>` representing the callback to invoke when the value
    ///                          changes.
    ///   - unbindCallback: An `UnbindCallback` representing the callback to invoke when the observer
    ///                     unregisters.
    fileprivate init(valueCallback: @escaping ValueCallback<T>,
                     bindCallback: @escaping BindCallback<T>,
                     bindAndFireCallback: @escaping BindAndFireCallback<T>,
                     unbindCallback: @escaping UnbindCallback) {
        self.valueCallback = valueCallback
        self.bindCallback = bindCallback
        self.bindAndFireCallback = bindAndFireCallback
        self.unbindCallback = unbindCallback
    }
    
    
    // MARK: - Public Instance Methods
    
    /// Binds the listener for listening for changes to the value.
    ///
    /// - Parameters:
    ///   - listener: A `Listener?` representing the callback to invoked when the value changes.
    ///   - observer: An `AnyObject` representing the object that registered the listener.
    public func bind(_ listener: Listener<T>?, for observer: AnyObject) {
        bindCallback(listener, observer)
    }
    
    /// Binds the listener for listening for changes to the value and fires the listener immediately.
    ///
    /// - Parameters:
    ///   - listener: A `Listener?` representing the callback to invoked when the value changes.
    ///   - observer: An `AnyObject` representing the object that registered the listener.
    public func bindAndFire(_ listener: Listener<T>?, for observer: AnyObject) {
        bindAndFireCallback(listener, observer)
    }
    
    /// Removes the listener the observer registered.
    ///
    /// - Parameter observer: An `AnyObject` representing the object that registered the listener.
    public func unbind(for observer: AnyObject) {
        unbindCallback(observer)
    }
}


// MARK: - SGSwiftyBind

/// A class used for binding values and listening for value changes.
public final class SGSwiftyBind<T> {
    
    // MARK: - Public Instance Attributes
    
    /// The interface that handles all bindings.
    public private(set) var interface: SGSwiftyBindInterface<T>!
    
    /// The current value.
    var value: T {
        didSet {
            observers.forEach { $0.listener?(value) }
        }
    }
    
    /// The number of observers.
    var observerCount: Int { return observers.count }
    
    
    // MARK: - Private Instance Attributes
    
    /// The list of observers for this instance
    private var observers: [Observer<T>]
    
    
    // MARK: - Initializers
    
    /// Initializes an instance of `SGSwiftyBind`.
    ///
    /// - Parameter value: A `T` representing the value to bind and listen for changes.
    public init(_ value: T) {
        self.value = value
        observers = []
        interface = SGSwiftyBindInterface(
            valueCallback: {
                return self.value
            },
            bindCallback: { [weak self] (listener, observer) in
                return self?.bind(listener, for: observer)
            },
            bindAndFireCallback: { [weak self] (listener, observer) in
                return self?.bindAndFire(listener, for: observer)
            },
            unbindCallback: { [weak self] (observer) in
                return self?.unbind(for: observer)
            }
        )
    }
    
    
    // MARK: - Private Instance Methods
    
    /// Binds the listener for listening for changes to the value.
    ///
    /// - Parameters:
    ///   - listener: A `Listener?` representing the callback to invoked when the value changes.
    ///   - observer: An `AnyObject` representing the object that registered the listener.
    private func bind(_ listener: Listener<T>?, for observer: AnyObject) {
        let observer = Observer(observer: observer, listener: listener)
        observers.append(observer)
    }
    
    /// Binds the listener for listening for changes to the value and fires the listener immediately.
    ///
    /// - Parameters:
    ///   - listener: A `Listener?` representing the callback to invoked when the value changes.
    ///   - observer: An `AnyObject` representing the object that registered the listener.
    private func bindAndFire(_ listener: Listener<T>?, for observer: AnyObject) {
        bind(listener, for: observer)
        listener?(value)
    }
    
    /// Removes the listener the observer registered.
    ///
    /// - Parameter observer: An `AnyObject` representing the object that registered the listener.
    private func unbind(for observer: AnyObject) {
        let observer1 = observer
        observers = observers.filter { (observe) -> Bool in
            guard let observer2 = observe.observer else { return false }
            return observer1 !== observer2
        }
    }
}
