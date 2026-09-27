/// 🛡️ PERF: كاش LRU (Least Recently Used) محدود السعة.
///
/// يُستخدم لتخزين قيم مؤقتة (مثل روابط الصوت المُجهَّزة مسبقاً) مع ضمان
/// حدّ أعلى ثابت لاستهلاك الذاكرة، بدلاً من `Map` غير محدود ينمو بلا سقف
/// مع طول جلسة القراءة.
///
/// يعتمد `LinkedHashMap` (وهو الترتيب الافتراضي لخرائط Dart) للحفاظ على
/// ترتيب الإدراج، فأقدم عنصر هو أول عنصر يُحذَف عند تجاوز السعة.
class LruCache<K, V> {
  LruCache({required this.maximumSize})
    : assert(maximumSize > 0, 'maximumSize must be greater than zero'),
      _entries = <K, V>{};

  /// الحد الأقصى لعدد العناصر المحفوظة في الكاش.
  final int maximumSize;

  final Map<K, V> _entries;

  /// عدد العناصر المحفوظة حالياً.
  int get length => _entries.length;

  bool get isEmpty => _entries.isEmpty;

  bool get isNotEmpty => _entries.isNotEmpty;

  /// يعيد القيمة المخزّنة مع تحديث ترتيبها كـ "الأحدث استخداماً".
  V? operator [](K key) {
    final value = _entries.remove(key);
    if (value == null) {
      return null;
    }
    // إعادة الإدراج في النهاية = أحدث استخداماً.
    _entries[key] = value;
    return value;
  }

  bool containsKey(K key) => _entries.containsKey(key);

  /// يخزّن قيمة ويُزيل أقدم العناصر عند تجاوز السعة.
  void operator []=(K key, V value) {
    // إزالة أولاً لضمان تحديث الترتيب حتى لو كان المفتاح موجوداً.
    _entries.remove(key);
    _entries[key] = value;
    _evictOverflow();
  }

  /// يخزّن القيمة فقط إن لم تكن موجودة (يُبقي القيمة الحالية كما هي).
  V putIfAbsent(K key, V Function() ifAbsent) {
    final existing = this[key];
    if (existing != null) {
      return existing;
    }
    final created = ifAbsent();
    this[key] = created;
    return created;
  }

  V? remove(K key) => _entries.remove(key);

  void clear() => _entries.clear();

  void _evictOverflow() {
    while (_entries.length > maximumSize) {
      // أول مفتاح في الترتيب = الأقدم استخداماً.
      final oldestKey = _entries.keys.first;
      _entries.remove(oldestKey);
    }
  }
}
