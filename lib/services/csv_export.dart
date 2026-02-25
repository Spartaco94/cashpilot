import 'package:intl/intl.dart';
import '../models/transaction.dart';
import 'dart:convert';
import 'dart:html' as html;

class CsvExportService {
  static void exportTransactions(List<Transaction> transactions) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final buffer = StringBuffer();
    buffer.writeln('Tipo,Importo,Categoria,Descrizione,Data,Ricorrente');

    for (final t in transactions) {
      final type = t.type == TransactionType.income ? 'Entrata' : 'Uscita';
      final amount = t.amount.toStringAsFixed(2);
      final cat = t.category;
      final desc = '"${t.description.replaceAll('"', '""')}"';
      final date = dateFormat.format(t.date);
      final recurring = t.isRecurring ? 'Si' : 'No';
      buffer.writeln('$type,$amount,$cat,$desc,$date,$recurring');
    }

    final bytes = utf8.encode(buffer.toString());
    final blob = html.Blob([bytes], 'text/csv');
    final url = html.Url.createObjectUrlFromBlob(blob);
    html.AnchorElement(href: url)
      ..setAttribute('download', 'cashpilot_export_${DateFormat('yyyyMMdd').format(DateTime.now())}.csv')
      ..click();
    html.Url.revokeObjectUrl(url);
  }
}
