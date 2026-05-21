class BaseResponseModel<T> {
  const BaseResponseModel({
    required this.success,
    required this.message,
    required this.data,
    this.errors,
  });

  final bool success;
  final String message;
  final T? data;
  final dynamic errors;

  factory BaseResponseModel.fromJson(
    Map<String, dynamic> json, {
    T Function(dynamic raw)? dataParser,
  }) {
    final rawData = json['data'];
    final rawSuccess = json['success'];
    final ok = rawSuccess == true ||
        rawSuccess == 1 ||
        rawSuccess == '1' ||
        rawSuccess.toString().toLowerCase() == 'true';

    return BaseResponseModel<T>(
      success: ok,
      message: (json['message'] ?? '').toString(),
      data: dataParser != null ? dataParser(rawData) : rawData as T?,
      errors: json['errors'] ?? json['error'],
    );
  }
}
