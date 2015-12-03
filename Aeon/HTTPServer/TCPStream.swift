// TCPStream.swift
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

import TCPIP
import GrandCentralDispatch
import Stream

final class TCPStream: StreamType {
    let socket: TCPClientSocket
    var channel: IOChannel!
    var piped: Bool = false

    init(socket: TCPClientSocket) {
        self.socket = socket

        channel = IOChannel(type: .Stream, fileDescriptor: socket.fileDescriptor) { result in
            result.failure { error in
                print(error)
            }
            if !self.piped {
                socket.close()
            }
        }

        channel.setLowWater(1)
    }

    func receive(completion: (Void throws -> [Int8]) -> Void) {
        channel.read { result in
            result.success { done, data in
                completion({ data })
            }
            result.failure { error in
                completion({ throw error })
            }
        }
    }

    func send(data: [Int8], completion: (Void throws -> Void) -> Void) {
        channel.write(data: data) { result in
            result.success { done, _ in
                if done {
                    completion({})
                }
            }
            result.failure { error in
                completion({ throw error })
            }
        }
    }

    func close() {
        channel.close()
    }
    
    func pipe() -> StreamType {
        piped = true
        channel.close()
        return TCPStream(socket: socket)
    }
}
