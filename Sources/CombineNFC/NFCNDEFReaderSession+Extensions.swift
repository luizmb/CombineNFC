import Combine
import CoreNFC

extension NFCNDEFReaderSession {
    public static func combine(queue: DispatchQueue? = nil,
                               invalidateAfterFirstRead: Bool = false,
                               alertMessage: String? = nil) -> CombineNFCNDEFReaderSession {
        CombineNFCNDEFReaderSession(queue: queue,
                                    invalidateAfterFirstRead: invalidateAfterFirstRead,
                                    alertMessage: alertMessage)
    }
}
