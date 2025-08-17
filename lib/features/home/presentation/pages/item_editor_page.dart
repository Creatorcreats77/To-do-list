import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/datasources/db_helper.dart';
import '../../data/models/item_model.dart';

class ItemEditorDialog extends StatefulWidget {
  final int categoryId;
  final ItemModel? item;
  final int? isDone;

  ItemEditorDialog({required this.categoryId, this.item, this.isDone});

  @override
  _ItemEditorDialogState createState() => _ItemEditorDialogState();
}

class _ItemEditorDialogState extends State<ItemEditorDialog> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _textController = TextEditingController();

  String _title = '';
  String _text = '';

  DateTime? _selectedDate; // 📅 picked date
  TimeOfDay? _selectedTime; // ⏰ picked time
  List<String> _selectedDays = []; // 📆 repeat days (0 = Monday ... 6 = Sunday)
  
  bool _addReminder = false;
  bool _dateOrdays = false;

  @override
  void initState() {
    super.initState();

    if (widget.item != null) {
      _titleController.text = widget.item!.title;
      _textController.text = widget.item!.text;

      // If editing an existing reminder
      if (widget.item!.reminderAt != null) {
        final dt = DateTime.tryParse(widget.item!.reminderAt!);
        if (dt != null) {
          _selectedDate = dt;
          _selectedTime = TimeOfDay.fromDateTime(dt);
        }
      }
      if (widget.item!.repeatDays != null) {
        _selectedDays = List<String>.from(widget.item!.repeatDays!);
      }
    }
  }

  void saveData() {
    _title = _titleController.text.trim();
    _text = _textController.text.trim();
  }

  @override
  Widget build(BuildContext context) {
    final app = Provider.of<AppState>(context);
    return AlertDialog(
      title: Text(widget.item == null ? 'New item' : 'Edit item'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            SizedBox(height: 8),
            TextFormField(
              controller: _textController,
              decoration: InputDecoration(labelText: 'Text'),
            ),
            SizedBox(height: 16),


            
            
            
            
            
            
            _addReminder ? 
            Column(
              children: [
                // 📅 Select date
                Row(
                  children: [
                    Text("Date: "),
                    TextButton(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate ?? DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setState(() => _selectedDate = picked);
                        }
                      },
                      child: Text(
                        _selectedDate == null
                            ? "Pick date"
                            : "${_selectedDate!.toLocal()}".split(' ')[0],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 8),

                // ⏰ Select time

                // 📆 Repeat days (M T W T F S S)
                Text("Repeat on:"),
                Wrap(
                  children: [
                    for (final day in [
                      'Mon',
                      'Tue',
                      'Wed',
                      'Thu',
                      'Fri',
                      'Sat',
                      'Sun',
                    ])
                      FilterChip(
                        label: Text(day),
                        selected: _selectedDays.contains(day),
                        selectedColor: Colors.green,
                        checkmarkColor: Colors.white, // optional check icon color
                        labelStyle: TextStyle(
                          color: _selectedDays.contains(day) ? Colors.white : Colors.black,
                        ),
                        onSelected: _selectedDate == null ? (selected) {
                          setState(() {
                            if (selected) {
                              _selectedDays.add(day);
                              print(_selectedDays);
                            } else {
                              _selectedDays.remove(day);
                            }
                          });
                        } : null,
                      )

                  ],
                ),

                Row(
                  children: [
                    Text("Time: "),
                    TextButton(
                      onPressed: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: _selectedTime ?? TimeOfDay.now(),
                        );
                        if (picked != null) {
                          setState(() => _selectedTime = picked);
                        }
                      },
                      child: Text(
                        _selectedTime == null
                            ? "Pick time"
                            : _selectedTime!.format(context),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 12),
              ],
            ) :
            TextButton(onPressed: (){
              setState(() {
                _addReminder = !_addReminder;
              });
            }, child: Text('Add reminder'))
                
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            saveData();

            final now = DateTime.now().toIso8601String();
            final reminderDateTime =
                (_selectedDate != null && _selectedTime != null && _selectedDays.isEmpty)
                ? DateTime(
                    _selectedDate!.year,
                    _selectedDate!.month,
                    _selectedDate!.day,
                    _selectedTime!.hour,
                    _selectedTime!.minute,
                  )
                : null;
            print("aaaaaaaaaaaaaaaaaaaaa: $reminderDateTime");
            final newItem = ItemModel(
              id: widget.item?.id,
              categoryId: widget.categoryId,
              title: _title,
              text: _text,
              isDone: widget.isDone,
              createdAt: widget.item?.createdAt ?? now,
              reminderAt: reminderDateTime?.toIso8601String(),
              repeatDays: _selectedDays.isNotEmpty ? _selectedDays : null,
              reminderTime: _selectedTime != null ? "${_selectedTime!.hour}:${_selectedTime!.minute}" : null,
            );

            print("Herererereeeeeeeeeeeeee : $newItem");
            app.addOrUpdateItem(newItem);

            // TODO: schedule notification here

            Navigator.pop(context);
          },
          child: Text('Save'),
        ),
      ],
    );
  }
}
