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

/// Integration Tests of `LazyInject`
final class ITLazyInject: XCTestCase {
    override func setUp() {
        someContainer.removeAll()
    }

    override func tearDown() {
        someContainer.removeAll()
    }

    // MARK: - @LazyInject

    func testResolveSampleType_propertyWrapper() {
        // GIVEN
        let resolver = someContainer
        let expectedObject = SomeClass()
        var factoryClosureCallCount = 0
        let factory = Factory(type: SomeClass.self) { _, _ in
            factoryClosureCallCount += 1
            return expectedObject
        }

        resolver.store(factory: factory)

        // WHEN
        let classWithDIProperty = ClassThatUsesLazyDI()
        XCTAssertNil(classWithDIProperty.$injected.resolvedInstance, "the type is not expected to be resolved yet")

        // THEN
        XCTAssertTrue(expectedObject === classWithDIProperty.injected, "identity of resolved object should match")
        XCTAssertEqual(factoryClosureCallCount, 1, "the factory closure should be called once exactly")

        XCTAssertEqual(resolver.factories.count, resolver.store.count)
        XCTAssertEqual(resolver.factories.count, 1)
        XCTAssertEqual(resolver.store.count, 1)

        XCTAssertNotNil(classWithDIProperty.$injected.resolvedInstance, "the type should be resolved")
    }

    func testResolveSampleType_propertyWrapper_protocol() {
        // GIVEN
        let resolver = someContainer
        let expectedObject = SomeClassConforming()
        var factoryClosureCallCount = 0
        let factory = Factory(type: SomeClassable.self) { _, _ in
            factoryClosureCallCount += 1
            return expectedObject
        }

        resolver.store(factory: factory)

        // WHEN
        let classWithDIProperty = ClassThatUsesLazyConformingDI()
        XCTAssertNil(classWithDIProperty.$injected.resolvedInstance, "the type is not expected to be resolved yet")

        // THEN
        XCTAssertTrue(expectedObject === classWithDIProperty.injected, "identity of resolved object should match")
        XCTAssertEqual(factoryClosureCallCount, 1, "the factory closure should be called once exactly")

        XCTAssertEqual(resolver.factories.count, resolver.store.count)
        XCTAssertEqual(resolver.factories.count, 1)
        XCTAssertEqual(resolver.store.count, 1)
        XCTAssertNotNil(classWithDIProperty.$injected.resolvedInstance, "the type is expected to be resolved")
    }

    func testResolveSampleType_propertyWrapper_withCustomIdentifiers() {
        // GIVEN
        let resolver = someContainer
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
        XCTAssertNil(classWithServicies.$special.resolvedInstance, "the type is not expected to be resolved yet")
        XCTAssertNil(classWithServicies.$custom.resolvedInstance, "the type is not expected to be resolved yet")

        // THEN
        XCTAssertFalse(classWithServicies.custom === classWithServicies.special,
                       "`custom` and `special` should be resolved to two distinct objects")
        XCTAssertEqual(factoryClosureCallCount, 2, "the factory closure should be called twice exactly")

        XCTAssertEqual(resolver.factories.count, resolver.store.count)
        XCTAssertEqual(resolver.factories.count, 2)
        XCTAssertEqual(resolver.store.count, 2)

        XCTAssertNotNil(classWithServicies.$special.resolvedInstance, "the type is expected to be resolved")
        XCTAssertNotNil(classWithServicies.$custom.resolvedInstance, "the type is expected to be resolved")
    }

    func testResolveSampleType_propertyWrapper_withCustomParameters() {
        // GIVEN
        let resolver = someContainer
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
        let classWith = ClassThatUsesLazyFactoryParametersDI()
        XCTAssertNil(classWith.$injected.resolvedInstance, "the type is not expected to be resolved yet")

        // THEN
        XCTAssertTrue(classWith.injected === expectedObject, "the identity is expected to match")
        XCTAssertEqual(factoryClosureCallCount, 1, "the factory closure should be called twice exactly")

        XCTAssertEqual(resolver.factories.count, resolver.store.count)
        XCTAssertEqual(resolver.factories.count, 1)
        XCTAssertEqual(resolver.store.count, 1)
        XCTAssertNotNil(classWith.$injected.resolvedInstance, "the type is expected to be resolved")
    }

    func testResolveSampleType_propertyWrapper_identifierAndParameters() {
        // GIVEN
        let resolver = someContainer
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
        XCTAssertNil(classWithServicies.$special.resolvedInstance, "the type is not expected to be resolved yet")
        XCTAssertNil(classWithServicies.$custom.resolvedInstance, "the type is not expected to be resolved yet")

        // THEN
        XCTAssertFalse(classWithServicies.custom === classWithServicies.special,
                       "`custom` and `special` should resolve two distinct objects")
        XCTAssertEqual(factoryClosureCallCount, 2, "the factory closure should be called twice exactly")

        XCTAssertEqual(resolver.factories.count, resolver.store.count)
        XCTAssertEqual(resolver.factories.count, 2)
        XCTAssertEqual(resolver.store.count, 2)

        XCTAssertNotNil(classWithServicies.$special.resolvedInstance, "the type is expected to be resolved")
        XCTAssertNotNil(classWithServicies.$custom.resolvedInstance, "the type is expected to be resolved")
    }

    // You should not do inline lazy DI, but still I test it.
    func testResolveSampleType_inlineResolution() {
        // GIVEN
        let resolver = someContainer
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

final class ITLazyInject_Performance: XCTestCase {
    override func setUp() {
        someContainer.removeAll()

        // Make sure something is registered before doing a test.
        registerAllHelperTypes(container: someContainer)
    }

    override func tearDown() {
        someContainer.removeAll()
    }

    /// Testing the cost of doing a massive amount of creation of a LazyInject with a resolution of the wrapped type.
    func testCreationAndResolutionCost() {
        // WHEN
        measure {
            for _ in 0 ... 1_000_000 {
                let _ = LazyInject<SomeClass>(container: someContainer).wrappedValue
            }
        }
    }

    /// Testing the cost of doing a massive amount of creation of LazyInject, with comparison to mimic SwiftUI behaviour.
    func testCreationAndComparisonCost() {
        // GIVEN
        @LazyInject(container: someContainer) var baseProperty: SomeClass
        let _ = $baseProperty.wrappedValue // force a resolution to mimic SwiftUI, should not have an impact.

        // WHEN
        measure {
            for _ in 0 ... 1_000_000 {
                @LazyInject(container: someContainer) var newProperty: SomeClass
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

    @LazyInject(container: someContainer) var injected: SomeClass
}

/// A class with only one resolved property
class ClassThatUsesLazyConformingDI {
    init() {}

    @LazyInject(container: someContainer) var injected: SomeClassable
}

/// A class with one resolved property using `factoryParameters`
class ClassThatUsesLazyFactoryParametersDI {
    init() {}

    @LazyInject(factoryParameters: ["someKey": "someValue"], container: someContainer) var injected: SomeClass
}

/// A class with two resolved properties of the same type using `customTypeIdentifier`
class ClassThatUsesLazyCustomIdentifiersDI {
    init() {}

    @LazyInject(customTypeIdentifier: "specialIdentifier", container: someContainer) var special: SomeClass

    @LazyInject(customTypeIdentifier: "customIdentifier", container: someContainer) var custom: SomeClass
}

/// A class with two resolved properties of the same type using `customTypeIdentifier` and  using `factoryParameters`
class ClassThatUsesLazyComplexDI {
    init() {}

    @LazyInject(customTypeIdentifier: "special",
                       factoryParameters: ["someKey": "someValue"],
                       container: someContainer) var special: SomeClass

    @LazyInject(customTypeIdentifier: "custom",
                       factoryParameters: ["someKey": "someValue"],
                       container: someContainer) var custom: SomeClass
}

/// Resolve a type inside a function
class ClassThatDoesLazyInlineDI {
    init() {}

    func inlineDI() -> SomeClass {
        let resolved = LazyInject<SomeClass>(container: someContainer).wrappedValue
        return resolved
    }
}

/// A class with only one resolved property
class ClassThatChainsLazyDI {
    init() {}

    @LazyInject(container: someContainer) var injected: ClassWithSomeDependentType
}

/// A class with only one resolved property
struct StructThatChainsLazyDI {
    @LazyInject(container: someContainer) var injected: StructWithSomeDependentType
}
