import Foundation

open class CacheEntry<V> {
    
    public let key: String
    public let value: V
    public let expiredTimestamp: Date?
    
    public init(key: String, value: V, expiredTimestamp: Date? = nil) {
        self.key = key
        self.value = value
        self.expiredTimestamp =  expiredTimestamp
    }
    
    open func isCacheExpired(after date: Date = .now) -> Bool {
        guard let expiredTimestamp else {
            return false
        }
        return date > expiredTimestamp
    }
    
}
