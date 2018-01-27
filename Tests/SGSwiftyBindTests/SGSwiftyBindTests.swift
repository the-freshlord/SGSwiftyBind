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

@testable import SGSwiftyBind
import XCTest

// MARK: - Movement Type Enum

// swiftlint:disable identifier_name

/// An enum that representing supported movement types. This is used for testing.
private enum MovementType {
    case up
    case down
    case left
    case right
}

// swiftlint:enable identifier_name


// MARK: - SGSwiftyBind Test Suite

/// Test suite for testing SGSwiftyBind behavior.
final class SGSwiftyBindTests: XCTestCase {
    
    // MARK: - Public Class Attributes
    static var allTests = [
        ("testBindings", testBind)
    ]
    
    
    // MARK: - Tests
    
    /// Tests the binding behavior.
    func testBind() {
        let bindExpectation = expectation(description: "Test Bind Behavior: \(#function)")
        
        let swiftyBind: SGSwiftyBind<MovementType> = SGSwiftyBind(.up)
        swiftyBind.interface.bind({ _ in
            bindExpectation.fulfill()
        }, for: self)
        
        XCTAssertEqual(swiftyBind.observerCount, 1, "Observer was not registered!")
        
        swiftyBind.value = .right
        
        waitForExpectations(timeout: 10) { (error) in
            guard error == nil else {
                XCTFail("Error occured in expectation!")
                return
            }
            
            XCTAssertEqual(swiftyBind.interface.value, .right, "Value was not changed!")
            swiftyBind.interface.unbind(for: self)
            XCTAssertEqual(swiftyBind.observerCount, 0, "Observer was not unbinded!")
        }
    }
    
    /// Tests the bind and firing behavior.
    func testBindAndFire() {
        let bindAndFireExpectation = expectation(description: "Test Bind Behavior: \(#function)")
        
        let swiftyBind: SGSwiftyBind<MovementType> = SGSwiftyBind(.up)
        swiftyBind.interface.bindAndFire({ _ in
            bindAndFireExpectation.fulfill()
        }, for: self)
        
        waitForExpectations(timeout: 10) { (error) in
            guard error == nil else {
                XCTFail("Error occured in expectation!")
                return
            }
            
            XCTAssertEqual(swiftyBind.interface.value, .up, "Value was not changed!")
            
            XCTAssertEqual(swiftyBind.observerCount, 1, "Observer was not registered!")
            swiftyBind.interface.unbind(for: self)
            XCTAssertEqual(swiftyBind.observerCount, 0, "Observer was not unbinded!")
        }
    }
}
