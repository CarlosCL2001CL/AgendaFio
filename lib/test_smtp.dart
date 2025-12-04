import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'dart:developer' as developer;

// coverage:ignore-start
void testSmtp() async {
  String username = 'agendafio@gmail.com';
  String password = 'zkkc nqaj gsbq zxet';

  final smtpServer = gmail(username, password);

  final message = Message()
    ..from = Address(username, 'Agenda Fio')
    ..recipients.add('lissjeancarlos@gmail.com')
    ..subject = 'Prueba de correo electrónico desde Flutter'
    ..text =
        'Este es un correo de prueba enviado desde una aplicación de Flutter.';

  try {
    final sendReport = await send(message, smtpServer);
    developer.log(
      'Mensaje enviado: ${sendReport.toString()}',
      name: 'testSmtp',
    );
  } on MailerException catch (e, s) {
    developer.log('El mensaje no se pudo enviar.', name: 'testSmtp');
    for (var p in e.problems) {
      developer.log('Problema: ${p.code}: ${p.msg}', name: 'testSmtp');
    }
    developer.log(
      'Excepción de Mailer capturada',
      name: 'testSmtp',
      error: e,
      stackTrace: s,
    );
  } catch (e, s) {
    developer.log(
      'Se capturó una excepción desconocida',
      name: 'testSmtp',
      error: e,
      stackTrace: s,
    );
  }
}

// coverage:ignore-end
