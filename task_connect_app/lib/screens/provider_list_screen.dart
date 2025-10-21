import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:task_connect_app/models/service_provider.dart';
import 'package:task_connect_app/screens/book_page.dart';
import 'package:task_connect_app/util/provider_card%20.dart';

class ProviderListScreen extends StatefulWidget {
  const ProviderListScreen({super.key});

  @override
  State<ProviderListScreen> createState() => _ProviderListScreenState();
}

class _ProviderListScreenState extends State<ProviderListScreen> {
  List<ServiceProviderModel> providers = [];
  List<ServiceProviderModel> filteredProviders = [];
  bool isLoading = true;
  bool isUserIdLoading = true;

  final TextEditingController _searchController = TextEditingController();
  Map<String, bool> savedProviders = {};
  String get _baseUrl => 'http://127.0.0.1:8000';

  int? loggedInUserId;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await _loadUserId();
    await fetchProviders();
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');
    if (userId != null && userId > 0) {
      setState(() {
        loggedInUserId = userId;
        isUserIdLoading = false;
      });
    } else {
      setState(() => isUserIdLoading = false);
    }
  }

  Future<void> fetchProviders() async {
    try {
      final headers = {'Accept': 'application/json'};

      http.Response response = await http
          .get(Uri.parse('$_baseUrl/api/providers'), headers: headers)
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 404) {
        response = await http
            .get(Uri.parse('$_baseUrl/api/service-providers'), headers: headers)
            .timeout(const Duration(seconds: 15));
      }

      if (response.statusCode == 200) {
        dynamic decoded = jsonDecode(response.body);

        List<dynamic> list = [];
        if (decoded is List) {
          list = decoded;
        } else if (decoded is Map<String, dynamic> && decoded['data'] is List) {
          list = decoded['data'];
        } else {
          throw Exception('Unsupported JSON format: $decoded');
        }

        setState(() {
          providers = list
              .map((json) => ServiceProviderModel.fromJson(json))
              .toList();
          filteredProviders = providers;

          for (var provider in providers) {
            savedProviders[provider.id.toString()] = false;
          }

          isLoading = false;
        });
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      setState(() => isLoading = false);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error fetching providers: $e')));
      });
    }
  }

  void _filterByCategory(String category) {
    setState(() {
      if (category == 'All') {
        filteredProviders = providers;
      } else if (category == 'Saved') {
        filteredProviders = providers
            .where((p) => savedProviders[p.id.toString()] ?? false)
            .toList();
      } else if (category == 'Rating Category') {
        filteredProviders = providers
            .where((p) => (p.rating ?? 0.0) >= 4.5)
            .toList();
      }
    });
  }

  void _searchProviders(String query) {
    setState(() {
      filteredProviders = providers.where((p) {
        final name = (p.name ?? '').toLowerCase();
        final service = (p.service ?? '').toLowerCase();
        return name.contains(query.toLowerCase()) ||
            service.contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isUserIdLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // 🔹 Custom AppBar Section
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 10,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: theme.iconTheme.color),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Text(
                    "Service Providers",
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: Icon(Icons.filter_list, color: theme.iconTheme.color),
                    onSelected: _filterByCategory,
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'All',
                        child: Text('All', style: theme.textTheme.bodyMedium),
                      ),
                      PopupMenuItem(
                        value: 'Saved',
                        child: Text('Saved', style: theme.textTheme.bodyMedium),
                      ),
                      PopupMenuItem(
                        value: 'Rating Category',
                        child: Text(
                          'Rating ≥ 4.5',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 🔹 Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 5,
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    prefixIcon: Icon(
                      Icons.search,
                      color: theme.iconTheme.color,
                    ),
                    border: InputBorder.none,
                    hintText: "Search by name or service",
                    hintStyle: theme.textTheme.bodyMedium,
                  ),
                  onChanged: _searchProviders,
                ),
              ),
            ),

            const SizedBox(height: 8),

            // 🔹 Provider List
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filteredProviders.isEmpty
                  ? Center(
                      child: Text(
                        'No providers found.',
                        style: theme.textTheme.bodyMedium,
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: filteredProviders.length,
                      itemBuilder: (context, index) {
                        final provider = filteredProviders[index];
                        return Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 500),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 8.0,
                              ),
                              child: ProviderCard(
                                name: provider.name ?? 'No Name',
                                service: provider.service ?? 'No Service',
                                telnumber: provider.telnumber ?? 'No Tel',
                                description: provider.description ?? '',
                                images: provider.images ?? [],
                                rating: provider.rating ?? 0.0,
                                isSaved:
                                    savedProviders[provider.id.toString()] ??
                                    false,
                                onSaveToggle: (isSaved) {
                                  setState(() {
                                    savedProviders[provider.id.toString()] =
                                        isSaved;
                                  });
                                },
                                onBook: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => BookPage(
                                        provider: provider,
                                        userId: loggedInUserId!,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
