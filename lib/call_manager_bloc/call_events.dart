import 'package:daily_flutter/daily_flutter.dart';

abstract class CallEvent {}
class JoinRequested extends CallEvent { final String url; JoinRequested(this.url); }
class LeaveRequested extends CallEvent {}

class ChangeSpeaker extends CallEvent {
  Participant p;
  ChangeSpeaker({required this.p});

}

class MakeTimeLineEmpty extends CallEvent{}
