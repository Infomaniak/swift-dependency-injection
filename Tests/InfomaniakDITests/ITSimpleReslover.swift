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

/// Integration Tests of the Simple DI mechanism
final class ITSimpleReslover: XCTestCase {
    override func setUp() {
        SimpleResolver.sharedResolver.removeAll()
    }

    override func tearDown() {
        SimpleResolver.sharedResolver.removeAll()
    }
    
    // MARK: - store(factory:)
    
    func testStoreFactory_mainThread() {
        // GIVEN
        let resolver = SimpleResolver.sharedResolver
        let expectedObject = SomeClass()
        var factoryClosureCallCount = 0
        let factory = Factory(type: SomeClass.self) { _, _ in
            factoryClosureCallCount += 1
            return expectedObject
        }
        
        // WHEN
        resolver.store(factory: factory)
        let result = InjectService<SomeClass>().wrappedValue

        
        // THEN
        XCTAssertNotNil(result)
        XCTAssertEqual(resolver.factories.count, 1)
        XCTAssertEqual(resolver.store.count, 1)
    }
    
    func testStoreFactory_other() {
        // GIVEN
        let resolver = SimpleResolver.sharedResolver
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
            
            let result = InjectService<SomeClass>().wrappedValue
            
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
        let resolver = SimpleResolver.sharedResolver
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
        }
        catch {
            XCTFail("Unexpected: \(error)")
        }
        
        XCTAssertEqual(resolver.factories.count, resolver.store.count)
        XCTAssertEqual(resolver.factories.count, 1)
        XCTAssertEqual(resolver.store.count, 1)
    }
    
    func testResolveSampleType_chainedDependency_classes() {
        // GIVEN
        let resolver = SimpleResolver.sharedResolver
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
        let resolver = SimpleResolver.sharedResolver
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
