enum DataFetchPolicy {
  cacheFirst,
  networkFirst,
  cacheOnly,
  networkOnly,
  refresh,
}

extension DataFetchPolicyX on DataFetchPolicy {
  bool get canReadCache {
    return switch (this) {
      DataFetchPolicy.cacheFirst ||
      DataFetchPolicy.networkFirst ||
      DataFetchPolicy.cacheOnly => true,
      DataFetchPolicy.networkOnly || DataFetchPolicy.refresh => false,
    };
  }

  bool get canReadNetwork {
    return switch (this) {
      DataFetchPolicy.cacheFirst ||
      DataFetchPolicy.networkFirst ||
      DataFetchPolicy.networkOnly ||
      DataFetchPolicy.refresh => true,
      DataFetchPolicy.cacheOnly => false,
    };
  }

  bool get shouldRefreshCache {
    return this == DataFetchPolicy.refresh ||
        this == DataFetchPolicy.networkFirst;
  }
}
