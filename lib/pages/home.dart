import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:calories/provider/db_provider.dart';

class MyHomePage extends StatelessWidget {
  // ignore: use_super_parameters
  const MyHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Fit App"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ChangeNotifierProvider(
            create: (context) => DatabaseProvider(),
            child: Consumer<DatabaseProvider>(
              builder: (context, provider, child) {
                final List<String> activityLevels =
                    DatabaseProvider.activityMultipliers.keys.toList();
                final List<String> goals = DatabaseProvider.goals.keys.toList();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Enter your age:",
                      style: TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        provider.age = int.tryParse(value) ?? 0;
                      },
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Enter your age',
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Enter your weight (lbs):",
                      style: TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        provider.weightInPounds = int.tryParse(value) ?? 0;
                      },
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Enter your weight in pounds',
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Enter your height:",
                      style: TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              provider.heightInFeet =
                                  double.tryParse(value) ?? 0.0;
                            },
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Feet',
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              provider.heightInInches =
                                  double.tryParse(value) ?? 0.0;
                            },
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Inches',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Select your activity level:",
                      style: TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                      hint: const Text("Select your activity level"),
                      value: provider.selectedActivity,
                      onChanged: (value) {
                        provider.selectedActivity = value;
                      },
                      items: activityLevels.map((level) {
                        return DropdownMenuItem<String>(
                          value: level,
                          child: Text(level),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Select your top 3 goals:",
                      style: TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    Column(
                      children: goals.map((goal) {
                        return ListTile(
                          title: Text(goal),
                          trailing: provider.primaryGoal == goal
                              ? const Text('1')
                              : provider.secondaryGoal == goal
                                  ? const Text('2')
                                  : provider.thirdGoal == goal
                                      ? const Text('3')
                                      : null,
                          onTap: () {
                            if (provider.primaryGoal == goal ||
                                provider.secondaryGoal == goal ||
                                provider.thirdGoal == goal) {
                              provider.removeGoal(goal);
                            } else {
                              provider.addGoal(goal);
                            }
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          if (provider.primaryGoal != null &&
                              provider.secondaryGoal != null &&
                              provider.thirdGoal != null) {
                            // Perform calculation only once
                            final tdee = provider.calculateTDEE();
                            final ratios = provider.calculateRatios();
                            provider.recipe(); 
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('TDEE Calculation Result'),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                          'Your TDEE is: ${tdee.toStringAsFixed(2)}'),
                                      const SizedBox(height: 8),
                                      const Text(
                                        'You should have the following amounts per day:',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                          'Protein: ${ratios['protein']?.toStringAsFixed(2)} grams'),
                                      Text(
                                          'Fat: ${ratios['fat']?.toStringAsFixed(2)} grams'),
                                      Text(
                                          'Carbohydrates: ${ratios['carbs']?.toStringAsFixed(2)} grams'),
                                    ],
                                  ),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text('OK'),
                                    ),
                                  ],
                                );
                              },
                            );
                          } else {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Selection Error'),
                                  content: const Text(
                                      'Please select exactly 3 goals.'),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text('OK'),
                                    ),
                                  ],
                                );
                              },
                            );
                          }
                        },
                        child: const Text('Submit'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Logs:",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: provider.logs.map((log) {
                        return Text(log);
                      }).toList(),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
