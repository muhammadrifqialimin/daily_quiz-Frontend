class Quiz {
  final int id;
  final String question;
  final Map<String, dynamic> options;
  final String date;

  Quiz({
    required this.id,
    required this.question,
    required this.options,
    required this.date,
  });

  factory Quiz.fromJson(Map<String, dynamic> json) {
    return Quiz(
      id: json['id'],
      question: json['question'],
      options: Map<String, dynamic>.from(json['options']),
      date: json['date'],
    );
  }
}
