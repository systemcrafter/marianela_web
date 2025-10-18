import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:marianela_web/core/services/api_client.dart';
import 'package:marianela_web/core/widgets/wave_header.dart';
import 'package:marianela_web/screens/admin/user_form.dart';

class UsersListScreen extends StatefulWidget {
  const UsersListScreen({super.key});

  @override
  State<UsersListScreen> createState() => _UsersListScreenState();
}

class _UsersListScreenState extends State<UsersListScreen> {
  late Future<List<Map<String, dynamic>>> _futureUsers;
  String _q = '';

  @override
  void initState() {
    super.initState();
    _futureUsers = _fetchUsers();
  }

  Future<List<Map<String, dynamic>>> _fetchUsers() async {
    final res = await ApiClient.get('/users');
    if (res.statusCode == 200) {
      final payload = jsonDecode(res.body) as Map<String, dynamic>;
      final items = (payload['data'] as List).cast<Map<String, dynamic>>();

      // 🔎 Filtro extendido: nombre, email o casa
      if (_q.trim().isNotEmpty) {
        final q = _q.toLowerCase();
        return items.where((u) {
          final name = (u['name'] ?? '').toString().toLowerCase();
          final email = (u['email'] ?? '').toString().toLowerCase();
          final house = (u['house']?['name'] ?? '').toString().toLowerCase();
          return name.contains(q) || email.contains(q) || house.contains(q);
        }).toList();
      }
      return items;
    } else {
      throw Exception('Error (${res.statusCode}) al cargar usuarios');
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _futureUsers = _fetchUsers();
    });
  }

  void _onCreate() async {
    final changed = await Navigator.of(
      context,
    ).push<bool>(MaterialPageRoute(builder: (_) => const UserFormScreen()));
    if (changed == true) _refresh();
  }

  void _onEdit(Map<String, dynamic> user) async {
    final changed = await Navigator.of(
      context,
    ).push<bool>(MaterialPageRoute(builder: (_) => UserFormScreen(user: user)));
    if (changed == true) _refresh();
  }

  void _onDelete(int id) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirmar'),
        content: Text('¿Eliminar el usuario #$id?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (ok != true) return;

    final res = await ApiClient.delete('/users/$id');
    if (res.statusCode == 200) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Usuario eliminado')));
      }
      _refresh();
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al eliminar (${res.statusCode})'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Administración de Usuarios"),
        foregroundColor: Colors.white,
        toolbarHeight: 40,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF7A6CF7), Color(0xFF9B59F6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          const WaveHeader(height: 180),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Buscar por nombre, email o casa...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (v) {
                      _q = v;
                      _refresh();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                FilledButton(
                  onPressed: _onCreate,
                  child: Row(
                    children: const [
                      Icon(Icons.add),
                      SizedBox(width: 6),
                      Text('Nuevo'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _futureUsers,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final users = snapshot.data ?? [];
                if (users.isEmpty) {
                  return const Center(child: Text('Sin usuarios'));
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: users.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) {
                    final u = users[i];
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text(
                            (u['name'] ?? '?')
                                .toString()
                                .substring(0, 1)
                                .toUpperCase(),
                          ),
                        ),
                        title: Text(u['name'] ?? ''),
                        subtitle: Text(
                          '${u['email'] ?? ''}\n'
                          'Rol: ${u['role'] ?? ''}'
                          '${u['house'] != null ? '\nCasa: ${u['house']['name']}' : ''}',
                        ),
                        isThreeLine: true,
                        trailing: Wrap(
                          spacing: 8,
                          children: [
                            IconButton(
                              tooltip: 'Editar',
                              icon: const Icon(Icons.edit),
                              onPressed: () => _onEdit(u),
                            ),
                            IconButton(
                              tooltip: 'Eliminar',
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () => _onDelete(u['id'] as int),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
