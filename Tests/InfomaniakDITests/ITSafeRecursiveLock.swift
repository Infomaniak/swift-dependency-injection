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
    @Test("Stress test with many concurrent tasks, manual lock/unlock from arbitrary queues",
          arguments: [1, 100, 50], [100, 1, 50])
    func manyConcurrentTasksManualLock(taskCount: Int, iterationsPerTask: Int) {
        // GIVEN
        let group = DispatchGroup()
        var sharedCounter = 0
        let counterLock = NSLock()
        let safeLock = SafeRecursiveLock()

        // Create a pool of queues to simulate arbitrary queues
        let queuePool: [DispatchQueue] = (0 ..< 8).map { DispatchQueue(label: "test.queue.\($0)", attributes: .concurrent) }

        // WHEN
        for _ in 0 ..< taskCount {
            // Pick a random queue from the pool for this task
            let randomQueue = queuePool.randomElement()!
            randomQueue.async(group: group) {
                for i in 0 ..< iterationsPerTask {
                    // Small sleep to encourage thread interleaving
                    if i == 0 || i % 10 == 0 {
                        Thread.sleep(forTimeInterval: 0.001)
                    }

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
                }
            }
        }

        // THEN
        let waitResult = group.wait(timeout: .now() + .seconds(240))
        #expect(waitResult == .success)

        let expected = taskCount * iterationsPerTask * 2
        #expect(sharedCounter == expected, "sharedCounter should be \(expected), but was \(sharedCounter)")
    }

    @Test("Stress test long hold + many waiters, manual lock/unlock", arguments: [50])
    func longHoldWithManyWaitersManualLock(taskCount: Int) {
        // GIVEN
        let shortLock = SafeRecursiveLock()
        var sharedSum = 0
        let sumLock = NSLock()

        // WHEN
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
        let waitResult = group.wait(timeout: .now() + .seconds(240))
        #expect(waitResult == .success)

        #expect(sharedSum == (1 + taskCount), "sharedSum should be \(1 + taskCount), but was \(sharedSum)")
    }
}
