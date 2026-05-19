/// Standard meal slots trainers can add to a daily diet plan.
abstract final class DietMealTypes {
  static const breakfast = 'breakfast';
  static const lunch = 'lunch';
  static const dinner = 'dinner';
  static const snack = 'snack';
  static const preWorkout = 'pre_workout';
  static const postWorkout = 'post_workout';

  static const all = [breakfast, lunch, dinner, snack, preWorkout, postWorkout];

  static String label(String type) => switch (type) {
        breakfast => 'Breakfast',
        lunch => 'Lunch',
        dinner => 'Dinner',
        snack => 'Snack / Other',
        preWorkout => 'Pre-workout',
        postWorkout => 'Post-workout',
        _ => type,
      };

  static String defaultTime(String type) => switch (type) {
        breakfast => '07:30',
        lunch => '13:00',
        dinner => '20:00',
        snack => '16:00',
        preWorkout => '06:00',
        postWorkout => '08:30',
        _ => '12:00',
      };

  static String emoji(String type) => switch (type) {
        breakfast => '🌅',
        lunch => '☀️',
        dinner => '🌙',
        snack => '🥤',
        preWorkout => '🏃',
        postWorkout => '💪',
        _ => '🍽️',
      };
}

/// Weekday labels for weekly workout plans.
abstract final class WeekdayLabels {
  static const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static const full = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];
}
