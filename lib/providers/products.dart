import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shop_app/model/http_exception.dart';
import 'package:shop_app/providers/product.dart';
import 'package:http/http.dart' as http;
class Products with ChangeNotifier {
  List<Product> _items = [
    // Product(
    //   id: 'p1',
    //   title: 'Red Shirt',
    //   description: 'A red shirt - it is pretty red!',
    //   price: 29.99,
    //   imageUrl:
    //   'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    // ),
    // Product(
    //   id: 'p2',
    //   title: 'Trousers',
    //   description: 'A nice pair of trousers.',
    //   price: 59.99,
    //   imageUrl:
    //   'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    // ),
    // Product(
    //   id: 'p3',
    //   title: 'Yellow Scarf',
    //   description: 'Warm and cozy - exactly what you need for the winter.',
    //   price: 19.99,
    //   imageUrl:
    //   'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    // ),
    // Product(
    //   id: 'p4',
    //   title: 'A Pan',
    //   description: 'Prepare any meal you want.',
    //   price: 49.99,
    //   imageUrl:
    //   'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    // ),
  ];
  final String? token;
  final String? userId;
  Products(this.token, this._items, this.userId);

  // var _showFavoriteOnly = false;
  List<Product> get items {
    // if(_showFavoriteOnly){
    //   return _items.where((prodItem) => prodItem.isFavorite).toList();
    // }
    return [..._items];
  }

  Product findById(String id) {
    return _items.firstWhere((product) => product.id == id);
  }
  Future<void> fetchAndSetProducts([bool filterByUser = false]) async {
    final filterString = filterByUser? 'orderBy="creatorId"&equalTo="$userId"': '';
    try{
      var url = Uri.parse('https://flutter-update-109a1-default-rtdb.firebaseio.com/products.json?auth=$token&$filterString');
      // final url = Uri.https('flutter-update-109a1-default-rtdb.firebaseio.com', '/products.json');
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      if(extractedData.isEmpty){
        return;
      }
      url =Uri.parse('https://flutter-update-109a1-default-rtdb.firebaseio.com/userFavorite/$userId.json?auth=$token');
      final favoriteStatus = await http.get(url);
      final favoriteData = json.decode(favoriteStatus.body);
      final List<Product> loadedProducts = [];
      extractedData.forEach((productId, product) {
        loadedProducts.add(Product(
          id: productId,
          title: product['title'],
          price: product['price'],
          description: product['description'],
          isFavorite:  favoriteData == null? false:favoriteData[productId]?? false ,
          imageUrl: product['imageUrl']
        ));
      });
      _items = loadedProducts;
      notifyListeners();
      // print(json.decode(response.body));
    }catch(error) {
      throw(error);
    }

  }
  Future<void> addProduct(Product product) async {
    try{
      final url = Uri.parse('https://flutter-update-109a1-default-rtdb.firebaseio.com/products.json?auth=$token');
      // final url = 'https://flutter-update-109a1-default-rtdb.firebaseio.com/products.json';
      final response = await http.post(url, body: json.encode({
        'title': product.title,
        'description': product.description,
        'imageUrl': product.imageUrl,
        'price': product.price,
        'creatorId': userId,
      }),);
      final newProduct = Product(title: product.title,
        description: product.description,
        price: product.price,
        imageUrl: product.imageUrl,
        id: json.decode(response.body)['name'],);
      _items.add(newProduct);
      // _items.insert(0, newProduct);//add first of the list;
      notifyListeners();
    }catch(error){
      print(error);
      throw(error);
    }

  }

  // Future<void> addProduct(Product product) {
  //    final url = Uri.https('flutter-update-109a1-default-rtdb.firebaseio.com', '/products.json');
  //   // final url = 'https://flutter-update-109a1-default-rtdb.firebaseio.com/products.json';
  //   return http.post(url, body: json.encode({
  //       'title': product.title,
  //       'description': product.description,
  //       'imageUrl': product.imageUrl,
  //       'price': product.price,
  //       'isFavorite': product.isFavorite
  //     }),).then((response)
  //       {
  //     final newProduct = Product(title: product.title,
  //     description: product.description,
  //     price: product.price,
  //     imageUrl: product.imageUrl,
  //     id: json.decode(response.body)['name'],);
  //    _items.add(newProduct);
  //    // _items.insert(0, newProduct);//add first of the list;
  //    notifyListeners();
  //       }
  //   ).catchError((error) {
  //     print(error);
  //     throw(error);
  //   });
  //
  // }

  // void showFavoriteOnly(){
  //   _showFavoriteOnly = true;
  //   notifyListeners();
  // }
  // void showFavoriteAll(){
  //   _showFavoriteOnly = false;
  //   notifyListeners();
  // }
  List<Product> get favoriteItems {
    return _items.where((meal) => meal.isFavorite).toList();
  }
  Future<void> updateProduct(String productId, Product newProduct) async{
    final prodIndex = _items.indexWhere((prod) => prod.id == productId);
    if(prodIndex >= 0){
      final url = Uri.parse('https://flutter-update-109a1-default-rtdb.firebaseio.com/products/$productId.json?auth=$token');
      await http.patch(url, body: json.encode({
        'title': newProduct.title,
        'description': newProduct.description,
        'imageUrl': newProduct.imageUrl,
        'price': newProduct.price
      }));
      _items[prodIndex] = newProduct;
      notifyListeners();
    }else {
      print('i am here..........');
    }

  }
  Future<void> deleteProducts(String id) async{
    final url = Uri.parse('https://flutter-update-109a1-default-rtdb.firebaseio.com/products/$id.json?auth=$token');
    final existingProductIndex = _items.indexWhere((prod) => prod.id == id);
    Product? existingProduct = _items[existingProductIndex];
    _items.removeAt(existingProductIndex);
    notifyListeners();
     final response = await http.delete(url);
       if(response.statusCode >= 400){
         _items.insert(existingProductIndex, existingProduct);
         notifyListeners();
         throw HttpException('Could not delete.');
     }
       existingProduct = null;
  }
}
