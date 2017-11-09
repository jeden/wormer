# What's Wormer?
**Wormer** is a lightweight and simple dependency injection framework, written in pure Swift 3, and compatible with Swift 4.

It is freely inspired by [Unity](https://github.com/unitycontainer/unity), an open source DI container for the .NET platform (not to be confused with the Unity game engine).

Wormer uses a static declarative approach to link an interface to its implementation. An _interface_ is generally a protocol, but it can also be a base class, whereas an _implementation_ is either a class or a struct adopting that interface, but ideally it can also be any value type adopting the interface protocol.

The dependency injector container is accessed via the `Injector` class, which exposes a `default` static property. And, if you are wondering, yes, it uses the singleton pattern. The initializer is declared private, to prevent direct instantiation.

# How to use it
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

The `asSingleton` property specifies, when `true`, that a single instance should be created, and always returned - mimicking the singleton pattern. When it's set to `false` instead a new instance is created at any invocation of `instance()` (see below).

The last parameter `initializer` is a closure, which must create and return an instance of the implementation type. Note that this closure is stored internally, so a strong reference is maintained.

## Obtaining an instance bound to an interface

Once an interface is bound to an implementation, a new (or cached, in case of a singleton) instance is obtained by invoking the `instance(for:)` method:

```swift
let instance = Injector.default.instance(for: Interface.self)
```

An overload of `instance(for:)` is available, which takes advantage of type inference for the interface type:

```swift
let instance: Interface = Injector.default.instance()
```

**Warning**: both implementations internally use force unwrapping to cast the interface to the implementation. That results in a runtime exception if the interface has not been bound to an implementation. A safer methods is available, which doesn't use forced unwrapping,  returning an optional instead:

```swift
public func safeInstance<P>(for interfaceType: P.Type) -> P?
```

## Notes

- an interface can be bound to an implementation only
- an implementation can be bound to more than one interface

## How to use it
### Binding
Usually it's done when the app starts, so the most appropriate place is probably `application(didFinishLaunchingWithOptions:)`. I have the good habit of not overcrowding that method, so I usually create an external struct (or enum) with a static method, doing all initialization.

```swift
enum DependencyBuilder {
	static func build() {
		let injector = Injector.default

		/// 1
		injector.bind(interface: EventBus.self,
			toImplementation: EventBusImplementation.self, asSingleton: true) {
			EventBusImplementation()
		}
		let eventBus: EventBus = injector.instance()

		/// 2
		injector.bind(interface: NotificationGateway.self,
			toImplementation: NotificationGatewayImplementation.self, asSingleton: true) {
			NotificationGatewayImplementation(eventBus: eventBus)
		}

		/// 3
		injector.bind(interface: NearableProximityProvider.self,
			toImplementation: BrandedNearableProximityProvider.self, asSingleton: false) {
			BrandedNearableProximityProvider()
		}
	}
}
```

In the above code, three bindings are created:

1. The `EventBus` is bound to `EventBusImplementation`, singleton enabled
2. The `NotificationGateway` is bound to `NotificationGatewayImplementation`, singleton enabled. Note how the initializer requires an `EventBus` instance
3. The `NearableProximityProvider` is bound to `BrandedNearableProximityProvider`, without using the singleton pattern, so a new instance is created at every invocation of `instance()`

### Obtaining instances
As mentioned in the previous paragraph, an instance bound to an interface is obtained using the `instance()` method, or its `instance(for:)` overload.

There are 2 ways dependencies can be injected:

- in the initializer
- via a property

I tend to favor the former in all cases, except when I can't define a new initializer - a typical example is `UIViewController`, whose lifecycle is usually outside of our control, as well as what initializer is used to instantiate it.

### Initializer injection
Suppose to have a class or struct like this:

```swift
struct SomeProvider {
	private var eventBus: EventBus
	init(eventBus: EventBus) {
		self.eventBus = eventBus
	}
}
```

which takes an `EventBus` in the initializer. To create an instance:

```swift
let eventBus: EventBus = Injector.default.instance()
let provider = SomeProvider(eventBus: eventBus)
```

### Property injection
When creating an initializer is not an option, then property injection is the only alternative left, at least in Wormer.
It can be achieved as follows:

```swift
class EventViewController : UIViewController /* NSViewController */ {
	private lazy var eventBus: EventBus = Injector.default.instance()
}

EventViewController()
```

As you can see, I prefer lazy initialization, so that instantiation occurs only if needed.

# Installation
## Platforms
- iOS: yes
- macOS: not yet
- watchOS: not yet
- tvOS: not yet

## Cocoapods
```ruby
pod `wormer`
```

## Carthage
Sorry, not available yet (help appreciated!!)

## Manual
Copy the `Wormer.swift` file and paste it into your project.

# License
MIT license. Read the `LICENSE` file.
