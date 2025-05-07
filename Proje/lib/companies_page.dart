import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'database_helper.dart';

class CompaniesPage extends StatefulWidget {
  final int userId;
  const CompaniesPage({super.key, required this.userId});

  @override
  State<CompaniesPage> createState() => _CompaniesPageState();
}

class _CompaniesPageState extends State<CompaniesPage> {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  List<Map<String, dynamic>> _companies = [];
  List<Map<String, dynamic>> _filteredCompanies = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadCompanies();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _loadCompanies() async {
    final companies = await _databaseHelper.getCompanies(widget.userId);
    setState(() {
      _companies = companies;
      _filteredCompanies = companies;
    });
  }

  Future<void> _addCompany() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Yeni Firma Ekle'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Firma Adı',
                  prefixIcon: Icon(Icons.business),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Adres',
                  prefixIcon: Icon(Icons.location_on),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Telefon',
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'E-posta',
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _clearControllers();
            },
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () async {
              if (_nameController.text.isNotEmpty) {
                final company = {
                  'name': _nameController.text,
                  'address': _addressController.text,
                  'phone': _phoneController.text,
                  'email': _emailController.text,
                  'user_id': widget.userId,
                };

                await _databaseHelper.insertCompany(company);
                await _loadCompanies();

                if (mounted) {
                  Navigator.pop(context);
                  _clearControllers();
                }
              }
            },
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
  }

  void _clearControllers() {
    _nameController.clear();
    _addressController.clear();
    _phoneController.clear();
    _emailController.clear();
  }

  Future<void> _editCompany(Map<String, dynamic> company) async {
    _nameController.text = company['name'];
    _addressController.text = company['address'] ?? '';
    _phoneController.text = company['phone'] ?? '';
    _emailController.text = company['email'] ?? '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Firmayı Düzenle'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Firma Adı',
                  prefixIcon: Icon(Icons.business),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Adres',
                  prefixIcon: Icon(Icons.location_on),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Telefon',
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'E-posta',
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _clearControllers();
            },
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () async {
              if (_nameController.text.isNotEmpty) {
                final updatedCompany = {
                  'id': company['id'],
                  'name': _nameController.text,
                  'address': _addressController.text,
                  'phone': _phoneController.text,
                  'email': _emailController.text,
                  'user_id': widget.userId,
                };

                await _databaseHelper.updateCompany(updatedCompany);
                await _loadCompanies();

                if (mounted) {
                  Navigator.pop(context);
                  _clearControllers();
                }
              }
            },
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteCompany(int id) async {
    await _databaseHelper.deleteCompany(id);
    await _loadCompanies();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 300,
          child: FlutterMap(
            mapController: _mapController,
            options: const MapOptions(
              initialCenter: LatLng(41.0082, 28.9784),
              initialZoom: 10,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.app',
              ),
              MarkerLayer(
                markers: _companies.map((company) {
                  return Marker(
                    point: LatLng(
                      company['latitude'] ?? 41.0082,
                      company['longitude'] ?? 28.9784,
                    ),
                    child: const Icon(
                      Icons.location_on,
                      color: Colors.red,
                      size: 40,
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Şirket ara...',
                    prefixIcon: const Icon(Icons.search, color: Colors.red),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: Colors.red),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _filteredCompanies = _companies;
                              });
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.red),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.red, width: 2),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _filteredCompanies = _companies.where((company) {
                        final name = company['name'].toString().toLowerCase();
                        final address =
                            company['address'].toString().toLowerCase();
                        final searchLower = value.toLowerCase();
                        return name.contains(searchLower) ||
                            address.contains(searchLower);
                      }).toList();
                    });
                  },
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.add_circle_outline, color: Colors.red),
                onPressed: _addCompany,
              ),
            ],
          ),
        ),
        Expanded(
          child: _filteredCompanies.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _searchController.text.isEmpty
                            ? Icons.business
                            : Icons.search_off,
                        size: 60,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _searchController.text.isEmpty
                            ? 'Henüz şirket eklenmemiş'
                            : 'Arama sonucu bulunamadı',
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _filteredCompanies.length,
                  itemBuilder: (context, index) {
                    final company = _filteredCompanies[index];
                    return Dismissible(
                      key: Key(company['id'].toString()),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: const Icon(
                          Icons.delete,
                          color: Colors.white,
                        ),
                      ),
                      onDismissed: (direction) {
                        _deleteCompany(company['id']);
                      },
                      child: Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: Colors.red,
                            child: Icon(
                              Icons.business,
                              color: Colors.white,
                            ),
                          ),
                          title: Text(
                            company['name'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.location_on,
                                    size: 16,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(company['address']),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.phone,
                                    size: 16,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(company['phone']),
                                ],
                              ),
                              if (company['email'].isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.email,
                                      size: 16,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(company['email']),
                                  ],
                                ),
                              ],
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(
                              Icons.edit,
                              color: Colors.blue,
                            ),
                            onPressed: () => _editCompany(company),
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
