class UserModel {
  final String id;
  final String username;
  final String email;
  final List<DeviceModel> devices;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.devices,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      devices: (json['devices'] as List?)
              ?.map((d) => DeviceModel.fromJson(d))
              .toList() ??
          [],
    );
  }
}

class DeviceModel {
  final String id;
  final String deviceId;
  final String publicKey;
  final String keyExchangeBase;
  final String? deviceName;
  final bool isActive;

  DeviceModel({
    required this.id,
    required this.deviceId,
    required this.publicKey,
    required this.keyExchangeBase,
    this.deviceName,
    this.isActive = true,
  });

  factory DeviceModel.fromJson(Map<String, dynamic> json) {
    return DeviceModel(
      id: json['id'],
      deviceId: json['deviceId'],
      publicKey: json['publicKey'],
      keyExchangeBase: json['keyExchangeBase'],
      deviceName: json['deviceName'],
      isActive: json['isActive'] ?? true,
    );
  }
}
