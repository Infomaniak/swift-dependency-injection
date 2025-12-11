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
import os.lock

/// A thread safe recursive lock
///
/// Unlike `NSRecursiveLock`, it can be called from arbitrary threads without creating deadlocks.
final class SafeRecursiveLock: @unchecked Sendable {
    private var unfairLock = os_unfair_lock()
    private var owningThread: Thread?
    private var recursionCount: Int = 0

    @inline(__always)
    func lock() {
        let currentTread = Thread.current

        if owningThread === currentTread {
            recursionCount += 1
            return
        }

        os_unfair_lock_lock(&unfairLock)
        owningThread = currentTread
        recursionCount = 1
    }

    @inline(__always)
    func unlock() {
        let current = Thread.current
        guard owningThread === current else {
            fatalError("Unlock from wrong thread")
        }

        recursionCount -= 1

        if recursionCount == 0 {
            owningThread = nil
            os_unfair_lock_unlock(&unfairLock)
        }
    }
}
