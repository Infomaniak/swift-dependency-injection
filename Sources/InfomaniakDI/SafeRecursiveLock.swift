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

/// A Thread safe recursive lock
///
/// Unlike `NSRecursiveLock`, it can be called from arbitrary threads without creating deadlocks.
final class SafeRecursiveLock: @unchecked Sendable {
    private let accessSemaphore = DispatchSemaphore(value: 1)
    private let internalLock = NSLock()

    private var owningThread: Thread?
    private var recursionCount: Int = 0

    @inline(__always)
    func lock() {
        let currentThread = Thread.current

        internalLock.lock()
        if owningThread == currentThread {
            // Recursive lock by the same thread
            recursionCount += 1
            internalLock.unlock()
            return
        }
        internalLock.unlock()

        // Wait until lock is available
        accessSemaphore.wait()

        // We now own the lock
        internalLock.lock()
        owningThread = currentThread
        recursionCount = 1
        internalLock.unlock()
    }

    @inline(__always)
    func unlock() {
        internalLock.lock()
        let currentThread = Thread.current
        guard owningThread == currentThread else {
            internalLock.unlock()
            fatalError("Unlock called from a different thread!")
        }

        recursionCount -= 1
        if recursionCount == 0 {
            owningThread = nil
            internalLock.unlock()
            accessSemaphore.signal() // allow other threads to acquire
        } else {
            internalLock.unlock()
        }
    }
}
