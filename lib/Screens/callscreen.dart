import 'package:daily_call_app/utils/snackbar.dart';
import 'package:daily_call_app/widgets/call_end_button.dart';
import 'package:daily_call_app/widgets/join_button.dart';
import 'package:daily_call_app/widgets/show_call_logs.dart';
import 'package:daily_call_app/widgets/url_textfield.dart';
import 'package:daily_flutter/daily_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../call_manager_bloc/call_events.dart';
import '../call_manager_bloc/call_manager_bloc.dart';
import '../call_manager_bloc/call_states.dart';
import '../utils/permisson_service.dart';
import '../widgets/video_tile.dart';

class CallScreen extends StatefulWidget {
  @override
  _CallScreenState createState() => _CallScreenState();
}


class _CallScreenState extends State<CallScreen> {
  final TextEditingController _urlController = TextEditingController();




  Future<void> _checkAndRequestPermissions() async {

    bool hasPermissions = await PermissionService.checkPermissions();

    if (!hasPermissions && mounted) {

      bool permissionsGranted = await PermissionService.requestPermissions();

      if (!permissionsGranted && mounted) {
        ShowSnacBar(
          context: context,
          discrip: "Camera and microphone permissions are required for calls",
          type: SnackBarType.Error,
        );
      } else if (permissionsGranted && mounted) {
        ShowSnacBar(
          context: context,
          discrip: "Permissions granted! You can now join calls.",
          type: SnackBarType.Success,
        );
      }
    } else if (hasPermissions && mounted) {

      ShowSnacBar(
        context: context,
        discrip: "Camera and microphone permissions are already granted.",
        type: SnackBarType.Success,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _checkAndRequestPermissions();

  }

  @override
  void dispose() {
    super.dispose();
    _urlController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Daily Demo"),
        centerTitle: true,
      ),
      body: BlocConsumer<CallBloc, CallRoomState>(
        listener: (context, state) {
          if (state.errMsg != null) {
            debugPrint(state.errMsg);
            ShowSnacBar(
              context: context,
              discrip: "Something went wrong",
              type: SnackBarType.Error,
            );
          }
        },
        builder: (context, state) {
          // ================= JOINED SCREEN =================
          if (state.status == CallState.joined) {
            final participants = state.participants.values.toList();

            if (participants.isEmpty) {
              return const Center(child: Text("No participants"));
            }

            final local = participants.firstWhere(
                  (p) => p.info.isLocal,
              orElse: () => participants.first,
            );

            final remoteList =
            participants.where((p) => !p.info.isLocal).toList();

            final remote =
            remoteList.isNotEmpty ? remoteList.first : local;

            return Stack(
              children: [
                // Remote video (full screen)
                Positioned.fill(
                  child: VideoTile(
                    participant: remote,
                    isActiveSpeaker:
                    remote.id == state.activeSpeakerId,
                  ),
                ),

                // Local video (small preview)
                Positioned(
                  bottom: 80,
                  right: 10,
                  width: 120,
                  height: 180,
                  child: VideoTile(
                    participant: local,
                    isActiveSpeaker:
                    local.id == state.activeSpeakerId,
                  ),
                ),

                // Call Logs
                Positioned(
                  bottom: 100,
                  left: 16,
                  right: 16,
                  child: ShowCallLogs(timeLine: state.timeline),
                ),

                // End Call Button
                Positioned(
                  bottom: 16,
                  left: 120,
                  right: 120,
                  child: CallEndButton(
                    onTap: () {
                      context.read<CallBloc>().add(LeaveRequested());
                    },
                  ),
                ),
              ],
            );
          }

          // ================= JOIN SCREEN =================
          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                UrlTextfield(urlController: _urlController),
                const SizedBox(height: 20),

                JoinButton(
                  onTap: state.status == CallState.joining
                      ? (){}
                      : () {
                    if (_urlController.text.isEmpty) {
                      ShowSnacBar(
                        context: context,
                        discrip: "URL cannot be empty",
                        type: SnackBarType.Error,
                      );
                      return;
                    }

                    context.read<CallBloc>().add(
                      JoinRequested(_urlController.text),
                    );
                  },
                  hint: state.status == CallState.joining
                      ? "Joining"
                      : "Join",
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}