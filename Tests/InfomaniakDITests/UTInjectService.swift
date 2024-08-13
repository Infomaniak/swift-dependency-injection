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

/// Unit Tests of `Inject` regarding identity and equality
final class UTInject_Identity: XCTestCase {
    override func setUp() {
        someContainer.removeAll()

        // Make sure something is registered before doing a test, resolution does not matter in this test set.
        registerAllHelperTypes(container: someContainer)
    }

    override func tearDown() {
        someContainer.removeAll()
    }

    /// Two `Inject` that points to the same Metatype are expected to be equal (for the sake of SwiftUI correctness)
    func testTwoLazyInject_SameIdentityOfPropertyWrappers_ForClass() {
        // GIVEN
        @Inject(container: someContainer) var some: SomeClass
        @Inject(container: someContainer) var someBis: SomeClass

        // THEN
        XCTAssertEqual($some, $someBis, "Equality of the property wrappers are expected to match")
        XCTAssertTrue(
            $some.id == $someBis.id,
            "The identity of the property wrappers are expected to match \($some.id) \($someBis.id)"
        )
    }

    func testTwoLazyInject_SameIdentityOfPropertyWrappers_ForProtocol() {
        // GIVEN
        @Inject(container: someContainer) var some: SomeClassable
        @Inject(container: someContainer) var someBis: SomeClassable

        // THEN
        XCTAssertEqual($some, $someBis, "Equality of the property wrappers are expected to match")
        XCTAssertTrue(
            $some.id == $someBis.id,
            "The identity of the property wrappers are expected to match \($some.id) \($someBis.id)"
        )
    }

    func testTwoLazyInject_SameIdentityOfPropertyWrappers_ForStruct() {
        // GIVEN
        @Inject(container: someContainer) var some: SomeStruct
        @Inject(container: someContainer) var someBis: SomeStruct

        // THEN
        XCTAssertEqual($some, $someBis, "Equality of the property wrappers are expected to match")
        XCTAssertTrue(
            $some.id == $someBis.id,
            "The identity of the property wrappers are expected to match \($some.id) \($someBis.id)"
        )
    }

    func testTwoLazyInject_SameIdentityOfPropertyWrappers_ForEnum() {
        // GIVEN
        @Inject(container: someContainer) var some: SomeEnum
        @Inject(container: someContainer) var someBis: SomeEnum

        // THEN
        XCTAssertEqual($some, $someBis, "Equality of the property wrappers are expected to match")
        XCTAssertTrue(
            $some.id == $someBis.id,
            "The identity of the property wrappers are expected to match \($some.id) \($someBis.id)"
        )
    }

    func testTwoLazyInject_NotSameIdentityOfPropertyWrappers_BetweenTwoClasses() {
        // GIVEN
        @Inject(container: someContainer) var some: SomeClass
        @Inject(container: someContainer) var someOther: SomeOtherClass

        // THEN
        XCTAssertFalse(
            $some.id == $someOther.id,
            "The identity of the property wrappers should not match \($some.id) \($someOther.id)"
        )
    }

    func testTwoLazyInject_NotSameIdentityOfPropertyWrappers_BetweenClassAndProtocol() {
        // GIVEN
        @Inject(container: someContainer) var someClass: SomeClass
        @Inject(container: someContainer) var someProtocol: SomeClassable

        // THEN
        XCTAssertFalse(
            $someClass.id == $someProtocol.id,
            "The identity of the property wrappers should not match \($someClass.id) \($someProtocol.id)"
        )
    }

    func testTwoLazyInject_SameIdentityOfPropertyWrappers_BetweenProtocolAndConformingClass() {
        // GIVEN
        @Inject(container: someContainer) var someClassConforming: SomeClassConforming
        @Inject(container: someContainer) var someProtocol: SomeClassable

        // THEN
        XCTAssertFalse(
            $someClassConforming.id == $someProtocol.id,
            "The identity of the property wrappers should not match \($someClassConforming.id) \($someProtocol.id)"
        )
    }
}
