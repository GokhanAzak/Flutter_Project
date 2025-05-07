import 'package:flutter/material.dart';
import 'package:app1/companies_page.dart';
import 'package:app1/notes_page.dart';
import 'package:app1/login_page.dart';
import 'database_helper.dart';

class DashboardPage extends StatefulWidget {
  final int userId;
  const DashboardPage({super.key, required this.userId});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  List<Map<String, dynamic>> _recentNotes = [];
  List<Map<String, dynamic>> _recentCompanies = [];
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadRecentData();
  }

  Future<void> _loadRecentData() async {
    final notes = await _databaseHelper.getNotes(widget.userId);
    final companies = await _databaseHelper.getCompanies(widget.userId);

    setState(() {
      _recentNotes = notes.take(5).toList();
      _recentCompanies = companies.take(5).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _selectedIndex == 0
              ? 'Ana Sayfa'
              : _selectedIndex == 1
                  ? 'Firmalar'
                  : 'Notlar',
        ),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          // Ana Sayfa
          RefreshIndicator(
            onRefresh: _loadRecentData,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // İstatistikler
                Row(
                  children: [
                    Expanded(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              const Icon(Icons.business, size: 40, color: Colors.red),
                              const SizedBox(height: 8),
                              Text(
                                '${_recentCompanies.length}',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Text('Firma'),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              const Icon(Icons.note, size: 40, color: Colors.red),
                              const SizedBox(height: 8),
                              Text(
                                '${_recentNotes.length}',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Text('Not'),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Son Eklenen Firmalar
                const Text(
                  'Son Eklenen Firmalar',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                if (_recentCompanies.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'Henüz firma eklenmemiş',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _recentCompanies.length,
                    itemBuilder: (context, index) {
                      final company = _recentCompanies[index];
                      return Card(
                        child: ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: Colors.red,
                            child: Icon(Icons.business, color: Colors.white),
                          ),
                          title: Text(company['name']),
                          subtitle: Text(company['address'] ?? ''),
                        ),
                      );
                    },
                  ),
                const SizedBox(height: 24),
                // Son Eklenen Notlar
                const Text(
                  'Son Eklenen Notlar',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                if (_recentNotes.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'Henüz not eklenmemiş',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _recentNotes.length,
                    itemBuilder: (context, index) {
                      final note = _recentNotes[index];
                      return Card(
                        child: ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: Colors.red,
                            child: Icon(Icons.note, color: Colors.white),
                          ),
                          title: Text(note['title']),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (note['type']?.isNotEmpty ?? false)
                                Text('Tür: ${note['type']}'),
                              if (note['name']?.isNotEmpty ?? false)
                                Text('Ad: ${note['name']}'),
                              if (note['price'] != null)
                                Text('Fiyat: ${note['price']} TL'),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
          // Firmalar Sayfası
          CompaniesPage(userId: widget.userId),
          // Notlar Sayfası
          NotesPage(userId: widget.userId),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Ana Sayfa',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.business),
            label: 'Firmalar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.note),
            label: 'Notlar',
          ),
        ],
        selectedItemColor: Colors.red,
      ),
    );
  }
}
