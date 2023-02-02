/*
 InfomaniakDITests
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

@testable import InfomaniakDI
import XCTest

/// Integration Tests of @InjectService
final class ITLazyInjectService: XCTestCase {
    override func setUp() {
        SimpleResolver.sharedResolver.removeAll()
    }

    override func tearDown() {
        SimpleResolver.sharedResolver.removeAll()
    }
    
    // MARK: - @LazyInjectService
    
    func testResolveSampleType_propertyWrapper() {
        // GIVEN
        let resolver = SimpleResolver.sharedResolver
        let expectedObject = SomeClass()
        var factoryClosureCallCount = 0
        let factory = Factory(type: SomeClass.self) { _, _ in
            factoryClosureCallCount += 1
            return expectedObject
        }
        
        resolver.store(factory: factory)
        
        // WHEN
        let classWithDIProperty = ClassThatUsesLazyDI()
        XCTAssertNil(classWithDIProperty.$injected.service, "the service is not expected to be resolved yet")
        
        // THEN
        XCTAssertTrue(expectedObject === classWithDIProperty.injected, "identity of resolved object should match")
        XCTAssertEqual(factoryClosureCallCount, 1, "the factory closure should be called once exactly")
        
        XCTAssertEqual(resolver.factories.count, resolver.store.count)
        XCTAssertEqual(resolver.factories.count, 1)
        XCTAssertEqual(resolver.store.count, 1)
        
        XCTAssertNotNil(classWithDIProperty.$injected.service, "the service should be resolved")
    }
    
    func testResolveSampleType_propertyWrapper_protocol() {
        // GIVEN
        let resolver = SimpleResolver.sharedResolver
        let expectedObject = SomeClassConforming()
        var factoryClosureCallCount = 0
        let factory = Factory(type: SomeClassable.self) { _, _ in
            factoryClosureCallCount += 1
            return expectedObject
        }
        
        resolver.store(factory: factory)
        
        // WHEN
        let classWithDIProperty = ClassThatUsesLazyConformingDI()
        XCTAssertNil(classWithDIProperty.$injected.service, "the service is not expected to be resolved yet")
        
        // THEN
        XCTAssertTrue(expectedObject === classWithDIProperty.injected, "identity of resolved object should match")
        XCTAssertEqual(factoryClosureCallCount, 1, "the factory closure should be called once exactly")
        
        XCTAssertEqual(resolver.factories.count, resolver.store.count)
        XCTAssertEqual(resolver.factories.count, 1)
        XCTAssertEqual(resolver.store.count, 1)
        XCTAssertNotNil(classWithDIProperty.$injected.service, "the service is expected to be resolved")
    }
    
    func testResolveSampleType_propertyWrapper_withCustomIdentifiers() {
        // GIVEN
        let resolver = SimpleResolver.sharedResolver
        var factoryClosureCallCount = 0
        let factory = Factory(type: SomeClass.self) { _, _ in
            factoryClosureCallCount += 1
            return SomeClass()
        }
        
        // We store a factory for a specific specialized type using an identifier
        let specialIdentifier = "specialIdentifier"
        let customIdentifier = "customIdentifier"
        
        resolver.store(factory: factory, forCustomTypeIdentifier: specialIdentifier)
        resolver.store(factory: factory, forCustomTypeIdentifier: customIdentifier)
        
        // WHEN
        let classWithServicies = ClassThatUsesLazyCustomIdentifiersDI()
        XCTAssertNil(classWithServicies.$special.service, "the service is not expected to be resolved yet")
        XCTAssertNil(classWithServicies.$custom.service, "the service is not expected to be resolved yet")
        
        // THEN
        XCTAssertFalse(classWithServicies.custom === classWithServicies.special,
                       "`custom` and `special` should be resolved to two distinct objects")
        XCTAssertEqual(factoryClosureCallCount, 2, "the factory closure should be called twice exactly")
        
        XCTAssertEqual(resolver.factories.count, resolver.store.count)
        XCTAssertEqual(resolver.factories.count, 2)
        XCTAssertEqual(resolver.store.count, 2)
        
        XCTAssertNotNil(classWithServicies.$special.service, "the service is expected to be resolved")
        XCTAssertNotNil(classWithServicies.$custom.service, "the service is expected to be resolved")
    }
    
    func testResolveSampleType_propertyWrapper_withCustomParameters() {
        // GIVEN
        let resolver = SimpleResolver.sharedResolver
        let expectedObject = SomeClass()
        let expectedFactoryParameters = ["someKey": "someValue"]
        var factoryClosureCallCount = 0
        let factory = Factory(type: SomeClass.self) { parameters, _ in
            guard let parameters else {
                XCTFail("unexpected")
                return
            }
            XCTAssertEqual(parameters as NSDictionary, expectedFactoryParameters as NSDictionary)
            factoryClosureCallCount += 1
            return expectedObject
        }

        resolver.store(factory: factory)
        
        // WHEN
        let classWithService = ClassThatUsesLazyFactoryParametersDI()
        XCTAssertNil(classWithService.$injected.service, "the service is not expected to be resolved yet")
        
        // THEN
        XCTAssertTrue(classWithService.injected === expectedObject, "the identity is expected to match")
        XCTAssertEqual(factoryClosureCallCount, 1, "the factory closure should be called twice exactly")
        
        XCTAssertEqual(resolver.factories.count, resolver.store.count)
        XCTAssertEqual(resolver.factories.count, 1)
        XCTAssertEqual(resolver.store.count, 1)
        XCTAssertNotNil(classWithService.$injected.service, "the service is expected to be resolved")
    }
    
    func testResolveSampleType_propertyWrapper_identifierAndParameters() {
        // GIVEN
        let resolver = SimpleResolver.sharedResolver
        let expectedFactoryParameters = ["someKey": "someValue"]
        var factoryClosureCallCount = 0
        let factory = Factory(type: SomeClass.self) { parameters, _ in
            guard let parameters else {
                XCTFail("unexpected")
                return
            }
            XCTAssertEqual(parameters as NSDictionary, expectedFactoryParameters as NSDictionary)
            factoryClosureCallCount += 1
            return SomeClass()
        }
        
        // We store a factory for a specific specialized type using an identifier
        let specialIdentifier = "special"
        let customIdentifier = "custom"
        
        resolver.store(factory: factory, forCustomTypeIdentifier: specialIdentifier)
        resolver.store(factory: factory, forCustomTypeIdentifier: customIdentifier)
        
        // WHEN
        let classWithServicies = ClassThatUsesLazyComplexDI()
        XCTAssertNil(classWithServicies.$special.service, "the service is not expected to be resolved yet")
        XCTAssertNil(classWithServicies.$custom.service, "the service is not expected to be resolved yet")
        
        // THEN
        XCTAssertFalse(classWithServicies.custom === classWithServicies.special,
                       "`custom` and `special` should resolve two distinct objects")
        XCTAssertEqual(factoryClosureCallCount, 2, "the factory closure should be called twice exactly")
        
        XCTAssertEqual(resolver.factories.count, resolver.store.count)
        XCTAssertEqual(resolver.factories.count, 2)
        XCTAssertEqual(resolver.store.count, 2)
        
        XCTAssertNotNil(classWithServicies.$special.service, "the service is expected to be resolved")
        XCTAssertNotNil(classWithServicies.$custom.service, "the service is expected to be resolved")
    }
    
    // You should not do inline lazy DI, but still I test it.
    func testResolveSampleType_inlineResolution() {
        // GIVEN
        let resolver = SimpleResolver.sharedResolver
        let expectedObject = SomeClass()
        var factoryClosureCallCount = 0
        let factory = Factory(type: SomeClass.self) { _, _ in
            factoryClosureCallCount += 1
            return expectedObject
        }
        
        resolver.store(factory: factory)
        
        let classThatDoesInlineDI = ClassThatDoesLazyInlineDI()
        
        // WHEN
        let resolved = classThatDoesInlineDI.inlineDI()
        
        // THEN
        XCTAssertTrue(expectedObject === resolved, "identity of resolved object should match")
        XCTAssertEqual(factoryClosureCallCount, 1, "the factory closure should be called once exactly")
        
        XCTAssertEqual(resolver.factories.count, resolver.store.count)
        XCTAssertEqual(resolver.factories.count, 1)
        XCTAssertEqual(resolver.store.count, 1)
    }
}

// MARK: - Lazy Helper Class

/// A class with only one resolved property
class ClassThatUsesLazyDI {
    init() {}
    
    @LazyInjectService var injected: SomeClass
}

/// A class with only one resolved property
class ClassThatUsesLazyConformingDI {
    init() {}
    
    @LazyInjectService var injected: SomeClassable
}

/// A class with one resolved property using `factoryParameters`
class ClassThatUsesLazyFactoryParametersDI {
    init() {}
    
    @LazyInjectService(factoryParameters: ["someKey": "someValue"]) var injected: SomeClass
}

/// A class with two resolved properties of the same type using `customTypeIdentifier`
class ClassThatUsesLazyCustomIdentifiersDI {
    init() {}
    
    @LazyInjectService(customTypeIdentifier: "specialIdentifier") var special: SomeClass
    
    @LazyInjectService(customTypeIdentifier: "customIdentifier") var custom: SomeClass
}

/// A class with two resolved properties of the same type using `customTypeIdentifier` and  using `factoryParameters`
class ClassThatUsesLazyComplexDI {
    init() {}
    
    @LazyInjectService(customTypeIdentifier: "special",
                       factoryParameters: ["someKey": "someValue"]) var special: SomeClass
    
    @LazyInjectService(customTypeIdentifier: "custom",
                       factoryParameters: ["someKey": "someValue"]) var custom: SomeClass
}

/// Resolve a type inside a function
class ClassThatDoesLazyInlineDI {
    init() {}
    
    func inlineDI() -> SomeClass {
        let resolved = LazyInjectService<SomeClass>().wrappedValue
        return resolved
    }
}

/// A class with only one resolved property
class ClassThatChainsLazyDI {
    init() {}
    
    @LazyInjectService var injected: ClassWithSomeDependentType
}

/// A class with only one resolved property
struct StructThatChainsLazyDI {
    @LazyInjectService var injected: StructWithSomeDependentType
}
