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

@testable import InfomaniakDI
import XCTest

/// Integration Tests of `LazyInjectService`
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

// MARK: - Performance

final class ITLazyInjectService_Performance: XCTestCase {
    override func setUp() {
        SimpleResolver.sharedResolver.removeAll()

        // Make sure something is registered before doing a test.
        registerAllHelperTypes()
    }

    override func tearDown() {
        SimpleResolver.sharedResolver.removeAll()
    }

    /// Testing the cost of doing a massive amount of creation of a LazyInjectService with a resolution of the wrapped type.
    func testCreationAndResolutionCost() {
        // WHEN
        measure {
            for _ in 0 ... 1_000_000 {
                let _ = LazyInjectService<SomeClass>().wrappedValue
            }
        }
    }

    /// Testing the cost of doing a massive amount of creation of LazyInjectService, with comparison to mimic SwiftUI behaviour.
    func testCreationAndComparisonCost() {
        // GIVEN
        @LazyInjectService var baseProperty: SomeClass
        let _ = $baseProperty.wrappedValue // force a resolution to mimic SwiftUI, should not have an impact.

        // WHEN
        measure {
            for _ in 0 ... 1_000_000 {
                @LazyInjectService var newProperty: SomeClass
                guard $baseProperty != $newProperty else {
                    return
                }

                XCTFail("Unexpected")
            }
        }
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
