import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:huaweicloud_iot_device_sdk/src/time_util.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class DeviceClient {
  final String host;
  final int port;
  final String deviceId;
  final String secret;
  final int keepAlivePeriod;
  final bool useTls;
  final bool disableTlsVerify;
  final bool disableTlsHostnameVerify;
  final bool disableHmacSha256Verify;
  late MqttServerClient _client;

  DeviceClient({
    required this.host,
    required this.port,
    required this.deviceId,
    required this.secret,
    this.keepAlivePeriod = 120,
    this.useTls = false,
    this.disableTlsVerify = false,
    this.disableTlsHostnameVerify = false,
    this.disableHmacSha256Verify = false,
  }) {
    _client = MqttServerClient.withPort(host, deviceId, port);
    _client.keepAlivePeriod = 120;
    if (useTls) {
      _client.secure = true;
      _client.securityContext = SecurityContext.defaultContext;
      if (disableTlsVerify) {
        _client.onBadCertificate = (Object cert) => true;
      }
    }
  }

  Future<void> connect() async {
    final timestamp = TimeUtil.getTimestamp();
    final signatureType = disableHmacSha256Verify ? '0' : '1';
    final clientId = '${deviceId}_0_${signatureType}_$timestamp';
    final password = Hmac(sha256, utf8.encode(timestamp))
        .convert(utf8.encode(secret))
        .toString();

    var mqttConnectMessage = MqttConnectMessage()
        .withClientIdentifier(clientId)
        .authenticateAs(deviceId, password)
        .withProtocolName("MQTT")
        .withProtocolVersion(4)
        .withWillQos(MqttQos.atMostOnce);
    _client.connectionMessage = mqttConnectMessage;
    await _client.connect();
  }

  Future<void> reportDeviceMessage({
    String? objectDeviceId,
    String? name,
    String? id,
    required dynamic content,
  }) async {
    objectDeviceId ??= deviceId;

    final topic = '\$oc/devices/$objectDeviceId/sys/messages/up';

    final messagePayload = {
      if (name != null) 'name': name,
      if (id != null) 'id': id,
      'content': content is String ? content : jsonEncode(content),
    };

    final mqttPublishMessage = MqttClientPayloadBuilder();
    mqttPublishMessage.addString(jsonEncode(messagePayload));

    _client.publishMessage(
        topic, MqttQos.atLeastOnce, mqttPublishMessage.payload!);
  }

  Future<void> disconnect() async {
    _client.disconnect();
  }
}
