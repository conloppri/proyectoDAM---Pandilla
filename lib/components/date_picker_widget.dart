import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DatePickerWidget extends StatefulWidget {
  final DateTime selectedDate;
  final String label;
  final DateTime firstDate;
  final DateTime lastDate;
  final Function onDateSelected;
  final Color buttonColor;
  final TextStyle labelStyle;
  const DatePickerWidget({super.key, required this.label, required this.firstDate, required this.lastDate, required this.onDateSelected, this.buttonColor = Colors.white, this.labelStyle = const TextStyle(), required this.selectedDate});

  @override
  State<DatePickerWidget> createState() => _DatePickerWidgetState();
}

class _DatePickerWidgetState extends State<DatePickerWidget> {
  DateTime _selectedDate =  DateTime.now();

  @override
  void didUpdateWidget(covariant DatePickerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.selectedDate != widget.selectedDate) {
      _selectedDate = widget.selectedDate;
    }
  }

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.selectedDate;
  }
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(widget.label, style: widget.labelStyle,),
        const SizedBox(width: 20),
        ElevatedButton(onPressed: () async {
                final picked = await showDatePicker(context: context,
                firstDate: widget.firstDate ,
                lastDate: widget.lastDate ,
                initialDate: widget.selectedDate);
                if(picked!=null){
                  setState(() {
                    _selectedDate = picked;
                  });
                  widget.onDateSelected(_selectedDate);
                }
        },
            style: ElevatedButton.styleFrom(backgroundColor: widget.buttonColor ),
            child: Text(DateFormat("dd/MM/yyyy").format(_selectedDate), style: widget.labelStyle,))
      ],
    );
  }
}
