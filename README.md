# InfomaniakDI

Minimalist dependency injection mechanism.

## Abstract
Register factories thanks to the `Factory` type into the resolver.
Use the property wrapper `@InjectService` to resolve a shared instance.

Can be used from the mainthread only, will throw otherwise

## Features
- [x] Pure Swift Type Support
- [x] Injection by name
- [x] Injection with Arguments
- [x] Integration tests

## Roadmap
- [ ] Thread safety
- [ ] Lazy init
- [ ] Optionals

## Requirements
- Swift 5.x +
- SPM

## Usage

Early on in the lifecycle of your app, you want to write something like this :

```
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
```
@InjectService var injected: SomeService
```
Injection will be performed at the init time of the owner of the property.

Checkout `ITSimpleReslover.swift` for more advanced examples.
