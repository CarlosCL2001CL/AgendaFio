import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

// Modelo para representar un gasto
class Expense {
  final String id;
  final String productName;
  final double price;

  Expense({required this.id, required this.productName, required this.price});
}

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  final _auth = FirebaseAuth.instance;
  User? _user;

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser;
    _selectedDay = DateTime.utc(_focusedDay.year, _focusedDay.month, _focusedDay.day);
  }

  // Cierra la sesión del usuario
  Future<void> _signOut() async {
    await _auth.signOut();
    if (mounted) {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AgendaFio - Mis Gastos'),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _signOut,
            tooltip: 'Cerrar Sesión',
          ),
        ],
      ),
      body: Column(
        children: [
          TableCalendar(
            locale: 'es_ES',
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              if (!isSameDay(_selectedDay, selectedDay)) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              }
            },
            onFormatChanged: (format) {
              if (_calendarFormat != format) {
                setState(() {
                  _calendarFormat = format;
                });
              }
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            calendarStyle: const CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Colors.deepPurpleAccent,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Colors.deepPurple,
                shape: BoxShape.circle,
              ),
              markerDecoration: BoxDecoration(
                color: Colors.amber,
                shape: BoxShape.circle,
              ),
            ),
            headerStyle: const HeaderStyle(
              titleCentered: true,
              formatButtonVisible: false,
            ),
          ),
          const SizedBox(height: 8.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Gastos del Día',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                MonthlyTotalWidget(focusedDay: _focusedDay, user: _user),
              ],
            ),
          ),
          Expanded(
            child: DailyExpensesList(selectedDay: _selectedDay, user: _user),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddExpenseDialog(context, _selectedDay, _user),
        backgroundColor: Colors.deepPurple,
        tooltip: 'Añadir Gasto',
        child: const Icon(Icons.add),
      ),
    );
  }
}

// Widget para mostrar el total de gastos del mes
class MonthlyTotalWidget extends StatelessWidget {
  final DateTime focusedDay;
  final User? user;

  const MonthlyTotalWidget({super.key, required this.focusedDay, this.user});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('expenses')
          .where('userId', isEqualTo: user?.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        if (!snapshot.hasData || snapshot.hasError) {
          return const Text(
            'Total del Mes: \$0.00',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
          );
        }

        double monthlyTotal = 0.0;
        for (var doc in snapshot.data!.docs) {
          final data = doc.data() as Map<String, dynamic>?;

          if (data != null) {
            final timestamp = data['date'] as Timestamp?;
            if (timestamp != null) {
              final expenseDate = timestamp.toDate();
              final utcExpenseDate = DateTime.utc(expenseDate.year, expenseDate.month, expenseDate.day);
              final utcFocusedDay = DateTime.utc(focusedDay.year, focusedDay.month, 1);

              if (utcExpenseDate.month == utcFocusedDay.month &&
                  utcExpenseDate.year == utcFocusedDay.year) {
                final price = data['price'] as num?;
                if (price != null) {
                  monthlyTotal += price.toDouble();
                }
              }
            }
          }
        }

        return Text(
          'Total del Mes: \$${monthlyTotal.toStringAsFixed(2)}',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
        );
      },
    );
  }
}

// Widget para la lista de gastos del día
class DailyExpensesList extends StatelessWidget {
  final DateTime? selectedDay;
  final User? user;

  const DailyExpensesList({super.key, this.selectedDay, this.user});

  @override
  Widget build(BuildContext context) {
    if (selectedDay == null || user == null) {
      return const Center(child: Text('Selecciona un día para ver los gastos'));
    }

    final normalizedDay = DateTime.utc(selectedDay!.year, selectedDay!.month, selectedDay!.day);

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('expenses')
          .where('userId', isEqualTo: user!.uid)
          .where('date', isEqualTo: Timestamp.fromDate(normalizedDay))
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final expenses = snapshot.data!.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return Expense(
            id: doc.id,
            productName: data['productName'] ?? 'Sin nombre',
            price: (data['price'] as num? ?? 0.0).toDouble(),
          );
        }).toList();

        if (expenses.isEmpty) {
          return const Center(child: Text('No hay gastos para este día.'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: expenses.length,
          itemBuilder: (context, index) {
            final expense = expenses[index];
            return Card(
              elevation: 2,
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: ListTile(
                title: Text(expense.productName),
                trailing: Text('\$${expense.price.toStringAsFixed(2)}'),
              ),
            );
          },
        );
      },
    );
  }
}


// Diálogo para añadir un nuevo gasto
Future<void> _showAddExpenseDialog(BuildContext context, DateTime? selectedDay, User? user) async {
    final productNameController = TextEditingController();
    final priceController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Añadir Nuevo Gasto'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: productNameController,
                  decoration: const InputDecoration(labelText: 'Producto'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, introduce un nombre de producto';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: priceController,
                  decoration: const InputDecoration(labelText: 'Precio (USD)', prefixText: '\$'),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, introduce un precio';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Introduce un número válido';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  _addExpense(
                    productNameController.text,
                    double.parse(priceController.text),
                    selectedDay,
                    user,
                  );
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  // Añade el gasto a Firestore
  void _addExpense(String productName, double price, DateTime? selectedDay, User? user) {
    if (user == null || selectedDay == null) return;
    
    final normalizedDay = DateTime.utc(selectedDay.year, selectedDay.month, selectedDay.day);

    FirebaseFirestore.instance.collection('expenses').add({
      'userId': user.uid,
      'date': Timestamp.fromDate(normalizedDay), 
      'productName': productName,
      'price': price,
    });
  }
