import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/cart.dart';
import 'package:shop_app/providers/products.dart';
import 'package:shop_app/screens/card_screen.dart';
import 'package:shop_app/widgets/ProductsGrid.dart';
import 'package:shop_app/widgets/app_drawer.dart';
import 'package:shop_app/widgets/badge.dart';

enum FilterOptions { Favorite, All }

class ProductsOverviewScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return ProductsOverviewScreenState();
  }
}

class ProductsOverviewScreenState extends State<ProductsOverviewScreen> {
  var _showOnleyFavorite = false;
  var _isInit = true;
  var _isLoading = false;

  void initState() {
    // Provider.of<Products>(context).fetchAndSetProducts(); wont work use listen= false;
    // Future.delayed(Duration.zero).then((value) {
    //   Provider.of<Products>(context).fetchAndSetProducts();
    // });
    super.initState();
  }
  void didChangeDependencies(){

    if(_isInit){
      setState(() {
      _isLoading = true;
      });
      Provider.of<Products>(context).fetchAndSetProducts().then((value) {
        setState(() {
        _isLoading = false;
        });
      });
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    // final productsContainer = Provider.of<Products>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: Text('MyShop'),
        actions: [
          PopupMenuButton(
            onSelected: (FilterOptions seleectdValue) {
              setState(() {
                if (seleectdValue == FilterOptions.Favorite) {
                  _showOnleyFavorite = true;
                } else {
                  _showOnleyFavorite = false;
                }
              });
            },
            icon: Icon(
              Icons.more_vert,
            ),
            itemBuilder: (_) => [
              PopupMenuItem(
                  child: Text(
                    'Only Favorites',
                  ),
                  value: FilterOptions.Favorite),
              PopupMenuItem(
                  child: Text(
                    'Show All',
                  ),
                  value: FilterOptions.All),
            ],
          ),
          Consumer<Cart>(
              builder: (_, cartData, ch) => Badge(
                  child:IconButton(icon: Icon(Icons.shopping_cart), onPressed: () {
                    Navigator.of(context).pushNamed(CartScreen.routeName);
                  } ,),
                  value: cartData.itemCount.toString(),
                    ),
                  ),
        ],
      ),
      drawer: AppDrawer(),
      body: _isLoading? Center(child: CircularProgressIndicator(),):ProductsGrid(_showOnleyFavorite),

    );
  }
}
