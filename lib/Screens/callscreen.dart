import 'package:daily_call_app/utils/snackbar.dart';
import 'package:daily_flutter/daily_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../call_manager_bloc/call_events.dart';
import '../call_manager_bloc/call_manager_bloc.dart';
import '../call_manager_bloc/call_states.dart';
import '../widgets/video_tile.dart';

class CallScreen extends StatelessWidget {
  final TextEditingController _urlController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Daily Demo"),centerTitle: true,),
      body: BlocConsumer<CallBloc, CallRoomState>(
        listener: (context,state){
          if(state.errMsg!=null) {
            return ShowSnacBar(context: context,
                discrip: "Something went wrong",
                type: SnackBarType.Error);
          }

        },
        builder: (context, state) {
          if (state.status == CallState.joined) {
            return Stack(
              children: [
                Positioned.fill(
                  child: GridView.count(
                    crossAxisCount: 2,
                    padding: const EdgeInsets.all(8),
                    children: state.participants.values
                        .map((p) => VideoTile(
                      participant: p,
                      isActiveSpeaker: p.id == state.activeSpeakerId,
                    ))
                        .toList(),
                  ),
                ),

                // Optional: Timeline overlay at top
                Positioned(
                  top: 16,
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

                // Leave button overlay at bottom
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: ElevatedButton(
                    onPressed: () =>
                        context.read<CallBloc>().add(LeaveRequested()),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red, minimumSize: Size.fromHeight(50)),
                    child: const Text("Leave Call"),
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