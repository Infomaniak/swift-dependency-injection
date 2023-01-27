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
    /// - Throws: will throw if the requested type is unavaillable, or if called not from main thread
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
    ///   - factory: the factory wrapper
    ///   - customIdentifier: use a custom identifier to be able to resolve _many_ objects of the _same_ type
    /// - Throws: will throw if called not from main thread
    func store(factory: Factory,
               forCustomTypeIdentifier customIdentifier: String?) throws
}

// MARK: - SimpleResolver

/// A minimalist DI solution
/// For now, once initiated, stores types as long as the app lives
///
/// Access from Main Queue only
public final class SimpleResolver: SimpleResolvable, SimpleStorable, CustomDebugStringConvertible {
    
    public var debugDescription: String {
        """
        <\(type(of: self)):\(Unmanaged.passUnretained(self).toOpaque())
        \(factories.count) factories and \(store.count) stored types
        factories: \(factories)
        store: \(store)>
        """
    }
    
    enum ErrorDomain: Error {
        case factoryMissing(identifier: String)
        case typeMissmatch(expected: String)
        case notMainThread
    }
    
    // The last singleton that will exist on our code in the end
    public static let sharedResolver = SimpleResolver()
    
    /// Factory collection
    var factories = [String: Factory]()
    
    /// Resolved object collection
    var store = [String: Any]()

    // MARK: SimpleStorable
    
    public func store(factory: Factory,
                      forCustomTypeIdentifier customIdentifier: String? = nil) throws {
        guard Thread.isMainThread == true else {
            throw ErrorDomain.notMainThread
        }
        
        let type = factory.type
        
        let identifier = buildIdentifier(type: type, forIdentifier: customIdentifier)
        factories[identifier] = factory
    }
        
    // MARK: SimpleResolvable
    
    public func resolve<Service>(type: Service.Type,
                                 forCustomTypeIdentifier customIdentifier: String?,
                                 factoryParameters: [String: Any]? = nil,
                                 resolver: SimpleResolvable) throws -> Service {
        guard Thread.isMainThread == true else {
            throw ErrorDomain.notMainThread
        }
        
        let serviceIdentifier = buildIdentifier(type: type, forIdentifier: customIdentifier)
        
        // load form store
        if let service = store[serviceIdentifier] as? Service {
            return service
        }
        
        // load service from factory
        guard let factory = factories[serviceIdentifier] else {
            throw ErrorDomain.factoryMissing(identifier: serviceIdentifier)
        }
        
        // Apply factory closure
        guard let service = try factory.build(factoryParameters: factoryParameters, resolver: resolver) as? Service else {
            throw ErrorDomain.typeMissmatch(expected: "\(Service.Type.self)")
        }
        
        // keep in store built object for later
        store[serviceIdentifier] = service
        
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
        factories.removeAll()
        store.removeAll()
    }
}