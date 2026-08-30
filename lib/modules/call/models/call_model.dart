class AgoraTokenData {
  final String appId;
  final String channelName;
  final String rtcToken;
  final int uid;
  final int remainingCallMinutes;
  final int tokenTtlSeconds;
  final String expiresAt;

  const AgoraTokenData({
    required this.appId,
    required this.channelName,
    required this.rtcToken,
    required this.uid,
    required this.remainingCallMinutes,
    required this.tokenTtlSeconds,
    required this.expiresAt,
  });

  factory AgoraTokenData.fromJson(Map<String, dynamic> json) {
    return AgoraTokenData(
      appId: json['app_id'] ?? '',
      channelName: json['channel_name'] ?? '',
      rtcToken: json['rtc_token'] ?? '',
      uid: json['uid'] is int ? json['uid'] : int.tryParse(json['uid']?.toString() ?? '0') ?? 0,
      remainingCallMinutes: json['remaining_call_minutes'] ?? 0,
      tokenTtlSeconds: json['token_ttl_seconds'] ?? 0,
      expiresAt: json['expires_at'] ?? '',
    );
  }
}
