//
//  Injector.swift
//  Wormer
//
//  Created by Antonio Bello on 2/15/15.
//  Copyright (c) 2015 Elapsus. All rights reserved.
//
//  Released under the MIT license. See the LICENSE file.


// MARK: - Instance
public class Injector {
    // MARK: Properties
    private var instantiators: [String : () -> AnyObject] = Dictionary()
    private var singletons = [String : AnyObject]()
    
    /// Singleton
    /// :returns: static instance
    private(set) public static var instance = Injector()
}

// MARK: - Interface
extension Injector {
    // Bind a protocol to an implementation type
    // :aProtocol: protocol identifying the registered type
    // :type: type of the actual protocol implementation
    // :asSingleton: flag indicating whether to use the singleton pattern
    // :initializer: closure creating an instance of the object
    public func bindInterface<P, T : AnyObject>(aProtocol: P.Type, toImplementation type:T.Type, asSingleton singleton:Bool, initializer: () -> T) {
        let key = keyForProtocol(aProtocol)
        return bindInterface(key, toImplementation: type, asSingleton: singleton, initializer: initializer)
    }
    
    // Bind a protocol to an implementation type
    // :protocolName: name of the protocol identifying the registered type
    // :type: type of the actual protocol implementation
    // :asSingleton: flag indicating whether to use the singleton pattern
    // :initializer: closure creating an instance of the object
    public func bindInterface<T : AnyObject>(protocolName: String, toImplementation type:T.Type, asSingleton singleton:Bool, initializer: () -> T) {
        // Check that the protocol has been registered
        if self.instantiators[protocolName] == nil {
            // Instantiation closure
            let instantiator = { () -> T in
                // Create an instance
                let instance: T = initializer()
                
                // If it's registered as singleton, stores the instance
                if (singleton) {
                    self.singletons[protocolName] = instance
                }
                
                return instance
            }
            
            // Store the instantiator
            self.instantiators[protocolName] = instantiator
        }
    }
    
	public func instanceForType<P>() -> P {
		return instanceForType(P.self)
	}

	public func instanceForType<P>(aProtocol: P.Type) -> P {
		return safeInstanceForType(aProtocol)!
	}

	public func safeInstanceForType<P>(aProtocol: P.Type) -> P? {
        let key = keyForProtocol(aProtocol)
        return safeInstanceForType(key)
    }
    
    public func safeInstanceForType<P>(protocolName: String) -> P? {
        let instance : AnyObject! = instanceForKey(protocolName)
        return instance as? P
    }
    
    public func reset() {
        self.instantiators.removeAll(keepCapacity: true)
        self.singletons.removeAll(keepCapacity: true)
    }
}

// MARK: - Internals
private extension Injector {
    /// :param: aProtocol
    /// :returns: key identifying the protocol
    func keyForProtocol<P>(aProtocol: P.Type) -> String {
        return ("\(aProtocol)")
    }
    
    /// :param: key the key identifying the protocol
    /// :returns: an instance of the specified type, or .None if the type has not been registered
    func instanceForKey(key: String) -> AnyObject! {
        if let instance : AnyObject = self.singletons[key] {
            return instance
        }
        
        if let instantiator = self.instantiators[key] {
            return instantiator()
        }
        
        return .None
    }
}
