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

/// Integration Tests of the Simple DI mechanism
final class ITSimpleReslover: XCTestCase {
    override func setUp() {
        someContainer.removeAll()
    }

    override func tearDown() {
        someContainer.removeAll()
    }

    // MARK: - store(factory:)

    func testStoreFactory_mainThread() {
        // GIVEN
        let resolver = someContainer
        let expectedObject = SomeClass()
        var factoryClosureCallCount = 0
        let factory = Factory(type: SomeClass.self) { _, _ in
            factoryClosureCallCount += 1
            return expectedObject
        }

        // WHEN
        resolver.store(factory: factory)
        let result = Inject<SomeClass>(container: someContainer).wrappedValue

        // THEN
        XCTAssertNotNil(result)
        XCTAssertEqual(resolver.factories.count, 1)
        XCTAssertEqual(resolver.store.count, 1)
    }

    func testStoreFactory_other() {
        // GIVEN
        let resolver = someContainer
        let expectedObject = SomeClass()
        var factoryClosureCallCount = 0
        let factory = Factory(type: SomeClass.self) { _, _ in
            factoryClosureCallCount += 1
            return expectedObject
        }

        let group = DispatchGroup()
        group.enter()

        // WHEN
        DispatchQueue.global(qos: .userInitiated).async {
            resolver.store(factory: factory)

            let result = Inject<SomeClass>(container: someContainer).wrappedValue

            XCTAssertNotNil(result)

            // all good
            group.leave()
        }
        group.wait()

        // THEN
        XCTAssertEqual(resolver.factories.count, resolver.store.count)
        XCTAssertEqual(resolver.factories.count, 1)
        XCTAssertEqual(resolver.store.count, 1)
    }

    // MARK: - resolve(type: forCustomTypeIdentifier: resolver:)

    func testResolveSampleType_callExplicitResolve() {
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
        do {
            let resolved = try resolver.resolve(type: SomeClass.self,
                                                forCustomTypeIdentifier: nil,
                                                resolver: resolver)

            // THEN
            XCTAssertTrue(resolved === expectedObject, "identity of resolved object should match")
            XCTAssertEqual(factoryClosureCallCount, 1, "the factory closure should be called once exactly")
        } catch {
            XCTFail("Unexpected: \(error)")
        }

        XCTAssertEqual(resolver.factories.count, resolver.store.count)
        XCTAssertEqual(resolver.factories.count, 1)
        XCTAssertEqual(resolver.store.count, 1)
    }

    func testResolveSampleType_chainedDependency_classes() {
        // GIVEN
        let resolver = someContainer
        let expectedObject = SomeClass()
        var factoryClosureCallCount = 0
        let factory = Factory(type: SomeClass.self) { _, _ in
            factoryClosureCallCount += 1
            return expectedObject
        }

        var dependentFactoryClosureCallCount = 0
        let dependentFactory = Factory(type: ClassWithSomeDependentType.self) { _, resolver in
            dependentFactoryClosureCallCount += 1

            do {
                let dependency = try resolver.resolve(type: SomeClass.self,
                                                      forCustomTypeIdentifier: nil,
                                                      factoryParameters: nil,
                                                      resolver: resolver)

                let resolved = ClassWithSomeDependentType(dependency: dependency)
                return resolved
            } catch {
                XCTFail("Unexpected resolution error:\(error)")
                return
            }
        }

        // Order of call to store does not matter, but should be done asap
        resolver.store(factory: dependentFactory)
        resolver.store(factory: factory)

        // WHEN
        let chain = ClassThatChainsDI()

        // THEN
        XCTAssertTrue(chain.injected.dependency === expectedObject,
                      "Resolution should provide the injected object with the correct dependency")
        XCTAssertEqual(factoryClosureCallCount, 1, "the closure should be called once exactly")
        XCTAssertEqual(dependentFactoryClosureCallCount, 1, "the closure should be called once exactly")

        XCTAssertEqual(resolver.factories.count, resolver.store.count)
        XCTAssertEqual(resolver.factories.count, 2)
        XCTAssertEqual(resolver.store.count, 2)
    }

    func testResolveSampleType_chainedDependency_struct() {
        // GIVEN
        let resolver = someContainer
        let expectedStruct = SomeStruct()
        var factoryClosureCallCount = 0
        let factory = Factory(type: SomeStruct.self) { _, _ in
            factoryClosureCallCount += 1
            return expectedStruct
        }

        var dependentFactoryClosureCallCount = 0
        let dependentFactory = Factory(type: StructWithSomeDependentType.self) { _, resolver in
            dependentFactoryClosureCallCount += 1

            do {
                let dependency = try resolver.resolve(type: SomeStruct.self,
                                                      forCustomTypeIdentifier: nil,
                                                      factoryParameters: nil,
                                                      resolver: resolver)

                let resolved = StructWithSomeDependentType(dependency: dependency)
                return resolved
            } catch {
                XCTFail("Unexpected resolution error:\(error)")
                return
            }
        }

        // Order of call to store does not matter, but should be done asap
        resolver.store(factory: dependentFactory)
        resolver.store(factory: factory)

        // WHEN
        let chain = StructThatChainsDI()

        // THEN
        XCTAssertEqual(chain.injected.dependency.identity, expectedStruct.identity,
                       "identity is expected to match")
        XCTAssertEqual(factoryClosureCallCount, 1, "the closure should be called once exactly")
        XCTAssertEqual(dependentFactoryClosureCallCount, 1, "the closure should be called once exactly")

        XCTAssertEqual(resolver.factories.count, resolver.store.count)
        XCTAssertEqual(resolver.factories.count, 2)
        XCTAssertEqual(resolver.store.count, 2)
    }
}
