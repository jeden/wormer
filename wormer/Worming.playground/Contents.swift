//: Playground - noun: a place where people can play

import UIKit
import Wormer

protocol EventBus{}
class EventBusImplementation:EventBus{}
protocol NotificationGateway{}
class NotificationGatewayImplementation:NotificationGateway{ init(eventBus: EventBus){}}
protocol NearableProximityProvider {}
struct BrandedNearableProximityProvider : NearableProximityProvider {}

do {
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

struct SomeProvider {
	private var eventBus: EventBus
	init(eventBus: EventBus) {
		self.eventBus = eventBus
	}
}

let eventBus: EventBus = Injector.default.instance()
let provider = SomeProvider(eventBus: eventBus)

class EventViewController : UIViewController /* NSViewController */ {
	private lazy var eventBus: EventBus = Injector.default.instance()
}

EventViewController()