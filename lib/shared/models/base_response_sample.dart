class BaseResponse {
  BaseResponse({
    required this.code,
    required this.status,
    required this.message,
    this.data,
    this.error,
  });

  final int code;
  final bool status;
  final String message;
  final dynamic data;
  final dynamic error;

  factory BaseResponse.fromJson(Map<String, dynamic> json) {
    dynamic parsedError = json['error'] ?? json['errors'];

    // Normalize error format.
    if (parsedError is List) {
      parsedError = parsedError.map((e) => e.toString()).toList();
    } else if (parsedError is Map) {
      parsedError = parsedError.toString();
    }

    return BaseResponse(
      code: json['code'] ?? 0,
      status: json['success'] ?? json['status'] ?? false,
      message: json['message'] ?? '',
      data: json['data'],
      error: parsedError,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'status': status,
      'message': message,
      'data': data,
      'error': error,
    };
  }
}
