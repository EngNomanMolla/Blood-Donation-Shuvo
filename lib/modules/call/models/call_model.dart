class AgoraTokenData {
  final String appId;
  final String channelName;
  final String rtcToken;
  final int uid;
  final int recipientId;
  final int remainingCallMinutes;
  final int tokenTtlSeconds;
  final String expiresAt;
  final bool pushNotificationSent;

  const AgoraTokenData({
    required this.appId,
    required this.channelName,
    required this.rtcToken,
    required this.uid,
    this.recipientId = 0,
    required this.remainingCallMinutes,
    required this.tokenTtlSeconds,
    required this.expiresAt,
    this.pushNotificationSent = false,
  });

  factory AgoraTokenData.fromJson(Map<String, dynamic> json) {
    return AgoraTokenData(
      appId: json['app_id'] ?? '',
      channelName: json['channel_name'] ?? '',
      rtcToken: json['rtc_token'] ?? '',
      uid: json['uid'] is int ? json['uid'] : int.tryParse(json['uid']?.toString() ?? '0') ?? 0,
      recipientId: json['recipient_id'] is int ? json['recipient_id'] : int.tryParse(json['recipient_id']?.toString() ?? '0') ?? 0,
      remainingCallMinutes: json['remaining_call_minutes'] ?? 0,
      tokenTtlSeconds: json['token_ttl_seconds'] ?? 0,
      expiresAt: json['expires_at'] ?? '',
      pushNotificationSent: json['push_notification_sent'] == true || json['push_notification_sent'] == 1,
    );
  }
}
