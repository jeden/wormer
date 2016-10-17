//
//  WormerTests.swift
//  WormerTests
//
//  Created by Antonio Bello on 2/15/15.
//  Copyright (c) 2015 Elapsus. All rights reserved.
//

import XCTest
import Wormer

private protocol IProtocol { }
private class Implementation: IProtocol { }
private class UnboundImplementation { }
private struct StructImplementation: IProtocol { init() {} }
private enum EnumImplementation: IProtocol { case Something }

private class BaseInterface { }
private class InheritedImplementation : BaseInterface { }

class WormerTests: XCTestCase {
	
	fileprivate var injector = Injector.default
	
	override func setUp() {
		super.setUp()
		self.injector.reset()
	}
	
	override func tearDown() {
		super.tearDown()
	}

	/// Bind a protocol to an implementation
	/// Retrieve an instance and verifies it can be cast to the implementation type
	func testObtainInstance() {
		self.injector.bind(interface: IProtocol.self, toImplementation: Implementation.self, asSingleton: false, initializer: { Implementation() })
		
		let instance: IProtocol = self.injector.instance(for: IProtocol.self)
		
		XCTAssertTrue(instance is Implementation, "Instance not of the expected type")
	}
	
	/// Bind a protocol to an implementation
	/// Using type inference to determine the interface type, rather than passing it as parameter
	func testObtainInstanceUsingAltMethod() {
		self.injector.bind(interface: IProtocol.self, toImplementation: Implementation.self, asSingleton: false, initializer: { Implementation() })
		
		let instance: IProtocol = self.injector.instance()
		
		XCTAssertTrue(instance is Implementation, "Instance not of the expected type")
	}
	
	/// Bind a protocol to an implementation not adopting the protocol itself
	/// Verify that retrieving an instance returns nil
	func testSafeRegisterUnboundInstance() {
		self.injector.bind(interface: IProtocol.self, toImplementation: UnboundImplementation.self, asSingleton: false, initializer: { UnboundImplementation() })
		
		let instance: IProtocol? = self.injector.safeInstance(for: IProtocol.self)
		
		XCTAssertTrue(instance == nil, "The instance should be nil")
	}

	/// Bind a protocol to an implementation NOT using the singleton mode
	/// Verify that a new instance is always returned
	func testNonSingletonReturnDifferentInstances() {
		self.injector.bind(interface: IProtocol.self, toImplementation: Implementation.self, asSingleton: false, initializer: { Implementation() })
		
		let instance1 = self.injector.instance(for: IProtocol.self) as! Implementation
		let instance2 = self.injector.instance(for: IProtocol.self) as! Implementation
		
		XCTAssertTrue(instance1 !== instance2, "The 2 instances should be different")
	}
	
	/// Bind a protocol to an implementation using the singleton mode
	/// Verify that the same instance is returned
	func testSingletonReturnDifferentInstances() {
		self.injector.bind(interface: IProtocol.self, toImplementation: Implementation.self, asSingleton: true, initializer: { Implementation() })
		
		let instance1 = self.injector.instance(for: IProtocol.self) as! Implementation
		let instance2 = self.injector.instance(for: IProtocol.self) as! Implementation
		
		XCTAssertTrue(instance1 === instance2, "The 2 references should point to the same instance")
	}

	/// Bind a base class (the interface) to another class inherited from it (the implementation)
	func testBaseClassAsInterface() {
		self.injector.bind(interface: BaseInterface.self, toImplementation: InheritedImplementation.self, asSingleton: false, initializer: { InheritedImplementation() })

		let instance: BaseInterface = self.injector.instance(for: BaseInterface.self)

		XCTAssertTrue(instance is InheritedImplementation, "Instance not of the expected type")
	}

	/// Bind a protocol to a struct implementation
	func testBindProtocolToStruct() {
		self.injector.bind(interface: IProtocol.self, toImplementation: StructImplementation.self, asSingleton: false, initializer: { return StructImplementation() })

		let instance: IProtocol = self.injector.instance(for: IProtocol.self)

		XCTAssertTrue(instance is StructImplementation, "Instance not of the expected type")
	}

	/// Bind a protocol to an enum implementation
	func testBindProtocolToEnum() {
		self.injector.bind(interface: IProtocol.self, toImplementation: EnumImplementation.self, asSingleton: false, initializer: { return EnumImplementation.Something })

		let instance: IProtocol = self.injector.instance(for: IProtocol.self)

		XCTAssertTrue(instance is EnumImplementation, "Instance not of the expected type")
	}
}
