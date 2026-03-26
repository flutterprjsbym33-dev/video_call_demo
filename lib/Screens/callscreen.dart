import 'package:daily_call_app/utils/snackbar.dart';
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
  final _formKey = GlobalKey<FormState>();



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
      // Optional: show that permissions are already granted
      ShowSnacBar(
        context: context,
        discrip: "Camera and microphone permissions are already granted.",
        type: SnackBarType.Success,
      );
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _checkAndRequestPermissions();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Daily Demo"),centerTitle: true,),
      body: BlocConsumer<CallBloc, CallRoomState>(
        listener: (context,state){
          if(state.errMsg!=null) {
            return ShowSnacBar(context: context,
                discrip: state.errMsg!,
                type: SnackBarType.Error);
          }
        },
        builder: (context, state) {
          if (state.status == CallState.joined) {
            return Stack(
              children: [
                Positioned.fill(
                  child: Stack(
                    children: [
                      Builder(
                        builder: (context) {
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
                              Positioned.fill(
                                child: VideoTile(
                                  participant: remote,
                                  isActiveSpeaker:
                                  remote.id == state.activeSpeakerId,
                                ),
                              ),
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
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),

                Positioned(
                  bottom: 100,
                  left: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: state.timeline
                          .map((t) => Text(t,
                        style: const TextStyle(
                            fontSize: 12, color: Colors.white),
                      ))
                          .toList(),
                    ),
                  ),
                ),







                Positioned(
                  bottom: 16,
                  left: 120,
                  right: 120,
                  child:
                     ElevatedButton(
                      onPressed: () =>
                          context.read<CallBloc>().add(LeaveRequested()),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red, minimumSize: Size.fromHeight(50)),
                      child: const Icon(Icons.call_end),
                    ),
                  ),

              ],
            );
          }

          // JOIN SCREEN
          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextFormField(
                  controller: _urlController,
                  decoration:
                  InputDecoration(labelText: "Daily Room URL",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15)
                  )),
                ),
                const SizedBox(height: 20),
                 ElevatedButton(
                   style: ElevatedButton.styleFrom(
                     backgroundColor: Colors.green,
                     shape: RoundedRectangleBorder(
                       borderRadius: BorderRadius.circular(15)
                     )
                   ),
                  onPressed: () {
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
                  child: state.status == CallState.joining
                      ?Text("Joining....") : Text('Join Call',style: TextStyle(color: Colors.white),),
                 ),
              ],
            ),
          );
        },
      ),
    );
  }
}