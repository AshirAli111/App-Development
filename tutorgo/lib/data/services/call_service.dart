import 'package:jitsi_meet_flutter_sdk/jitsi_meet_flutter_sdk.dart';
import 'chat_service.dart';

class CallService {
  final ChatService chatService;
  final String userName;

  CallService({required this.chatService, required this.userName});

  final _jitsiMeet = JitsiMeet();

  /// Generate a unique Jitsi room name
  String _generateRoomName(String chatId) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'tutorgo_${chatId}_$timestamp';
  }

  /// Start a video call - sends invite and joins room
  Future<String?> startVideoCall(String chatId) async {
    final roomName = _generateRoomName(chatId);

    // Send call_invite message
    await chatService.sendMessage(
      chatId,
      text: roomName,
      type: 'call_invite',
    );

    // Join the Jitsi room
    await _joinRoom(roomName, videoMuted: false);
    return roomName;
  }

  /// Start a voice call - sends invite and joins with video off
  Future<String?> startVoiceCall(String chatId) async {
    final roomName = _generateRoomName(chatId);

    // Send call_invite message
    await chatService.sendMessage(
      chatId,
      text: roomName,
      type: 'call_invite',
    );

    // Join with video muted
    await _joinRoom(roomName, videoMuted: true);
    return roomName;
  }

  /// Join an existing Jitsi room (e.g., accepting an incoming call)
  Future<void> joinCall(String roomName, {bool videoMuted = false}) async {
    await _joinRoom(roomName, videoMuted: videoMuted);
  }

  /// Send call_ended message to chat
  Future<void> endCall(String chatId) async {
    await chatService.sendMessage(
      chatId,
      text: 'Call ended',
      type: 'call_ended',
    );
  }

  /// Send call_declined message to chat
  Future<void> declineCall(String chatId) async {
    await chatService.sendMessage(
      chatId,
      text: 'Call declined',
      type: 'call_declined',
    );
  }

  Future<void> _joinRoom(String roomName, {required bool videoMuted}) async {
    final options = JitsiMeetConferenceOptions(
      room: roomName,
      serverURL: 'https://meet.jit.si',
      userInfo: JitsiMeetUserInfo(displayName: userName),
      configOverrides: {
        'startWithAudioMuted': false,
        'startWithVideoMuted': videoMuted,
        'prejoinPageEnabled': false,
      },
      featureFlags: {
        'welcomepage.enabled': false,
        'prejoinpage.enabled': false,
      },
    );

    await _jitsiMeet.join(options);
  }
}
