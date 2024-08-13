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

/// Entry point of the DI library
///
/// Allows to add and remove dynamically containers.
/// Also provides a standard, shared, singleton style, container.
public final class DependencyInjectionService {
    
    /// Shared container of all singletons of an executable
    var _sharedContainer: Container
    
    public var sharedContainer: Container {
        _sharedContainer
    }
    
    public init(sharedContainer: Container = Container()) {
        self._sharedContainer = sharedContainer
    }
    
}
