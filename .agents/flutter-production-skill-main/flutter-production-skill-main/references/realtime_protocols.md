# Realtime Protocols — MQTT, Socket.IO, SignalR & WebSocket Advanced

## MQTT (IoT, VPN control plane, lightweight pub/sub)

```yaml
dependencies:
  mqtt_client: ^10.2.1
```

```dart
@lazySingleton
class MqttService {
  MqttServerClient? _client;
  final _messageController = StreamController<MqttMessage>.broadcast();

  Stream<MqttMessage> get messages => _messageController.stream;

  Future<void> connect({
    required String broker,
    required String clientId,
    int port = 1883,           // 8883 for TLS
    String? username,
    String? password,
    bool useTls = true,
  }) async {
    _client = MqttServerClient.withPort(broker, clientId, port);

    _client!
      ..logging(on: kDebugMode)
      ..keepAlivePeriod = 30
      ..connectTimeoutPeriod = 10000
      ..onDisconnected = _onDisconnected
      ..onConnected = _onConnected
      ..onSubscribed = (topic) => log.d('MQTT subscribed: $topic')
      ..autoReconnect = true;

    if (useTls) {
      _client!.secure = true;
      _client!.securityContext = SecurityContext.defaultContext;
    }

    final connMessage = MqttConnectMessage()
        .withClientIdentifier(clientId)
        .withWillQos(MqttQos.atLeastOnce)
        .startClean();

    if (username != null) {
      connMessage.authenticateAs(username, password);
    }

    _client!.connectionMessage = connMessage;

    try {
      await _client!.connect();
    } on NoConnectionException catch (e) {
      log.e('MQTT connection failed', e);
      _client!.disconnect();
      rethrow;
    }

    // Listen to all incoming messages
    _client!.updates!.listen((messages) {
      for (final msg in messages) {
        final payload = msg.payload as MqttPublishMessage;
        final data = MqttPublishPayload.bytesToStringAsString(
            payload.payload.message);
        _messageController.add(MqttMessage(
          topic: msg.topic,
          payload: data,
          timestamp: DateTime.now(),
        ));
      }
    });
  }

  void subscribe(String topic, {MqttQos qos = MqttQos.atLeastOnce}) {
    _client?.subscribe(topic, qos);
  }

  void publish(String topic, String message,
      {MqttQos qos = MqttQos.atLeastOnce}) {
    final builder = MqttClientPayloadBuilder()..addString(message);
    _client?.publishMessage(topic, qos, builder.payload!);
  }

  void unsubscribe(String topic) => _client?.unsubscribe(topic);

  void disconnect() {
    _client?.disconnect();
    _messageController.close();
  }

  void _onConnected() => log.i('MQTT connected');
  void _onDisconnected() {
    log.w('MQTT disconnected');
    // autoReconnect handles reconnection
  }
}

class MqttMessage {
  final String topic;
  final String payload;
  final DateTime timestamp;
  const MqttMessage({
    required this.topic,
    required this.payload,
    required this.timestamp,
  });
}

// Usage — subscribe to VPN status topic
mqttService.subscribe('vpn/${userId}/status');
mqttService.messages
    .where((m) => m.topic == 'vpn/${userId}/status')
    .listen((msg) {
      final data = jsonDecode(msg.payload);
      vpnController.updateStatus(data['status']);
    });
```

---

## Socket.IO (Real-time bidirectional, Node.js backends)

```yaml
dependencies:
  socket_io_client: ^2.0.3+1
```

```dart
@lazySingleton
class SocketService {
  late final IO.Socket _socket;
  final _eventController = StreamController<SocketEvent>.broadcast();

  Stream<SocketEvent> get events => _eventController.stream;
  bool get isConnected => _socket.connected;

  void connect({required String serverUrl, required String authToken}) {
    _socket = IO.io(
      serverUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .enableReconnection()
          .setReconnectionAttempts(5)
          .setReconnectionDelay(1000)
          .setExtraHeaders({'Authorization': 'Bearer $authToken'})
          .setAuth({'token': authToken})
          .build(),
    );

    _socket
      ..onConnect((_) {
        log.i('Socket connected: ${_socket.id}');
        _emit(SocketEvent.connected());
      })
      ..onDisconnect((reason) {
        log.w('Socket disconnected: $reason');
        _emit(SocketEvent.disconnected(reason.toString()));
      })
      ..onConnectError((data) {
        log.e('Socket connect error: $data');
        _emit(SocketEvent.error(data.toString()));
      })
      ..onReconnect((_) => log.i('Socket reconnected'))
      ..on('message', (data) => _emit(SocketEvent.message(data)))
      ..on('notification', (data) => _emit(SocketEvent.notification(data)))
      ..on('user_joined', (data) => _emit(SocketEvent.userJoined(data)))
      ..connect();
  }

  void emit(String event, [dynamic data]) {
    if (!isConnected) {
      log.w('Socket not connected — queueing: $event');
      return;
    }
    _socket.emit(event, data);
  }

  void emitWithAck(String event, dynamic data,
      {required void Function(dynamic) onAck}) {
    _socket.emitWithAck(event, data, ack: onAck);
  }

  void on(String event, void Function(dynamic) handler) =>
      _socket.on(event, handler);

  void off(String event) => _socket.off(event);

  void disconnect() {
    _socket.disconnect();
    _eventController.close();
  }

  void _emit(SocketEvent event) => _eventController.add(event);
}

sealed class SocketEvent {}
class SocketConnected extends SocketEvent {
  SocketConnected();
}
class SocketDisconnected extends SocketEvent {
  final String reason;
  SocketDisconnected(this.reason);
}
class SocketError extends SocketEvent {
  final String message;
  SocketError(this.message);
}
class SocketMessage extends SocketEvent {
  final dynamic data;
  SocketMessage(this.data);
}
class SocketNotification extends SocketEvent {
  final dynamic data;
  SocketNotification(this.data);
}
class SocketUserJoined extends SocketEvent {
  final dynamic data;
  SocketUserJoined(this.data);
}

extension SocketEventFactory on SocketEvent {
  static SocketEvent connected() => SocketConnected();
  static SocketEvent disconnected(String r) => SocketDisconnected(r);
  static SocketEvent error(String m) => SocketError(m);
  static SocketEvent message(dynamic d) => SocketMessage(d);
  static SocketEvent notification(dynamic d) => SocketNotification(d);
  static SocketEvent userJoined(dynamic d) => SocketUserJoined(d);
}
```

---

## SignalR (.NET backends)

```yaml
dependencies:
  signalr_netcore: ^2.1.3
```

```dart
@lazySingleton
class SignalRService {
  late final HubConnection _connection;

  Future<void> connect(String hubUrl, String accessToken) async {
    _connection = HubConnectionBuilder()
        .withUrl(
          hubUrl,
          options: HttpConnectionOptions(
            accessTokenFactory: () async => accessToken,
            transport: HttpTransportType.webSockets,
            skipNegotiation: true,
          ),
        )
        .withAutomaticReconnect(retryDelays: [0, 2000, 5000, 10000, null])
        .build();

    _connection.onclose((error) => log.w('SignalR closed: $error'));
    _connection.onreconnecting((error) => log.d('SignalR reconnecting'));
    _connection.onreconnected((id) => log.i('SignalR reconnected: $id'));

    await _connection.start();
    log.i('SignalR connected');
  }

  void on<T>(String method, void Function(T) handler) {
    _connection.on(method, (args) {
      if (args != null && args.isNotEmpty) {
        handler(args[0] as T);
      }
    });
  }

  Future<dynamic> invoke(String method, {List<Object>? args}) =>
      _connection.invoke(method, args: args);

  Future<void> send(String method, {List<Object>? args}) =>
      _connection.send(method: method, args: args);

  Future<void> disconnect() => _connection.stop();
}

// Usage example:
signalRService.on<Map<String, dynamic>>('ReceiveMessage', (data) {
  final message = ChatMessage.fromJson(data);
  chatController.addMessage(message);
});

// Send
await signalRService.invoke('SendMessage', args: [chatId, messageText]);
```

---

## WebSocket (Raw — for custom protocols)

```dart
@lazySingleton
class WebSocketService {
  WebSocketChannel? _channel;
  Timer? _heartbeatTimer;
  Timer? _reconnectTimer;
  String? _lastUrl;
  Map<String, String>? _lastHeaders;
  bool _intentionalClose = false;

  final _incomingController = StreamController<dynamic>.broadcast();
  final _statusController = StreamController<WsStatus>.broadcast();

  Stream<dynamic> get stream => _incomingController.stream;
  Stream<WsStatus> get status => _statusController.stream;

  Future<void> connect(String url,
      {Map<String, String>? headers}) async {
    _lastUrl = url;
    _lastHeaders = headers;
    _intentionalClose = false;

    try {
      _channel = WebSocketChannel.connect(Uri.parse(url),
          protocols: headers?.values.toList());

      _statusController.add(WsStatus.connected);
      _startHeartbeat();

      _channel!.stream.listen(
        (data) {
          final parsed = data is String ? jsonDecode(data) : data;
          _incomingController.add(parsed);
        },
        onError: (error) {
          log.e('WebSocket error', error);
          _statusController.add(WsStatus.error);
          _scheduleReconnect();
        },
        onDone: () {
          if (!_intentionalClose) {
            _statusController.add(WsStatus.disconnected);
            _scheduleReconnect();
          }
        },
      );
    } catch (e) {
      log.e('WebSocket connect failed', e);
      _scheduleReconnect();
    }
  }

  void send(Map<String, dynamic> data) {
    _channel?.sink.add(jsonEncode(data));
  }

  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      send({'type': 'ping', 'ts': DateTime.now().millisecondsSinceEpoch});
    });
  }

  void _scheduleReconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 3), () {
      if (_lastUrl != null && !_intentionalClose) {
        connect(_lastUrl!, headers: _lastHeaders);
      }
    });
  }

  void close() {
    _intentionalClose = true;
    _heartbeatTimer?.cancel();
    _reconnectTimer?.cancel();
    _channel?.sink.close();
    _statusController.add(WsStatus.disconnected);
  }
}

enum WsStatus { connected, disconnected, error }
```

---

## Protocol Selection Guide

| Protocol | Best For | Backend | Flutter Package |
|----------|----------|---------|----------------|
| **MQTT** | IoT, VPN control, low bandwidth | Any MQTT broker (Mosquitto, AWS IoT, HiveMQ) | `mqtt_client` |
| **Socket.IO** | Chat, live feeds, games | Node.js + Socket.IO | `socket_io_client` |
| **SignalR** | Enterprise real-time, .NET APIs | ASP.NET Core | `signalr_netcore` |
| **WebSocket** | Custom protocols, binary data | Any | `web_socket_channel` |
| **Firebase** | Simple real-time, no infra | Firebase | `cloud_firestore` |
| **Supabase Realtime** | Postgres change events | Supabase | `supabase_flutter` |
