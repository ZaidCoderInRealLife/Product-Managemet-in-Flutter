import 'dart:convert';

import 'package:flutter/material.dart';
import './cart.dart';
import 'package:http/http.dart' as http;

class OrderItem {
  final String? id;
  final double? amount;
  final List<CartItem>? products;
  final DateTime? dateTime;

  OrderItem(
      {@required this.id,
      @required this.amount,
      @required this.products,
      @required this.dateTime});
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];
  final String authToken;
  final String userId;
  Orders(this.authToken, this._orders, this.userId);

  List<OrderItem> get orders {
    return [..._orders];
  }

  Future fetchAndSetOrders() async {
    var url = Uri.parse(
        "https://myapp-add99-default-rtdb.firebaseio.com/Orders/$userId.json?auth=$authToken");
    final response = await http.get(url);
    final List<OrderItem> loadedOrders = [];
    final extractedData = jsonDecode(response.body) as Map;
    if (extractedData == null) {
      return;
    }
    extractedData.forEach((orderId, orderData) {
      loadedOrders.add(OrderItem(
          id: orderId,
          amount: orderData['amount'],
          dateTime: DateTime.parse(orderData['dateTime']),
          products: (orderData['products'] as List)
              .map((e) => CartItem(
                  id: e['id'],
                  title: e['title'],
                  price: e['price'],
                  quantity: e['quantity']))
              .toList()));
    });
    _orders = loadedOrders.reversed.toList();
    notifyListeners();
  }

  Future addOrder(List<CartItem> cardProducts, double total) async {
    var url = Uri.parse(
        "https://myapp-add99-default-rtdb.firebaseio.com/Orders/$userId.json?auth=$authToken");
    final timestap = DateTime.now();
    final response = await http.post(url,
        body: jsonEncode({
          'amount': total,
          'dateTime': timestap.toIso8601String(),
          'products': cardProducts
              .map((cp) => {
                    'id': cp.id,
                    'title': cp.title,
                    'quantity': cp.quantity,
                    'price': cp.price
                  })
              .toList(),
        }));
    _orders.insert(
        0,
        OrderItem(
            id: jsonDecode(response.body)['name'],
            amount: total,
            products: cardProducts,
            dateTime: timestap));
    notifyListeners();
  }
}
