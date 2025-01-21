//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing,
//  software distributed under the License is distributed on an
//  "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
//  KIND, either express or implied.  See the License for the
//  specific language governing permissions and limitations
//  under the License.

import Foundation

/// Inject a service at the first use of the property
@propertyWrapper public final class LazyInjectService<Service: Sendable>: Equatable, Identifiable, @unchecked Sendable {
    private let semaphore = DispatchSemaphore(value: 1)

    var service: Service?

    /// Identifiable
    ///
    /// Something to link the identity of this property wrapper to the underlying Service type.
    public let id = ObjectIdentifier(Service.self)

    /// Equatable
    ///
    /// Two `LazyInjectService` that points to the same `Service` Metatype are expected to be equal (for the sake of SwiftUI
    /// correctness)
    public static func == (lhs: LazyInjectService<Service>, rhs: LazyInjectService<Service>) -> Bool {
        return lhs.id == rhs.id
    }

    public var debugDescription: String {
        """
        <\(type(of: self))
        wrapping type:'\(Service.self)'
        customTypeIdentifier:\(String(describing: customTypeIdentifier))
        factoryParameters:\(String(describing: factoryParameters))
        id:\(id)'>
        """
    }

    public let container: SimpleResolvable
    public let customTypeIdentifier: String?
    public let factoryParameters: [String: Sendable]?

    public init(customTypeIdentifier: String? = nil,
                factoryParameters: [String: Sendable]? = nil,
                container: SimpleResolvable = SimpleResolver.sharedResolver) {
        self.customTypeIdentifier = customTypeIdentifier
        self.factoryParameters = factoryParameters
        self.container = container
    }

    public var wrappedValue: Service {
        get {
            semaphore.wait()
            defer { semaphore.signal() }

            if let service {
                return service
            }

            do {
                let resolvedService = try container.resolve(type: Service.self,
                                                            forCustomTypeIdentifier: customTypeIdentifier,
                                                            factoryParameters: factoryParameters,
                                                            resolver: container)
                service = resolvedService
                return resolvedService
            } catch {
                fatalError("DI fatal error :\(error)")
            }
        }
        set {
            fatalError("You are not expected to substitute resolved objects")
        }
    }

    /// The property wrapper itself for debugging and testing
    public var projectedValue: LazyInjectService {
        self
    }
}
