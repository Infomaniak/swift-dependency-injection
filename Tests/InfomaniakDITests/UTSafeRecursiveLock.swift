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
import Testing

@MainActor
struct UTSafeRecursiveLock {

    // MARK: - lock() recursive on same thread

    @Test("lock() allows recursive locking on the same thread", .timeLimit(.minutes(1)))
    func testLockRecursiveSameThread() {
        // GIVEN
        let lock = SafeRecursiveLock()
        var value = 0

        // WHEN
        lock.lock()
        lock.lock() // recursive lock on same thread
        value += 10
        lock.unlock()
        lock.unlock()

        // THEN
        #expect(value == 10, "Value should be 10 after recursive lock/unlock")
    }

    // MARK: - lock() blocks other threads

    @Test("lock() blocks other threads until released", .timeLimit(.minutes(1)))
    func testLockBlocksOtherThreads() {
        // GIVEN
        let lock = SafeRecursiveLock()
        var sharedCounter = 0
        let group = DispatchGroup()
        lock.lock() // main thread locks first

        // WHEN
        DispatchQueue.global().async(group: group) {
            lock.lock() // should block until main thread unlocks
            sharedCounter += 1
            lock.unlock()
        }

        // give async thread a chance to attempt the lock
        Thread.sleep(forTimeInterval: 0.1)

        // THEN
        #expect(sharedCounter == 0, "Shared counter should still be 0, lock not released yet")

        // WHEN
        lock.unlock() // release lock, allowing other thread to proceed

        // THEN
        let waitResult = group.wait(timeout: .now() + .seconds(1))
        #expect(waitResult == .success)
        #expect(sharedCounter == 1, "Shared counter should be 1 after other thread acquires lock")
    }

    // MARK: - unlock() releases the lock

    @Test("unlock() releases the lock and allows waiting threads to proceed", .timeLimit(.minutes(1)))
    func testUnlockReleasesLock() {
        // GIVEN
        let lock = SafeRecursiveLock()
        var sharedCounter = 0
        let group = DispatchGroup()
        lock.lock()

        // WHEN
        DispatchQueue.global().async(group: group) {
            lock.lock()
            sharedCounter += 1
            lock.unlock()
        }

        // THEN
        lock.unlock() // release lock for other thread
        let waitResult = group.wait(timeout: .now() + .seconds(1))
        #expect(waitResult == .success)
        #expect(sharedCounter == 1, "Shared counter should be 1 after unlock")
    }

    // MARK: - unlock() called from wrong thread

    @Test("unlock() from wrong thread triggers fatalError (cannot catch in tests)", .timeLimit(.minutes(1)))
    func testUnlockFromWrongThread() {
        // GIVEN
        let lock = SafeRecursiveLock()
        lock.lock()

        // WHEN
        DispatchQueue.global().async {
            // Normally fatalError cannot be caught in Testing
            // This shows intent; do not uncomment in real test or it will crash
            // lock.unlock()
        }

        // THEN
        // Just ensure main thread can clean up
        lock.unlock()
    }
}
