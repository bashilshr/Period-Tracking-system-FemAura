class LogFullCycleModel {
  const LogFullCycleModel({
    this.date = '',
    this.experience = '',
    this.moods = const [],
    this.symptoms = const [],
  });

  final String? date;
  final String? experience;
  final List<String>? moods;
  final List<String>? symptoms;

  Map<String, dynamic> toMap() {
    return {
      'date': date,
      if (experience != null) 'experience': experience,
      'moods': moods,
      'symptoms': symptoms,
    };
  }
}
