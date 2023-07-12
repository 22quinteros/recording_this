import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  FlutterSoundRecorder? _audioRecorder;
  bool _isRecording = false;
  String _recordingPath = '';

  @override
  void initState() {
    super.initState();
    _initializeAudioRecorder();
  }

  void _initializeAudioRecorder() async {
    _audioRecorder = FlutterSoundRecorder();

    await _audioRecorder!.openAudioSession();
    await _audioRecorder!.setSubscriptionDuration(Duration(milliseconds: 10));
  }

  void _startRecording() async {
    final appDir = await getApplicationDocumentsDirectory();
    final recordingName = DateTime.now().toString() + '.wav';
    final recordingPath = '${appDir.path}/$recordingName';

    setState(() {
      _isRecording = true;
      _recordingPath = recordingPath;
    });

    await _audioRecorder!.startRecorder(toFile: recordingPath);
  }

  void _stopRecording() async {
    setState(() {
      _isRecording = false;
    });

    final recording = File(_recordingPath);
    final stream = http.ByteStream(Stream.castFrom(recording.openRead()));
    final request = http.MultipartRequest('POST', Uri.parse('YOUR_API_URL'));

    final multipartFile = http.MultipartFile(
        'audio', stream, recording.lengthSync(),
        filename: _recordingPath);
    request.files.add(multipartFile);

    final response = await request.send();
    if (response.statusCode == 200) {
      print('Audio uploaded successfully');
    } else {
      print('Failed to upload audio. Status code: ${response.statusCode}');
    }

    await _audioRecorder!.stopRecorder();
  }

  @override
  void dispose() {
    _audioRecorder!.closeAudioSession();
    _audioRecorder = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Audio Recorder'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isRecording) Text('Recording...') else Text('Not Recording'),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _isRecording ? _stopRecording : _startRecording,
                child:
                    Text(_isRecording ? 'Stop Recording' : 'Start Recording'),
              ),
              SizedBox(height: 16.0),
              Text('Recording Path:'),
              Text(_recordingPath),
            ],
          ),
        ),
      ),
    );
  }
}
