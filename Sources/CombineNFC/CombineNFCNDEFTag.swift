import Combine
import CoreNFC
import Foundation

public struct CombineNFCNDEFTag {
    public let tag: NFCNDEFTag

    public func queryNDEFStatus() -> Future<(status: NFCNDEFStatus, capacity: Int), Error> {
        .init { completion in
            self.tag.queryNDEFStatus { status, capacity, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }

                completion(.success((status: status, capacity: capacity)))
            }
        }
    }

    public func readNDEF() -> Future<NFCNDEFMessage, Error> {
        .init { completion in
            self.tag.readNDEF { message, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }

                if let message = message {
                    completion(.success(message))
                    return
                }
            }
        }
    }

    public func writeNDEF(_ ndefMessage: NFCNDEFMessage) -> Future<Void, Error> {
        .init { completion in
            self.tag.writeNDEF(ndefMessage) { error in
                if let error = error {
                    completion(.failure(error))
                    return
                }

                completion(.success(()))
            }
        }
    }

    public func writeLock() -> Future<Void, Error> {
        .init { completion in
            self.tag.writeLock { error in
                if let error = error {
                    completion(.failure(error))
                    return
                }

                completion(.success(()))
            }
        }
    }
}
