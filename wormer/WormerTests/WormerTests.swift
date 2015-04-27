//
//  WormerTests.swift
//  WormerTests
//
//  Created by Antonio Bello on 2/15/15.
//  Copyright (c) 2015 Elapsus. All rights reserved.
//

import XCTest
import Wormer

private protocol IProtocol {
	
}

private class Implementation: IProtocol {
	
}

private class UnboundImplementation {
	
}

class WormerTests: XCTestCase {
	
	private var injector = Injector.instance
	
	override func setUp() {
		super.setUp()
		self.injector.reset()
	}
	
	override func tearDown() {
		super.tearDown()
	}
	
	/**
	Bind a protocol to an implementation
	Retrieve an instance and verifies it can be cast to the implementation type
	*/
	func testObtainInstance() {
		self.injector.bindInterface(IProtocol.self, toImplementation: Implementation.self, asSingleton: false, initializer: { Implementation() })
		
		let instance: IProtocol = self.injector.instanceForType(IProtocol.self)
		
		XCTAssertTrue(instance is Implementation, "Instance not of the expected type")
	}
	
	/**
	Bind a protocol to an implementation
	Using the overload using type inference to determine the interface type, rather than passing it as parameter
	*/
	func testObtainInstanceUsingAltMethod() {
		self.injector.bindInterface(IProtocol.self, toImplementation: Implementation.self, asSingleton: false, initializer: { Implementation() })
		
		let instance: IProtocol = self.injector.instanceForType()
		
		XCTAssertTrue(instance is Implementation, "Instance not of the expected type")
	}
	
	/**
	Bind a protocol to an implementation not adopting the protocol itself
	Verify that retrieving an instance returns nil
	*/
	func testRegisterUnboundInstance() {
		self.injector.bindInterface(IProtocol.self, toImplementation: UnboundImplementation.self, asSingleton: false, initializer: { UnboundImplementation() })
		
		let instance: IProtocol? = self.injector.safeInstanceForType(IProtocol.self)
		
		XCTAssertTrue(instance == nil, "The instance should be nil")
	}
	
	/**
	Bind a protocol to an implementation NOT using the singleton mode
	Verify that a new instance is returned
	*/
	func testNonSingletonReturnDifferentInstances() {
		self.injector.bindInterface(IProtocol.self, toImplementation: Implementation.self, asSingleton: false, initializer: { Implementation() })
		
		let instance1 = self.injector.instanceForType(IProtocol.self) as! Implementation
		let instance2 = self.injector.instanceForType(IProtocol.self) as! Implementation
		
		XCTAssertTrue(instance1 !== instance2, "The 2 instances should be different")
	}
	
	/**
	Bind a protocol to an implementation using the singleton mode
	Verify that the same instance is returned
	*/
	func testSingletonReturnDifferentInstances() {
		self.injector.bindInterface(IProtocol.self, toImplementation: Implementation.self, asSingleton: true, initializer: { Implementation() })
		
		let instance1 = self.injector.instanceForType(IProtocol.self) as! Implementation
		let instance2 = self.injector.instanceForType(IProtocol.self) as! Implementation
		
		XCTAssertTrue(instance1 === instance2, "The 2 references should point to the same instance")
	}
}
