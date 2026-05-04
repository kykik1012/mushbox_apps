import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart'; // MENGGUNAKAN SERVER CLIENT (ANDROID)

class MqttService {
  // 1. URL KEMBALI KE NATIVE (Tanpa wss:// dan /mqtt)
  final String _server = 'd602c79b764043ceb3efa34e5c0b1abc.s1.eu.hivemq.cloud';
  final String _topic = 'mewing/sensor/data';
  final String _username = 'angganyobait';
  final String _password = '1Sampai8';

  late MqttServerClient _client; // SERVER CLIENT

  MqttService() {
    String clientId = 'flutter_app_${DateTime.now().millisecondsSinceEpoch}';
    
    // 2. PORT KEMBALI KE 8883
    _client = MqttServerClient.withPort(_server, clientId, 8883);
  }

  Future<void> connect({
    required Function(Map<String, dynamic>) onMessageReceived,
    required Function onDisconnected,
  }) async {
    _client.secure = true; // WAJIB UNTUK PORT 8883
    _client.logging(on: true);
    _client.keepAlivePeriod = 60;
    _client.setProtocolV311();

    final connMess = MqttConnectMessage()
        .authenticateAs(_username, _password)
        .withClientIdentifier(_client.clientIdentifier);

    _client.connectionMessage = connMess;

    try {
      debugPrint('MQTT: Sedang menyambungkan ke HiveMQ Cloud (Native Android)...');
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
