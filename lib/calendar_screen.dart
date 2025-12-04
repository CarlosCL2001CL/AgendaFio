import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/widgets/auth_widgets.dart';
import 'package:myapp/widgets/ui_widgets.dart';

// Modelo para representar un gasto
class Expense {
  final String id;
  final String productName;
  final double price;
  final DateTime date;

  Expense({
    required this.id,
    required this.productName,
    required this.price,
    required this.date,
  });
}

// Función auxiliar para normalizar fechas (solo año, mes, día sin hora)
DateTime _normalizeDate(DateTime date) {
  return DateTime(date.year, date.month, date.day);
}

// Función para convertir DateTime a string de fecha (YYYY-MM-DD)
String _dateToString(DateTime date) {
  return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
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
    _selectedDay = _normalizeDate(_focusedDay);
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
      extendBodyBehindAppBar: true, // Extender el cuerpo detrás de la AppBar
      appBar: AppBar(
        backgroundColor: Colors.transparent, // AppBar transparente
        elevation: 0, // Sin sombra
        title: const Text(
          'AgendaFio',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _signOut,
            tooltip: 'Cerrar Sesión',
          ),
        ],
      ),
      body: GradientBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 24.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Mensaje de bienvenida
                Padding(
                  padding: const EdgeInsets.only(bottom: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bienvenid@ ${_user?.email?.split('@').first ?? 'Usuario'}',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Gestiona tus gastos diarios',
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                      ),
                    ],
                  ),
                ),

                // Calendario en una tarjeta transparente
                TransparentCard(
                  child: TableCalendar(
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
                          _selectedDay = _normalizeDate(selectedDay);
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
                      setState(() {
                        _focusedDay = focusedDay;
                      });
                    },
                    calendarBuilders: CalendarBuilders(
                      dowBuilder: (context, day) {
                        final text = DateFormat.E('es_ES').format(day);
                        return Center(
                          child: Text(
                            text,
                            style: const TextStyle(color: Colors.white),
                          ),
                        );
                      },
                    ),
                    daysOfWeekStyle: const DaysOfWeekStyle(
                      weekdayStyle: TextStyle(color: Colors.white),
                      weekendStyle: TextStyle(color: Colors.white),
                    ),
                    calendarStyle: CalendarStyle(
                      todayDecoration: BoxDecoration(
                        color: Colors.deepPurpleAccent.withOpacity(0.7),
                        shape: BoxShape.circle,
                      ),
                      selectedDecoration: const BoxDecoration(
                        color: Colors.deepPurple,
                        shape: BoxShape.circle,
                      ),
                      markerDecoration: const BoxDecoration(
                        color: Colors.amber,
                        shape: BoxShape.circle,
                      ),
                      defaultTextStyle: const TextStyle(color: Colors.white),
                      weekendTextStyle: const TextStyle(color: Colors.white70),
                      outsideTextStyle: const TextStyle(color: Colors.white30),
                    ),
                    headerStyle: const HeaderStyle(
                      titleCentered: true,
                      formatButtonVisible: false,
                      titleTextStyle: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      leftChevronIcon: Icon(
                        Icons.chevron_left,
                        color: Colors.white,
                      ),
                      rightChevronIcon: Icon(
                        Icons.chevron_right,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24.0),

                // Gastos y totales
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 16.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Gastos del Día',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      MonthlyTotalWidget(focusedDay: _focusedDay, user: _user),
                    ],
                  ),
                ),

                // Lista de gastos
                SizedBox(
                  height: 300,
                  child: DailyExpensesList(
                    selectedDay: _selectedDay,
                    user: _user,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (_selectedDay == null || _user == null)
            ? null
            : () => _showAddExpenseDialog(context, _selectedDay, _user),
        backgroundColor: Colors.transparent,
        elevation: 0,
        tooltip: 'Añadir Gasto',
        child: const Icon(Icons.add, color: Colors.white),
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
    if (user == null) {
      return const Text(
        'Total del Mes: \$0.00',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.red,
        ),
      );
    }

    final firstDayOfMonth = DateTime(focusedDay.year, focusedDay.month, 1);
    final lastDayOfMonth = DateTime(focusedDay.year, focusedDay.month + 1, 0);

    final startOfMonth = _dateToString(firstDayOfMonth);
    final endOfMonth = _dateToString(lastDayOfMonth);

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('expenses')
          .where('userId', isEqualTo: user!.uid)
          .where('dateString', isGreaterThanOrEqualTo: startOfMonth)
          .where('dateString', isLessThanOrEqualTo: endOfMonth)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator(color: Colors.white);
        }

        if (!snapshot.hasData || snapshot.hasError) {
          return const Text(
            'Total del Mes: \$0.00',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          );
        }

        double monthlyTotal = 0.0;
        for (var doc in snapshot.data!.docs) {
          final data = doc.data() as Map<String, dynamic>?;
          if (data != null) {
            final price = data['price'] as num?;
            if (price != null) {
              monthlyTotal += price.toDouble();
            }
          }
        }

        return Text(
          'Total del Mes: \$${monthlyTotal.toStringAsFixed(2)}',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.greenAccent,
          ),
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
      return const Center(
        child: Text(
          'Selecciona un día para ver los gastos',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    final dateString = _dateToString(selectedDay!);

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('expenses')
          .where('userId', isEqualTo: user!.uid)
          .where('dateString', isEqualTo: dateString)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        }

        if (!snapshot.hasData || snapshot.hasError) {
          return const Center(
            child: Text(
              'Error al cargar gastos',
              style: TextStyle(color: Colors.red),
            ),
          );
        }

        final expenses = snapshot.data!.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return Expense(
            id: doc.id,
            productName: data['productName'] ?? 'Sin nombre',
            price: (data['price'] as num? ?? 0.0).toDouble(),
            date: selectedDay!,
          );
        }).toList();

        if (expenses.isEmpty) {
          return const Center(
            child: Text(
              'No hay gastos para este día.',
              style: TextStyle(color: Colors.white70),
            ),
          );
        }

        double dailyTotal = 0.0;
        for (var expense in expenses) {
          dailyTotal += expense.price;
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Text(
                'Total del día: \$${dailyTotal.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                itemCount: expenses.length,
                itemBuilder: (context, index) {
                  final expense = expenses[index];
                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: Colors.white.withOpacity(0.9),
                    child: ListTile(
                      title: Text(
                        expense.productName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '\$${expense.price.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.redAccent,
                            ),
                            onPressed: () =>
                                _deleteExpense(context, expense.id),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  void _deleteExpense(BuildContext context, String expenseId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Eliminar Gasto'),
          content: const Text(
            '¿Estás seguro de que deseas eliminar este gasto?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                FirebaseFirestore.instance
                    .collection('expenses')
                    .doc(expenseId)
                    .delete();
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }
}

Future<void> _showAddExpenseDialog(
  BuildContext context,
  DateTime? selectedDay,
  User? user,
) async {
  final productNameController = TextEditingController();
  final priceController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: Colors.white.withOpacity(0.2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Añadir Nuevo Gasto',
          style: TextStyle(color: Colors.white),
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: productNameController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Producto',
                  labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.white.withOpacity(0.5),
                    ),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white, width: 2),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, introduce un nombre de producto';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: priceController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Precio (USD)',
                  labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                  prefixText: '\$',
                  prefixStyle: const TextStyle(color: Colors.white),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.white.withOpacity(0.5),
                    ),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white, width: 2),
                  ),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
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
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Colors.white),
            ),
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
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Guardar', style: TextStyle(color: Colors.white)),
          ),
        ],
      );
    },
  );
}

void _addExpense(
  String productName,
  double price,
  DateTime? selectedDay,
  User? user,
) {
  if (user == null || selectedDay == null) return;

  final normalizedDay = _normalizeDate(selectedDay);
  final dateString = _dateToString(normalizedDay);

  FirebaseFirestore.instance.collection('expenses').add({
    'userId': user.uid,
    'dateString': dateString,
    'productName': productName,
    'price': price,
    'timestamp': FieldValue.serverTimestamp(),
  });
}
