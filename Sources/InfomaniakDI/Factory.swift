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

/// Something that can build a type, given some extra parameters and a resolver for chained dependency
public typealias FactoryClosure = (_ parameters: [String: Any]?, _ resolver: Resolvable) throws -> Any

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
    func build(factoryParameters: [String: Any]?, resolver: Resolvable) throws -> Any

    /// The registered type, prefer using a Protocol here. Great for testing.
    var type: Any.Type { get }
}

public struct Factory: Factoryable, CustomDebugStringConvertible {
    /// The factory closure
    private let closure: FactoryClosure

    public let type: Any.Type

    // MARK: Factoryable

    public init<Service>(type: Service.Type, closure: @escaping FactoryClosure) {
        self.closure = closure
        self.type = type
    }

    public func build(factoryParameters: [String: Any]? = nil,
                      resolver: Resolvable) throws -> Any {
        try closure(factoryParameters, resolver)
    }

    // MARK: CustomDebugStringConvertible

    public var debugDescription: String {
        "<\(Swift.type(of: self)): for type:\(type), closure:\(String(describing: closure))>"
    }
}
