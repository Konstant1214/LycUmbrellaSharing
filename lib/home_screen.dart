import 'package:flutter/material.dart';
import 'api_service.dart';
import 'user_store.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> terminals = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTerminals();
  }

  Future<void> _loadTerminals() async {
    final result = await ApiService.getTerminals();
    setState(() {
      terminals = result;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Umbrella Rent'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.pushNamed(context, '/profile');
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Терминалы выдачи:',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: terminals.isEmpty
                        ? const Center(
                            child: Text('Нет доступных терминалов'),
                          )
                        : ListView.builder(
                            itemCount: terminals.length,
                            itemBuilder: (context, index) {
                              var terminal = terminals[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                child: ListTile(
                                  leading: const Icon(
                                    Icons.location_on,
                                    color: Colors.blue,
                                    size: 32,
                                  ),
                                  title: Text(
                                    terminal['name'],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 4),
                                      Text(terminal['address']),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Зонтов доступно: ${terminal['availableUmbrellas']}',
                                        style: TextStyle(
                                          color: terminal['availableUmbrellas'] >
                                                  0
                                              ? Colors.green
                                              : Colors.red,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  trailing: ElevatedButton(
                                    onPressed:
                                        terminal['availableUmbrellas'] > 0
                                            ? () async {
                                                final result =
                                                    await ApiService
                                                        .createRental(
                                                  userId:
                                                      currentUser!['id'],
                                                  terminalId:
                                                      terminal['id'],
                                                );

                                                if (!mounted) return;

                                                if (result
                                                    .containsKey('error')) {
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                        result['error'],
                                                      ),
                                                    ),
                                                  );
                                                } else {
                                                  Navigator.pushNamed(
                                                    context,
                                                    '/rental',
                                                    arguments: {
                                                      'terminal': terminal,
                                                      'rental': result,
                                                    },
                                                  );
                                                }
                                              }
                                            : null,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                      foregroundColor: Colors.white,
                                    ),
                                    child: const Text('Арендовать'),
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
