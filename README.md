Aeon
====

[![Swift 2.1](https://img.shields.io/badge/Swift-2.1-orange.svg?style=flat)](https://developer.apple.com/swift/)
[![Platforms OS X | iOS](https://img.shields.io/badge/Platforms-OS%20X%20%7C%20iOS-lightgray.svg?style=flat)](https://developer.apple.com/swift/)
[![Cocoapods Compatible](https://img.shields.io/badge/Cocoapods-Compatible-4BC51D.svg?style=flat)](https://cocoapods.org/pods/Luminescence)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-Compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![License MIT](https://img.shields.io/badge/License-MIT-blue.svg?style=flat)](https://github.com/Carthage/Carthage)

**Aeon** is a GCD based HTTP server for **Swift 2**.

## Features

- [x] No `Foundation` dependency (**Linux ready**)

## Dependencies

**Aeon** is made of:

- [Currents](https://github.com/Zewo/Currents) - TCP/IP
- [Luminescence](https://github.com/Zewo/Luminescence) - HTTP parser
- [Kalopsia](https://github.com/Zewo/Kalopsia) - GCD wrapper

## Related Projects

- [Spell](https://github.com/Zewo/Spell) - HTTP router
- [Fuzz](https://github.com/Zewo/Fuzz) - HTTP middleware framework

## Usage

### Solo

You can use **Aeon** without any extra dependencies if you wish.

```swift
import Curvature
import Otherside
import Aeon

struct HTTPServerResponder: HTTPResponderType {
    func respond(request: HTTPRequest) -> HTTPResponse {
    
        // do something based on the HTTPRequest

        return HTTPResponse(status: .OK)
    }
}

let responder = HTTPServerResponder()
let server = HTTPServer(port: 8080, responder: responder)
server.start()
```

### Aeon + Spell

You'll probably need an HTTP router to make thinks easier. **Aeon** and [Spell](https://www.github.com/Zewo/Spell) were designed to work with each other seamlessly.

```swift
import Curvature
import Otherside
import Aeon
import Spell

let router = HTTPRouter { router in
    router.post("/users") { request in

        // do something based on the HTTPRequest

        return HTTPResponse(status: .Created)
    }

    router.get("/users/:id") { request in

        // do something based on the HTTPRequest
        let id = request.parameters["id"]

        return HTTPResponse(status: .OK)
    } 
}

let server = HTTPServer(port: 8080, responder: router)
server.start()
```

## Performance

Start *Aeon Command Line Application* and then run:

```bash
> ab -n 12800 -c 128 http://localhost:8080/   
```

Results in a Macbook Pro early 2013:

```
Concurrency Level:      128
Time taken for tests:   4.223 seconds
Complete requests:      12800
Failed requests:        0
Total transferred:      243200 bytes
HTML transferred:       0 bytes
Requests per second:    3031.00 [#/sec] (mean)
Time per request:       42.230 [ms] (mean)
Time per request:       0.330 [ms] (mean, across all concurrent requests)
Transfer rate:          56.24 [Kbytes/sec] received

Connection Times (ms)
              min  mean[+/-sd] median   max
Connect:        2   21  14.3     20     189
Processing:     5   21  14.1     21     189
Waiting:        3   20  14.5     20     189
Total:         10   42  22.6     42     210

Percentage of the requests served within a certain time (ms)
  50%     42
  66%     50
  75%     54
  80%     58
  90%     61
  95%     63
  98%     64
  99%    203
 100%    210 (longest request)
```

To make this results have any meaning you should create, for example, a node.js server that responds with 200 OK and compare it with **Aeon**.

## Installation

### CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects. You can install it with the following command:

```bash
$ gem install cocoapods
```

> CocoaPods 0.39.0+ is required to build Aeon.

To integrate **Aeon** into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
use_frameworks!

pod 'Aeon', '0.2'
```

Then, run the following command:

```bash
$ pod install
```

### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that automates the process of adding frameworks to your Cocoa application.

You can install Carthage with [Homebrew](http://brew.sh/) using the following command:

```bash
$ brew update
$ brew install carthage
```

To integrate **Aeon** into your Xcode project using Carthage, specify it in your `Cartfile`:

```ogdl
github "Zewo/Aeon" == 0.2
```

### Command Line Application

To use **Aeon** in a command line application:

- Install the [Swift Command Line Application](https://github.com/Zewo/Swift-Command-Line-Application-Template) Xcode template
- Follow [Cocoa Pods](#cocoapods) or [Carthage](#carthage) instructions.

License
-------

**Aeon** is released under the MIT license. See LICENSE for details.
