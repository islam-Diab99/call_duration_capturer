import 'package:call_duration_task/widgets/last_call_details.dart';
import 'package:flutter/material.dart';
import 'package:call_log/call_log.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';



class LastCallDurationPage extends StatefulWidget {
  const LastCallDurationPage({super.key});


  _LastCallDurationPageState createState() => _LastCallDurationPageState();
}

class _LastCallDurationPageState extends State<LastCallDurationPage> {
  late Stream<String> _callDurationStream;

  @override
  void initState() {
    super.initState();
    _callDurationStream = _createCallDurationStream();
  }

  Stream<String> _createCallDurationStream() async* {
    var status = await _requestPermissions();
    if (!status.isGranted) {
      yield 'Permission denied';
      return;
    }

    while (true) {
      await Future.delayed(const Duration(seconds: 2));
      yield await _getLastCallDetails();
    }
  }

  Future<PermissionStatus> _requestPermissions() async {
    var status = await Permission.phone.request();
    if (status.isGranted) {
      return status;
    } else {
      var statuses = await [
        Permission.contacts,
        Permission.phone,
      ].request();
      return statuses[Permission.phone]!;
    }
  }

  Future<String> _getLastCallDetails() async {
    var thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    var callLogs = await CallLog.query(
      dateFrom: thirtyDaysAgo.millisecondsSinceEpoch,
    );

    if (callLogs.isNotEmpty) {
      var lastCall = callLogs.firstWhere(
          (call) => call.callType?.name != 'missed' && call.callType?.name != 'rejected',
          orElse: () => callLogs.first);

      return '${_formatDuration(lastCall.duration)} seconds';
    } else {
      return 'No call logs found';
    }
  }

  String _formatDuration(int? seconds) {
    if (seconds == null) return '0 seconds';

    int minutes = (seconds / 60).floor();
    int remainingSeconds = seconds % 60;
    return '$minutes minutes and $remainingSeconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Last Call Duration'),
      ),
      body: Center(
        child: StreamBuilder<String>(
          stream: _callDurationStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (!snapshot.hasData || snapshot.data == null) {
              return const Text('No call duration available');
            } else {
              return LastCallDetails(snapshot.data);
            }
          },
        ),
      ),
    );
  }
}
