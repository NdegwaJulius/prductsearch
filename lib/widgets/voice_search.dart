// File: lib/widgets/voice_search_widget.dart

import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../config/app_theme.dart';

class VoiceSearchWidget extends StatefulWidget {
  final Function(String) onSearch;

  const VoiceSearchWidget({Key? key, required this.onSearch}) : super(key: key);

  @override
  _VoiceSearchWidgetState createState() => _VoiceSearchWidgetState();
}

class _VoiceSearchWidgetState extends State<VoiceSearchWidget> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _text = '';
  bool _isAvailable = false;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _initSpeechRecognition();
  }

  void _initSpeechRecognition() async {
    try {
      _isAvailable = await _speech.initialize(
        onStatus: (status) => print('onStatus: $status'),
        onError: (errorNotification) => print('onError: $errorNotification'),
      );
    } catch (e) {
      print('Failed to initialize speech recognition: $e');
      _isAvailable = false;
    }
    if (mounted) setState(() {});
  }

  void _listen() async {
    if (!_isAvailable) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Speech Recognition Unavailable'),
          content: Text('Speech recognition is not available on this device. Please try text search instead.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    if (!_isListening) {
      setState(() => _isListening = true);
      _speech.listen(
        onResult: (result) {
          setState(() {
            _text = result.recognizedWords;
          });
        },
      );
    } else {
      setState(() => _isListening = false);
      _speech.stop();
      if (_text.isNotEmpty) {
        widget.onSearch(_text);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton.icon(
          onPressed: _listen,
          icon: Icon(_isListening ? Icons.mic : Icons.mic_none),
          label: Text(_isListening ? 'Listening...' : 'Start Voice Search'),
          style: ElevatedButton.styleFrom(
            backgroundColor: _isListening ? AppTheme.purplePrimary : AppTheme.greenPrimary,
            foregroundColor: Colors.white,
          ),
        ),
        SizedBox(height: 10),
        Text(
          _text,
          style: TextStyle(
            fontSize: 16,
            color: AppTheme.greenDark,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }
}