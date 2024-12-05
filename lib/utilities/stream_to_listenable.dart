import 'dart:async';
import 'package:flutter/cupertino.dart';

/// Converts multiple streams into a `ChangeNotifier` that notifies listeners on stream events.
class StreamToListenable extends ChangeNotifier {
  late final List<StreamSubscription> subscriptions;

  StreamToListenable(List<Stream> streams) {
    subscriptions = streams.map((stream) {
      return stream.asBroadcastStream().listen((event) => notifyListeners());
    }).toList();
  }

  @override
  void dispose() {
    for (var subscription in subscriptions) {
      subscription.cancel();
    }
    super.dispose();
  }
}
