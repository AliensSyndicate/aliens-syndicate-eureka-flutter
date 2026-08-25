import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

enum LessonNarrationState { stopped, playing, paused }

abstract interface class LessonNarrationController implements Listenable {
  LessonNarrationState get state;
  Future<void> toggle(String content);
  Future<void> stop();
  void dispose();
}

/// Coordena a leitura em voz alta do conteúdo da aula.
class LessonNarrationService extends ChangeNotifier
    implements LessonNarrationController {
  LessonNarrationService({FlutterTts? textToSpeech})
    : _textToSpeech = textToSpeech ?? FlutterTts() {
    _registerHandlers();
  }

  final FlutterTts _textToSpeech;
  LessonNarrationState _state = LessonNarrationState.stopped;
  bool _configured = false;
  bool _isDisposed = false;

  @override
  LessonNarrationState get state => _state;

  void _registerHandlers() {
    _textToSpeech.setStartHandler(
      () => _setState(LessonNarrationState.playing),
    );
    _textToSpeech.setPauseHandler(() => _setState(LessonNarrationState.paused));
    _textToSpeech.setContinueHandler(
      () => _setState(LessonNarrationState.playing),
    );
    _textToSpeech.setCompletionHandler(_finish);
    _textToSpeech.setCancelHandler(_finish);
    _textToSpeech.setErrorHandler((_) => _finish());
  }

  Future<void> _configure() async {
    if (_configured || _isDisposed) return;
    await _textToSpeech.setLanguage('pt-BR');
    await _textToSpeech.setSpeechRate(.46);
    await _textToSpeech.setPitch(1);
    await _textToSpeech.setVolume(1);
    await _textToSpeech.awaitSynthCompletion(true);
    _configured = true;
  }

  @override
  Future<void> toggle(String content) async {
    if (_isDisposed) return;
    final text = content.trim();
    if (text.isEmpty) return;
    try {
      await _configure();
      if (_isDisposed) return;
      if (_state == LessonNarrationState.playing) {
        await _textToSpeech.pause();
        return;
      }
      await _textToSpeech.speak(text);
    } on Object {
      _finish();
    }
  }

  @override
  Future<void> stop() async {
    if (!_configured) return;
    try {
      await _textToSpeech.stop();
    } on Object {
      // A ausência de uma voz instalada não pode bloquear o estudo.
    }
    _finish();
  }

  void _setState(LessonNarrationState value) {
    if (_isDisposed) return;
    _state = value;
    notifyListeners();
  }

  void _finish() {
    if (_isDisposed) return;
    _state = LessonNarrationState.stopped;
    notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    if (_configured) {
      unawaited(_textToSpeech.stop());
    }
    super.dispose();
  }
}
