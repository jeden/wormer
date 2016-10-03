**Wormer** is a lightweight and simple dependency injection framework, written in pure Swift.

It is freely inspired by [Unity](https://github.com/unitycontainer/unity), an open source DI container for the .NET platform.

Wormer uses a static declarative approach to link an interface to its implementation. An _interface_ is generally a protocol, but it can also be a base class, whereas an _implementation_ is either a class or a struct adopting that interface, but ideally it can also be any value type adopting the interface protocol.

The dependency injector container is accessed via the `Injector` class, which exposes a `default` static property. And, if you are wondering, yes, it uses the singleton pattern. The initializer is declared private, to prevent direct instantiation.

## Binding an interface to its implementation

Given an interface:

```swift
protocol Interface {}
```

and a class implementing that interface:

```swift
final class Implementation : Interface {}
```

a link is established by invoking the `bind` method:

```swift
Injector.default.bind(interface: Interface.self, toImplementation: Implementation.self, asSingleton: false, initializer: { Implementation() })
```

The `asSingleton` property specifies, when `true`, that a single instance should be instantiated, and that same instance returned - mimicking the singleton pattern. When it's set to `false` instead a new instance is created at any invocation of `instance()` (see below).

The last parameter `initializer` is a closure, which must create and return an instance of the implementation type. Note that this closure is stored internally, so a strong reference is maintained.

## Obtaining an instance bound to an interface

Once an interface is bound to an implementation, a new (or cached, in case of a singleton) instance is obtained by invoking the `instance(for:)` method:

```swift
let instance = Injector.default.instance(for: Interface.self)
```

An overload of `instance` is available, taking advantage of type inference for the interface type:

```swift
let instance: Interface = Injector.default.instance()
```

**Warning**: both implementation internally use force unwrapping to cast the interface to the implementation. That results in a runtime exception if the interface has not been bound to an implementation. A safer methods is available, which doesn't use forced unwrapping,  return an optional instead:

```swift
public func safeInstance<P>(for interfaceType: P.Type) -> P?
```

## Notes

- an interface can be bound to an implementation only
- an implementation can be bound to more than one interface

## Installation
### Cocoapods
```ruby
pod `wormer`
```

### Carthage
Sorry, not available yet

### Manual
Copy the `Wormer.swift` file and paste it into your project.