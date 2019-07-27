#if canImport(CoreNFC)
import Combine
import CoreNFC
import Foundation

final class CombineNFCNDEFReaderSessionDelegateProxy: NSObject, NFCNDEFReaderSessionDelegate, Publisher {
    typealias Output = NFCNDEFReaderSessionEvent
    typealias Failure = Error

    let subject = PassthroughSubject<NFCNDEFReaderSessionEvent, Error>()

    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        subject.send(completion: .failure(error))
    }

    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        subject.send(.didDetectNDEFs(messages: messages))
    }

    func readerSession(_ session: NFCNDEFReaderSession, didDetect tags: [NFCNDEFTag]) {
        subject.send(.didDetect(tags: tags))
    }

    func readerSessionDidBecomeActive(_ session: NFCNDEFReaderSession) {
        subject.send(.didBecomeActive)
    }

    func receive<S>(subscriber: S) where S : Subscriber, Failure == S.Failure, Output == S.Input {
        subject.subscribe(subscriber)
    }
}
#endif
