import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:convert';

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
  FlutterSoundRecorder?
      _recorder; // FlutterSoundRecorder object to manage audio recording.
  bool _isRecording = false; // Flag to keep track of recording status.

  @override
  void initState() {
    super.initState();
    _recorder =
        FlutterSoundRecorder(); // Initializing the FlutterSoundRecorder.
    _recorder!.openAudioSession(); // Opening the audio session.
  }

  @override
  void dispose() {
    _recorder!
        .closeAudioSession(); // Closing the audio session when the widget is disposed.
    super.dispose();
  }

  Future<void> _startRecording() async {
    final tempDir =
        await getTemporaryDirectory(); // Getting the temporary directory path.
    final audioPath =
        '${tempDir.path}/recording.wav'; // Creating the path for the audio file.
    await _recorder!
        .startRecorder(toFile: audioPath); // Starting the audio recording.

    setState(() {
      _isRecording = true; // Updating the recording status to true.
    });
  }

  Future<void> _stopRecording() async {
    final result =
        await _recorder!.stopRecorder(); // Stopping the audio recording.

    if (result != null && result.isNotEmpty) {
      final audioPath = result; // Getting the path of the recorded audio.

      // Make POST request to API
      final response = await http.post(
        Uri.parse(
            'http://10.47.166.34:5000/api/flutter'), // API endpoint to send the audio data.
        headers: {
          HttpHeaders.contentTypeHeader:
              'audio/wav', // Setting the content type for the request.
        },
        body: File(audioPath)
            .readAsBytesSync(), // Reading the audio file as bytes and sending it in the request body.
      );

      if (response.statusCode == 200) {
        // Successfully uploaded audio
        print('Audio uploaded successfully');
      } else {
        // Failed to upload audio
        print('Failed to upload audio');
      }
    } else {
      print('Error: Audio file path is empty or null.');
    }

    setState(() {
      _isRecording = false; // Updating the recording status to false.
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
              onPressed: _isRecording
                  ? _stopRecording
                  : _startRecording, // Handling the button press for recording and stopping.
              icon: Icon(
                _isRecording
                    ? Icons.stop
                    : Icons
                        .mic, // Displaying different icons based on recording status.
                color: _isRecording
                    ? Colors.red
                    : Colors
                        .blue, // Changing the icon color based on recording status.
              ),
            ),
          ],
        ),
      ),
    );
  }
}
