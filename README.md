# SGSwiftyBind

A light weight approach to event based programming

[![Build Status](https://travis-ci.org/eman6576/SGSwiftyBind.svg?branch=master)](https://travis-ci.org/eman6576/SGSwiftyBind)
[![codecov](https://codecov.io/gh/eman6576/SGSwiftyBind/branch/master/graph/badge.svg)](https://codecov.io/gh/eman6576/SGSwiftyBind)
![Swift 4.0](https://img.shields.io/badge/Swift-4.0-orange.svg?style=flat)
[![DUB](https://img.shields.io/dub/l/vibe-d.svg)](https://github.com/eman6576/SGSwiftyBind/blob/master/LICENSE)
[![platform](https://img.shields.io/badge/platform-iOS%20%7C%20macOS%20%7C%20Linux-lightgrey.svg)]()
[![standard-readme compliant](https://img.shields.io/badge/readme%20style-standard-brightgreen.svg?style=flat-square)](https://github.com/RichardLitt/standard-readme)

## Table of Contents

- [Background](#background)
- [Install](#install)
- [Usage](#usage)
- [API](#api)
- [Contribute](#contribute)
- [License](#license)

## Background

When developing applications using architectures like Model-View-Viewmodel, needing to know when a value changes in an object, or
just wanting to have a notification based API, I have found using APIs like `NotificationCenter` were diffcult to write good unit tests to validate that execution happened. Also using these existing API's would promote the bad practice of not using a unidirectional dataflow.

## Install

### CocoaPods

You can use [CocoaPods](https://cocoapods.org) to install `SGSwiftyBind` by adding it to your `Podfile`:

```ruby
platform :ios, '9.0'
use_frameworks

target 'MyApp' do
    pod 'SGSwiftyBind'
end
```

### Carthage

You can use [Carthage](https://github.com/Carthage/Carthage) to install `SGSwiftyBind` by adding it to your `Cartfile`:

```bash
github "eman6576/SGSwiftyBind"
```

### Swift Package Manager

You can use [Swift Package Manager](https://swift.org/package-manager/) to install `SGSwiftyBind` by adding the proper description to your `Package.swift` file:

```swift
import PackageDescription

let package = Package(
    name: "YOUR_PROJECT_NAME",
    dependencies: [
        .package(url: "https://github.com/eman6576/SGSwiftyBind.git", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "YOUR_TARGET_NAME",
            dependencies: [
                "SGSwiftyBind"
            ])
    ]
)
```

## Usage

**NB**: This repository contains an examples directory with different examples on how to use this library. We recommend trying the examples out. Also check out the unit tests to see the library in action as well.

### Initialization

To access the available data types, import `SGSwiftyBind` into your project like so:

```swift
import SGSwiftyBind
```

### Functionality

`SGSwiftyBind` uses generics for storing different data types:

```swift
let intBind: SGSwiftyBind<Int> = SGSwiftyBind(1)
let doubleBind: SGSwiftyBind<Double> = SGSwiftyBind(1.2)
let stringBind: SGSwiftyBind<String> = SGSwiftyBind("Hello World")
```

You can even use your own custom types:

```swift
protocol Animal {
    var age: Int { get }

    init(age: Int)

    func makeSound()

    func increaseAge()
}

struct Dog: Animal {
    var age: Int

    init(age: Int) {
        self.age = age
    }

    func makeSound() {
        print("Bark")
    }

    func increaseAge() {
        age += 1
    }
}

let dog = Dog(age: 3)
let animalBind: SGSwiftyBind<Animal> = SGSwiftyBind(dog)
```

A great use case for using SGSwiftyBind is for knowing when a variable changes or some event occurs. Lets modify our `Animal` protocol to use `SGSwiftyBind`:

```swift
protocol Animal {
    var age: SGSwiftyBindInterface<Int> { get }

    init(age: Int)

    func makeSound()

    func increaseAge()
}

struct Dog: Animal {
    var age: SGSwiftyBindInterface<Int> {
        return ageBind.interface
    }

    private let ageBind: SGSwiftyBind<Int>

    init(age: Int) {
        ageBind = SGSwiftyBind(age)
    }

    func makeSound() {
        print("Bark")
    }

    func increaseAge() {
        ageBind.value += 1
    }
}
```

We modified our `Animal` to have a binder interface on the `age` property. Our `Dog` would need to update its `age` property to return a binder interface. and added a private binder called `ageBind` of type `SGSwiftyBind<Int>`. Now lets use our `Dog` object:

```swift
let dog = Dog(age: 3)

dog.age.bind({ (newAge) in
    print("This is the dog's new age: \(newAge)")
}, for: self)

dog.makeSound()
dog.increaseAge()
```

In the example, we allocate a `Dog` instance. We then register a binder on the age property so that when the value changes, we can get the new value and do something with it. In our case, we are printing the value to the console.

The `age` property on a `Dog` instance is of type `SGSwiftyBindInterface<Int>` and not `SGSwiftyBind<Int>`. The idea behind this is so the outside can not mutate the state of `ageBind`. Here is an example:

```swift
let currentAge = dog.age.value // We can retrieve the current value of age
dog.age.value = currentAge     // The complier would give us an error stating that `age.value` is a get-only property
```

Once we are done using the binder on our `Dog` instance, we should perform some clean up and remove it like so:

```swift
dog.age.unbind(for: self)
```

We can also get the current number of observers that have registered a particular binder:

```swift
let observerCount = dog.age.observerCount
```

## Contribute

See [the contribute file](CONTRIBUTING.md)!

PRs accepted.

Small note: If editing the Readme, please conform to the [standard-readme](https://github.com/RichardLitt/standard-readme) specification.

## Maintainers

Manny Guerrero [![Twitter Follow](https://img.shields.io/twitter/follow/SwiftyGuerrero.svg?style=social&label=Follow)](https://twitter.com/SwiftyGuerrero) [![GitHub followers](https://img.shields.io/github/followers/eman6576.svg?style=social&label=Follow)](https://github.com/eman6576)

## License

[MIT © Manny Guerrero.](https://github.com/eman6576/SGSwiftyBind/blob/master/LICENSE)
