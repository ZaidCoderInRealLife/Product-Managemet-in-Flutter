import 'package:flutter/material.dart';


class Cart with ChangeNotifier{
  Map<String , CartItem> _item={};

  Map<String , CartItem> get items{
    return {..._item};
  }

  int get itemCount{
    return _item==null ? 0 : _item.length;
  }

  double get totalAmount{
    double total=0;
    _item.forEach((key, value) {
      total+=value.price !* (value.quantity as num);
    });
    return total;
  }

  void removeItem(String productId){
    _item.remove(productId);
    notifyListeners();
  }
  void clear(){
    _item={};
    notifyListeners();
  }
  
  void removeSingleItem(String productId){
    if(!_item.containsKey(productId)){
      return ;
    }
    if((_item[productId]!.quantity as int )>1){
      _item.update(productId, (value) => CartItem(
        id: value.id, 
        title: value.title, 
        price: value.price, 
        quantity: (value.quantity as int)-1));
    }
    else{
      _item.remove(productId);
    }
    notifyListeners();
  }

  void addItem(String productId,double price,String title){
    if(_item.containsKey(productId)){
      _item.update(productId, (value) => CartItem(
          id:  value.id,
          title: value.title,
          price: value.price,
          quantity: value.quantity!+1));
    }
    else{
      _item.putIfAbsent(productId,() => CartItem(quantity: 1,id: DateTime.now().toString(),title: title,price: price));
    }
   notifyListeners();
  }
}



class CartItem{
  final String? id;
  final String? title;
  final int? quantity;
  final double? price;

  CartItem({
    @required this.id,
    @required this.title,
    @required this.price,
    @required this.quantity});
}
