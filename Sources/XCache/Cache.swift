import Foundation

open class Cache<V> {
    
    fileprivate let cache: NSCache<NSString, CacheEntry<V>> = .init()
    
    public init() {}
    
    open subscript(_ key: String) -> V? {
        get { value(forKey: key) }
        set { setValue(newValue, forKey: key)}
    }

    open func setValue(_ value: V?, forKey key: String, expiredTimestamp: Date? = nil) {
        if let value = value {
            let cacheEntry = CacheEntry(key: key, value: value, expiredTimestamp: expiredTimestamp)
              cache.setObject(cacheEntry, forKey: key as NSString)
        } else {
            removeValue(forKey: key)
        }
    }
    
    open func value(forKey key: String) -> V? {
        guard let entry = cache.object(forKey: key as NSString) else {
            return nil
        }
        
        guard !entry.isCacheExpired(after: Date()) else {
            removeValue(forKey: key)
            print("Cache: expired cache data for \(key)")
            return nil
        }
        
        return entry.value
    }
    
    open func removeValue(forKey key: String) {
        cache.removeObject(forKey: key as NSString)
    }
    
    open func removeAllValues() {
        cache.removeAllObjects()
    }
}
