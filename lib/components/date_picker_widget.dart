import 'package:flutter/material.dart';

class DatePickerWidget extends StatefulWidget {
  final DateTime selectedDate = DateTime.now();
  final String label;
  final DateTime firstDate;
  final DateTime lastDate;
  final Function onDateSelected;
  DatePickerWidget({super.key, required this.label, required this.firstDate, required this.lastDate, required this.onDateSelected});

  @override
  State<DatePickerWidget> createState() => _DatePickerWidgetState();

  DateTime getDate(){
    return selectedDate;
  }
}

class _DatePickerWidgetState extends State<DatePickerWidget> {
  DateTime _selectedDate =  DateTime.now();
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(widget.label),
        SizedBox(width: 20),
        ElevatedButton(onPressed: () async {
                _selectedDate = await showDatePicker(context: context,
                firstDate: widget.firstDate ,
                lastDate: widget.lastDate ,
                initialDate: _selectedDate) as DateTime;
              setState(() {});
              widget.onDateSelected(_selectedDate);
        },
            child: Text("${_selectedDate.day<10?"0${_selectedDate.day}":"${_selectedDate.day}"}/${_selectedDate.month<10?"0${_selectedDate.month}":"${_selectedDate.month}"}/${_selectedDate.year}"))
      ],
    );
  }
}
