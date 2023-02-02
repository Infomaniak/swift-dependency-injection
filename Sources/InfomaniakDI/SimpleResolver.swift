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

// MARK: - Protocols

/// Something minimalist that can resolve a concrete type
///
/// Servicies are kept alive for the duration of the app's life
public protocol SimpleResolvable {
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
public protocol SimpleStorable {
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
public final class SimpleResolver: SimpleResolvable, SimpleStorable, CustomDebugStringConvertible {
    public var debugDescription: String {
        var buffer: String!
        queue.sync {
            buffer = """
            <\(type(of: self)):\(Unmanaged.passUnretained(self).toOpaque())
            \(factories.count) factories and \(store.count) stored types
            factories: \(factories)
            store: \(store)>
            """
        }
        return buffer
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

    /// A serial queue for thread safety
    private let queue = DispatchQueue(label: "com.infomaniakDI.resolver")
    
    // MARK: SimpleStorable
    
    public func store(factory: Factoryable,
                      forCustomTypeIdentifier customIdentifier: String? = nil) {
        let type = factory.type
        
        let identifier = buildIdentifier(type: type, forIdentifier: customIdentifier)
        queue.sync {
            factories[identifier] = factory
        }
    }
        
    // MARK: SimpleResolvable
    
    public func resolve<Service>(type: Service.Type,
                                 forCustomTypeIdentifier customIdentifier: String?,
                                 factoryParameters: [String: Any]? = nil,
                                 resolver: SimpleResolvable) throws -> Service {
        let serviceIdentifier = buildIdentifier(type: type, forIdentifier: customIdentifier)
        
        // load form store
        var fetchedService: Any?
        queue.sync {
            fetchedService = store[serviceIdentifier]
        }
        if let service = fetchedService as? Service {
            return service
        }
        
        // load service from factory
        var factory: Factoryable?
        queue.sync {
            factory = factories[serviceIdentifier]
        }
        guard let factory = factory else {
            throw ErrorDomain.factoryMissing(identifier: serviceIdentifier)
        }
        
        // Apply factory closure
        let builtType = try factory.build(factoryParameters: factoryParameters, resolver: resolver)
        guard let service = builtType as? Service else {
            throw ErrorDomain.typeMissmatch(expected: "\(Service.Type.self)", got: "\(builtType.self)")
        }
        
        // keep in store built object for later
        queue.sync {
            store[serviceIdentifier] = service
        }
        
        return service
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
        queue.sync {
            factories.removeAll()
            store.removeAll()
        }
    }
}
