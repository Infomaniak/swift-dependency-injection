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

// MARK: - Protocols

/// Something minimalist that can resolve a concrete type
///
/// Servicies are kept alive for the duration of the app's life
public protocol SimpleResolvable: Sendable {
    /// The main solver funtion, tries to fetch an existing object or apply a factory if availlable
    /// - Parameters:
    ///   - type: the wanted type
    ///   - customIdentifier: use a custom identifier to be able to resolve _many_ objects of the _same_ type
    ///   - factoryParameters: some arguments that can be passed to the factory, customising the requested objects.
    ///   - resolver: something that can resolve a type, usefull for chaining types
    /// - Returns: the resolved service
    /// - Throws: will throw if the requested type is unavaillable or if the types in the factory are not matching
    func resolve<Service>(type: Service.Type,
                          forCustomTypeIdentifier customIdentifier: String?,
                          factoryParameters: [String: Any]?,
                          resolver: SimpleResolvable) throws -> Service
}

/// Something that stores a factory for a given type
public protocol SimpleStorable: Sendable {
    /// Store a factory closure for a given type
    ///
    /// You will virtualy never call this directly
    /// - Parameters:
    ///   - factory: a factory wrapper type
    ///   - customIdentifier: use a custom identifier to be able to resolve _many_ objects of the _same_ type
    func store(factory: Factoryable, forCustomTypeIdentifier customIdentifier: String?)
}

// MARK: - SimpleResolver

/// A minimalist DI solution
/// Once initiated, stores types as long as the app lives
public final class SimpleResolver: SimpleResolvable, SimpleStorable, CustomDebugStringConvertible, @unchecked Sendable {
    private let recursiveLock = NSRecursiveLock()

    public var debugDescription: String {
        recursiveLock.lock()
        defer { recursiveLock.unlock() }

        return """
        <\(type(of: self)):\(Unmanaged.passUnretained(self).toOpaque())
        \(factories.count) factories and \(store.count) stored types
        factories: \(factories)
        store: \(store)>
        """
    }

    enum ErrorDomain: Error {
        case factoryMissing(identifier: String)
        case typeMissmatch(expected: String, got: String)
    }

    /// One singleton to rule them all
    public static let sharedResolver = SimpleResolver()

    /// Factory collection
    var factories = [String: Factoryable]()

    /// Resolved object collection
    var store = [String: Any]()

    // MARK: SimpleStorable

    public func store(factory: Factoryable,
                      forCustomTypeIdentifier customIdentifier: String? = nil) {
        recursiveLock.lock()
        defer { recursiveLock.unlock() }

        let type = factory.type
        let identifier = buildIdentifier(type: type, forIdentifier: customIdentifier)
        factories[identifier] = factory
    }

    // MARK: SimpleResolvable

    public func resolve<Service>(type: Service.Type,
                                 forCustomTypeIdentifier customIdentifier: String?,
                                 factoryParameters: [String: Any]? = nil,
                                 resolver: SimpleResolvable) throws -> Service {
        recursiveLock.lock()
        defer { recursiveLock.unlock() }

        let serviceIdentifier = buildIdentifier(type: type, forIdentifier: customIdentifier)
        return try loadOrResolve(
            serviceIdentifier: serviceIdentifier,
            factoryParameters: factoryParameters,
            resolver: resolver
        )
    }

    private func loadOrResolve<Service>(serviceIdentifier: String,
                                        factoryParameters: [String: Any]?,
                                        resolver: SimpleResolvable) throws -> Service {
        if let fetchedObject = store[serviceIdentifier],
           let fetchedService = fetchedObject as? Service {
            return fetchedService
        } else {
            guard let factory = factories[serviceIdentifier] else {
                throw ErrorDomain.factoryMissing(identifier: serviceIdentifier)
            }

            let builtType = try factory.build(factoryParameters: factoryParameters, resolver: resolver)
            guard let service = builtType as? Service else {
                throw ErrorDomain.typeMissmatch(expected: "\(Service.Type.self)", got: "\(builtType.self)")
            }

            store[serviceIdentifier] = service
            return service
        }
    }

    // MARK: internal

    func buildIdentifier(type: Any.Type,
                         forIdentifier identifier: String? = nil) -> String {
        if let identifier {
            return "\(type):\(identifier)"
        } else {
            return "\(type)"
        }
    }

    // MARK: testing

    func removeAll() {
        recursiveLock.lock()
        factories.removeAll()
        store.removeAll()
        recursiveLock.unlock()
    }
}
