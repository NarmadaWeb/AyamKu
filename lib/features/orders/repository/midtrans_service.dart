import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'midtrans_service.g.dart';

@riverpod
MidtransService midtransService(Ref ref) {
  return MidtransService();
}

class MidtransService {
  final String serverKey = 'SB-Mid-server-IYftE8VPjamqFzmU9O7oL2L5';
  final String clientKey = 'SB-Mid-client-dbYYHDftx7NAczbb';
  final String baseUrl = 'https://app.sandbox.midtrans.com/snap/v1';
  final String statusBaseUrl = 'https://api.sandbox.midtrans.com/v2';

  String get _authHeader => 'Basic ${base64Encode(utf8.encode('$serverKey:'))}';

  Future<Map<String, dynamic>> createTransaction({
    required String orderId,
    required double grossAmount,
    required String customerName,
    required String customerEmail,
    required String customerPhone,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/transactions'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': _authHeader,
      },
      body: jsonEncode({
        'transaction_details': {
          'order_id': orderId,
          'gross_amount': grossAmount.toInt(),
        },
        'customer_details': {
          'first_name': customerName,
          'email': customerEmail,
          'phone': customerPhone,
        },
        // We can specify enabled_payments here if we want to restrict
      }),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to create Midtrans transaction: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> checkTransactionStatus(String orderId) async {
    final response = await http.get(
      Uri.parse('$statusBaseUrl/$orderId/status'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': _authHeader,
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to check Midtrans transaction status: ${response.body}');
    }
  }
}
