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

/// A property wrapper that resolves shared types when the host type is initialized.
@propertyWrapper public struct InjectService<Injected>: CustomDebugStringConvertible, Equatable, Identifiable {
    /// Identifiable
    ///
    /// Something to link the identity of this property wrapper to the underlying Service type.
    public let id = ObjectIdentifier(Injected.self)

    /// Equatable
    ///
    /// Two `InjectService` that points to the same `Injected` Metatype are expected to be equal (for the sake of SwiftUI
    /// correctness)
    public static func == (lhs: InjectService<Injected>, rhs: InjectService<Injected>) -> Bool {
        return lhs.id == rhs.id
    }

    public var debugDescription: String {
        """
        <\(type(of: self))
        wrapping type:'\(Injected.self)'
        customTypeIdentifier:\(String(describing: customTypeIdentifier))
        factoryParameters:\(String(describing: factoryParameters))
        id:\(id)'>
        """
    }

    /// Store the resolved service
    var service: Injected!

    public var container: Resolvable
    public var customTypeIdentifier: String?
    public var factoryParameters: [String: Any]?

    public init(customTypeIdentifier: String? = nil,
                factoryParameters: [String: Any]? = nil) {
        self.customTypeIdentifier = customTypeIdentifier
        self.factoryParameters = factoryParameters
        container = DependencyInjectionService.sharedContainer

        do {
            service = try container.resolve(type: Injected.self,
                                            forCustomTypeIdentifier: customTypeIdentifier,
                                            factoryParameters: factoryParameters,
                                            resolver: container)
        } catch {
            fatalError("DI fatal error :\(error)")
        }
    }

    public var wrappedValue: Injected {
        get {
            service
        }
        set {
            fatalError("You are not expected to substitute resolved objects")
        }
    }

    /// The property wrapper itself for debugging and testing
    public var projectedValue: Self {
        self
    }
}
