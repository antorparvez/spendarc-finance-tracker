import 'dart:convert';

List<Map<String, dynamic>> decodeTransactionJsonList(String raw) {
  final list = jsonDecode(raw) as List<dynamic>;
  return list
      .map((e) => Map<String, dynamic>.from(e as Map<dynamic, dynamic>))
      .toList();
}
