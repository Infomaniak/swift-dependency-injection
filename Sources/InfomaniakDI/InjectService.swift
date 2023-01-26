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

// MARK: - InjectService<Service>

/// A property wrapper that resolves shared objects
@propertyWrapper public struct InjectService<Service> {
    private var service: Service!

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
        mutating get {
            do {
                self.service = try container.resolve(type: Service.self,
                                                     forCustomTypeIdentifier: customTypeIdentifier,
                                                     factoryParameters: factoryParameters,
                                                     resolver: container)
            } catch {
                fatalError("DI fatal error :\(error)")
            }
            return service
        }
        mutating set {
            service = newValue
        }
    }

    public var projectedValue: InjectService<Service> {
        get {
            return self
        }
        mutating set {
            self = newValue
        }
    }
}
