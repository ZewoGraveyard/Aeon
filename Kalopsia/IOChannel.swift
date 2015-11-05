// IOChannel.swift
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

public enum IOChannelType {
    case Stream
    case RandomAccess

    private var value: dispatch_io_type_t {
        switch self {
        case .Stream: return DISPATCH_IO_STREAM
        case .RandomAccess: return DISPATCH_IO_RANDOM
        }
    }
}

public enum IOChannelCleanUpResult {
    case Success
    case Failure(error: ErrorType)

    func success(f: Void -> Void) {
        switch self {
        case Success: f()
        default: break
        }
    }

    func failure(f: ErrorType -> Void) {
        switch self {
        case Failure(let e): f(e)
        default: break
        }
    }
}

public enum IOChannelResult {
    case Success(done: Bool, data: [Int8])
    case Canceled(data: [Int8])
    case Failure(error: ErrorType)

    func success(f: (done: Bool, data: [Int8]) -> Void) {
        switch self {
        case Success(let done, let data): f(done: done, data: data)
        default: break
        }
    }

    func failure(f: ErrorType -> Void) {
        switch self {
        case Failure(let e): f(e)
        default: break
        }
    }

    func canceled(f: (data: [Int8]) -> Void) {
        switch self {
        case Canceled(let data): f(data: data)
        default: break
        }
    }
}

public struct IOChannel {
    let channel: dispatch_io_t

    public init(type: IOChannelType, fileDescriptor: Int32, queue: Queue = defaultQueue, cleanupHandler: IOChannelCleanUpResult -> Void) {
        channel = dispatch_io_create(type.value, fileDescriptor, queue.queue) { errorNumber in
            if errorNumber == 0 {
                cleanupHandler(.Success)
            } else {
                let error = DispatchError.fromErrorNumber(errorNumber)
                cleanupHandler(.Failure(error: error))
            }
        }!
    }

    public func read(offset: Int64 = 0, length: Int = Int.max, queue: Queue = defaultQueue, handler: IOChannelResult -> Void) {
        let mappedHandler = mapHandler(handler)
        dispatch_io_read(channel, offset, length, queue.queue, mappedHandler)
    }

    public func write(offset: Int64 = 0, length: Int = Int.max, queue: Queue = defaultQueue, data: [Int8], handler: IOChannelResult -> Void) {
        let data = dispatch_data_create(data, data.count, queue.queue, nil)
        let mappedHandler = mapHandler(handler)
        dispatch_io_write(channel, offset, data, queue.queue, mappedHandler)
    }

    private func mapHandler(handler: IOChannelResult -> Void)(done: Bool, data: dispatch_data_t!, errorNumber: Int32) {
        if errorNumber == ECANCELED {
            handler(.Canceled(data: bufferFromData(data)))
        } else if errorNumber != 0 {
            let error = DispatchError.fromErrorNumber(errorNumber)
            handler(.Failure(error: error))
        } else {
            handler(.Success(done: done, data: bufferFromData(data)))
        }
    }

    public func setLowWater(lowWater: Int) {
        dispatch_io_set_low_water(channel, lowWater)
    }

    public func setHighWater(highWater: Int) {
        dispatch_io_set_high_water(channel, highWater)
    }

    public var fileDescriptor: Int32 {
        return dispatch_io_get_descriptor(channel)
    }

    public func close() {
        dispatch_io_close(channel, DISPATCH_IO_STOP)
    }
}
