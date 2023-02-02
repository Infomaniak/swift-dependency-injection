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

/// Something that can build a type, given some extra parameters and a resolver for chained dependency
public typealias FactoryClosure = (_ parameters: [String: Any]?, _ resolver: SimpleResolvable) throws -> Any

/// Something that can build a type
public protocol Factoryable {
    
    /// Required init for a Factoryable
    /// - Parameters:
    ///   - type: The type we register, prefer using a Protocol here. Great for testing.
    ///   - closure: The closure that will return something that can be casted as `type`
    init<Service>(type: Service.Type, closure: @escaping FactoryClosure)

    /// Something that uses the stored closure to produce a type
    /// - Parameters:
    ///   - factoryParameters: Extra parameters that can be used to customize a type.
    ///   - resolver: A resolver for chained resolution
    /// - Returns: Return something that can be casted as the `type` declared at init. Will throw otherwise.
    func build(factoryParameters: [String: Any]?, resolver: SimpleResolvable) throws -> Any
}

public struct Factory: Factoryable, CustomDebugStringConvertible {
    var closure: FactoryClosure
    var type: Any.Type

    // MARK: Factoryable

    public init<Service>(type: Service.Type, closure: @escaping FactoryClosure) {
        self.closure = closure
        self.type = type
    }

    public func build(factoryParameters: [String: Any]? = nil,
                      resolver: SimpleResolvable = SimpleResolver.sharedResolver) throws -> Any {
        try self.closure(factoryParameters, resolver)
    }

    // MARK: CustomDebugStringConvertible

    public var debugDescription: String {
        "<\(Swift.type(of: self)): for type:\(self.type), closure:\(String(describing: self.closure))>"
    }
}
