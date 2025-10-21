import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class LoginHistoryPage extends StatelessWidget {
  const LoginHistoryPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Inicios de Sesión'),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('login_history')
            .where('uid', isEqualTo: user?.uid)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data?.docs ?? [];

          if (data.isEmpty) {
            return const Center(
              child: Text(
                'No hay registros de inicio de sesión aún.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              final item = data[index];
              final timestamp = item['timestamp'] as Timestamp?;
              final formattedDate = timestamp != null
                  ? DateFormat('dd/MM/yyyy HH:mm:ss').format(timestamp.toDate())
                  : 'Fecha desconocida';
              final device = item['device'] ?? 'Desconocido';
              final ip = item['ip_address'] ?? 'N/A';

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                elevation: 2,
                child: ListTile(
                  leading: const Icon(Icons.login, color: Colors.blue),
                  title: Text(formattedDate),
                  subtitle: Text('Dispositivo: $device\nIP: $ip'),
                  isThreeLine: true,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
