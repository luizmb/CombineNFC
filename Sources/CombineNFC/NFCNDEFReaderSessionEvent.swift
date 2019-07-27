import CoreNFC

public enum NFCNDEFReaderSessionEvent {
    case didDetectNDEFs(messages: [NFCNDEFMessage])
    case didDetect(tags: [NFCNDEFTag])
    case didBecomeActive
}
