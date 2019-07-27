# CombineNFC

CoreNFC extensions to use it with Swift Combine framework.

```swift
NFCNDEFReaderSession
    .combine()
    .begin()
    .onDetectTags
    .mapError { $0 as Error }
    .flatMap { session, tags in session.connect(to: tags.first!.tag) }
    .flatMap { _, tag in tag.readNDEF().map { message in (message, tag) } }
    .handleEvents(receiveOutput: { message, _ in Swift.dump(message) })
    .flatMap { message, tag -> AnyPublisher<CombineNFCNDEFTag, Error> in
        message.records.append(NFCNDEFPayload(format: .empty, type: Data(), identifier: Data(), payload: Data()))
        return tag.writeNDEF(message).map { _ in tag }.eraseToAnyPublisher()
    }
    .flatMap { tag in tag.writeLock().map { _ in () } }
    .sink(
        receiveCompletion: { completion in
            guard case let .failure(error) = completion else { return }
            print(error.localizedDescription)
        },
        receiveValue: { _ in
            print("Success!")
        }
    ).store(in: &cancelBag)
```