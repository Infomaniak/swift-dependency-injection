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

/// Unit Tests of `LazyInjectService` regarding identity and equality
final class UTLazyInjectService_Identity: XCTestCase {
    /// Two `LazyInjectService` that points to the same Metatype are expected to be equal (for the sake of SwiftUI correctness)
    func testTwoLazyInjectService_SameIdentityOfPropertyWrappers_ForClass() {
        // GIVEN
        @LazyInjectService var some: SomeClass
        @LazyInjectService var someBis: SomeClass

        // THEN
        XCTAssertEqual($some, $someBis, "Equality of the property wrappers are expected to match")
        XCTAssertTrue(
            $some.id == $someBis.id,
            "The identity of the property wrappers are expected to match \($some.id) \($someBis.id)"
        )
    }

    func testTwoLazyInjectService_SameIdentityOfPropertyWrappers_ForProtocol() {
        // GIVEN
        @LazyInjectService var some: SomeClassable
        @LazyInjectService var someBis: SomeClassable

        // THEN
        XCTAssertEqual($some, $someBis, "Equality of the property wrappers are expected to match")
        XCTAssertTrue(
            $some.id == $someBis.id,
            "The identity of the property wrappers are expected to match \($some.id) \($someBis.id)"
        )
    }

    func testTwoLazyInjectService_SameIdentityOfPropertyWrappers_ForStruct() {
        // GIVEN
        @LazyInjectService var some: SomeStruct
        @LazyInjectService var someBis: SomeStruct

        // THEN
        XCTAssertEqual($some, $someBis, "Equality of the property wrappers are expected to match")
        XCTAssertTrue(
            $some.id == $someBis.id,
            "The identity of the property wrappers are expected to match \($some.id) \($someBis.id)"
        )
    }

    func testTwoLazyInjectService_SameIdentityOfPropertyWrappers_ForEnum() {
        // GIVEN
        @LazyInjectService var some: SomeEnum
        @LazyInjectService var someBis: SomeEnum

        // THEN
        XCTAssertEqual($some, $someBis, "Equality of the property wrappers are expected to match")
        XCTAssertTrue(
            $some.id == $someBis.id,
            "The identity of the property wrappers are expected to match \($some.id) \($someBis.id)"
        )
    }

    func testTwoLazyInjectService_NotSameIdentityOfPropertyWrappers_BetweenTwoClasses() {
        // GIVEN
        @LazyInjectService var some: SomeClass
        @LazyInjectService var someOther: SomeOtherClass

        // THEN
        XCTAssertFalse(
            $some.id == $someOther.id,
            "The identity of the property wrappers should not match \($some.id) \($someOther.id)"
        )
    }

    func testTwoLazyInjectService_NotSameIdentityOfPropertyWrappers_BetweenClassAndProtocol() {
        // GIVEN
        @LazyInjectService var someClass: SomeClass
        @LazyInjectService var someProtocol: SomeClassable

        // THEN
        XCTAssertFalse(
            $someClass.id == $someProtocol.id,
            "The identity of the property wrappers should not match \($someClass.id) \($someProtocol.id)"
        )
    }

    func testTwoLazyInjectService_SameIdentityOfPropertyWrappers_BetweenProtocolAndConformingClass() {
        // GIVEN
        @LazyInjectService var someClassConforming: SomeClassConforming
        @LazyInjectService var someProtocol: SomeClassable

        // THEN
        XCTAssertFalse(
            $someClassConforming.id == $someProtocol.id,
            "The identity of the property wrappers should not match \($someClassConforming.id) \($someProtocol.id)"
        )
    }
}
