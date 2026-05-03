import 'dart:convert';
import 'package:mqtt_client/mqtt_client.dart';
// 1. IMPORT DIUBAH KE BROWSER CLIENT
import 'package:mqtt_client/mqtt_browser_client.dart'; 

class MqttService {
  // 2. URL DITAMBAH 'wss://' DI DEPAN DAN '/mqtt' DI BELAKANG
  final String _server = 'wss://a6da7a9ae5cd4fbcabb35e78fd0f5f4d.s1.eu.hivemq.cloud/mqtt'; 
  final String _topic = 'mushbox/unij/sensor';
  
  final String _username = 'device_mushbox';
  final String _password = 'Rahasia123!';

  // 3. CLASS DIUBAH KE BROWSER CLIENT
  late MqttBrowserClient _client;

  MqttService() {
    // 4. PORT UNTUK WEB ADALAH 8884
    _client = MqttBrowserClient.withPort(_server, 'flutter_mushbox_web', 8884);
  }

  Future<void> connect(Function(Map<String, dynamic>) onDataReceived) async {
    _client.logging(on: true); 
    _client.keepAlivePeriod = 60;
    
    final connMess = MqttConnectMessage()
        .authenticateAs(_username, _password)
        .withWillQos(MqttQos.atLeastOnce);
    _client.connectionMessage = connMess;

    try {
      print('Menyambungkan ke HiveMQ Cloud (Via Web)...');
      await _client.connect();
      print('MQTT Tersambung ke Cloud via Web!');
      
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