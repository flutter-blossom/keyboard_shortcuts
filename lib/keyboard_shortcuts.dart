library keyboard_shortcuts;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:visibility_detector/visibility_detector.dart';

List<_KeyBoardShortcuts> _keyBoardShortcuts = [];

class KeyBoardShortcuts extends StatefulWidget {
  final Widget child;

  /// You can use shortCut function with BasicShortCuts to avoid write data by yourself
  final Set<LogicalKeyboardKey>? keysToPress;

  /// Function when keys are pressed
  final VoidCallback? onKeysPressed;

  /// Label who will be displayed in helper
  final String? helpLabel;

  KeyBoardShortcuts(
      {this.keysToPress,
      this.onKeysPressed,
      this.helpLabel,
      required this.child,
      Key? key})
      : super(key: key);

  @override
  _KeyBoardShortcuts createState() => _KeyBoardShortcuts();
}

class _KeyBoardShortcuts extends State<KeyBoardShortcuts> {
  ScrollController _controller = ScrollController();
  bool controllerIsReady = false;
  bool listening = false;
  late Key key;
  @override
  void initState() {
    _controller.addListener(() {
      if (_controller.hasClients) setState(() => controllerIsReady = true);
    });
    _attachKeyboardIfDetached();
    key = widget.key ?? UniqueKey();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
    _detachKeyboardIfAttached();
  }

  void _attachKeyboardIfDetached() {
    if (listening) return;
    _keyBoardShortcuts.add(this);
    RawKeyboard.instance.addListener(listener);
    listening = true;
  }

  void _detachKeyboardIfAttached() {
    if (!listening) return;
    _keyBoardShortcuts.remove(this);
    RawKeyboard.instance.removeListener(listener);
    listening = false;
  }

  bool _isPressed(Set<LogicalKeyboardKey> keysPressed,
      Set<LogicalKeyboardKey> keysToPress) {
    keysToPress = LogicalKeyboardKey.collapseSynonyms(keysToPress);
    keysPressed = LogicalKeyboardKey.collapseSynonyms(keysPressed);

    return keysPressed.containsAll(keysToPress) &&
        keysPressed.length == keysToPress.length;
  }

  void listener(RawKeyEvent v) async {
    if (!mounted) return;

    Set<LogicalKeyboardKey> keysPressed = RawKeyboard.instance.keysPressed;
    if (v.runtimeType == RawKeyDownEvent) {
      // when user type keysToPress
      if (widget.keysToPress != null &&
          widget.onKeysPressed != null &&
          _isPressed(keysPressed, widget.keysToPress!)) {
        widget.onKeysPressed!();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: key,
      child:
          PrimaryScrollController(controller: _controller, child: widget.child),
      onVisibilityChanged: (visibilityInfo) {
        if (visibilityInfo.visibleFraction == 1)
          _attachKeyboardIfDetached();
        else
          _detachKeyboardIfAttached();
      },
    );
  }
}
