import 'package:cloud_firestore/cloud_firestore.dart';

// Script para migrar datos de 'date' (Timestamp) a 'dateString' (String)
// Ejecuta esta función una sola vez para migrar todos los datos existentes
Future<void> migrateExpensesData() async {
  try {
    final firestore = FirebaseFirestore.instance;
    final expensesCollection = firestore.collection('expenses');

    // Obtener todos los documentos
    final snapshot = await expensesCollection.get();

    for (var doc in snapshot.docs) {
      final data = doc.data();

      // Si tiene 'date' (Timestamp) pero no tiene 'dateString'
      if (data.containsKey('date') && !data.containsKey('dateString')) {
        final timestamp = data['date'] as Timestamp;
        final date = timestamp.toDate();
        final dateString =
            '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

        // Actualizar el documento
        await expensesCollection.doc(doc.id).update({'dateString': dateString});
      }
    }
  } catch (e) {
    // Error en la migración, continuar
  }
}
