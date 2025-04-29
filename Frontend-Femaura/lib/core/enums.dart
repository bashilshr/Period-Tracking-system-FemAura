enum LoadingState { initial, loading, success, error }

enum OTPVerificationFor { signup, resetPassword }

enum CycleMoodTags {
  calm('Calm'),
  happy('Happy'),
  lowEnergy('Low energy'),
  irritated('Irritated'),
  anxious('Anxious'),
  cravings('Cravings'),
  moodSwings('Mood swings'),
  sad('Sad'),
  angry('Angry'),
  relaxed('Relaxed');

  const CycleMoodTags(this.label);
  final String label;
}

enum CycleSymptomsTags {
  everythingIsGood('Everything is good'),
  cramps('Cramps'),
  fatigue('Fatigue'),
  headache('Headache'),
  insomnia('Insomnia'),
  acne('Acne'),
  abdominalPain('Abdominal Pain'),
  breastTenderness('Breast tenderness'),
  backPain('Backpain'),
  cravings('Cravings');

  const CycleSymptomsTags(this.label);
  final String label;
}
