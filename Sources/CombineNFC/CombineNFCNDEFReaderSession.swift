#if canImport(CoreNFC)
import Combine
import CoreNFC
import Foundation

public final class CombineNFCNDEFReaderSession {
    private let delegate: PassthroughSubject<NFCNDEFReaderSessionEvent, Error>
    private let session: NFCNDEFReaderSession

    init(queue: DispatchQueue? = nil, invalidateAfterFirstRead: Bool, alertMessage: String? = nil) {
        let proxy = CombineNFCNDEFReaderSessionDelegateProxy()
        delegate = proxy.subject
        session = NFCNDEFReaderSession(delegate: proxy, queue: queue, invalidateAfterFirstRead: invalidateAfterFirstRead)
        alertMessage.map { session.alertMessage = $0 }
    }

    @discardableResult
    public func begin() -> CombineNFCNDEFReaderSession {
        session.begin()
        return self
    }

    public func connect(to tag: NFCNDEFTag) -> Future<(CombineNFCNDEFReaderSession, CombineNFCNDEFTag), Error> {
        .init { [weak self] completion in
            self?.session.connect(to: tag) { error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                guard let self = self else { return }
                completion(.success((self, CombineNFCNDEFTag(tag: tag))))
            }
        }
    }

    @discardableResult
    public func restartPolling() -> CombineNFCNDEFReaderSession {
        session.restartPolling()
        return self
    }

    public var onEvent: AnyPublisher<NFCNDEFReaderSessionEvent, Error> {
        delegate.eraseToAnyPublisher()
    }

    public var onDetectNDEFsMessages: AnyPublisher<[NFCNDEFMessage], Never> {
        delegate
            .compactMap { event in
                guard case let .didDetectNDEFs(messages) = event else { return nil }
                return messages
            }
            .replaceError(with: nil)
            .compactMap { $0 }
            .eraseToAnyPublisher()
    }

    public var onDetectTags: AnyPublisher<(session: CombineNFCNDEFReaderSession, tags: [CombineNFCNDEFTag]), Never> {
        delegate
            .compactMap { [weak self] event in
                guard case let .didDetect(tags) = event else { return nil }
                guard let self = self else { return nil }
                return (session: self, tags: tags.map(CombineNFCNDEFTag.init))
            }
            .replaceError(with: nil)
            .compactMap { $0 }
            .eraseToAnyPublisher()
    }

    public var onBecomeActive: AnyPublisher<Void, Never> {
        delegate
            .compactMap { event in
                guard case .didBecomeActive = event else { return nil }
                return ()
            }
            .replaceError(with: nil)
            .compactMap { $0 }
            .eraseToAnyPublisher()
    }
}
