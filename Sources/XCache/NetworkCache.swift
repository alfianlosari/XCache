import Foundation

public enum NetworkFetchState<V> {
    case fetching(Task<V, Error>)
    case cached(V)
}

public actor NetworkCache<V: Decodable> {
    
    private let cache = Cache<NetworkFetchState<V>>()
    
    public var decoder: JSONDecoder
    public var urlSession: URLSession
    public var expiredTimestampProvider: ((V) -> Date?)?
    
    public init(decoder: JSONDecoder, urlSession: URLSession = URLSession.shared, expiredTimestampProvider: ( (V) -> Date?)? = nil) {
        self.decoder = decoder
        self.urlSession = urlSession
        self.expiredTimestampProvider = expiredTimestampProvider
    }
    
    public func set(expiredTimestampProvider: ((V) -> Date?)?) {
        self.expiredTimestampProvider = expiredTimestampProvider
    }
    
    public func value(from urlRequest: URLRequest) async throws -> V? {
        guard let urlString = urlRequest.url?.absoluteString else {
            throw "Invalid URL"
        }
        if let cached = cache[urlString] {
            switch cached {
            case .cached(let value):
                return value
            case .fetching(let task):
                return try await task.value
            }
        }
        
        let task = Task<V, Error> {
            let (data, response) = try await self.urlSession.data(for: urlRequest)
            guard let resp = response as? HTTPURLResponse, (200...299).contains(resp.statusCode) else {
                throw "Invalid response status code"
            }
            let value = try self.decoder.decode(V.self, from: data)
            return value
        }
        cache[urlString] = .fetching(task)
        do {
            let value = try await task.value
            cache.setValue(.cached(value), forKey: urlString, expiredTimestamp: expiredTimestampProvider?(value))
            return value
        } catch {
            cache[urlString] = nil
            throw error
        }
    }
    
    public func invalidateCache() {
        cache.removeAllValues()
    }
    
}

extension String: @retroactive Error {}

