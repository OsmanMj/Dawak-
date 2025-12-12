import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/medication.dart';
import '../providers/medication_provider.dart';

class AddMedicationScreen extends StatefulWidget {
  final Medication? medication;
  const AddMedicationScreen({super.key, this.medication});

  @override
  State<AddMedicationScreen> createState() => _AddMedicationScreenState();
}

class _AddMedicationScreenState extends State<AddMedicationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _doseController = TextEditingController();

  Frequency _frequency = Frequency.daily;
  List<TimeOfDay> _scheduleTimes = [const TimeOfDay(hour: 9, minute: 0)];

  @override
  void initState() {
    super.initState();
    if (widget.medication != null) {
      _nameController.text = widget.medication!.name;
      _doseController.text = widget.medication!.dose;
      _frequency = widget.medication!.frequency;
      _scheduleTimes = List.from(widget.medication!.scheduleTimes);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _doseController.dispose();
    super.dispose();
  }

  Future<void> _selectTime(int index) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _scheduleTimes[index],
    );
    if (picked != null) {
      setState(() {
        _scheduleTimes[index] = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            widget.medication == null ? 'إضافة دواء جديد' : 'تعديل الدواء'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'اسم الدواء',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.medical_services),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى إدخال اسم الدواء';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _doseController,
                decoration: const InputDecoration(
                  labelText: 'الجرعة (مثال: 500mg, 1 حبة)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.scale),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى إدخال الجرعة';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              const Text('تكرار التناول',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              DropdownButtonFormField<Frequency>(
                value: _frequency,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                items: Frequency.values.map((f) {
                  String label;
                  switch (f) {
                    case Frequency.daily:
                      label = 'يومي';
                      break;
                    case Frequency.weekly:
                      label = 'أسبوعي';
                      break;
                    case Frequency.monthly:
                      label = 'شهري';
                      break;
                    case Frequency.asNeeded:
                      label = 'عند اللزوم';
                      break;
                  }
                  return DropdownMenuItem(value: f, child: Text(label));
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _frequency = val);
                },
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('أوقات التناول',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.add_circle, color: Colors.teal),
                    onPressed: () {
                      setState(() {
                        _scheduleTimes.add(const TimeOfDay(hour: 8, minute: 0));
                      });
                    },
                  )
                ],
              ),
              ..._scheduleTimes.asMap().entries.map((entry) {
                int index = entry.key;
                TimeOfDay time = entry.value;
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: const Icon(Icons.access_time),
                    title: Text('${time.format(context)}'),
                    trailing: _scheduleTimes.length > 1
                        ? IconButton(
                            icon: const Icon(Icons.remove_circle,
                                color: Colors.red),
                            onPressed: () {
                              setState(() {
                                _scheduleTimes.removeAt(index);
                              });
                            },
                          )
                        : null,
                    onTap: () => _selectTime(index),
                  ),
                );
              }),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _saveMedication,
                  child: const Text('حفظ', style: TextStyle(fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveMedication() {
    if (_formKey.currentState!.validate()) {
      final medication = Medication(
        id: widget.medication?.id ?? const Uuid().v4(),
        name: _nameController.text,
        dose: _doseController.text,
        frequency: _frequency,
        scheduleTimes: _scheduleTimes,
        startDate: DateTime.now(),
      );

      final provider = Provider.of<MedicationProvider>(context, listen: false);
      if (widget.medication != null) {
        provider.updateMedication(medication);
      } else {
        provider.addMedication(medication);
      }

      Navigator.pop(context);
    }
  }
}
