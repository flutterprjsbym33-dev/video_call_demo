import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:daily_flutter/daily_flutter.dart';
import 'package:intl/intl.dart';

import 'call_events.dart';
import 'call_states.dart';

class _LogEvent extends CallEvent { final String message; _LogEvent(this.message); }
class _UpdateParticipants extends CallEvent {}



class CallBloc extends Bloc<CallEvent, CallRoomState> {
  late final CallClient _client;
  bool _isReady = false;

  CallBloc() : super(CallRoomState()) {

    // Handles logging events into timeline
    on<_LogEvent>(_onLogEvent);

    // Handles active speaker change
    on<ChangeSpeaker>(_onChangeSpeaker);

    // Clears timeline
    on<MakeTimeLineEmpty>(_onClearTimeline);

    // Updates participants and call state
    on<_UpdateParticipants>(_onUpdateParticipants);

    // Handles join request
    on<JoinRequested>(_onJoinRequested);

    // Handles leaving call
    on<LeaveRequested>(_onLeaveRequested);

    _setup();
  }

  // Adds log message with timestamp
  void _onLogEvent(_LogEvent event, Emitter<CallRoomState> emit) {
    final time = DateFormat('HH:mm:ss').format(DateTime.now());
    emit(state.copyWith(
      timeline: ["[$time] ${event.message}", ...state.timeline],
    ));
  }

  // Updates active speaker ID
  void _onChangeSpeaker(ChangeSpeaker event, Emitter<CallRoomState> emit) {
    emit(state.copyWith(activeSpeakerId: event.p.id));
  }

  // Clears timeline list
  void _onClearTimeline(MakeTimeLineEmpty event, Emitter<CallRoomState> emit) {
    emit(state.copyWith(timeline: []));
  }

  // Updates participants and call status from client
  void _onUpdateParticipants(_UpdateParticipants event, Emitter<CallRoomState> emit) {
    emit(state.copyWith(
      status: _client.callState,
      participants: _client.participants.all,
    ));
  }

  // Handles joining the call
  Future<void> _onJoinRequested(JoinRequested event, Emitter<CallRoomState> emit) async {
    if (!_isReady) {
      emit(state.copyWith(errMsg: "Internet Connection Error"));
      return;
    }

    emit(state.copyWith(status: CallState.joining));
    _addLog("Room URL set: ${event.url}");

    try {
      await _client.join(url: Uri.parse(event.url));
    } on SocketException{
      emit(state.copyWith(
        errMsg: "No Internet Connection",
        status: CallState.initialized,
      ));
    }
    catch (e) {
      emit(state.copyWith(
        errMsg: e.toString(),
        status: CallState.initialized,
      ));
    }
  }

  // Handles leaving the call and resets state
  Future<void> _onLeaveRequested(LeaveRequested event, Emitter<CallRoomState> emit) async {
    await _client.leave();

    emit(state.copyWith(
      timeline: [],
      participants: {},
      activeSpeakerId: null,
      status: CallState.initialized,
    ));
  }

  // Helper to add logs
  void _addLog(String msg) => add(_LogEvent(msg));

  // Initializes client and listens to events
  Future<void> _setup() async {
    _client = await CallClient.create();
    _isReady = true;

    _addLog("App Initialized");

    _client.events.listen((event) {
      event.whenOrNull(
        callStateUpdated: (state) {
          if (state.state == CallState.left) {
            _addLog("Call ended");
          } else {
            _addLog("Call State: ${state.state}");
          }
          add(_UpdateParticipants());
        },
        participantJoined: (p) {
          _addLog("Participant joined: ${p.info.username}");
          add(_UpdateParticipants());
        },
        participantLeft: (p) {
          _addLog("Participant left: ${p.info.username}");
          add(_UpdateParticipants());
        },
        participantUpdated: (p) {
          add(_UpdateParticipants());
        },
        activeSpeakerChanged: (p) {
          if (p != null) {
            add(ChangeSpeaker(p: p));
            _addLog("Active Speaker: ${p.info.username}");
          }
        },
        error: (error) => _addLog("Error: $error"),
      );
    });
  }

  @override
  Future<void> close() {
    _client.dispose();
    return super.close();
  }
}