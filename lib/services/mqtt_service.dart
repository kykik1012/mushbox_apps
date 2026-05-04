import 'dart:convert';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart'; 

class MqttService {
  final String _server = 'd602c79b764043ceb3efa34e5c0b1abc.s1.eu.hivemq.cloud'; 
  final String _topic = 'mewing/sensor/data';
  
  final String _username = 'angganyobait';
  final String _password = '1Sampai8';

  late MqttServerClient _client;

  MqttService() {
    // 1. PERBAIKAN: Buat Client ID selalu unik agar tidak ditolak server jika restart aplikasi
    String uniqueId = 'flutter_mushbox_${DateTime.now().millisecondsSinceEpoch}';
    _client = MqttServerClient.withPort(_server, uniqueId, 8883);
  }

  Future<void> connect(Function(Map<String, dynamic>) onDataReceived) async {
    _client.secure = true;
    _client.logging(on: true); 
    _client.keepAlivePeriod = 60;
    
    // 2. PERBAIKAN: Wajib untuk HiveMQ Cloud! Paksa gunakan protokol versi 3.1.1
    _client.setProtocolV311();
    
    final connMess = MqttConnectMessage()
        .authenticateAs(_username, _password)
        .withWillQos(MqttQos.atLeastOnce);
    _client.connectionMessage = connMess;

    try {
      print('Menyambungkan ke HiveMQ Cloud (Native Android)...');
      await _client.connect();
      
      // JIKA TULISAN INI MUNCUL DI CONSOLE, BERARTI SUKSES 100%
      print('MQTT Tersambung ke Cloud!'); 
      
      _client.subscribe(_topic, MqttQos.atMostOnce);
      
      _client.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
        final MqttPublishMessage recMess = c![0].payload as MqttPublishMessage;
        final String pt = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
        
        try {
          final data = jsonDecode(pt);
          onDataReceived(data); 
        } catch (e) {
          print('Gagal parse JSON: $e');
        }
      });
    } catch (e) {
      print('MQTT Gagal tersambung: $e');
      _client.disconnect();
    }
  }
}