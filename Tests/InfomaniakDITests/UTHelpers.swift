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
