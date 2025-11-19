import Foundation

struct SystemMetrics {
    static func ramUsedFraction() -> Double {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size) / 4
        let kerr = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
            }
        }
        guard kerr == KERN_SUCCESS else { return 0 }
        let used = Double(info.resident_size)
        let deviceRam = Double(ProcessInfo.processInfo.physicalMemory)
        return used / deviceRam
    }

    private static let threadBasicInfoCount: mach_msg_type_number_t =
        UInt32(MemoryLayout<thread_basic_info_data_t>.size / MemoryLayout<integer_t>.size)

    static func cpuUsageFraction() -> Double {
        var threads: thread_act_array_t?
        var threadCount = mach_msg_type_number_t()
        let task = mach_task_self_

        guard task_threads(task, &threads, &threadCount) == KERN_SUCCESS, let threads = threads else { return 0 }
        var totalUsage: Double = 0
        for i in 0..<Int(threadCount) {
            var info = thread_basic_info()
            var count = threadBasicInfoCount
            let res = withUnsafeMutablePointer(to: &info) {
                $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                    thread_info(threads[i], thread_flavor_t(THREAD_BASIC_INFO), $0, &count)
                }
            }
            if res == KERN_SUCCESS && (info.flags & TH_FLAGS_IDLE) == 0 {
                totalUsage += Double(info.cpu_usage) / Double(TH_USAGE_SCALE)
            }
        }
        vm_deallocate(mach_task_self_, vm_address_t(bitPattern: threads), vm_size_t(threadCount) * vm_size_t(MemoryLayout<thread_t>.size))
        return totalUsage
    }

    static func storageInfo() -> (free: Double, total: Double)? {
        if let attrs = try? FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory()),
           let free = attrs[.systemFreeSize] as? Double,
           let total = attrs[.systemSize] as? Double {
            return (free / 1024 / 1024 / 1024, total / 1024 / 1024 / 1024) // Go
        }
        return nil
    }

    static func uptimeText() -> String {
        let uptime = ProcessInfo.processInfo.systemUptime
        let heures = Int(uptime / 3600)
        let minutes = Int(uptime / 60) % 60
        let secondes = Int(uptime) % 60
        return "\(heures)h \(minutes)m \(secondes)s"
    }
}
