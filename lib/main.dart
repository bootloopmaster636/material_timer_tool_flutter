import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:time/time.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const Main());
}

class Main extends StatelessWidget {
  const Main({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ClockEngine(),
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
          useMaterial3: true,
        ),
        home: const ClockPage(),
      ),
    );
  }
}

class ClockEngine extends ChangeNotifier {
  Duration display = const Duration(seconds: 0);

  Future<void> _selectTime(BuildContext context) async {
    final selectedTime = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 0, minute: 0),
    );

    if (selectedTime != null &&
        selectedTime !=
            TimeOfDay(hour: display.inHours, minute: display.inMinutes)) {
      display =
          Duration(hours: selectedTime.hour, minutes: selectedTime.minute);
      notifyListeners();
    }
  }

  late Timer _timer;
  startCountDown() {
    _timer = Timer.periodic(1.seconds, (timer) {
      if (display.inSeconds > 0) {
        display = display - 1.seconds;
        notifyListeners();
      } else {
        _timer.cancel();
      }
    });
  }
}

class ClockPage extends StatefulWidget {
  const ClockPage({super.key});

  @override
  State<ClockPage> createState() => _ClockPageState();
}

class _ClockPageState extends State<ClockPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.timer),
          onPressed: () {
            context.read<ClockEngine>()._selectTime(context);
          },
        ),
        title: const Text('Clock'),
      ),
      body: Center(
        child: Column(
          children: [
           StreamBuilder(builder: (context, snapshot) {
             return Text(
               context.watch<ClockEngine>().display.toString().split('.')[0],
               style: Theme.of(context).textTheme.displayLarge,
             );}),
            ElevatedButton(
              onPressed: () {
                context.read<ClockEngine>().startCountDown();
              },
              child: const Text('Start'),
            ),
          ],
        ),
      ),
    );
  }
}
