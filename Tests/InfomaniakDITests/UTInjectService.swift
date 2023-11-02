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
