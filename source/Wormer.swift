//
//  Injector.swift
//  Wormer
//
//  Created by Antonio Bello on 2/15/15.
//  Copyright (c) 2015 Elapsus. All rights reserved.
//
//  Released under the MIT license. See the LICENSE file.


// MARK: - Instance

/// Dependency injector
/// Class exposing a singleton instance which can be used to:
/// - bind interface types to implementtion types,
/// - create an instance of the implementation type bound to an interface type
public final class Injector {
    // MARK: Properties
    fileprivate var instantiators: [String : () -> AnyObject] = Dictionary()
    fileprivate var singletons = [String : AnyObject]()
    
    /// Singleton
    /// :returns: static instance
    public private(set) static var `default` = Injector()
}

// MARK: - Interface
extension Injector {
	/// Bind an interface to an implementation type
    ///
    /// - parameter interfaceType:      interface identifying the registered type
    /// - parameter implementationType: type of the actual interface implementation
    /// - parameter singleton:          flag indicating whether to use the singleton pattern
    /// - parameter initializer:        closure creating an instance of the object
    public func bind<P, T : AnyObject>(interface interfaceType: P.Type, toImplementation implementationType:T.Type, asSingleton singleton:Bool, initializer: @escaping () -> T) {
		let name = key(for: interfaceType)
		return bindInterface(named: name, toImplementation: implementationType, asSingleton: singleton, initializer: initializer)
    }

    /// Bind a protocol to an implementation type
    ///
    /// - parameter interfaceName: name of the interface identifying the registered type
    /// - parameter implementationType: type of the actual protocol implementation
    /// - parameter singleton: flag indicating whether to use the singleton pattern
    /// - parameter initializer: closure creating an instance of the object
    public func bindInterface<T : AnyObject>(named interfaceName: String, toImplementation implementationType:T.Type, asSingleton singleton:Bool, initializer: @escaping () -> T) {
        // Check that the protocol has been registered
        if self.instantiators[interfaceName] == nil {
            // Instantiation closure
            let instantiator = { () -> T in
                // Create an instance
                let instance: T = initializer()
                
                // If it's registered as singleton, stores the instance
                if (singleton) {
                    self.singletons[interfaceName] = instance
                }
                
                return instance
            }
            
            // Store the instantiator
            self.instantiators[interfaceName] = instantiator
        }
    }

	/// Return the implementation corresponding to the interface type
	/// identified by the return value, using type inference to detect
	/// the correct type
	///
	/// - returns: implementation for the type inferred interface type
	public func instance<P>() -> P {
		return instance(for: P.self)
	}


	/// Retrieve the implementaton type for the specified `interfaceType`
	/// interface, and return an instance of it
	///
	/// - parameter interfaceType: type of the interface (protocol or base class) bound to the implementation type to retrieve
	///
	/// - returns: instance of the implementation type bound to `interfaceType`
	public func instance<P>(for interfaceType: P.Type) -> P {
		return safeInstance(for: interfaceType)!
	}

	public func safeInstance<P>(for interfaceType: P.Type) -> P? {
		let name = key(for: interfaceType)
		return safeInstance(named: name)
    }
    
    public func safeInstance<P>(named interfaceName: String) -> P? {
		guard let _instance = instance(named: interfaceName) else { return .none }
        return _instance as? P
    }
    
    public func reset() {
        self.instantiators.removeAll(keepingCapacity: true)
        self.singletons.removeAll(keepingCapacity: true)
    }
}

// MARK: - Internals
private extension Injector {
	/// Retrieve a name for an interface type
	///
	/// - parameter interfaceType: type of the interface 
	///
	/// - returns: name (key) identifying the interface
	func key<P>(for interfaceType: P.Type) -> String {
        return ("\(interfaceType)")
    }
    
    /// <#Description#>
    ///
    /// - parameter interfaceType: the key identifying the protocol
    ///
    /// - returns: an instance of the specified type, or .None if the type has not been registered
    func instance(named interfaceType: String) -> AnyObject? {
        if let _instance : AnyObject = self.singletons[interfaceType] {
            return _instance
        }
        
        if let instantiator = self.instantiators[interfaceType] {
            return instantiator()
        }
        
        return .none
    }
}
