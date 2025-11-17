import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_connect_app/models/service_provider.dart';
import 'package:task_connect_app/screens/settings_screen.dart';
import 'package:task_connect_app/screens/provider_list_screen.dart';
import 'package:task_connect_app/services/api_service.dart';
import 'package:task_connect_app/util/Service_card.dart';
import 'package:task_connect_app/util/category_card.dart';

class HomePage extends StatefulWidget {
  final VoidCallback? onNavigateToProviders;
  final int? userId;
  const HomePage({super.key, this.onNavigateToProviders, this.userId});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<ServiceProviderModel> providers = [];
  String? currentUserName;
  bool isLoading = true;
  bool isLoadingUser = true;

  @override
  void initState() {
    super.initState();
    _fetchProviders();
    _loadCurrentUser();
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

  Future<void> _loadCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final storedName = prefs.getString('userName');
    if (!mounted) return;
    setState(() {
      currentUserName = storedName;
      isLoadingUser = false;
    });
  }

  void _openCategoryPage(BuildContext context, String category) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProviderListScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final isLight = theme.brightness == Brightness.light;
    final displayName =
        (currentUserName?.trim().isNotEmpty ?? false) ? currentUserName!.trim().toLowerCase() : "user";

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: isLight
              ? const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFB3E5FC),
                    Color.fromARGB(255, 170, 198, 218),
                  ],
                )
              : null,
          color: !isLight ? colorScheme.surface : null,
        ),
        child: SafeArea(
          child: (isLoading || isLoadingUser)
              ? Center(
                  child: CircularProgressIndicator(color: colorScheme.primary),
                )
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      // APP BAR
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("hello", style: textTheme.bodyMedium),
                                const SizedBox(height: 8),
                                Text(
                                  displayName,
                                  style: textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Stack(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: colorScheme.primaryContainer,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    Icons.person,
                                    size: 50,
                                    color: colorScheme.onPrimaryContainer,
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const SettingsScreen(),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
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
                                        size: 14,
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

                      // PROMO CARD
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: colorScheme.surface,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: isLight
                                    ? Colors.black12
                                    : Colors.black45,
                                blurRadius: 6,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              SizedBox(
                                height: 100,
                                width: 100,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.asset(
                                    "assets/images/taskConnect1.jpg",
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "authentic services await",
                                      style: textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      "book for the home services you need",
                                      style: textTheme.bodySmall,
                                    ),
                                    const SizedBox(height: 12),
                                    GestureDetector(
                                      onTap: widget.onNavigateToProviders,
                                      child: Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: colorScheme.primary,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            "get started",
                                            style: textTheme.bodyMedium
                                                ?.copyWith(
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

                      const SizedBox(height: 25),

                      // SEARCH BAR
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
                              prefixIcon: Icon(
                                Icons.search,
                                color: colorScheme.onSurfaceVariant,
                              ),
                              border: InputBorder.none,
                              hintText: "search basing on the service?",
                              hintStyle: textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 25),

                      // CATEGORIES
                      SizedBox(
                        height: 80,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 25.0),
                          children: [
                            CategoryCard(
                              iconImagePath: "assets/icons/providers.png",
                              categoryName: "service providers",
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const ProviderListScreen(),
                                  ),
                                );
                              },
                            ),
                            CategoryCard(
                              iconImagePath: "assets/icons/plumber.png",
                              categoryName: "plumbers",
                              onTap: () =>
                                  _openCategoryPage(context, "plumber"),
                            ),
                            CategoryCard(
                              iconImagePath: "assets/icons/electrician.png",
                              categoryName: "electricians",
                              onTap: () =>
                                  _openCategoryPage(context, "electrician"),
                            ),
                            CategoryCard(
                              iconImagePath: "assets/icons/cleaner.png",
                              categoryName: "cleaners",
                              onTap: () =>
                                  _openCategoryPage(context, "cleaner"),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 25),

                      // SERVICE LIST HEADER
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "service provider list",
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "see all",
                              style: textTheme.bodyMedium?.copyWith(
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 25),

                      // SERVICE CARDS
                      SizedBox(
                        height: 220,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 25),
                          itemCount: providers.length,
                          itemBuilder: (context, index) {
                            final provider = providers[index];
                            final List<String> imagesList = provider.images;
                            final String imagePath = imagesList.isNotEmpty
                                ? imagesList.first
                                : '';
                            return ServiceCard(
                              providerImagePath: imagePath,
                              name: provider.name,
                              service: provider.service,
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
      ),
    );
  }
}
