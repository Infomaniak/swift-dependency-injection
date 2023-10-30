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

import Foundation
@testable import InfomaniakDI

public func registerAllHelperTypes() {
    let resolver = SimpleResolver.sharedResolver

    let factories = [
        Factory(type: SomeClass.self) { _, _ in
            SomeClass()
        },
        Factory(type: SomeOtherClass.self) { _, _ in
            SomeOtherClass()
        },
        Factory(type: SomeClassConforming.self) { _, _ in
            SomeClassConforming()
        },
        Factory(type: SomeClassable.self) { _, _ in
            SomeClassConforming()
        },
        Factory(type: SomeEnum.self) { _, _ in
            SomeEnum.someCase
        },
        Factory(type: SomeStruct.self) { _, _ in
            SomeStruct()
        }
    ]

    for factory in factories {
        resolver.store(factory: factory)
    }
}

// MARK: - Helper Class

class SomeClass {}

class SomeOtherClass {}

protocol SomeClassable: AnyObject {}

class SomeClassConforming: SomeClassable {}

/// A class with only one resolved property
class ClassThatUsesDI {
    init() {}

    @InjectService var injected: SomeClass
}

/// A class with only one resolved property
class ClassThatUsesConformingDI {
    init() {}

    @InjectService var injected: SomeClassable
}

/// A class with one resolved property using `factoryParameters`
class ClassThatUsesFactoryParametersDI {
    init() {}

    @InjectService(factoryParameters: ["someKey": "someValue"]) var injected: SomeClass
}

/// A class with two resolved properties of the same type using `customTypeIdentifier`
class ClassThatUsesCustomIdentifiersDI {
    init() {}

    @InjectService(customTypeIdentifier: "specialIdentifier") var special: SomeClass

    @InjectService(customTypeIdentifier: "customIdentifier") var custom: SomeClass
}

/// A class with two resolved properties of the same type using `customTypeIdentifier` and  using `factoryParameters`
class ClassThatUsesComplexDI {
    init() {}

    @InjectService(customTypeIdentifier: "special",
                   factoryParameters: ["someKey": "someValue"]) var special: SomeClass

    @InjectService(customTypeIdentifier: "custom",
                   factoryParameters: ["someKey": "someValue"]) var custom: SomeClass
}

/// A class with only one resolved property
class ClassThatChainsDI {
    init() {}

    @InjectService var injected: ClassWithSomeDependentType
}

/// Resolve a type inside a function
class ClassThatDoesInlineDI {
    init() {}

    func inlineDI() -> SomeClass {
        let resolved = InjectService<SomeClass>().wrappedValue
        return resolved
    }
}

class ClassWithSomeDependentType {
    let dependency: SomeClass

    init(dependency: SomeClass) {
        self.dependency = dependency
    }
}

// MARK: - Helper Struct

struct SomeStruct {
    let identity: String = UUID().uuidString
}

/// A class with only one resolved property
struct StructThatChainsDI {
    @InjectService var injected: StructWithSomeDependentType
}

class StructWithSomeDependentType {
    let dependency: SomeStruct

    init(dependency: SomeStruct) {
        self.dependency = dependency
    }
}

// MARK: - Helper Enum

enum SomeEnum: String {
    case someCase
    case someOtherCase
}
