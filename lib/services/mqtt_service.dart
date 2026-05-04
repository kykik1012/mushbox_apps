import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_browser_client.dart';

class MqttService {
  // 1. URL BERSIH: Hapus :8884 dari dalam string URL ini
  final String _server =
      'wss://d602c79b764043ceb3efa34e5c0b1abc.s1.eu.hivemq.cloud/mqtt';
  final String _topic = 'mewing/sensor/data';
  final String _username = 'angganyobait';
  final String _password = '1Sampai8';

  late MqttBrowserClient _client;

  MqttService() {
    String clientId = 'flutter_web_${DateTime.now().millisecondsSinceEpoch}';

    // 2. KUNCI FINAL: Gunakan .withPort secara eksplisit di sini
    _client = MqttBrowserClient.withPort(_server, clientId, 8884);

    // 3. Wajib untuk HiveMQ WebSockets agar tidak ditolak saat handshake
    _client.websocketProtocols = MqttClientConstants.protocolsSingleDefault;
  }
  // ... (lanjutan kodingan connect kamu di bawahnya tetap sama)

  Future<void> connect({
    required Function(Map<String, dynamic>) onMessageReceived,
    required Function onDisconnected,
  }) async {
    _client.logging(on: true);
    _client.keepAlivePeriod = 60;
    _client.setProtocolV311();

    // PESAN LOGIN DISEDERHANAKAN
    final connMess = MqttConnectMessage()
        .authenticateAs(_username, _password)
        .withClientIdentifier(_client.clientIdentifier);
    // .withWillQos dihapus agar tidak dianggap malformed packet oleh HiveMQ

    _client.connectionMessage = connMess;

    try {
      debugPrint('MQTT: Sedang menyambungkan ke HiveMQ Cloud (WebSockets)...');
      // ... (kode di bawahnya tetap sama)
      await _client.connect();
    } catch (e) {
      debugPrint('MQTT: Gagal connect - $e');
      _client.disconnect();
      onDisconnected();
      return;
    }

    if (_client.connectionStatus!.state == MqttConnectionState.connected) {
      debugPrint('MQTT: BERHASIL TERSAMBUNG!');

      _client.subscribe(_topic, MqttQos.atMostOnce);

      _client.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
        final recMess = c![0].payload as MqttPublishMessage;
        final payload = MqttPublishPayload.bytesToStringAsString(
          recMess.payload.message,
        );

        debugPrint('MQTT Data Masuk: $payload');
        try {
          final data = jsonDecode(payload);
          onMessageReceived(data);
        } catch (e) {
          debugPrint("MQTT: Format data dari ESP bukan JSON ($e)");
        }
      });

      _client.onDisconnected = () {
        debugPrint('MQTT: Terputus dari server');
        onDisconnected();
      };
    } else {
      debugPrint(
        'MQTT: Gagal tersambung, status: ${_client.connectionStatus!.state}',
      );
      _client.disconnect();
      onDisconnected();
    }
  }

  void disconnect() {
    _client.disconnect();
  }
}
