# Performance & Optimization — 2026

## Widget Optimization

### const Everything
```dart
// ✅ compile-time constant, never rebuilt
const SizedBox(height: 16)
const Icon(Icons.wifi)
const Text('Connect')

// ❌ Bad — new instance every build
SizedBox(height: 16)
```

### Avoid Rebuilding Parents
```dart
// ❌ Bad — entire parent rebuilds
class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text('Count: ${counter.value}'), // triggers full rebuild
      ExpensiveListWidget(),
    ]);
  }
}

// ✅ Good — only leaf rebuilds
class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      CounterText(),                    // isolated
      const ExpensiveListWidget(),      // never rebuilds
    ]);
  }
}

// GetX: Obx() at the smallest possible level
// Riverpod: watch in leaf widgets only
// BLoC: BlocSelector for granular rebuilds
BlocSelector<CounterBloc, CounterState, int>(
  selector: (state) => state.count,
  builder: (context, count) => Text('Count: $count'),
)
```

---

## Lists & Lazy Loading

```dart
// Always use builder; set itemExtent when height is fixed
ListView.builder(
  itemCount: items.length,
  itemExtent: 72.0,           // fixed height = massive GPU perf boost
  addRepaintBoundaries: true,
  physics: const BouncingScrollPhysics(),
  itemBuilder: (context, index) => RepaintBoundary(
    child: ItemTile(item: items[index]),
  ),
)

// Separated list (preferred over manually adding Dividers)
ListView.separated(
  itemCount: items.length,
  physics: const BouncingScrollPhysics(),
  separatorBuilder: (_, __) => const Divider(height: 1),
  itemBuilder: (_, i) => ItemTile(item: items[i]),
)
```

### Pagination
```dart
@riverpod
class ServersNotifier extends _$ServersNotifier {
  static const _pageSize = 20;
  int _page = 1;
  bool _hasMore = true;

  @override
  Future<List<Server>> build() async => _fetchPage(1);

  Future<void> loadMore() async {
    if (!_hasMore) return;
    final current = state.valueOrNull ?? [];
    final newItems = await _fetchPage(++_page);
    _hasMore = newItems.length == _pageSize;
    state = AsyncData([...current, ...newItems]);
  }

  Future<List<Server>> _fetchPage(int page) =>
      ref.read(serverRepositoryProvider).getServers(page: page, perPage: _pageSize);
}

// Trigger pagination in UI
NotificationListener<ScrollNotification>(
  onNotification: (notification) {
    if (notification is ScrollEndNotification &&
        notification.metrics.extentAfter < 200) {
      ref.read(serversNotifierProvider.notifier).loadMore();
    }
    return false;
  },
  child: ListView.builder(...),
)
```

---

## Image Optimization

```dart
// cached_network_image — always; never Image.network directly
CachedNetworkImage(
  imageUrl: server.flagUrl,
  width: 32,
  height: 32,
  memCacheWidth: 64,   // cache at 2x for retina
  memCacheHeight: 64,
  placeholder: (_, __) => const SizedBox(width: 32, height: 32),
  errorWidget: (_, __, ___) => const Icon(Icons.flag),
)

// SVG vectors — flutter_svg
SvgPicture.asset('assets/flags/pk.svg', width: 24)
```

---

## RepaintBoundary

```dart
// Wrap anything that animates independently
RepaintBoundary(child: AnimatedConnectionOrb())

// Always wrap animated list items
ListView.builder(
  itemBuilder: (_, i) => RepaintBoundary(
    child: AnimatedServerTile(server: servers[i]),
  ),
)
```

---

## Compute for Heavy Processing

```dart
// Heavy JSON off the main thread
Future<List<Server>> parseServers(String jsonString) =>
    compute(_parseIsolate, jsonString);

List<Server> _parseIsolate(String jsonString) {
  final json = jsonDecode(jsonString) as List;
  return json.map((e) => ServerModel.fromJson(e as Map<String, dynamic>)).toList();
}
```

---

## Memory Management — Zero Leaks Policy

```dart
// StatefulWidget — always dispose
@override
void dispose() {
  _animationController.dispose();
  _textController.dispose();
  _scrollController.dispose();
  _timer?.cancel();
  _subscription?.cancel();
  super.dispose();
}

// GetX — onClose()
@override
void onClose() {
  _timer?.cancel();
  _subscription?.cancel();
  super.onClose();
}

// Riverpod — ref.onDispose
@riverpod
Stream<List<Server>> servers(Ref ref) {
  final controller = StreamController<List<Server>>();
  final sub = _startListening(controller);
  ref.onDispose(() {
    sub.cancel();
    controller.close();
  });
  return controller.stream;
}
```

---

## Crash-Safe Async Guards

```dart
// Always check mounted before setState after async gap
Future<void> _loadData() async {
  final data = await _repo.fetchData();
  if (!mounted) return;        // ← guard every time
  setState(() => _data = data);
}

// GetX — check isClosed before updating Rx
Future<void> fetchServers() async {
  final result = await _repo.getServers();
  if (isClosed) return;        // ← guard for GetX
  servers.value = result.fold((_) => [], (s) => s);
}

// Avoid Future.microtask abuse; prefer WidgetsBinding
WidgetsBinding.instance.addPostFrameCallback((_) {
  if (mounted) _initSomething();
});
```

---

## Anti-Crash Patterns

```dart
// Safe list access
final item = list.elementAtOrNull(index);

// Safe map access
final value = map['key'] as String?;

// Safe cast
final model = data is Map<String, dynamic> ? ServerModel.fromJson(data) : null;

// Null-safe navigation with context.mounted
if (context.mounted) {
  Navigator.pop(context);
}

// Stream listen with error handler — always
_stream.listen(
  (data) => _handle(data),
  onError: (e, st) => log.e('Stream error', e, st),
  cancelOnError: false,
);
```

---

## Build & Size Optimization

```bash
flutter build apk --release --split-per-abi     # smaller per-ABI APKs
flutter build appbundle --release               # AAB for Play Store
flutter build apk --release --analyze-size      # size breakdown
```

```groovy
// android/app/build.gradle
buildTypes {
  release {
    minifyEnabled true
    shrinkResources true
    proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
  }
}
```

---

## DevTools Checklist

1. `flutter run --profile`
2. Open DevTools → Frame chart → keep frames <16ms (60fps) / <8ms (120fps)
3. Memory tab — check for leaks after navigation
4. Widget Inspector → enable "Highlight Repaints"
5. Performance Overlay: `showPerformanceOverlay: true` in MaterialApp

---

## Performance Checklist

- [ ] All static widgets use `const`
- [ ] `ListView.builder` everywhere (never `ListView` with `.map`)
- [ ] `itemExtent` set where item height is fixed
- [ ] `CachedNetworkImage` for all network images
- [ ] `compute()` for JSON parsing >500 items
- [ ] `RepaintBoundary` wraps animated widgets and list items
- [ ] All controllers/streams/timers disposed in `dispose()`/`onClose()`
- [ ] `mounted`/`isClosed` checked after every `await`
- [ ] `Obx`/`BlocSelector`/`select` at smallest possible widget
- [ ] No `print()` anywhere (use logger)
- [ ] `Colors.X.withValues(alpha: v)` — never `withOpacity`
- [ ] Release APK profiled with DevTools
