/*
 InfomaniakDI
 Copyright (C) 2023 Infomaniak Network SA

 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import Foundation

/// Inject a service at the first use of the property
@propertyWrapper public final class LazyInjectService<Service>: Equatable, Identifiable {
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

    /// Store the resolved service
    var service: Service?

    public var container: SimpleResolvable
    public var customTypeIdentifier: String?
    public var factoryParameters: [String: Any]?

    public init(customTypeIdentifier: String? = nil,
                factoryParameters: [String: Any]? = nil,
                container: SimpleResolvable = SimpleResolver.sharedResolver) {
        self.customTypeIdentifier = customTypeIdentifier
        self.factoryParameters = factoryParameters
        self.container = container
    }

    public var wrappedValue: Service {
        get {
            if let service {
                return service
            }

            do {
                service = try container.resolve(type: Service.self,
                                                forCustomTypeIdentifier: customTypeIdentifier,
                                                factoryParameters: factoryParameters,
                                                resolver: container)
                return service!
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
