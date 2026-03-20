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

    on<_LogEvent>((event, emit) {
      final time = DateFormat('HH:mm:ss').format(DateTime.now());
      emit(state.copyWith(
        timeline: ["[$time] ${event.message}", ...state.timeline],
      ));
    });

    on<_UpdateParticipants>((event, emit) {
      emit(state.copyWith(
        status: _client.callState,
        participants: _client.participants.all,
      ));
    });

    on<JoinRequested>((event, emit) async {
      if (!_isReady) {
        emit(state.copyWith(errMsg: "Client not initialized yet"));
        return;
      }

      emit(state.copyWith(status: CallState.joining));

      _addLog("Room URL set: ${event.url}");

      try {
        await _client.join(url: Uri.parse(event.url));
      } catch (e) {
        emit(state.copyWith(
          errMsg: e.toString(),
          status: CallState.initialized,
        ));
      }
    });

    on<LeaveRequested>((event, emit) async {
      await _client.leave();
      _addLog("Left call");
    });

    _setup();
  }

  void _addLog(String msg) => add(_LogEvent(msg));

  Future<void> _setup() async {
    _client = await CallClient.create();
    _isReady = true;

    _addLog("App Initialized");

    _client.events.listen((event) {
      event.whenOrNull(
        callStateUpdated: (state) {
          _addLog("Call State: ${state.state}");
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
        activeSpeakerChanged: (p) {
          emit(this.state.copyWith(activeSpeakerId: p?.id));
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