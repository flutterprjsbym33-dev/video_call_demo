
import 'package:daily_flutter/daily_flutter.dart';

class CallRoomState {
  final CallState status;
  final Map<ParticipantId, Participant> participants;
  final ParticipantId? activeSpeakerId;
  final List<String> timeline;
  final String? errMsg;
  // ← add this

  CallRoomState({
    this.status = CallState.initialized,
    this.participants = const {},
    this.activeSpeakerId,
    this.timeline = const [],
    this.errMsg// ← add this
  });

  CallRoomState copyWith({
    CallState? status,
    Map<ParticipantId, Participant>? participants,
    ParticipantId? activeSpeakerId,
    List<String>? timeline,
    CallClient? client,
    String? errMsg,// ← add this
  }) => CallRoomState(
    status: status ?? this.status,
    participants: participants ?? this.participants,
    activeSpeakerId: activeSpeakerId ?? this.activeSpeakerId,
    timeline: timeline ?? this.timeline,
     errMsg: errMsg ?? this.errMsg
     // ← add this
  );
}