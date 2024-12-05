import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import '../utilities/firebase_service.dart';
import '../navigation/route_names.dart';

class SportsPage extends StatelessWidget {
  final FirebaseService firebaseService;

  const SportsPage({super.key, required this.firebaseService});

  void _navigateToDetails(BuildContext context, String sportId) {
    context.goNamed(
      RouteNames.sportDetails,
      pathParameters: {'sportId': sportId}, // Pass sportId to details page
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text("Sports"),
      ),
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: firebaseService.getSports(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CupertinoActivityIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No sports available."));
          } else {
            final sports = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: sports.length,
                itemBuilder: (context, index) {
                  final sport = sports[index];
                  return GestureDetector(
                    onTap: () {
                      _navigateToDetails(context, sport['id']);
                    },
                    child: Column(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.asset(
                              sport['image'],
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          sport['name'],
                          style: CupertinoTheme.of(context)
                              .textTheme
                              .textStyle
                              .copyWith(fontWeight: FontWeight.w500),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          }
        },
      ),
    );
  }
}
