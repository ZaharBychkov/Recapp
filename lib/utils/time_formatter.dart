
String formatTime(int seconds) {
  int totalMinutes = seconds  ~/ 60;  //    ~/  возвращает целую часть от деления в данном случае количество минут без учета лишних секунд
  int minutes = totalMinutes % 60;    //Количество минут - остаток от деления на часы
  int hours = totalMinutes ~/ 60;     //Целое количество часов без остатка минут

  if (hours > 0) {
    if (minutes > 0) {
      return '$hours ч $minutes мин';
    } else {
      return '$hours ч';
    }
  } else {
    return '$minutes мин';
  }
}

String formatTimeMMSS(int seconds) {
  int totalMinutes = seconds  ~/ 60;
  int minutes = totalMinutes % 60;    //Количество минут - остаток от деления на часы
  int hours = totalMinutes ~/ 60;     //Целое количество часов без остатка минут

  if (hours > 0) {
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:00';
  } else {
    return '${minutes.toString().padLeft(2, '0')}:00';
  }
}