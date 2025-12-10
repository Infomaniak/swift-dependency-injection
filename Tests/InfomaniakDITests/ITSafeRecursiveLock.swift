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

struct ITSafeRecursiveLock {
    private let taskCount = 50
    private let iterationsPerTask = 100

    @Test("Stress test with many concurrent tasks, manual lock/unlock", .timeLimit(.minutes(1)))
    func manyConcurrentTasksManualLock() {
        // GIVEN
        let group = DispatchGroup()
        var sharedCounter = 0
        let counterLock = NSLock()
        let safeLock = SafeRecursiveLock()

        // WHEN
        for _ in 0 ..< taskCount {
            DispatchQueue.global().async(group: group) {
                for i in 0 ..< iterationsPerTask {
                    // Explicitly lock/unlock
                    safeLock.lock()
                    counterLock.lock()
                    sharedCounter += 1
                    counterLock.unlock()

                    // Recursive locking
                    safeLock.lock()
                    counterLock.lock()
                    sharedCounter += 1
                    counterLock.unlock()
                    safeLock.unlock()

                    safeLock.unlock()

                    // Small sleep to encourage thread interleaving
                    if i % 10 == 0 {
                        Thread.sleep(forTimeInterval: 0.001)
                    }
                }
            }
        }

        // THEN
        let waitResult = group.wait(timeout: .now() + .seconds(30))
        #expect(waitResult == .success)

        let expected = taskCount * iterationsPerTask * 2
        #expect(sharedCounter == expected, "sharedCounter should be \(expected), but was \(sharedCounter)")
    }

    @Test("Stress test long hold + many waiters, manual lock/unlock", .timeLimit(.minutes(1)))
    func longHoldWithManyWaitersManualLock() {
        // GIVEN
        let shortLock = SafeRecursiveLock()
        var sharedSum = 0
        let sumLock = NSLock()

        // WHEN
        // Task 0: long-holding task
        DispatchQueue.global().async {
            shortLock.lock()
            Thread.sleep(forTimeInterval: 1.0)
            sumLock.lock()
            sharedSum += 1
            sumLock.unlock()
            shortLock.unlock()
        }

        Thread.sleep(forTimeInterval: 0.1)

        let group = DispatchGroup()
        for _ in 0 ..< taskCount {
            DispatchQueue.global().async(group: group) {
                shortLock.lock()
                sumLock.lock()
                sharedSum += 1
                sumLock.unlock()
                shortLock.unlock()
            }
        }

        // THEN
        let waitResult = group.wait(timeout: .now() + .seconds(30))
        #expect(waitResult == .success)

        #expect(sharedSum == (1 + taskCount), "sharedSum should be \(1 + taskCount), but was \(sharedSum)")
    }
}
