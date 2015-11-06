// HTTPServer.swift
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

struct HTTPServerResponder : ResponderType {
    private let respondRequest: (request: HTTPRequest, completion: HTTPResponse -> Void) -> Void
    
    func respond(request: HTTPRequest, completion: HTTPResponse -> Void) {
        respondRequest(request: request, completion: completion)
    }
}

public struct HTTPServer {
    let server: RequestResponseServer<HTTPParser, HTTPServerResponder, HTTPSerializer>

    public init(port: Int, respond: (request: HTTPRequest, completion: HTTPResponse -> Void) -> Void) {
        self.server = RequestResponseServer(
            server: TCPServer(port: port),
            parser: HTTPParser(),
            responder: HTTPServerResponder(respondRequest: respond),
            serializer: HTTPSerializer()
        )
    }

    public func start(failure: ErrorType -> Void = HTTPServer.defaultFailureHandler) {
        server.start(failure: failure)
    }
    
    public func stop() {
        server.stop()
    }

    private static func defaultFailureHandler(error: ErrorType) -> Void {
        print("Error: \(error)")
    }
}
