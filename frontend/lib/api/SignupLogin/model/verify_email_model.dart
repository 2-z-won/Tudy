class EmailVerificationRequest {
  final String email;
  final String code;

  EmailVerificationRequest({required this.email, required this.code});

  Map<String, dynamic> toJson() => {'email': email, 'code': code};
}

class EmailVerificationResponse {
  final bool success;
  final String? error;

  EmailVerificationResponse({required this.success, this.error});

  factory EmailVerificationResponse.fromJson(Map<String, dynamic> json) {
    return EmailVerificationResponse(
      success: json['success'] ?? false,
      error: json['error'],
    );
  }
}
