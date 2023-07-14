import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Audio Recorder',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  FlutterSoundRecorder? _recorder;
  bool _isRecording = false;

  @override
  void initState() {
    super.initState();
    _recorder = FlutterSoundRecorder();
    _recorder!.openAudioSession();
  }

  @override
  void dispose() {
    _recorder!.closeAudioSession();
    super.dispose();
  }

  Future<void> _startRecording() async {
    final tempDir = await getTemporaryDirectory();
    final audioPath = '${tempDir.path}/recording.wav';
    await _recorder!.startRecorder(toFile: audioPath);

    setState(() {
      _isRecording = true;
    });
  }

  Future<void> _stopRecording() async {
    final result = await _recorder!.stopRecorder();

    if (result != null) {
      final audioPath = result;

      // Make POST request to API
      final response = await http.post(
        Uri.parse('API_URL'),
        headers: {
          HttpHeaders.contentTypeHeader: 'audio/wav',
        },
        body: File(audioPath).readAsBytesSync(),
      );

      if (response.statusCode == 200) {
        // Successfully uploaded audio
        print('Audio uploaded successfully');
      } else {
        // Failed to upload audio
        print('Failed to upload audio');
      }
    }

    setState(() {
      _isRecording = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Audio Recorder'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Audio Recording',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 20),
            IconButton(
              iconSize: 80,
              onPressed: _isRecording ? _stopRecording : _startRecording,
              icon: Icon(
                _isRecording ? Icons.stop : Icons.mic,
                color: _isRecording ? Colors.red : Colors.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
