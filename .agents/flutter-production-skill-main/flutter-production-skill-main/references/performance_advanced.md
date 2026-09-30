# Performance Advanced — Isolates, DevTools Profiling, List Virtualization

## Isolates (Heavy Background Tasks)

### compute() — Simple One-Shot
```dart
// For one-off heavy operations — automatically spawns and kills isolate
Future<List<Server>> parseServersInBackground(String jsonString) =>
    compute(_parseServers, jsonString);

// Top-level or static function ONLY (no closures)
List<Server> _parseServers(String json) {
  final list = jsonDecode(json) as List;
  return list.map((e) => ServerModel.fromJson(e as Map<String, dynamic>)).toList();
}

// Other good compute() candidates:
Future<Uint8List> compressImage(Uint8List bytes) =>
    compute(_compressImageIsolate, bytes);

Future<String> encryptData(EncryptParams params) =>
    compute(_encryptIsolate, params);
```

### Long-Lived Isolate (Persistent Background Worker)
```dart
// For ongoing work: real-time processing, streaming, VPN speed tests
class IsolateWorker {
  Isolate? _isolate;
  SendPort? _sendPort;
  final _receivePort = ReceivePort();
  final _results = StreamController<dynamic>.broadcast();

  Stream<dynamic> get results => _results.stream;

  Future<void> start() async {
    _isolate = await Isolate.spawn(
      _workerEntryPoint,
      _receivePort.sendPort,
      debugName: 'BackgroundWorker',
    );

    _receivePort.listen((message) {
      if (message is SendPort) {
        _sendPort = message;
      } else {
        _results.add(message);
      }
    });

    // Wait for isolate to send its SendPort
    await _results.first;
  }

  void send(dynamic message) => _sendPort?.send(message);

  void stop() {
    _isolate?.kill(priority: Isolate.immediate);
    _receivePort.close();
    _results.close();
  }
}

@pragma('vm:entry-point')
void _workerEntryPoint(SendPort mainSendPort) {
  final receivePort = ReceivePort();
  mainSendPort.send(receivePort.sendPort);

  receivePort.listen((message) {
    // Process message and send result back
    final result = _heavyProcessing(message);
    mainSendPort.send(result);
  });
}
```

### Isolate.run() — Flutter 3.7+ Simplified API
```dart
// Cleaner than compute() for complex work
Future<ProcessedData> processData(RawData data) async {
  return Isolate.run(() {
    // Can use closures now (captured values are copied, not shared)
    final processed = data.items
        .where((item) => item.isValid)
        .map((item) => ProcessedItem.from(item))
        .toList();
    return ProcessedData(items: processed);
  });
}
```

### FlutterIsolate (Platform channels from isolate)
```dart
// flutter_isolate package — when you need plugins in background isolate
import 'package:flutter_isolate/flutter_isolate.dart';

@pragma('vm:entry-point')
void backgroundTask(String message) async {
  // Can call platform channels here
  await Firebase.initializeApp();
  await FirebaseMessaging.instance.getToken();
}

final isolate = await FlutterIsolate.spawn(backgroundTask, 'init');
```

---

## DevTools Profiling Guide

### Setup Profile Mode
```bash
# Always profile in profile mode — debug mode is ~5x slower
flutter run --profile

# Connect DevTools
flutter pub global activate devtools
flutter pub global run devtools
# Or: open http://localhost:9100 in browser after running
```

### CPU Profiler
```dart
// Add timeline markers for custom profiling spans
import 'dart:developer' as dev;

void expensiveOperation() {
  dev.Timeline.startSync('expensiveOperation', arguments: {'size': 1000});
  try {
    // ... your code
  } finally {
    dev.Timeline.finishSync();
  }
}

// Or use TimelineTask for async operations
final task = dev.TimelineTask()..start('fetchAndProcess');
await fetch();
task.instant('fetched');
await process();
task.finish();
```

### Frame Chart Analysis
```
Target: All frames < 16ms (60fps) or < 8ms (120fps)

Red frame    → UI thread jank (build/layout/paint took too long)
Shaded frame → Raster thread jank (GPU compositing too slow)

Fix UI jank:
  - Move work off build() — use compute() or isolates
  - Reduce widget rebuilds (const, select, Obx at leaf level)
  - Simplify widget trees

Fix Raster jank:
  - Add RepaintBoundary around complex animated widgets
  - Avoid saveLayer() in CustomPainter
  - Reduce overdraw (check with "Highlight repaints" in Inspector)
```

### Memory Leak Detection
```dart
// Enable leak tracking in debug/profile
import 'package:leak_tracker_flutter_testing/leak_tracker_flutter_testing.dart';

// In test:
testWidgets('no memory leaks', (tester) async {
  await tester.pumpWidget(const MyScreen());
  await tester.pumpAndSettle();
  // LeakTracker will report if objects aren't GC'd
});

// Manual: Watch Memory tab in DevTools
// - Heap grows without shrinking = likely leak
// - Take snapshots before/after user flow
// - Compare: look for classes with growing instance counts
```

### Widget Rebuild Inspector
```dart
// In main.dart (debug only)
void main() {
  // Shows colored borders on rebuilding widgets
  debugRepaintRainbowEnabled = false; // enable temporarily
  debugPrintRebuildDirtyWidgets = true; // console output
  runApp(const MyApp());
}
```

---

## List Virtualization (Large Data Sets)

### ListView.builder with Fixed Extent
```dart
// itemExtent = biggest perf win for uniform-height lists
ListView.builder(
  itemCount: 10000,
  itemExtent: 72.0,          // fixed height = O(1) layout
  cacheExtent: 500,          // pixels to cache outside viewport
  addRepaintBoundaries: true,
  addSemanticIndexes: false, // disable if not needed for a11y
  itemBuilder: (context, index) {
    return RepaintBoundary(
      child: ServerTile(server: servers[index]),
    );
  },
)
```

### SliverList with SliverChildBuilderDelegate
```dart
// For CustomScrollView — mixed content
CustomScrollView(
  slivers: [
    SliverAppBar(floating: true, title: const Text('Servers')),
    SliverPersistentHeader(
      pinned: true,
      delegate: FilterBarDelegate(),
    ),
    SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => ServerTile(server: servers[index]),
        childCount: servers.length,
        addRepaintBoundaries: true,
        addSemanticIndexes: true,
      ),
    ),
  ],
)
```

### Virtual Scroll for Huge Lists (100k+ items)
```dart
// scrollable_positioned_list — jump to arbitrary index instantly
ScrollablePositionedList.builder(
  itemCount: messages.length,
  itemScrollController: _scrollController,
  itemPositionsListener: _positionsListener,
  itemBuilder: (context, index) => MessageTile(message: messages[index]),
)

// Jump to item without rendering everything in between
await _scrollController.scrollTo(
  index: targetIndex,
  duration: const Duration(milliseconds: 300),
  curve: Curves.easeOut,
);
```

### Pagination + Prefetch
```dart
// Prefetch next page when user is 300px from the bottom
NotificationListener<ScrollMetricsNotification>(
  onNotification: (notification) {
    final metrics = notification.metrics;
    final threshold = metrics.maxScrollExtent - 300;
    if (metrics.pixels >= threshold && !isLoadingMore) {
      ref.read(serversProvider.notifier).loadNextPage();
    }
    return false;
  },
  child: ListView.builder(...),
)
```

### Windowed List (flutter_hooks + riverpod)
```dart
// Only render visible range + buffer
class WindowedList<T> extends HookConsumerWidget {
  final List<T> items;
  final Widget Function(BuildContext, T, int) itemBuilder;
  final int bufferSize;

  const WindowedList({
    required this.items,
    required this.itemBuilder,
    this.bufferSize = 10,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scrollController = useScrollController();
    final visibleStart = useState(0);

    useEffect(() {
      void listener() {
        final itemHeight = 72.0;
        final firstVisible =
            (scrollController.offset / itemHeight).floor();
        visibleStart.value =
            math.max(0, firstVisible - bufferSize);
      }
      scrollController.addListener(listener);
      return () => scrollController.removeListener(listener);
    }, [scrollController]);

    // Let ListView.builder handle the actual virtualization
    return ListView.builder(
      controller: scrollController,
      itemCount: items.length,
      itemExtent: 72,
      itemBuilder: (ctx, i) => itemBuilder(ctx, items[i], i),
    );
  }
}
```

---

## Image Memory Optimization
```dart
// Decode images at display size, not full resolution
CachedNetworkImage(
  imageUrl: url,
  memCacheWidth: (displayWidth * MediaQuery.of(context).devicePixelRatio).toInt(),
  memCacheHeight: (displayHeight * MediaQuery.of(context).devicePixelRatio).toInt(),
  maxWidthDiskCache: 800,
  maxHeightDiskCache: 800,
)

// Precache images before they're needed
@override
void didChangeDependencies() {
  super.didChangeDependencies();
  precacheImage(AssetImage('assets/onboarding_1.png'), context);
}

// Clear image cache when memory pressure hits
@override
void didReceiveMemoryWarning() {
  PaintingBinding.instance.imageCache.clear();
  PaintingBinding.instance.imageCache.clearLiveImages();
  super.didReceiveMemoryWarning();
}
```
