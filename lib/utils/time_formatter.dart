String formatDuration(Duration duration) {

  String twoDigits(int number) {

    return number.toString().padLeft(2, '0');

  }


  final hours = twoDigits(
    duration.inHours,
  );


  final minutes = twoDigits(
    duration.inMinutes.remainder(60),
  );


  final seconds = twoDigits(
    duration.inSeconds.remainder(60),
  );


  return "$hours:$minutes:$seconds";

}