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

/// Unit Tests of `InjectService` regarding identity and equality
final class UTInjectService_Identity: XCTestCase {
    override func setUp() {
        SimpleResolver.sharedResolver.removeAll()

        // Make sure something is registered before doing a test, resolution does not matter in this test set.
        registerAllHelperTypes()
    }

    override func tearDown() {
        SimpleResolver.sharedResolver.removeAll()
    }

    /// Two `InjectService` that points to the same Metatype are expected to be equal (for the sake of SwiftUI correctness)
    func testTwoLazyInjectService_SameIdentityOfPropertyWrappers_ForClass() {
        // GIVEN
        @InjectService var some: SomeClass
        @InjectService var someBis: SomeClass

        // THEN
        XCTAssertEqual($some, $someBis, "Equality of the property wrappers are expected to match")
        XCTAssertTrue(
            $some.id == $someBis.id,
            "The identity of the property wrappers are expected to match \($some.id) \($someBis.id)"
        )
    }

    func testTwoLazyInjectService_SameIdentityOfPropertyWrappers_ForProtocol() {
        // GIVEN
        @InjectService var some: SomeClassable
        @InjectService var someBis: SomeClassable

        // THEN
        XCTAssertEqual($some, $someBis, "Equality of the property wrappers are expected to match")
        XCTAssertTrue(
            $some.id == $someBis.id,
            "The identity of the property wrappers are expected to match \($some.id) \($someBis.id)"
        )
    }

    func testTwoLazyInjectService_SameIdentityOfPropertyWrappers_ForStruct() {
        // GIVEN
        @InjectService var some: SomeStruct
        @InjectService var someBis: SomeStruct

        // THEN
        XCTAssertEqual($some, $someBis, "Equality of the property wrappers are expected to match")
        XCTAssertTrue(
            $some.id == $someBis.id,
            "The identity of the property wrappers are expected to match \($some.id) \($someBis.id)"
        )
    }

    func testTwoLazyInjectService_SameIdentityOfPropertyWrappers_ForEnum() {
        // GIVEN
        @InjectService var some: SomeEnum
        @InjectService var someBis: SomeEnum

        // THEN
        XCTAssertEqual($some, $someBis, "Equality of the property wrappers are expected to match")
        XCTAssertTrue(
            $some.id == $someBis.id,
            "The identity of the property wrappers are expected to match \($some.id) \($someBis.id)"
        )
    }

    func testTwoLazyInjectService_NotSameIdentityOfPropertyWrappers_BetweenTwoClasses() {
        // GIVEN
        @InjectService var some: SomeClass
        @InjectService var someOther: SomeOtherClass

        // THEN
        XCTAssertFalse(
            $some.id == $someOther.id,
            "The identity of the property wrappers should not match \($some.id) \($someOther.id)"
        )
    }

    func testTwoLazyInjectService_NotSameIdentityOfPropertyWrappers_BetweenClassAndProtocol() {
        // GIVEN
        @InjectService var someClass: SomeClass
        @InjectService var someProtocol: SomeClassable

        // THEN
        XCTAssertFalse(
            $someClass.id == $someProtocol.id,
            "The identity of the property wrappers should not match \($someClass.id) \($someProtocol.id)"
        )
    }

    func testTwoLazyInjectService_SameIdentityOfPropertyWrappers_BetweenProtocolAndConformingClass() {
        // GIVEN
        @InjectService var someClassConforming: SomeClassConforming
        @InjectService var someProtocol: SomeClassable

        // THEN
        XCTAssertFalse(
            $someClassConforming.id == $someProtocol.id,
            "The identity of the property wrappers should not match \($someClassConforming.id) \($someProtocol.id)"
        )
    }
}
