import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class DatabaseProvider with ChangeNotifier {
  static const Map<String, double> activityMultipliers = {
    'Sedentary': 1.2,
    'Lightly Active': 1.375,
    'Moderately Active': 1.55,
    'Very Active': 1.725,
    'Extremely Active': 1.9,
  };
  static const Map<String, double> goals = {
    'Build Muscles': 0.10, // 10% increase
    'Shape Up': 0.05, // 5% increase
    'Get Stronger': 0.15, // 15% increase
    'Lose Weight': -0.20, // 20% decrease
    'Improve Flexibility': 0.0, // No change
    'General Fitness': 0.0, // No change
  };
  List<Map<String, double>> recipes = [
    {
      'calories': 521,
      'carbs': 15,
      'protein': 48,
      'fat': 40,
    },
    {
      'calories': 521,
      'carbs': 10,
      'protein': 20,
      'fat': 30,
    },
    {
      'calories': 100,
      'carbs': 12,
      'protein': 15,
      'fat': 11,
    }
  ];

  void recipe() {
    Map<String, double> calculatedRatios = calculateRatios();
// Initialize totals
    double totalCalories = 0;
    double totalCarbs = 0;
    double totalProtein = 0;
    double totalFat = 0;

    // Sum up the values
    for (var recipe in recipes) {
      totalCalories += recipe['calories']!;
      totalCarbs += recipe['carbs']!;
      totalProtein += recipe['protein']!;
      totalFat += recipe['fat']!;
    

    print('Total Calories: $totalCalories');
    print('Total Carbs: $totalCarbs grams');
    print('Total Protein: $totalProtein grams');
    print('Total Fat: $totalFat grams');

   

      double calculatedProtein = calculatedRatios['protein']!;
      double calculatedFat = calculatedRatios['fat']!;
      double calculatedCarbs = calculatedRatios['carbs']!;

      double proteinPercentage = (totalProtein / calculatedProtein) * 100;
      double fatPercentage = (totalFat / calculatedFat) * 100;
      double carbPercentage = (totalCarbs / calculatedCarbs) * 100;
      print('Protein in the recipe : ${proteinPercentage.toStringAsFixed(2)}%');
      print('Fat in the recipe : ${fatPercentage.toStringAsFixed(2)}%');
      print('Carbs in the recipe : ${carbPercentage.toStringAsFixed(2)}%');

      List<String> goalsList = [
        if (primaryGoal != null) primaryGoal!,
        if (secondaryGoal != null) secondaryGoal!,
        if (thirdGoal != null) thirdGoal!,
      ];

      MacronutrientRatios? ratios = findMacronutrientRatios(goalsList);
      if (ratios != null) {
        double protratio = ratios.proteinRatio * 100;
        double fatratio = ratios.fatRatio * 100;
        double carbratio = ratios.carbRatio * 100;
        print(' The protein  ratios : $protratio');
        print(' The fat  ratios : $fatratio');
        print(' The carbs  ratios : $carbratio');

        double goalProtein = (proteinPercentage / protratio) * 100;
        double goalFat = (fatPercentage / fatratio) * 100;
        double goalCarbs = (carbPercentage / carbratio) * 100;

        print('You Acheived : ');
        print('$goalCarbs from what you need in carbs');
        print('$goalProtein from what yoy need in protein');
        print('$goalFat from what yoy need in fat');
      }
    }
  }

  void addGoal(String goal) {
    if (primaryGoal == null) {
      primaryGoal = goal;
    } else if (secondaryGoal == null) {
      secondaryGoal = goal;
      // ignore: prefer_conditional_assignment
    } else if (thirdGoal == null) {
      thirdGoal = goal;
    }
    notifyListeners();
  }

  void removeGoal(String goal) {
    if (primaryGoal == goal) {
      primaryGoal = secondaryGoal;
      secondaryGoal = thirdGoal;
      thirdGoal = null;
    } else if (secondaryGoal == goal) {
      secondaryGoal = thirdGoal;
      thirdGoal = null;
    } else if (thirdGoal == goal) {
      thirdGoal = null;
    }

    notifyListeners();
  }

  // User data fields
  int age = 0;
  int weightInPounds = 0;
  double heightInFeet = 0.0;
  double heightInInches = 0.0;
  String? selectedActivity;

  // Selected goals
  String? primaryGoal;
  String? secondaryGoal;
  String? thirdGoal;
  // Calculate height in inches
  double get heightInTotalInches => (heightInFeet * 12) + heightInInches;

  // Calculate BMR for females using the Harris-Benedict Equation
  double calculateBMR() {
    return (4.536 * weightInPounds) +
        (15.88 * heightInTotalInches) -
        (5.0 * age) -
        161.0;
  }

  List<String> logs = [];
  double _cachedTDEE = 0.0;

  void addLog(String message) {
    // Schedule the state update after the build phase
    if (!logs.contains(message)) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        logs.add(message);
        notifyListeners();
      });
    }
  }

  double calculateTDEE() {
    if (selectedActivity != null &&
        activityMultipliers.containsKey(selectedActivity)) {
      double bmr = calculateBMR();
      double activityMultiplier = activityMultipliers[selectedActivity]!;
      double baseTDEE = bmr * activityMultiplier;

      if (_cachedTDEE == 0.0) {
        addLog('BMR is $bmr');
        addLog('TDEE before adjustment is $baseTDEE');
        addLog("goals : $primaryGoal ; $secondaryGoal ; $thirdGoal");

        List<String> goalsList = [
          if (primaryGoal != null) primaryGoal!,
          if (secondaryGoal != null) secondaryGoal!,
          if (thirdGoal != null) thirdGoal!,
        ];

        addLog("Goals List: $goalsList");

        GoalAdjustments? adjustments = findGoalAdjustments(goalsList);
        addLog("Adjustments: $adjustments");
        if (adjustments != null) {
          // Apply primary goal adjustment
          double adjustedTDEE1 = baseTDEE *
              (1 + (goals[primaryGoal] ?? 0.0)) *
              adjustments.primary;
          addLog("Adjusted TDEE after primary goal: $adjustedTDEE1");

          // Apply secondary goal adjustment
          double adjustedTDEE2 = baseTDEE *
              (1 + (goals[secondaryGoal] ?? 0.0)) *
              adjustments.secondary;
          addLog("Adjusted TDEE after secondary goal: $adjustedTDEE2");

          // Apply tertiary goal adjustment
          double adjustedTDEE3 =
              baseTDEE * (1 + (goals[thirdGoal] ?? 0.0)) * adjustments.tertiary;
          addLog("Adjusted TDEE after tertiary goal: $adjustedTDEE3");

          double finalTDEE = adjustedTDEE1 + adjustedTDEE2 + adjustedTDEE3;
          addLog('TDEE after adjustment is $finalTDEE');
          return finalTDEE;
        }
      } else {
        _cachedTDEE = baseTDEE;
        addLog('TDEE after adjustment is $baseTDEE');
      }

      // Return base TDEE if no adjustments are found
      return baseTDEE;
    }
    return 0.0;
  }

  // Calculate macronutrient ratios in grams based on TDEE
  Map<String, double> calculateRatios() {
    double tdee = calculateTDEE();
    List<String> goalsList = [
      if (primaryGoal != null) primaryGoal!,
      if (secondaryGoal != null) secondaryGoal!,
      if (thirdGoal != null) thirdGoal!,
    ];

    MacronutrientRatios? ratios = findMacronutrientRatios(goalsList);

    double proteinCalories;
    double fatCalories;
    double carbCalories;

    if (ratios != null) {
      proteinCalories = ratios.proteinRatio * tdee;
      fatCalories = ratios.fatRatio * tdee;
      carbCalories = ratios.carbRatio * tdee;
    } else {
      proteinCalories = 0.50 * tdee;
      fatCalories = 0.35 * tdee;
      carbCalories = 0.15 * tdee;
    }

    return {
      'protein': proteinCalories / 4,
      'fat': fatCalories / 9,
      'carbs': carbCalories / 4,
    };
  }

  GoalAdjustments? findGoalAdjustments(List<String> goalsList) {
    for (List<String> key in goalAdjustmentMap.keys) {
      if (_listsEqual(key, goalsList)) {
        return goalAdjustmentMap[key];
      }
    }
    return null;
  }

  MacronutrientRatios? findMacronutrientRatios(List<String> goalsList) {
    for (List<String> key in goalMacronutrientRatiosMap.keys) {
      if (_listsEqual(key, goalsList)) {
        return goalMacronutrientRatiosMap[key];
      }
    }
    return null;
  }

  bool _listsEqual(List<String> list1, List<String> list2) {
    if (list1.length != list2.length) return false;
    for (int i = 0; i < list1.length; i++) {
      if (list1[i] != list2[i]) return false;
    }
    return true;
  }
}

class GoalAdjustments {
  final double primary;
  final double secondary;
  final double tertiary;

  GoalAdjustments({
    required this.primary,
    required this.secondary,
    required this.tertiary,
  });
}

class MacronutrientRatios {
  final double proteinRatio;
  final double fatRatio;
  final double carbRatio;

  MacronutrientRatios({
    required this.proteinRatio,
    required this.fatRatio,
    required this.carbRatio,
  });
}

Map<List<String>, GoalAdjustments> goalAdjustmentMap = {
  ['Build Muscles', 'Shape Up', 'Get Stronger']:
      GoalAdjustments(primary: 0.55, secondary: 0.3, tertiary: 0.15),
  ['Build Muscles', 'Shape Up', 'Lose Weight']:
      GoalAdjustments(primary: 0.5, secondary: 0.3, tertiary: 0.2),
  ['Build Muscles', 'Shape Up', 'Improve Flexibility']:
      GoalAdjustments(primary: 0.5, secondary: 0.3, tertiary: 0.2),
  ['Build Muscles', 'Shape Up', 'General Fitness']:
      GoalAdjustments(primary: 0.5, secondary: 0.3, tertiary: 0.2),
  ['Build Muscles', 'Get Stronger', 'Shape Up']:
      GoalAdjustments(primary: 0.55, secondary: 0.3, tertiary: 0.15),
  ['Build Muscles', 'Get Stronger', 'Lose Weight']:
      GoalAdjustments(primary: 0.5, secondary: 0.3, tertiary: 0.2),
  ['Build Muscles', 'Get Stronger', 'Improve Flexibility']:
      GoalAdjustments(primary: 0.5, secondary: 0.3, tertiary: 0.2),
  ['Build Muscles', 'Get Stronger', 'General Fitness']:
      GoalAdjustments(primary: 0.5, secondary: 0.3, tertiary: 0.2),
  ['Build Muscles', 'Lose Weight', 'Shape Up']:
      GoalAdjustments(primary: 0.5, secondary: 0.3, tertiary: 0.2),
  ['Build Muscles', 'Lose Weight', 'Get Stronger']:
      GoalAdjustments(primary: 0.45, secondary: 0.3, tertiary: 0.25),
  ['Build Muscles', 'Lose Weight', 'Improve Flexibility']:
      GoalAdjustments(primary: 0.45, secondary: 0.3, tertiary: 0.25),
  ['Build Muscles', 'Lose Weight', 'General Fitness']:
      GoalAdjustments(primary: 0.45, secondary: 0.3, tertiary: 0.25),
  ['Build Muscles', 'Improve Flexibility', 'Shape Up']:
      GoalAdjustments(primary: 0.5, secondary: 0.3, tertiary: 0.2),
  ['Build Muscles', 'Improve Flexibility', 'Get Stronger']:
      GoalAdjustments(primary: 0.5, secondary: 0.3, tertiary: 0.2),
  ['Build Muscles', 'Improve Flexibility', 'Lose Weight']:
      GoalAdjustments(primary: 0.45, secondary: 0.3, tertiary: 0.25),
  ['Build Muscles', 'Improve Flexibility', 'General Fitness']:
      GoalAdjustments(primary: 0.45, secondary: 0.3, tertiary: 0.25),
  ['Build Muscles', 'General Fitness', 'Shape Up']:
      GoalAdjustments(primary: 0.5, secondary: 0.3, tertiary: 0.2),
  ['Build Muscles', 'General Fitness', 'Get Stronger']:
      GoalAdjustments(primary: 0.5, secondary: 0.3, tertiary: 0.2),
  ['Build Muscles', 'General Fitness', 'Lose Weight']:
      GoalAdjustments(primary: 0.5, secondary: 0.3, tertiary: 0.2),
  ['Build Muscles', 'General Fitness', 'Improve Flexibility']:
      GoalAdjustments(primary: 0.45, secondary: 0.3, tertiary: 0.25),
  ['Shape Up', 'Build Muscles', 'Get Stronger']:
      GoalAdjustments(primary: 0.55, secondary: 0.3, tertiary: 0.15),
  ['Shape Up', 'Build Muscles', 'Lose Weight']:
      GoalAdjustments(primary: 0.5, secondary: 0.3, tertiary: 0.2),
  ['Shape Up', 'Build Muscles', 'Improve Flexibility']:
      GoalAdjustments(primary: 0.5, secondary: 0.3, tertiary: 0.2),
  ['Shape Up', 'Build Muscles', 'General Fitness']:
      GoalAdjustments(primary: 0.5, secondary: 0.3, tertiary: 0.2),
  ['Shape Up', 'Get Stronger', 'Build Muscles']:
      GoalAdjustments(primary: 0.55, secondary: 0.3, tertiary: 0.15),
  ['Shape Up', 'Get Stronger', 'Lose Weight']:
      GoalAdjustments(primary: 0.5, secondary: 0.3, tertiary: 0.2),
  ['Shape Up', 'Get Stronger', 'Improve Flexibility']:
      GoalAdjustments(primary: 0.5, secondary: 0.3, tertiary: 0.2),
  ['Shape Up', 'Get Stronger', 'General Fitness']:
      GoalAdjustments(primary: 0.5, secondary: 0.3, tertiary: 0.2),
  ['Shape Up', 'Lose Weight', 'Build Muscles']:
      GoalAdjustments(primary: 0.5, secondary: 0.3, tertiary: 0.2),
  ['Shape Up', 'Lose Weight', 'Get Stronger']:
      GoalAdjustments(primary: 0.45, secondary: 0.3, tertiary: 0.25),
  ['Shape Up', 'Lose Weight', 'Improve Flexibility']:
      GoalAdjustments(primary: 0.45, secondary: 0.3, tertiary: 0.25),
  ['Shape Up', 'Lose Weight', 'General Fitness']:
      GoalAdjustments(primary: 0.45, secondary: 0.3, tertiary: 0.25),
  ['Shape Up', 'Improve Flexibility', 'Build Muscles']:
      GoalAdjustments(primary: 0.5, secondary: 0.3, tertiary: 0.2),
  ['Shape Up', 'Improve Flexibility', 'Get Stronger']:
      GoalAdjustments(primary: 0.5, secondary: 0.3, tertiary: 0.2),
  ['Shape Up', 'Improve Flexibility', 'Lose Weight']:
      GoalAdjustments(primary: 0.45, secondary: 0.3, tertiary: 0.25),
  ['Shape Up', 'Improve Flexibility', 'General Fitness']:
      GoalAdjustments(primary: 0.45, secondary: 0.3, tertiary: 0.25),
  ['Shape Up', 'General Fitness', 'Build Muscles']:
      GoalAdjustments(primary: 0.5, secondary: 0.3, tertiary: 0.2),
  ['Shape Up', 'General Fitness', 'Get Stronger']:
      GoalAdjustments(primary: 0.5, secondary: 0.3, tertiary: 0.2),
  ['Shape Up', 'General Fitness', 'Lose Weight']:
      GoalAdjustments(primary: 0.45, secondary: 0.3, tertiary: 0.25),
  ['Shape Up', 'General Fitness', 'Improve Flexibility']:
      GoalAdjustments(primary: 0.45, secondary: 0.3, tertiary: 0.25),
  ['Get Stronger', 'Build Muscles', 'Shape Up']:
      GoalAdjustments(primary: 0.6, secondary: 0.3, tertiary: 0.1),
  ['Get Stronger', 'Build Muscles', 'Lose Weight']:
      GoalAdjustments(primary: 0.5, secondary: 0.3, tertiary: 0.2),
  ['Get Stronger', 'Build Muscles', 'Improve Flexibility']:
      GoalAdjustments(primary: 0.5, secondary: 0.3, tertiary: 0.2),
  ['Get Stronger', 'Build Muscles', 'General Fitness']:
      GoalAdjustments(primary: 0.5, secondary: 0.3, tertiary: 0.2),
  ['Get Stronger', 'Shape Up', 'Build Muscles']:
      GoalAdjustments(primary: 0.6, secondary: 0.3, tertiary: 0.1),
  ['Get Stronger', 'Shape Up', 'Lose Weight']:
      GoalAdjustments(primary: 0.5, secondary: 0.3, tertiary: 0.2),
  ['Get Stronger', 'Shape Up', 'Improve Flexibility']:
      GoalAdjustments(primary: 0.5, secondary: 0.3, tertiary: 0.2),
  ['Get Stronger', 'Shape Up', 'General Fitness']:
      GoalAdjustments(primary: 0.5, secondary: 0.3, tertiary: 0.2),
  ['Get Stronger', 'Lose Weight', 'Build Muscles']:
      GoalAdjustments(primary: 0.45, secondary: 0.3, tertiary: 0.25),
  ['Get Stronger', 'Lose Weight', 'Shape Up']:
      GoalAdjustments(primary: 0.45, secondary: 0.3, tertiary: 0.25),
  ['Get Stronger', 'Lose Weight', 'Improve Flexibility']:
      GoalAdjustments(primary: 0.45, secondary: 0.3, tertiary: 0.25),
  ['Get Stronger', 'Lose Weight', 'General Fitness']:
      GoalAdjustments(primary: 0.45, secondary: 0.3, tertiary: 0.25),
  ['Get Stronger', 'Improve Flexibility', 'Build Muscles']:
      GoalAdjustments(primary: 0.5, secondary: 0.3, tertiary: 0.2),
  ['Get Stronger', 'Improve Flexibility', 'Shape Up']:
      GoalAdjustments(primary: 0.5, secondary: 0.3, tertiary: 0.2),
  ['Get Stronger', 'Improve Flexibility', 'Lose Weight']:
      GoalAdjustments(primary: 0.45, secondary: 0.3, tertiary: 0.25),
  ['Get Stronger', 'Improve Flexibility', 'General Fitness']:
      GoalAdjustments(primary: 0.45, secondary: 0.3, tertiary: 0.25),
  ['Get Stronger', 'General Fitness', 'Build Muscles']:
      GoalAdjustments(primary: 0.5, secondary: 0.3, tertiary: 0.2),
  ['Get Stronger', 'General Fitness', 'Shape Up']:
      GoalAdjustments(primary: 0.5, secondary: 0.3, tertiary: 0.2),
  ['Get Stronger', 'General Fitness', 'Lose Weight']:
      GoalAdjustments(primary: 0.45, secondary: 0.3, tertiary: 0.25),
  ['Get Stronger', 'General Fitness', 'Improve Flexibility']:
      GoalAdjustments(primary: 0.45, secondary: 0.3, tertiary: 0.25),
  ['Lose Weight', 'Build Muscles', 'Shape Up']:
      GoalAdjustments(primary: 0.5, secondary: 0.3, tertiary: 0.2),
  ['Lose Weight', 'Build Muscles', 'Get Stronger']:
      GoalAdjustments(primary: 0.45, secondary: 0.3, tertiary: 0.25),
  ['Lose Weight', 'Build Muscles', 'Improve Flexibility']:
      GoalAdjustments(primary: 0.45, secondary: 0.3, tertiary: 0.25),
  ['Lose Weight', 'Build Muscles', 'General Fitness']:
      GoalAdjustments(primary: 0.45, secondary: 0.3, tertiary: 0.25),
  ['Lose Weight', 'Shape Up', 'Build Muscles']:
      GoalAdjustments(primary: 0.5, secondary: 0.3, tertiary: 0.2),
  ['Lose Weight', 'Shape Up', 'Get Stronger']:
      GoalAdjustments(primary: 0.45, secondary: 0.3, tertiary: 0.25),
  ['Lose Weight', 'Shape Up', 'Improve Flexibility']:
      GoalAdjustments(primary: 0.45, secondary: 0.3, tertiary: 0.25),
  ['Lose Weight', 'Shape Up', 'General Fitness']:
      GoalAdjustments(primary: 0.45, secondary: 0.3, tertiary: 0.25),
  ['Lose Weight', 'Get Stronger', 'Build Muscles']:
      GoalAdjustments(primary: 0.45, secondary: 0.3, tertiary: 0.25),
  ['Lose Weight', 'Get Stronger', 'Shape Up']:
      GoalAdjustments(primary: 0.45, secondary: 0.3, tertiary: 0.25),
  ['Lose Weight', 'Get Stronger', 'Improve Flexibility']:
      GoalAdjustments(primary: 0.45, secondary: 0.3, tertiary: 0.25),
  ['Lose Weight', 'Get Stronger', 'General Fitness']:
      GoalAdjustments(primary: 0.45, secondary: 0.3, tertiary: 0.25),
  ['Lose Weight', 'Improve Flexibility', 'Build Muscles']:
      GoalAdjustments(primary: 0.45, secondary: 0.3, tertiary: 0.25),
  ['Lose Weight', 'Improve Flexibility', 'Shape Up']:
      GoalAdjustments(primary: 0.45, secondary: 0.3, tertiary: 0.25),
  ['Lose Weight', 'Improve Flexibility', 'Get Stronger']:
      GoalAdjustments(primary: 0.45, secondary: 0.3, tertiary: 0.25),
  ['Lose Weight', 'Improve Flexibility', 'General Fitness']:
      GoalAdjustments(primary: 0.45, secondary: 0.3, tertiary: 0.25),
  ['Lose Weight', 'General Fitness', 'Build Muscles']:
      GoalAdjustments(primary: 0.45, secondary: 0.3, tertiary: 0.25),
  ['Lose Weight', 'General Fitness', 'Shape Up']:
      GoalAdjustments(primary: 0.45, secondary: 0.3, tertiary: 0.25),
  ['Lose Weight', 'General Fitness', 'Get Stronger']:
      GoalAdjustments(primary: 0.45, secondary: 0.3, tertiary: 0.25),
  ['Lose Weight', 'General Fitness', 'Improve Flexibility']:
      GoalAdjustments(primary: 0.45, secondary: 0.3, tertiary: 0.25),
  ['Improve Flexibility', 'Build Muscles', 'Shape Up']:
      GoalAdjustments(primary: 0.5, secondary: 0.3, tertiary: 0.2),
  ['Improve Flexibility', 'Build Muscles', 'Get Stronger']:
      GoalAdjustments(primary: 0.5, secondary: 0.3, tertiary: 0.2),
  ['Improve Flexibility', 'Build Muscles', 'Lose Weight']:
      GoalAdjustments(primary: 0.45, secondary: 0.3, tertiary: 0.25),
  ['Improve Flexibility', 'Build Muscles', 'General Fitness']:
      GoalAdjustments(primary: 0.45, secondary: 0.3, tertiary: 0.25),
  ['Improve Flexibility', 'Shape Up', 'Build Muscles']:
      GoalAdjustments(primary: 0.5, secondary: 0.3, tertiary: 0.2),
  ['Improve Flexibility', 'Shape Up', 'Get Stronger']:
      GoalAdjustments(primary: 0.5, secondary: 0.3, tertiary: 0.2),
  ['Improve Flexibility', 'Shape Up', 'Lose Weight']:
      GoalAdjustments(primary: 0.45, secondary: 0.3, tertiary: 0.25),
  ['Improve Flexibility', 'Shape Up', 'General Fitness']:
      GoalAdjustments(primary: 0.45, secondary: 0.3, tertiary: 0.25),
  ['Improve Flexibility', 'Get Stronger', 'Build Muscles']:
      GoalAdjustments(primary: 0.5, secondary: 0.3, tertiary: 0.2),
  ['Improve Flexibility', 'Get Stronger', 'Shape Up']:
      GoalAdjustments(primary: 0.5, secondary: 0.3, tertiary: 0.2),
  ['Improve Flexibility', 'Get Stronger', 'Lose Weight']:
      GoalAdjustments(primary: 0.45, secondary: 0.3, tertiary: 0.25),
  ['Improve Flexibility', 'Get Stronger', 'General Fitness']:
      GoalAdjustments(primary: 0.45, secondary: 0.3, tertiary: 0.25),
  ['Improve Flexibility', 'Lose Weight', 'Build Muscles']:
      GoalAdjustments(primary: 0.45, secondary: 0.3, tertiary: 0.25),
  ['Improve Flexibility', 'Lose Weight', 'Shape Up']:
      GoalAdjustments(primary: 0.45, secondary: 0.3, tertiary: 0.25),
  ['Improve Flexibility', 'Lose Weight', 'Get Stronger']:
      GoalAdjustments(primary: 0.45, secondary: 0.3, tertiary: 0.25),
  ['Improve Flexibility', 'Lose Weight', 'General Fitness']:
      GoalAdjustments(primary: 0.45, secondary: 0.3, tertiary: 0.25),
  ['Improve Flexibility', 'General Fitness', 'Build Muscles']:
      GoalAdjustments(primary: 0.45, secondary: 0.3, tertiary: 0.25),
  ['Improve Flexibility', 'General Fitness', 'Shape Up']:
      GoalAdjustments(primary: 0.45, secondary: 0.3, tertiary: 0.25),
  ['Improve Flexibility', 'General Fitness', 'Get Stronger']:
      GoalAdjustments(primary: 0.45, secondary: 0.3, tertiary: 0.25),
  ['Improve Flexibility', 'General Fitness', 'Lose Weight']:
      GoalAdjustments(primary: 0.45, secondary: 0.3, tertiary: 0.25),
  ['General Fitness', 'Build Muscles', 'Shape Up']:
      GoalAdjustments(primary: 0.5, secondary: 0.3, tertiary: 0.2),
  ['General Fitness', 'Build Muscles', 'Get Stronger']:
      GoalAdjustments(primary: 0.5, secondary: 0.3, tertiary: 0.2),
  ['General Fitness', 'Build Muscles', 'Lose Weight']:
      GoalAdjustments(primary: 0.45, secondary: 0.3, tertiary: 0.25),
  ['General Fitness', 'Build Muscles', 'Improve Flexibility']:
      GoalAdjustments(primary: 0.45, secondary: 0.3, tertiary: 0.25),
  ['General Fitness', 'Shape Up', 'Build Muscles']:
      GoalAdjustments(primary: 0.5, secondary: 0.3, tertiary: 0.2),
  ['General Fitness', 'Shape Up', 'Get Stronger']:
      GoalAdjustments(primary: 0.5, secondary: 0.3, tertiary: 0.2),
  ['General Fitness', 'Shape Up', 'Lose Weight']:
      GoalAdjustments(primary: 0.45, secondary: 0.3, tertiary: 0.25),
  ['General Fitness', 'Shape Up', 'Improve Flexibility']:
      GoalAdjustments(primary: 0.45, secondary: 0.3, tertiary: 0.25),
  ['General Fitness', 'Get Stronger', 'Build Muscles']:
      GoalAdjustments(primary: 0.5, secondary: 0.3, tertiary: 0.2),
  ['General Fitness', 'Get Stronger', 'Shape Up']:
      GoalAdjustments(primary: 0.5, secondary: 0.3, tertiary: 0.2),
  ['General Fitness', 'Get Stronger', 'Lose Weight']:
      GoalAdjustments(primary: 0.45, secondary: 0.3, tertiary: 0.25),
  ['General Fitness', 'Get Stronger', 'Improve Flexibility']:
      GoalAdjustments(primary: 0.45, secondary: 0.3, tertiary: 0.25),
  ['General Fitness', 'Lose Weight', 'Build Muscles']:
      GoalAdjustments(primary: 0.45, secondary: 0.3, tertiary: 0.25),
  ['General Fitness', 'Lose Weight', 'Shape Up']:
      GoalAdjustments(primary: 0.45, secondary: 0.3, tertiary: 0.25),
  ['General Fitness', 'Lose Weight', 'Get Stronger']:
      GoalAdjustments(primary: 0.45, secondary: 0.3, tertiary: 0.25),
  ['General Fitness', 'Lose Weight', 'Improve Flexibility']:
      GoalAdjustments(primary: 0.45, secondary: 0.3, tertiary: 0.25),
  ['General Fitness', 'Improve Flexibility', 'Build Muscles']:
      GoalAdjustments(primary: 0.45, secondary: 0.3, tertiary: 0.25),
  ['General Fitness', 'Improve Flexibility', 'Shape Up']:
      GoalAdjustments(primary: 0.45, secondary: 0.3, tertiary: 0.25),
  ['General Fitness', 'Improve Flexibility', 'Get Stronger']:
      GoalAdjustments(primary: 0.45, secondary: 0.3, tertiary: 0.25),
  ['General Fitness', 'Improve Flexibility', 'Lose Weight']:
      GoalAdjustments(primary: 0.45, secondary: 0.3, tertiary: 0.25),
};

Map<List<String>, MacronutrientRatios> goalMacronutrientRatiosMap = {
  ['Build Muscles', 'Shape Up', 'Get Stronger']:
      MacronutrientRatios(proteinRatio: 0.30, fatRatio: 0.20, carbRatio: 0.50),
  ['Build Muscles', 'Shape Up', 'Lose Weight']:
      MacronutrientRatios(proteinRatio: 0.30, fatRatio: 0.25, carbRatio: 0.45),
  ['Build Muscles', 'Shape Up', 'Improve Flexibility']:
      MacronutrientRatios(proteinRatio: 0.30, fatRatio: 0.25, carbRatio: 0.45),
  ['Build Muscles', 'Shape Up', 'General Fitness']:
      MacronutrientRatios(proteinRatio: 0.30, fatRatio: 0.25, carbRatio: 0.45),
  ['Build Muscles', 'Get Stronger', 'Shape Up']:
      MacronutrientRatios(proteinRatio: 0.30, fatRatio: 0.20, carbRatio: 0.50),
  ['Build Muscles', 'Get Stronger', 'Lose Weight']:
      MacronutrientRatios(proteinRatio: 0.30, fatRatio: 0.25, carbRatio: 0.45),
  ['Build Muscles', 'Get Stronger', 'Improve Flexibility']:
      MacronutrientRatios(proteinRatio: 0.30, fatRatio: 0.25, carbRatio: 0.45),
  ['Build Muscles', 'Get Stronger', 'General Fitness']:
      MacronutrientRatios(proteinRatio: 0.30, fatRatio: 0.25, carbRatio: 0.45),
  ['Build Muscles', 'Lose Weight', 'Shape Up']:
      MacronutrientRatios(proteinRatio: 0.30, fatRatio: 0.25, carbRatio: 0.45),
  ['Build Muscles', 'Lose Weight', 'Get Stronger']:
      MacronutrientRatios(proteinRatio: 0.30, fatRatio: 0.25, carbRatio: 0.45),
  ['Build Muscles', 'Lose Weight', 'Improve Flexibility']:
      MacronutrientRatios(proteinRatio: 0.30, fatRatio: 0.25, carbRatio: 0.45),
  ['Build Muscles', 'Lose Weight', 'General Fitness']:
      MacronutrientRatios(proteinRatio: 0.30, fatRatio: 0.25, carbRatio: 0.45),
  ['Build Muscles', 'Improve Flexibility', 'Shape Up']:
      MacronutrientRatios(proteinRatio: 0.30, fatRatio: 0.25, carbRatio: 0.45),
  ['Build Muscles', 'Improve Flexibility', 'Get Stronger']:
      MacronutrientRatios(proteinRatio: 0.30, fatRatio: 0.25, carbRatio: 0.45),
  ['Build Muscles', 'Improve Flexibility', 'Lose Weight']:
      MacronutrientRatios(proteinRatio: 0.30, fatRatio: 0.25, carbRatio: 0.45),
  ['Build Muscles', 'Improve Flexibility', 'General Fitness']:
      MacronutrientRatios(proteinRatio: 0.30, fatRatio: 0.25, carbRatio: 0.45),
  ['Build Muscles', 'General Fitness', 'Shape Up']:
      MacronutrientRatios(proteinRatio: 0.30, fatRatio: 0.25, carbRatio: 0.45),
  ['Build Muscles', 'General Fitness', 'Get Stronger']:
      MacronutrientRatios(proteinRatio: 0.30, fatRatio: 0.25, carbRatio: 0.45),
  ['Build Muscles', 'General Fitness', 'Lose Weight']:
      MacronutrientRatios(proteinRatio: 0.30, fatRatio: 0.25, carbRatio: 0.45),
  ['Build Muscles', 'General Fitness', 'Improve Flexibility']:
      MacronutrientRatios(proteinRatio: 0.30, fatRatio: 0.25, carbRatio: 0.45),
  ['Shape Up', 'Build Muscles', 'Get Stronger']:
      MacronutrientRatios(proteinRatio: 0.25, fatRatio: 0.20, carbRatio: 0.55),
  ['Shape Up', 'Build Muscles', 'Lose Weight']:
      MacronutrientRatios(proteinRatio: 0.25, fatRatio: 0.25, carbRatio: 0.50),
  ['Shape Up', 'Build Muscles', 'Improve Flexibility']:
      MacronutrientRatios(proteinRatio: 0.25, fatRatio: 0.25, carbRatio: 0.50),
  ['Shape Up', 'Build Muscles', 'General Fitness']:
      MacronutrientRatios(proteinRatio: 0.25, fatRatio: 0.25, carbRatio: 0.50),
  ['Shape Up', 'Get Stronger', 'Build Muscles']:
      MacronutrientRatios(proteinRatio: 0.25, fatRatio: 0.20, carbRatio: 0.55),
  ['Shape Up', 'Get Stronger', 'Lose Weight']:
      MacronutrientRatios(proteinRatio: 0.25, fatRatio: 0.25, carbRatio: 0.50),
  ['Shape Up', 'Get Stronger', 'Improve Flexibility']:
      MacronutrientRatios(proteinRatio: 0.25, fatRatio: 0.25, carbRatio: 0.50),
  ['Shape Up', 'Get Stronger', 'General Fitness']:
      MacronutrientRatios(proteinRatio: 0.25, fatRatio: 0.25, carbRatio: 0.50),
  ['Shape Up', 'Lose Weight', 'Build Muscles']:
      MacronutrientRatios(proteinRatio: 0.25, fatRatio: 0.25, carbRatio: 0.50),
  ['Shape Up', 'Lose Weight', 'Get Stronger']:
      MacronutrientRatios(proteinRatio: 0.25, fatRatio: 0.25, carbRatio: 0.50),
  ['Shape Up', 'Lose Weight', 'Improve Flexibility']:
      MacronutrientRatios(proteinRatio: 0.25, fatRatio: 0.25, carbRatio: 0.50),
  ['Shape Up', 'Lose Weight', 'General Fitness']:
      MacronutrientRatios(proteinRatio: 0.25, fatRatio: 0.25, carbRatio: 0.50),
  ['Shape Up', 'Improve Flexibility', 'Build Muscles']:
      MacronutrientRatios(proteinRatio: 0.25, fatRatio: 0.25, carbRatio: 0.50),
  ['Shape Up', 'Improve Flexibility', 'Get Stronger']:
      MacronutrientRatios(proteinRatio: 0.25, fatRatio: 0.25, carbRatio: 0.50),
  ['Shape Up', 'Improve Flexibility', 'Lose Weight']:
      MacronutrientRatios(proteinRatio: 0.25, fatRatio: 0.25, carbRatio: 0.50),
  ['Shape Up', 'Improve Flexibility', 'General Fitness']:
      MacronutrientRatios(proteinRatio: 0.25, fatRatio: 0.25, carbRatio: 0.50),
  ['Shape Up', 'General Fitness', 'Build Muscles']:
      MacronutrientRatios(proteinRatio: 0.25, fatRatio: 0.25, carbRatio: 0.50),
  ['Shape Up', 'General Fitness', 'Get Stronger']:
      MacronutrientRatios(proteinRatio: 0.25, fatRatio: 0.25, carbRatio: 0.50),
  ['Shape Up', 'General Fitness', 'Lose Weight']:
      MacronutrientRatios(proteinRatio: 0.25, fatRatio: 0.25, carbRatio: 0.50),
  ['Shape Up', 'General Fitness', 'Improve Flexibility']:
      MacronutrientRatios(proteinRatio: 0.25, fatRatio: 0.25, carbRatio: 0.50),
  ['Get Stronger', 'Build Muscles', 'Shape Up']:
      MacronutrientRatios(proteinRatio: 0.30, fatRatio: 0.20, carbRatio: 0.50),
  ['Get Stronger', 'Build Muscles', 'Lose Weight']:
      MacronutrientRatios(proteinRatio: 0.30, fatRatio: 0.25, carbRatio: 0.45),
  ['Get Stronger', 'Build Muscles', 'Improve Flexibility']:
      MacronutrientRatios(proteinRatio: 0.30, fatRatio: 0.25, carbRatio: 0.45),
  ['Get Stronger', 'Build Muscles', 'General Fitness']:
      MacronutrientRatios(proteinRatio: 0.30, fatRatio: 0.25, carbRatio: 0.45),
  ['Get Stronger', 'Shape Up', 'Build Muscles']:
      MacronutrientRatios(proteinRatio: 0.30, fatRatio: 0.20, carbRatio: 0.50),
  ['Get Stronger', 'Shape Up', 'Lose Weight']:
      MacronutrientRatios(proteinRatio: 0.30, fatRatio: 0.25, carbRatio: 0.45),
  ['Get Stronger', 'Shape Up', 'Improve Flexibility']:
      MacronutrientRatios(proteinRatio: 0.30, fatRatio: 0.25, carbRatio: 0.45),
  ['Get Stronger', 'Shape Up', 'General Fitness']:
      MacronutrientRatios(proteinRatio: 0.30, fatRatio: 0.25, carbRatio: 0.45),
  ['Get Stronger', 'Lose Weight', 'Build Muscles']:
      MacronutrientRatios(proteinRatio: 0.30, fatRatio: 0.25, carbRatio: 0.45),
  ['Get Stronger', 'Lose Weight', 'Shape Up']:
      MacronutrientRatios(proteinRatio: 0.30, fatRatio: 0.25, carbRatio: 0.45),
  ['Get Stronger', 'Lose Weight', 'Improve Flexibility']:
      MacronutrientRatios(proteinRatio: 0.30, fatRatio: 0.25, carbRatio: 0.45),
  ['Get Stronger', 'Lose Weight', 'General Fitness']:
      MacronutrientRatios(proteinRatio: 0.30, fatRatio: 0.25, carbRatio: 0.45),
  ['Get Stronger', 'Improve Flexibility', 'Build Muscles']:
      MacronutrientRatios(proteinRatio: 0.30, fatRatio: 0.25, carbRatio: 0.45),
  ['Get Stronger', 'Improve Flexibility', 'Shape Up']:
      MacronutrientRatios(proteinRatio: 0.30, fatRatio: 0.25, carbRatio: 0.45),
  ['Get Stronger', 'Improve Flexibility', 'Lose Weight']:
      MacronutrientRatios(proteinRatio: 0.30, fatRatio: 0.25, carbRatio: 0.45),
  ['Get Stronger', 'Improve Flexibility', 'General Fitness']:
      MacronutrientRatios(proteinRatio: 0.30, fatRatio: 0.25, carbRatio: 0.45),
  ['Get Stronger', 'General Fitness', 'Build Muscles']:
      MacronutrientRatios(proteinRatio: 0.30, fatRatio: 0.25, carbRatio: 0.45),
  ['Get Stronger', 'General Fitness', 'Shape Up']:
      MacronutrientRatios(proteinRatio: 0.30, fatRatio: 0.25, carbRatio: 0.45),
  ['Get Stronger', 'General Fitness', 'Lose Weight']:
      MacronutrientRatios(proteinRatio: 0.30, fatRatio: 0.25, carbRatio: 0.45),
  ['Get Stronger', 'General Fitness', 'Improve Flexibility']:
      MacronutrientRatios(proteinRatio: 0.30, fatRatio: 0.25, carbRatio: 0.45),
  ['Lose Weight', 'Build Muscles', 'Shape Up']:
      MacronutrientRatios(proteinRatio: 0.30, fatRatio: 0.25, carbRatio: 0.45),
  ['Lose Weight', 'Build Muscles', 'Get Stronger']:
      MacronutrientRatios(proteinRatio: 0.30, fatRatio: 0.25, carbRatio: 0.45),
  ['Lose Weight', 'Build Muscles', 'Improve Flexibility']:
      MacronutrientRatios(proteinRatio: 0.30, fatRatio: 0.25, carbRatio: 0.45),
  ['Lose Weight', 'Build Muscles', 'General Fitness']:
      MacronutrientRatios(proteinRatio: 0.30, fatRatio: 0.25, carbRatio: 0.45),
  ['Lose Weight', 'Shape Up', 'Build Muscles']:
      MacronutrientRatios(proteinRatio: 0.30, fatRatio: 0.25, carbRatio: 0.45),
  ['Lose Weight', 'Shape Up', 'Get Stronger']:
      MacronutrientRatios(proteinRatio: 0.30, fatRatio: 0.25, carbRatio: 0.45),
  ['Lose Weight', 'Shape Up', 'Improve Flexibility']:
      MacronutrientRatios(proteinRatio: 0.30, fatRatio: 0.25, carbRatio: 0.45),
  ['Lose Weight', 'Shape Up', 'General Fitness']:
      MacronutrientRatios(proteinRatio: 0.30, fatRatio: 0.25, carbRatio: 0.45),
  ['Lose Weight', 'Get Stronger', 'Build Muscles']:
      MacronutrientRatios(proteinRatio: 0.30, fatRatio: 0.25, carbRatio: 0.45),
  ['Lose Weight', 'Get Stronger', 'Shape Up']:
      MacronutrientRatios(proteinRatio: 0.30, fatRatio: 0.25, carbRatio: 0.45),
  ['Lose Weight', 'Get Stronger', 'Improve Flexibility']:
      MacronutrientRatios(proteinRatio: 0.30, fatRatio: 0.25, carbRatio: 0.45),
  ['Lose Weight', 'Get Stronger', 'General Fitness']:
      MacronutrientRatios(proteinRatio: 0.30, fatRatio: 0.25, carbRatio: 0.45),
  ['Lose Weight', 'Improve Flexibility', 'Build Muscles']:
      MacronutrientRatios(proteinRatio: 0.30, fatRatio: 0.25, carbRatio: 0.45),
  ['Lose Weight', 'Improve Flexibility', 'Shape Up']:
      MacronutrientRatios(proteinRatio: 0.30, fatRatio: 0.25, carbRatio: 0.45),
  ['Lose Weight', 'Improve Flexibility', 'Get Stronger']:
      MacronutrientRatios(proteinRatio: 0.30, fatRatio: 0.25, carbRatio: 0.45),
  ['Lose Weight', 'Improve Flexibility', 'General Fitness']:
      MacronutrientRatios(proteinRatio: 0.30, fatRatio: 0.25, carbRatio: 0.45),
  ['Lose Weight', 'General Fitness', 'Build Muscles']:
      MacronutrientRatios(proteinRatio: 0.30, fatRatio: 0.25, carbRatio: 0.45),
  ['Lose Weight', 'General Fitness', 'Shape Up']:
      MacronutrientRatios(proteinRatio: 0.30, fatRatio: 0.25, carbRatio: 0.45),
  ['Lose Weight', 'General Fitness', 'Get Stronger']:
      MacronutrientRatios(proteinRatio: 0.30, fatRatio: 0.25, carbRatio: 0.45),
  ['Lose Weight', 'General Fitness', 'Improve Flexibility']:
      MacronutrientRatios(proteinRatio: 0.30, fatRatio: 0.25, carbRatio: 0.45),
  ['Improve Flexibility', 'Build Muscles', 'Shape Up']:
      MacronutrientRatios(proteinRatio: 0.20, fatRatio: 0.30, carbRatio: 0.50),
  ['Improve Flexibility', 'Build Muscles', 'Get Stronger']:
      MacronutrientRatios(proteinRatio: 0.20, fatRatio: 0.30, carbRatio: 0.50),
  ['Improve Flexibility', 'Build Muscles', 'Lose Weight']:
      MacronutrientRatios(proteinRatio: 0.20, fatRatio: 0.30, carbRatio: 0.50),
  ['Improve Flexibility', 'Build Muscles', 'General Fitness']:
      MacronutrientRatios(proteinRatio: 0.20, fatRatio: 0.30, carbRatio: 0.50),
  ['Improve Flexibility', 'Shape Up', 'Build Muscles']:
      MacronutrientRatios(proteinRatio: 0.20, fatRatio: 0.30, carbRatio: 0.50),
  ['Improve Flexibility', 'Shape Up', 'Get Stronger']:
      MacronutrientRatios(proteinRatio: 0.20, fatRatio: 0.30, carbRatio: 0.50),
  ['Improve Flexibility', 'Shape Up', 'Lose Weight']:
      MacronutrientRatios(proteinRatio: 0.20, fatRatio: 0.30, carbRatio: 0.50),
  ['Improve Flexibility', 'Shape Up', 'General Fitness']:
      MacronutrientRatios(proteinRatio: 0.20, fatRatio: 0.30, carbRatio: 0.50),
  ['Improve Flexibility', 'Get Stronger', 'Build Muscles']:
      MacronutrientRatios(proteinRatio: 0.20, fatRatio: 0.30, carbRatio: 0.50),
  ['Improve Flexibility', 'Get Stronger', 'Shape Up']:
      MacronutrientRatios(proteinRatio: 0.20, fatRatio: 0.30, carbRatio: 0.50),
  ['Improve Flexibility', 'Get Stronger', 'Lose Weight']:
      MacronutrientRatios(proteinRatio: 0.20, fatRatio: 0.30, carbRatio: 0.50),
  ['Improve Flexibility', 'Get Stronger', 'General Fitness']:
      MacronutrientRatios(proteinRatio: 0.20, fatRatio: 0.30, carbRatio: 0.50),
  ['Improve Flexibility', 'Lose Weight', 'Build Muscles']:
      MacronutrientRatios(proteinRatio: 0.20, fatRatio: 0.30, carbRatio: 0.50),
  ['Improve Flexibility', 'Lose Weight', 'Shape Up']:
      MacronutrientRatios(proteinRatio: 0.20, fatRatio: 0.30, carbRatio: 0.50),
  ['Improve Flexibility', 'Lose Weight', 'Get Stronger']:
      MacronutrientRatios(proteinRatio: 0.20, fatRatio: 0.30, carbRatio: 0.50),
  ['Improve Flexibility', 'Lose Weight', 'General Fitness']:
      MacronutrientRatios(proteinRatio: 0.20, fatRatio: 0.30, carbRatio: 0.50),
  ['Improve Flexibility', 'General Fitness', 'Build Muscles']:
      MacronutrientRatios(proteinRatio: 0.20, fatRatio: 0.30, carbRatio: 0.50),
  ['Improve Flexibility', 'General Fitness', 'Shape Up']:
      MacronutrientRatios(proteinRatio: 0.20, fatRatio: 0.30, carbRatio: 0.50),
  ['Improve Flexibility', 'General Fitness', 'Get Stronger']:
      MacronutrientRatios(proteinRatio: 0.20, fatRatio: 0.30, carbRatio: 0.50),
  ['Improve Flexibility', 'General Fitness', 'Lose Weight']:
      MacronutrientRatios(proteinRatio: 0.20, fatRatio: 0.30, carbRatio: 0.50),
  ['General Fitness', 'Build Muscles', 'Shape Up']:
      MacronutrientRatios(proteinRatio: 0.25, fatRatio: 0.25, carbRatio: 0.50),
  ['General Fitness', 'Build Muscles', 'Get Stronger']:
      MacronutrientRatios(proteinRatio: 0.25, fatRatio: 0.25, carbRatio: 0.50),
  ['General Fitness', 'Build Muscles', 'Lose Weight']:
      MacronutrientRatios(proteinRatio: 0.25, fatRatio: 0.25, carbRatio: 0.50),
  ['General Fitness', 'Build Muscles', 'Improve Flexibility']:
      MacronutrientRatios(proteinRatio: 0.25, fatRatio: 0.25, carbRatio: 0.50),
  ['General Fitness', 'Shape Up', 'Build Muscles']:
      MacronutrientRatios(proteinRatio: 0.25, fatRatio: 0.25, carbRatio: 0.50),
  ['General Fitness', 'Shape Up', 'Get Stronger']:
      MacronutrientRatios(proteinRatio: 0.25, fatRatio: 0.25, carbRatio: 0.50),
  ['General Fitness', 'Shape Up', 'Lose Weight']:
      MacronutrientRatios(proteinRatio: 0.25, fatRatio: 0.25, carbRatio: 0.50),
  ['General Fitness', 'Shape Up', 'Improve Flexibility']:
      MacronutrientRatios(proteinRatio: 0.25, fatRatio: 0.25, carbRatio: 0.50),
  ['General Fitness', 'Get Stronger', 'Build Muscles']:
      MacronutrientRatios(proteinRatio: 0.25, fatRatio: 0.25, carbRatio: 0.50),
  ['General Fitness', 'Get Stronger', 'Shape Up']:
      MacronutrientRatios(proteinRatio: 0.25, fatRatio: 0.25, carbRatio: 0.50),
  ['General Fitness', 'Get Stronger', 'Lose Weight']:
      MacronutrientRatios(proteinRatio: 0.25, fatRatio: 0.25, carbRatio: 0.50),
  ['General Fitness', 'Get Stronger', 'Improve Flexibility']:
      MacronutrientRatios(proteinRatio: 0.25, fatRatio: 0.25, carbRatio: 0.50),
  ['General Fitness', 'Lose Weight', 'Build Muscles']:
      MacronutrientRatios(proteinRatio: 0.25, fatRatio: 0.25, carbRatio: 0.50),
  ['General Fitness', 'Lose Weight', 'Shape Up']:
      MacronutrientRatios(proteinRatio: 0.25, fatRatio: 0.25, carbRatio: 0.50),
  ['General Fitness', 'Lose Weight', 'Get Stronger']:
      MacronutrientRatios(proteinRatio: 0.25, fatRatio: 0.25, carbRatio: 0.50),
  ['General Fitness', 'Lose Weight', 'Improve Flexibility']:
      MacronutrientRatios(proteinRatio: 0.25, fatRatio: 0.25, carbRatio: 0.50),
  ['General Fitness', 'Improve Flexibility', 'Build Muscles']:
      MacronutrientRatios(proteinRatio: 0.25, fatRatio: 0.25, carbRatio: 0.50),
  ['General Fitness', 'Improve Flexibility', 'Shape Up']:
      MacronutrientRatios(proteinRatio: 0.25, fatRatio: 0.25, carbRatio: 0.50),
  ['General Fitness', 'Improve Flexibility', 'Get Stronger']:
      MacronutrientRatios(proteinRatio: 0.25, fatRatio: 0.25, carbRatio: 0.50),
  ['General Fitness', 'Improve Flexibility', 'Lose Weight']:
      MacronutrientRatios(proteinRatio: 0.25, fatRatio: 0.25, carbRatio: 0.50),
};

