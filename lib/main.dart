import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:confetti/confetti.dart';
import 'package:uuid/uuid.dart';
import 'dart:math' show pi;
import 'models/button_model.dart';
import 'services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final storageService = StorageService(prefs);
  runApp(MyApp(storageService: storageService));
}

class MyApp extends StatelessWidget {
  final StorageService storageService;

  const MyApp({super.key, required this.storageService});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Button Management Interface',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: ButtonManagementScreen(storageService: storageService),
    );
  }
}

class ButtonManagementScreen extends StatefulWidget {
  final StorageService storageService;

  const ButtonManagementScreen({super.key, required this.storageService});

  @override
  State<ButtonManagementScreen> createState() => _ButtonManagementScreenState();
}

class _ButtonManagementScreenState extends State<ButtonManagementScreen> {
  List<ButtonModel> buttons = [];
  late ConfettiController _confettiController;
  int totalCount = 0;

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 1));
    _loadButtons();
  }

  Future<void> _loadButtons() async {
    final loadedButtons = await widget.storageService.getButtons();
    setState(() {
      buttons = loadedButtons;
      _updateTotalCount();
    });
  }

  void _updateTotalCount() {
    totalCount = buttons.fold(0, (sum, button) => sum + button.count);
  }

  Future<void> _saveButtons() async {
    await widget.storageService.saveButtons(buttons);
  }

  void _decrementCount(ButtonModel button) {
    setState(() {
      button.count--;
      _updateTotalCount();
      _saveButtons();
    });

    if (button.count == 0) {
      _confettiController.play();
    }
  }

  void _showEditDialog(ButtonModel button) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Button'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'Label'),
              controller: TextEditingController(text: button.label),
              onChanged: (value) => button.label = value,
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Count'),
              controller: TextEditingController(text: button.count.toString()),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                if (value.isNotEmpty) {
                  button.count = int.parse(value);
                }
              },
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: [
                Colors.blue,
                Colors.red,
                Colors.green,
                Colors.yellow,
                Colors.purple,
              ]
                  .map((color) => GestureDetector(
                        onTap: () {
                          setState(() {
                            button.color = color;
                          });
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: button.color == color
                                  ? Colors.black
                                  : Colors.transparent,
                            ),
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                buttons.remove(button);
                _updateTotalCount();
                _saveButtons();
              });
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
          TextButton(
            onPressed: () {
              _saveButtons();
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showAddDialog() {
    final newButton = ButtonModel(
      label: '',
      count: 0,
      color: Colors.blue,
      id: const Uuid().v4(),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Button'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'Label'),
              onChanged: (value) => newButton.label = value,
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Count'),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                if (value.isNotEmpty) {
                  newButton.count = int.parse(value);
                }
              },
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: [
                Colors.blue,
                Colors.red,
                Colors.green,
                Colors.yellow,
                Colors.purple,
              ]
                  .map((color) => GestureDetector(
                        onTap: () {
                          setState(() {
                            newButton.color = color;
                          });
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: newButton.color == color
                                  ? Colors.black
                                  : Colors.transparent,
                            ),
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (newButton.label.isNotEmpty) {
                setState(() {
                  buttons.add(newButton);
                  _updateTotalCount();
                  _saveButtons();
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: const Text('Button Management'),
            actions: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Total: $totalCount',
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
          body: buttons.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'No buttons yet!',
                        style: TextStyle(fontSize: 24),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _showAddDialog,
                        child: const Text('Add Your First Button'),
                      ),
                    ],
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: buttons.length,
                  itemBuilder: (context, index) {
                    final button = buttons[index];
                    return GestureDetector(
                      onTap: () => _decrementCount(button),
                      onLongPress: () => _showEditDialog(button),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: button.color
                              .withOpacity(button.count == 0 ? 0.5 : 1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              button.label,
                              style: TextStyle(
                                fontSize: 20,
                                color: button.count == 0
                                    ? Colors.green
                                    : Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              button.count.toString(),
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
          floatingActionButton: FloatingActionButton(
            onPressed: _showAddDialog,
            child: const Icon(Icons.add),
          ),
        ),
        ConfettiWidget(
          confettiController: _confettiController,
          blastDirection: -pi / 2,
          maxBlastForce: 5,
          minBlastForce: 1,
          emissionFrequency: 0.05,
          numberOfParticles: 50,
          gravity: 0.1,
          shouldLoop: false,
          colors: const [
            Colors.green,
            Colors.blue,
            Colors.pink,
            Colors.orange,
            Colors.purple,
          ],
          child: Container(),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }
}
