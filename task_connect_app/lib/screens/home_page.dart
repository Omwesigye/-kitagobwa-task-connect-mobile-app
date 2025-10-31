import 'package:flutter/material.dart';
import 'package:task_connect_app/models/service_provider.dart';
import 'package:task_connect_app/screens/settings_screen.dart';
import 'package:task_connect_app/services/api_service.dart';
import 'package:task_connect_app/util/Service_card.dart';
import 'package:task_connect_app/util/category_card.dart';

class HomePage extends StatefulWidget {
  final VoidCallback? onNavigateToProviders;
  const HomePage({super.key, this.onNavigateToProviders});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<ServiceProviderModel> providers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProviders();
  }

  Future<void> _fetchProviders() async {
    try {
      final fetchedProviders = await ApiService.fetchProviders();
      setState(() {
        providers = fetchedProviders;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Error fetching providers: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: isLoading
            ? Center(child: CircularProgressIndicator(color: colorScheme.primary))
            : SingleChildScrollView(
                child: Column(
                  children: [
                    // App bar section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "hello",
                                style: textTheme.bodySmall,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "john",
                                style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),

                          // Profile icon + edit button
                          Stack(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: colorScheme.primaryContainer,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(Icons.person, size: 50, color: colorScheme.onPrimaryContainer),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const SettingsScreen(),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: colorScheme.secondary,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: colorScheme.surface,
                                        width: 2,
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.edit,
                                      size: 18,
                                      color: colorScheme.onSecondary,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 25),

                    // Promo card
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: colorScheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            const SizedBox(width: 10),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: colorScheme.tertiaryContainer,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      height: 100,
                                      width: 100,
                                      child: Image.asset(
                                        "assets/images/taskConnect1.jpg",
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    const SizedBox(width: 20),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "authentic services await",
                                            style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(height: 12),
                                          Text(
                                            "book for the home services you need",
                                            style: textTheme.bodySmall,
                                          ),
                                          const SizedBox(height: 12),
                                          GestureDetector(
                                            onTap: () {
                                              if (widget.onNavigateToProviders != null) {
                                                widget.onNavigateToProviders!();
                                              }
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                color: colorScheme.primary,
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  "get started",
                                                  style: textTheme.bodyMedium?.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                    color: colorScheme.onPrimary,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 25),

                    // Search bar
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25.0),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextField(
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.search, color: colorScheme.onSurfaceVariant),
                            border: InputBorder.none,
                            hintText: "search basing on the service?",
                            hintStyle: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 25),

                    // Categories
                    SizedBox(
                      height: 80,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 25.0),
                        children: [
                          CategoryCard(
                            iconImagePath: "assets/icons/providers.png",
                            categoryName: "service providers",
                          ),
                          CategoryCard(
                            iconImagePath: "assets/icons/plumber.png",
                            categoryName: "plumbers",
                          ),
                          CategoryCard(
                            iconImagePath: "assets/icons/electrician.png",
                            categoryName: "electricians",
                          ),
                          CategoryCard(
                            iconImagePath: "assets/icons/cleaner.png",
                            categoryName: "cleaners",
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 25),

                    // Service provider list header
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "service provider list",
                            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "see all",
                            style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurface.withOpacity(0.6)),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 25),

                    // Service cards horizontal list
                    SizedBox(
                      height: 220,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 25),
                        itemCount: providers.length,
                        itemBuilder: (context, index) {
                          final provider = providers[index];
                          return ServiceCard(
                            providerImagePath: provider.images.first,
                            name: provider.name ?? "Unknown",
                            service: provider.service.toString(),
                            rating: provider.rating.toString(),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 25),
                  ],
                ),
              ),
      ),
    );
  }
}
