import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'database_helper.dart';

class NotesPage extends StatefulWidget {
  final int userId;
  const NotesPage({super.key, required this.userId});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _typeController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  List<Map<String, dynamic>> _notes = [];
  List<Map<String, dynamic>> _filteredNotes = [];
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    final notes = await _databaseHelper.getNotes(widget.userId);
    setState(() {
      _notes = notes;
      _filterNotes();
    });
  }

  void _filterNotes() {
    setState(() {
      _filteredNotes = _notes.where((note) {
        final noteDate = DateTime.parse(note['date']);
        return noteDate.year == _selectedDay.year &&
            noteDate.month == _selectedDay.month &&
            noteDate.day == _selectedDay.day;
      }).toList();
    });
  }

  Future<void> _addNote() async {
    _clearControllers();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Yeni Not Ekle'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Başlık',
                  prefixIcon: Icon(Icons.title),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _typeController,
                decoration: const InputDecoration(
                  labelText: 'Ürün Türü',
                  prefixIcon: Icon(Icons.category),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Ürün Adı',
                  prefixIcon: Icon(Icons.label),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'Fiyat',
                  prefixIcon: Icon(Icons.attach_money),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _quantityController,
                decoration: const InputDecoration(
                  labelText: 'Adet',
                  prefixIcon: Icon(Icons.format_list_numbered),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _noteController,
                decoration: const InputDecoration(
                  labelText: 'Not',
                  prefixIcon: Icon(Icons.note),
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
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
          ElevatedButton(
            onPressed: () async {
              if (_titleController.text.isNotEmpty) {
                try {
                  final note = {
                    'title': _titleController.text,
                    'product_type': _typeController.text,
                    'product_name': _nameController.text,
                    'price': double.tryParse(_priceController.text) ?? 0.0,
                    'quantity': int.tryParse(_quantityController.text) ?? 0,
                    'content': _noteController.text,
                    'date': _selectedDay.toIso8601String(),
                    'user_id': widget.userId,
                  };

                  await _databaseHelper.insertNote(note);
                  await _loadNotes();

                  if (mounted) {
                    Navigator.pop(context);
                    _clearControllers();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Not başarıyla eklendi'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Not eklenirken bir hata oluştu'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Başlık alanı boş bırakılamaz'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
  }

  void _clearControllers() {
    _titleController.clear();
    _typeController.clear();
    _nameController.clear();
    _priceController.clear();
    _quantityController.clear();
    _noteController.clear();
  }

  Future<void> _editNote(Map<String, dynamic> note) async {
    _titleController.text = note['title'];
    _typeController.text = note['product_type'] ?? '';
    _nameController.text = note['product_name'] ?? '';
    _priceController.text = (note['price'] ?? 0.0).toString();
    _quantityController.text = (note['quantity'] ?? 0).toString();
    _noteController.text = note['content'] ?? '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notu Düzenle'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Başlık',
                  prefixIcon: Icon(Icons.title),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _typeController,
                decoration: const InputDecoration(
                  labelText: 'Ürün Türü',
                  prefixIcon: Icon(Icons.category),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Ürün Adı',
                  prefixIcon: Icon(Icons.label),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'Fiyat',
                  prefixIcon: Icon(Icons.attach_money),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _quantityController,
                decoration: const InputDecoration(
                  labelText: 'Adet',
                  prefixIcon: Icon(Icons.format_list_numbered),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _noteController,
                decoration: const InputDecoration(
                  labelText: 'Not',
                  prefixIcon: Icon(Icons.note),
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
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
          ElevatedButton(
            onPressed: () async {
              if (_titleController.text.isNotEmpty) {
                try {
                  final updatedNote = {
                    'id': note['id'],
                    'title': _titleController.text,
                    'product_type': _typeController.text,
                    'product_name': _nameController.text,
                    'price': double.tryParse(_priceController.text) ?? 0.0,
                    'quantity': int.tryParse(_quantityController.text) ?? 0,
                    'content': _noteController.text,
                    'date': note['date'],
                    'user_id': widget.userId,
                  };

                  await _databaseHelper.updateNote(updatedNote);
                  await _loadNotes();

                  if (mounted) {
                    Navigator.pop(context);
                    _clearControllers();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Not başarıyla güncellendi'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Not güncellenirken bir hata oluştu'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Başlık alanı boş bırakılamaz'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteNote(int id) async {
    await _databaseHelper.deleteNote(id);
    await _loadNotes();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Not başarıyla silindi')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TableCalendar(
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: _focusedDay,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          calendarFormat: _calendarFormat,
          onFormatChanged: (format) {
            setState(() {
              _calendarFormat = format;
            });
          },
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
            _filterNotes();
          },
          calendarStyle: const CalendarStyle(
            selectedDecoration: BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
            todayDecoration: BoxDecoration(
              color: Colors.redAccent,
              shape: BoxShape.circle,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_selectedDay.day}/${_selectedDay.month}/${_selectedDay.year}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton.icon(
                onPressed: _addNote,
                icon: const Icon(Icons.add),
                label: const Text('Yeni Not'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _filteredNotes.isEmpty
              ? const Center(
                  child: Text(
                    'Bu tarihte not bulunmuyor',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                )
              : ListView.builder(
                  itemCount: _filteredNotes.length,
                  itemBuilder: (context, index) {
                    final note = _filteredNotes[index];
                    return Dismissible(
                      key: Key(note['id'].toString()),
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
                        _deleteNote(note['id']);
                      },
                      child: Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: Colors.red,
                            child: Icon(Icons.note, color: Colors.white),
                          ),
                          title: Text(
                            note['title'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (note['product_type']?.isNotEmpty ?? false)
                                Text('Ürün Türü: ${note['product_type']}'),
                              if (note['product_name']?.isNotEmpty ?? false)
                                Text('Ürün Adı: ${note['product_name']}'),
                              if (note['price'] != null)
                                Text('Fiyat: ${note['price']} TL'),
                              if (note['quantity'] != null)
                                Text('Adet: ${note['quantity']}'),
                              if (note['content']?.isNotEmpty ?? false)
                                Text('Not: ${note['content']}'),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _editNote(note),
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
