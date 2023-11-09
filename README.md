# InfomaniakDI

Minimalist dependency injection mechanism written in pure Swift.

## Abstract
Register factories thanks to the `Factory` type into the resolver.
Use the property wrapper `@InjectService` to resolve a shared instance from any queue.

## Features
- [x] Pure Swift Type Support
- [x] Thread safety
- [x] Injection by name
- [x] Injection with Arguments
- [x] Integration tests
- [x] Lazy init (with @LazyInjectService)
- [x] Efficient SwiftUI with `@LazyInjectService` and `@InjectService` used as IVAR in `View`

## OS Support

Anything with first party Swift support. (iOS / macOS / Linux …)

## Roadmap
- [ ] Optionals
- [ ] Multiple containers

## Requirements
- Swift 5.x +
- SPM

## Usage

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

Checkout `ITSimpleReslover.swift` for more advanced examples.

## Licence

This package is available under the permissive ApacheV2 licence for you to enjoy. 
