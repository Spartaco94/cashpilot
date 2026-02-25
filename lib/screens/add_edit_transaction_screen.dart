import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../models/transaction.dart';
import '../providers/transaction_provider.dart';
import '../providers/category_provider.dart';

class AddEditTransactionScreen extends ConsumerStatefulWidget {
  final String? transactionId;
  const AddEditTransactionScreen({super.key, this.transactionId});

  @override
  ConsumerState<AddEditTransactionScreen> createState() => _AddEditTransactionState();
}

class _AddEditTransactionState extends ConsumerState<AddEditTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  late TransactionType _type;
  late TextEditingController _amountCtrl;
  late TextEditingController _descCtrl;
  String? _category;
  late DateTime _date;
  bool _recurring = false;
  bool _isEdit = false;

  @override
  void initState() {
    super.initState();
    _type = TransactionType.expense;
    _amountCtrl = TextEditingController();
    _descCtrl = TextEditingController();
    _date = DateTime.now();

    if (widget.transactionId != null) {
      final all = ref.read(transactionProvider);
      try {
        final t = all.firstWhere((tx) => tx.id == widget.transactionId);
        _isEdit = true;
        _type = t.type;
        _amountCtrl.text = t.amount.toStringAsFixed(2);
        _descCtrl.text = t.description;
        _category = t.category;
        _date = t.date;
        _recurring = t.isRecurring;
      } catch (_) {}
    }
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoryProvider);

    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? 'Modifica Transazione' : 'Nuova Transazione')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SegmentedButton<TransactionType>(
                segments: const [
                  ButtonSegment(value: TransactionType.income, label: Text('Entrata'), icon: Icon(Icons.trending_up)),
                  ButtonSegment(value: TransactionType.expense, label: Text('Uscita'), icon: Icon(Icons.trending_down)),
                ],
                selected: {_type},
                onSelectionChanged: (s) => setState(() => _type = s.first),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountCtrl,
                decoration: const InputDecoration(labelText: 'Importo (€)', prefixIcon: Icon(Icons.euro)),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))],
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Inserisci un importo';
                  final n = double.tryParse(v);
                  if (n == null || n <= 0) return 'Importo non valido';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _category,
                decoration: const InputDecoration(labelText: 'Categoria', prefixIcon: Icon(Icons.category)),
                items: categories.map((c) => DropdownMenuItem(value: c.name, child: Text('${c.emoji} ${c.name}'))).toList(),
                onChanged: (v) => setState(() => _category = v),
                validator: (v) => v == null ? 'Seleziona una categoria' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descCtrl,
                decoration: const InputDecoration(labelText: 'Descrizione', prefixIcon: Icon(Icons.notes)),
                maxLines: 1,
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today),
                title: Text(DateFormat('dd MMMM yyyy', 'it').format(_date)),
                trailing: const Icon(Icons.edit_calendar),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _date,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                  );
                  if (picked != null) setState(() => _date = picked);
                },
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Transazione ricorrente'),
                secondary: const Icon(Icons.repeat),
                value: _recurring,
                onChanged: (v) => setState(() => _recurring = v),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: Icon(_isEdit ? Icons.save : Icons.add),
                label: Text(_isEdit ? 'Salva Modifiche' : 'Aggiungi Transazione'),
                onPressed: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final tx = Transaction(
      id: widget.transactionId ?? const Uuid().v4(),
      type: _type,
      amount: double.parse(_amountCtrl.text),
      category: _category!,
      description: _descCtrl.text,
      date: _date,
      isRecurring: _recurring,
    );

    if (_isEdit) {
      ref.read(transactionProvider.notifier).update(widget.transactionId!, tx);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Transazione aggiornata!')));
    } else {
      ref.read(transactionProvider.notifier).add(tx);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Transazione aggiunta!')));
    }
    context.pop();
  }
}
