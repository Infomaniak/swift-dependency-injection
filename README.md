# InfomaniakDI

[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FInfomaniak%2Fswift-dependency-injection%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/Infomaniak/swift-dependency-injection)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FInfomaniak%2Fswift-dependency-injection%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/Infomaniak/swift-dependency-injection)

Minimalist dependency injection mechanism written in pure Swift.

Support any first party Swift platfom. [ iOS / iPadOS / watchOS / macOS / Linux ]

Well tested. Used in production across the Infomaniak iOS Apps.

Property wrapper based with `@LazyInjectService` and `@InjectService`.

Optimised to work well with SwiftUI Views.

## Features
- [x] Efficient SwiftUI. `@(Lazy)InjectService` will not re-resolve, when used as a property, on a `View` redraw.
- [x] Good integration test coverage
- [x] Pure Swift Type Support
- [x] Thread safety
- [x] Injection by name
- [x] Injection with Arguments
- [x] Lazy init (with @LazyInjectService)

## Roadmap
- [ ] Optionals
- [ ] Multiple containers

## Requirements
- Swift 5.6 +
- SPM

## Setup

Early on in the lifecycle of your app, you want to write something like this :

```swift
import InfomaniakDI

[…]

let factory = Factory(type: SomeService.self) { _, _ in
   SomeService()
}

do {
    try SimpleResolver.sharedResolver.store(factory: factory)
}
catch {
    FatalError("unexpected DI error \(error)")
}
```

later on, when you want to resolve a service use the property wrapper like so:
```swift
@InjectService var injected: SomeService
```
Injection will be performed at the init time of the owner of the property. 

Use `@LazyInjectService` for resolution at first use of the wrapped property. Prefer `@LazyInjectService` when used as a property.

## Documentation

Checkout `ITSimpleReslover.swift` for more advanced examples.

## Licence

This package is available under the permissive ApacheV2 licence for you to enjoy. 
