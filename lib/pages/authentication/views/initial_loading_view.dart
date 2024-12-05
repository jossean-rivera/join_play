import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

import '../../../navigation/route_paths.dart';

class InitalLoadingView extends StatefulWidget {
  final Duration timeout;
  const InitalLoadingView({super.key, this.timeout = const Duration(seconds: 5)});

  @override
  State<InitalLoadingView> createState() => _InitalLoadingViewState();
}

class _InitalLoadingViewState extends State<InitalLoadingView> {
  @override
  void initState() {
    super.initState();

    Future.delayed(widget.timeout, () {
      if (mounted) {
        context.goNamed(RoutePaths.login); // Navigate to the '/login' page
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const CupertinoPageScaffold(
      child: Center(
        child: CupertinoActivityIndicator(), // Cupertino-style loading icon
      ),
    );
  }
}
