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
final class ITInjectService: XCTestCase {
    override func setUp() {
        SimpleResolver.sharedResolver.removeAll()
    }

    override func tearDown() {
        SimpleResolver.sharedResolver.removeAll()
    }

    // MARK: - @InjectService

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
        let classWithDIProperty = ClassThatUsesDI()
        XCTAssertNotNil(classWithDIProperty.$injected.service, "the service is expected to be resolved")

        // THEN
        XCTAssertTrue(expectedObject === classWithDIProperty.injected, "identity of resolved object should match")
        XCTAssertEqual(factoryClosureCallCount, 1, "the factory closure should be called once exactly")

        XCTAssertEqual(resolver.factories.count, resolver.store.count)
        XCTAssertEqual(resolver.factories.count, 1)
        XCTAssertEqual(resolver.store.count, 1)
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
        let classWithDIProperty = ClassThatUsesConformingDI()
        XCTAssertNotNil(classWithDIProperty.$injected.service, "the service is expected to be resolved")

        // THEN
        XCTAssertTrue(expectedObject === classWithDIProperty.injected, "identity of resolved object should match")
        XCTAssertEqual(factoryClosureCallCount, 1, "the factory closure should be called once exactly")

        XCTAssertEqual(resolver.factories.count, resolver.store.count)
        XCTAssertEqual(resolver.factories.count, 1)
        XCTAssertEqual(resolver.store.count, 1)
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
        let classWithServicies = ClassThatUsesCustomIdentifiersDI()
        XCTAssertNotNil(classWithServicies.$special.service, "the service is expected to be resolved")
        XCTAssertNotNil(classWithServicies.$custom.service, "the service is expected to be resolved")

        // THEN
        XCTAssertFalse(classWithServicies.custom === classWithServicies.special,
                       "`custom` and `special` should be resolved to two distinct objects")
        XCTAssertEqual(factoryClosureCallCount, 2, "the factory closure should be called twice exactly")

        XCTAssertEqual(resolver.factories.count, resolver.store.count)
        XCTAssertEqual(resolver.factories.count, 2)
        XCTAssertEqual(resolver.store.count, 2)
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
        let classWithService = ClassThatUsesFactoryParametersDI()
        XCTAssertNotNil(classWithService.$injected.service, "the service is expected to be resolved")

        // THEN
        XCTAssertTrue(classWithService.injected === expectedObject, "the identity is expected to match")
        XCTAssertEqual(factoryClosureCallCount, 1, "the factory closure should be called twice exactly")

        XCTAssertEqual(resolver.factories.count, resolver.store.count)
        XCTAssertEqual(resolver.factories.count, 1)
        XCTAssertEqual(resolver.store.count, 1)
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
        let classWithServicies = ClassThatUsesComplexDI()
        XCTAssertNotNil(classWithServicies.$special.service, "the service is expected to be resolved")
        XCTAssertNotNil(classWithServicies.$custom.service, "the service is expected to be resolved")

        // THEN
        XCTAssertFalse(classWithServicies.custom === classWithServicies.special,
                       "`custom` and `special` should resolve two distinct objects")
        XCTAssertEqual(factoryClosureCallCount, 2, "the factory closure should be called twice exactly")

        XCTAssertEqual(resolver.factories.count, resolver.store.count)
        XCTAssertEqual(resolver.factories.count, 2)
        XCTAssertEqual(resolver.store.count, 2)
    }

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

        let classThatDoesInlineDI = ClassThatDoesInlineDI()

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

final class ITInjectService_Performance: XCTestCase {
    override func setUp() {
        SimpleResolver.sharedResolver.removeAll()

        // Make sure something is registered before doing a test.
        registerAllHelperTypes()
    }

    override func tearDown() {
        SimpleResolver.sharedResolver.removeAll()
    }

    /// Testing the cost of doing a massive amount of creation of a InjectService with a resolution of the wrapped type.
    func testCreationAndResolutionCost() {
        // WHEN
        measure {
            for _ in 0 ... 1_000_000 {
                let _ = InjectService<SomeClass>().wrappedValue
            }
        }
    }

    /// Testing the cost of doing a massive amount of creation of InjectService, with comparison to mimic SwiftUI behaviour.
    func testCreationAndComparisonCost() {
        // GIVEN
        @InjectService var baseProperty: SomeClass
        let _ = $baseProperty.wrappedValue // force a resolution

        // WHEN
        measure {
            for _ in 0 ... 1_000_000 {
                @InjectService var newProperty: SomeClass
                guard $baseProperty != $newProperty else {
                    return
                }

                XCTFail("Unexpected")
            }
        }
    }
}
