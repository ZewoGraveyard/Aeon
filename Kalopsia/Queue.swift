// Queue.swift
//
// The MIT License (MIT)
//
// Copyright (c) 2015 Zewo
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import Belle

public enum QualityOfServiceClass {
    case UserInteractive
    case UserInitiated
    case Default
    case Utility
    case Background

    private var value: qos_class_t {
        switch self {
        case UserInteractive:
            if #available(OSX 10.10, *) {
                return QOS_CLASS_USER_INTERACTIVE
            } else {
                return qos_class_t(UInt32(DISPATCH_QUEUE_PRIORITY_HIGH))
            }
        case UserInitiated:
            if #available(OSX 10.10, *) {
                return QOS_CLASS_USER_INITIATED
            } else {
                return qos_class_t(UInt32(DISPATCH_QUEUE_PRIORITY_HIGH))
            }
        case Default:
            if #available(OSX 10.10, *) {
                return QOS_CLASS_DEFAULT
            } else {
                return qos_class_t(UInt32(DISPATCH_QUEUE_PRIORITY_DEFAULT))
            }
        case Utility:
            if #available(OSX 10.10, *) {
                return QOS_CLASS_UTILITY
            } else {
                return qos_class_t(UInt32(DISPATCH_QUEUE_PRIORITY_LOW))
            }
        case Background:
            if #available(OSX 10.10, *) {
                return QOS_CLASS_BACKGROUND
            } else {
                return qos_class_t(UInt32(DISPATCH_QUEUE_PRIORITY_BACKGROUND))
            }
        }
    }
}

public var mainQueue = Queue(queue: dispatch_get_main_queue()!)
/// Work performed in this queue is interactive with the user. Such work is requested to run at high priority relative to other work on the system. Specifying this QOS class is a request to run with nearly all available system CPU and I/O bandwidth even under contention. This is not an energy-efficient QOS class to use for large tasks. The use of this QOS class should be limited to critical interaction with the user such as handling events on the main event loop, view drawing, animation, etc.
public var userInteractiveQueue = getGlobalQueue(qualityOfServiceClass: .UserInteractive)
/// Work performed in this queue is initiated by the user and the user is likely waiting for the results. Such work is requested to run at a priority below critical user-interactive work, but relatively higher than other work on the system. This is not an energy-efficient QOS class to use for large tasks and the use of this QOS class should be limited to operations where the user is immediately waiting for the results.
public var userInitiatedQueue = getGlobalQueue(qualityOfServiceClass: .UserInitiated)
/// A default queue used by the system in cases where more specific QOS class information is not available. Such work is requested to run at a priority below critical user-interactive and user-initiated work, but relatively higher than utility and background tasks. Threads created by pthread_create() without an attribute specifying a QOS class will default to QOS_CLASS_DEFAULT. This QOS class value is not intended to be used as a work classification, it should only be set when propagating or restoring QOS class values provided by the system.
public var defaultQueue = getGlobalQueue(qualityOfServiceClass: .Default)
/// Work performed in this queue may or may not be initiated by the user and the user is unlikely to be immediately waiting for the results. Such work is requested to run at a priority below critical user-interactive and user-initiated work, but relatively higher than low-level system maintenance tasks. The use of this QOS class indicates the work should be run in an energy and thermally-efficient manner.
public var utilityQueue = getGlobalQueue(qualityOfServiceClass: .Utility)
/// Work performed in this queue is not initiated by the user and the user may be unaware of the results. Such work is requested to run at a priority below other work. The use of this QOS class indicates the work should be run in the most energy and thermally-efficient manner.
public var backgroundQueue = getGlobalQueue(qualityOfServiceClass: .Background)

func getGlobalQueue(qualityOfServiceClass qos: QualityOfServiceClass) -> Queue {
    return Queue(queue: dispatch_get_global_queue(qos.value, 0))
}

public enum QueueType {
    case Serial
    case Concurrent

    var value: dispatch_queue_attr_t!  {
        switch self {
        case Serial: return DISPATCH_QUEUE_SERIAL
        case Concurrent: return DISPATCH_QUEUE_CONCURRENT
        }
    }
}

public struct Queue {
    let queue: dispatch_queue_t

    init(queue: dispatch_queue_t) {
        self.queue = queue
    }

    public init(label: String = "", type: QueueType = .Serial, qualityOfServiceClass qos: QualityOfServiceClass = .Default, relativePriority: Int32 = 0) {
        if #available(OSX 10.10, *) {
            let attributes = dispatch_queue_attr_make_with_qos_class(type.value, qos.value, relativePriority)
            queue = dispatch_queue_create(label, attributes)
        } else {
            queue = dispatch_queue_create(label, type.value)
        }
    }

    /**
     Submits a closure for asynchronous execution on a dispatch queue.

     The `async()` function is the fundamental mechanism for submitting closures to a dispatch queue.

     Calls to `async()` always return immediately after the closure has been submitted, and never wait for the closure to be invoked.

     The target queue determines whether the closure will be invoked serially or concurrently with respect to other closures submitted to that same queue. Serial queues are processed concurrently with respect to each other.

     :param: queue   The target dispatch queue to which the closure is submitted. The system will hold a reference on the target queue until the closure has finished. The default parameter is the **default queue**.
     :param: closure The closure to submit to the target dispatch queue.
     */
    public func async(closure: Void -> Void) {
        dispatch_async(queue, closure)
    }

    /**
     Submits a closure for synchronous execution on a dispatch queue.

     Submits a closure to a dispatch queue like `async()`, however `sync()` will not return until the closure has finished.

     Calls to `sync()` targeting the current queue will result in dead-lock. Use of `sync()` is also subject to the same multi-party dead-lock problems that may result from the use of a mutex. Use of `async()` is preferred.

     Unlike `async()`, no retain is performed on the target queue. Because calls to this function are synchronous, the `sync()` "borrows" the reference of the caller.

     As an optimization, `sync()` invokes the closure on the current thread when possible.

     :param: queue   The target dispatch queue to which the closure is submitted. The default parameter is the **main queue**.
     :param: closure The closure to be invoked on the target dispatch queue.
     */
    public func sync(closure: Void -> Void) {
        dispatch_sync(queue, closure)
    }

    public func after(time: Double, closure: Void -> Void) {
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(time * Double(NSEC_PER_SEC)))
        dispatch_after(time, queue, closure)
    }
}

public func main() {
    dispatch_main()
}
