// File: lib/widgets/voice_conversation_widget.dart

import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart'; // Import the package
import '../config/app_theme.dart';

class VoiceConversationWidget extends StatefulWidget {
  final Function(String) onSearch;

  const VoiceConversationWidget({Key? key, required this.onSearch}) : super(key: key);

  @override
  _VoiceConversationWidgetState createState() => _VoiceConversationWidgetState();
}

class _VoiceConversationWidgetState extends State<VoiceConversationWidget> with SingleTickerProviderStateMixin {
  late stt.SpeechToText _speech;
  late FlutterTts _flutterTts; // Create an instance of FlutterTts
  bool _isListening = false;
  String _text = '';
  bool _isAvailable = false;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _flutterTts = FlutterTts(); // Initialize FlutterTts
    _initSpeechRecognition();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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

  Future<void> _speak(String text) async {
    await _flutterTts.setLanguage("en-US"); // Set the language
    await _flutterTts.setPitch(1.0); // Set the pitch
    await _flutterTts.speak(text); // Speak the text
  }

  void _listen() async {
    if (!_isAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Speech recognition is not available on this device.')),
      );
      return;
    }

    if (!_isListening) {
      try {
        setState(() => _isListening = true);
        _animationController.repeat(reverse: true);
        await _speech.listen(
          onResult: (result) {
            setState(() {
              _text = result.recognizedWords;
            });
          },
        );
      } catch (e) {
        print('Error listening: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error starting voice recognition. Please try again.')),
        );
        setState(() => _isListening = false);
        _animationController.stop();
      }
    } else {
      setState(() => _isListening = false);
      _animationController.stop();
      await _speech.stop();
      if (_text.isNotEmpty) {
        widget.onSearch(_text);
        await _speak("You searched for: $_text"); // Give feedback to the user
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Talk to Search',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.greenDark),
          ),
          SizedBox(height: 20),
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isListening ? AppTheme.purplePrimary : AppTheme.greenPrimary,
                  boxShadow: [
                    BoxShadow(
                      color: _isListening ? AppTheme.purplePrimary.withOpacity(0.5) : AppTheme.greenPrimary.withOpacity(0.5),
                      blurRadius: 10 * _animationController.value,
                      spreadRadius: 5 * _animationController.value,
                    ),
                  ],
                ),
                child: IconButton(
                  icon: Icon(_isListening ? Icons.mic : Icons.mic_none, color: Colors.white, size: 40),
                  onPressed: _listen,
                ),
              );
            },
          ),
          SizedBox(height: 20),
          Text(
            _isListening ? 'Listening...' : 'Tap the microphone to start',
            style: TextStyle(fontSize: 18, color: AppTheme.greenDark),
          ),
          SizedBox(height: 20),
          Text(
            _text,
            style: TextStyle(fontSize: 16, color: AppTheme.purpleDark, fontStyle: FontStyle.italic),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
