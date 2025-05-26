import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> showDeleteAccountDialog(BuildContext context) async {
  final confirm = await showDialog<bool>(
    context: context,
    builder:
        (context) => AlertDialog(
          title: const Text('Konfirmasi Hapus Akun'),
          content: const Text(
            'Apakah Anda yakin ingin menghapus akun ini? Semua data Anda akan hilang dan tidak dapat dikembalikan.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Hapus', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
  );

  if (confirm == true) {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Hapus dokumen user di Firestore
        final usersQuery =
            await FirebaseFirestore.instance
                .collection('users')
                .where('email', isEqualTo: user.email)
                .limit(1)
                .get();
        if (usersQuery.docs.isNotEmpty) {
          await usersQuery.docs.first.reference.delete();
        }
        // Hapus akun Auth
        await user.delete();
        if (context.mounted) {
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil('/splash', (route) => false);
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menghapus akun: ${e.toString()}')),
      );
    }
  }
}
