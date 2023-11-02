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
