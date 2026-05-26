import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  static final SocketService _instance = SocketService._internal();

  factory SocketService() => _instance;

  SocketService._internal();

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  IO.Socket? _socket;

  IO.Socket? get socket => _socket;

  bool get isConnected => _socket?.connected ?? false;

  Future<void> connect() async {
    if (_socket != null && _socket!.connected) {
      return;
    }

    final token = await _storage.read(key: "token") ?? "";

    _socket = IO.io(
      "http://192.168.75.22:5000",

      IO.OptionBuilder()
          .setTransports(["websocket"])
          .enableAutoConnect()
          .setExtraHeaders({"Authorization": "Bearer $token"})
          .enableReconnection()
          .setReconnectionAttempts(5)
          .setReconnectionDelay(2000)
          .build(),
    );

    _socket!.onConnect((_) {
      print(
        "SOCKET CONNECTED: "
        "${_socket!.id}",
      );
    });

    _socket!.onDisconnect((_) {
      print("SOCKET DISCONNECTED");
    });

    _socket!.onConnectError((data) {
      print(
        "SOCKET CONNECT ERROR: "
        "$data",
      );
    });

    _socket!.onError((data) {
      print(
        "SOCKET ERROR: "
        "$data",
      );
    });
  }

  void disconnect() {
    _socket?.disconnect();

    _socket?.dispose();

    _socket = null;
  }

  void joinConversation(String conversationId) {
    _socket?.emit("joinConversation", conversationId);
  }

  void sendMessage({
    required String conversationId,
    required String senderId,
    required String content,
  }) {
    _socket?.emit("sendMessage", {
      "conversationId": conversationId,

      "senderId": senderId,

      "content": content,
    });
  }

  void onReceiveMessage(Function(dynamic data) callback) {
    _socket?.on("receiveMessage", callback);
  }

  void removeListener(String event) {
    _socket?.off(event);
  }
}
