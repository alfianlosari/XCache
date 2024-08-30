# XCache Swift Generic & Network Request Cache

![Alt text](https://i.imghippo.com/files/56Clq1725020693.png "image")

In-Memory Generic and Network Request Cache for Swift with support of optional expiration date timestamp 

## Supported Platforms

- iOS/iPadOS 15
- macOS 13
- tvOS 15
- watchOS 8
- visionOS 1.x

## Installation

### Swift Package Manager
- File > Swift Packages > Add Package Dependency
- Copy and paste this URL

```swift
https://github.com/alfianlosari/XCache
```

### Import
Import to your project source file.

```swift
import XCache
```

### Generic Cache

Use this to store any Swift type that you want in the cache. It uses in-memory NSCache under the hood to automatically purge the data when memory is low.

```swift
let cache = Cache<[Articles]>()
let articles = try await api.fetchArticles()

// Cache array of articles using unique string key with subscript 
cache["myKey"] = articles

// Get articles array from cache given the unique string key if exists
let cachedArticles = cache["myKey"] // Optional if exists 
```

You can also set expiration timestamp when setting the value of a key using the `setValue` method

```swift
// Set expiration timestamp to 10 minutes from now
cache.setValue(articles, forKey: urlString, expiredTimestamp:                 Calendar.current.date(byAdding: .minute, value: 10, to: .now))
```

To invalidate all the values in cache, you can simply invoke
```swift
cache.removeAllValues()
```


### Network Request Cache

You can use `NetworkCache` to store network request as a cache. It uses Swift `actor` type to handle multithreaded access. When resource for the given URL is being fetched for the first time, it stores the progress using Swift Task and store the final value in the cache. When a another thread access while its still fetching, it will get the ongoing fetching task from the cache to avoid multiple network requests for the same URL. 

```swift

let postsURL = URL(string: "https://dummyjson.com/posts")!
let cache: NetworkCache<PostResponse> = .init()

// Run this in async context
let postResponse = try await cache.value(from: URLRequest(url: postsURL))
```

To set the expiration timestamp, you can invoke `setExpirationTimestampHandlerIfNeeded`. Its a closure with parameter containing the fetched response and return type of optional Date. This is useful if the expiration value is dynamic from the server side as you can retrieve it from the response`

```swift
// Run this in async context
await cache.set { resp in
    // use value from the response or provide your own timestamp 
    resp.expirationTimestamp
}
```

To invalidate the cache, you can simply invoke
```swift
cache.invalidateCache()
```
