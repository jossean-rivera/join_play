import 'package:flutter/material.dart';
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
    final mediaQuery = MediaQuery.of(context);
    final isLandscape = mediaQuery.orientation == Orientation.landscape;
    final crossAxisCount = mediaQuery.size.width > 600 ? 3 : 2; // Adjust columns for larger screens
    final fontSize = mediaQuery.size.width > 600 ? 16.0 : 14.0; // Adjust font size for larger screens
    final padding = mediaQuery.size.width > 600 ? 24.0 : 16.0; // Increase padding for larger screens

    return Padding(
      padding: EdgeInsets.all(padding),
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: firebaseService.getSports(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No sports available."));
          } else {
            final sports = snapshot.data!;
            return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount, // Dynamic columns
                crossAxisSpacing: padding,
                mainAxisSpacing: padding,
                childAspectRatio: 1, // Keep items square
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
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontSize: fontSize), // Dynamic font size
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
