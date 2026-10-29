import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:smart_ai_university_student_assistant/features/assistant/presentation/controllers/demo_chat_controller.dart';
import 'package:smart_ai_university_student_assistant/features/assistant/presentation/demo/chat_demo_data.dart';
import 'package:smart_ai_university_student_assistant/features/assistant/presentation/models/chat_message.dart';

/// Controller with a fixed clock, disposed with the test.
DemoChatController _controller({DateTime? now}) {
  final controller = DemoChatController(
    now: () => now ?? DateTime(2026, 10, 28, 9, 5),
  );
  addTearDown(controller.dispose);
  return controller;
}

void main() {
  test('starts with the greeting only and nothing to send', () {
    final controller = _controller();

    expect(controller.messages, [ChatDemoData.greeting]);
    expect(controller.hasUserMessages, isFalse);
    expect(controller.canSend, isFalse);
    expect(controller.needsResetConfirmation, isFalse);
    expect(controller.draft.text, isEmpty);
  });

  test('prefill fills an empty composer with the cursor at the end', () {
    final controller = _controller();
    const prompt = 'Where is Building 11?';

    expect(controller.prefill(prompt), isTrue);
    expect(controller.draft.text, prompt);
    expect(
      controller.draft.selection,
      const TextSelection.collapsed(offset: prompt.length),
    );
    expect(controller.canSend, isTrue);
    expect(controller.needsResetConfirmation, isTrue);
    expect(controller.messages.length, 1);
  });

  test('prefill replaces a blank draft and re-applies the same text', () {
    final controller = _controller();
    controller.draft.text = '   ';

    expect(controller.prefill('When is my next exam?'), isTrue);
    expect(controller.draft.text, 'When is my next exam?');
    expect(controller.prefill('When is my next exam?'), isTrue);
    expect(controller.draft.text, 'When is my next exam?');
  });

  test('prefill keeps a different draft', () {
    final controller = _controller();
    controller.draft.text = 'My own question';

    expect(controller.prefill('When is my next exam?'), isFalse);
    expect(controller.draft.text, 'My own question');
  });

  test('send rejects a blank draft without changes or notifications', () {
    final controller = _controller();
    var notified = 0;
    controller.addListener(() => notified++);
    controller.draft.text = ' \n ';

    expect(controller.send(), isNull);
    expect(controller.messages.length, 1);
    expect(controller.hasUserMessages, isFalse);
    expect(notified, 0);
  });

  test('send appends one trimmed user message, clears the draft and '
      'notifies', () {
    final controller = _controller(now: DateTime(2026, 10, 28, 13, 7));
    var notified = 0;
    controller.addListener(() => notified++);
    controller.draft.text = '  Where is the library?  ';

    final message = controller.send();

    expect(message, isNotNull);
    expect(message!.role, ChatRole.user);
    expect(message.text, 'Where is the library?');
    expect(message.timeLabel, '01:07 PM');
    expect(controller.messages, [ChatDemoData.greeting, message]);
    expect(controller.draft.text, isEmpty);
    expect(controller.canSend, isFalse);
    expect(controller.hasUserMessages, isTrue);
    expect(notified, 1);

    // A repeated send with the now-empty draft adds nothing.
    expect(controller.send(), isNull);
    expect(controller.messages.length, 2);
    expect(notified, 1);
  });

  test('message ids stay unique across sends and resets', () {
    final controller = _controller();
    controller.draft.text = 'one';
    final first = controller.send()!;
    controller.draft.text = 'two';
    final second = controller.send()!;
    controller.reset();
    controller.draft.text = 'three';
    final third = controller.send()!;

    expect({first.id, second.id, third.id, ChatDemoData.greeting.id}.length, 4);
  });

  test('reset restores the greeting, clears the draft and notifies', () {
    final controller = _controller();
    controller.draft.text = 'one';
    controller.send();
    controller.draft.text = 'draft';
    var notified = 0;
    controller.addListener(() => notified++);

    controller.reset();

    expect(controller.messages, [ChatDemoData.greeting]);
    expect(controller.draft.text, isEmpty);
    expect(controller.needsResetConfirmation, isFalse);
    expect(notified, 1);
  });

  test('messages cannot be changed from outside', () {
    final controller = _controller();

    expect(
      () => controller.messages.add(ChatDemoData.greeting),
      throwsUnsupportedError,
    );
    expect(controller.messages.length, 1);
  });

  test('formatTime uses the 12-hour clock with AM/PM like the frame', () {
    expect(
      DemoChatController.formatTime(DateTime(2026, 1, 1, 0, 30)),
      '12:30 AM',
    );
    expect(
      DemoChatController.formatTime(DateTime(2026, 1, 1, 9, 0)),
      '09:00 AM',
    );
    expect(
      DemoChatController.formatTime(DateTime(2026, 1, 1, 12, 0)),
      '12:00 PM',
    );
    expect(
      DemoChatController.formatTime(DateTime(2026, 1, 1, 13, 7)),
      '01:07 PM',
    );
    expect(
      DemoChatController.formatTime(DateTime(2026, 1, 1, 23, 59)),
      '11:59 PM',
    );
  });
}
