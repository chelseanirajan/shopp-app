import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/orders.dart';
import 'package:shop_app/widgets/app_drawer.dart';
import 'package:shop_app/widgets/order_item.dart';

class OrdersScreen extends StatefulWidget{
  static const routeName = '/orders';
  @override
  State<StatefulWidget> createState() {
    return OrdersScreenState();
  }

}
class OrdersScreenState extends State<OrdersScreen>{
  var _isLoading = false;
  void initState(){
    Future.delayed(Duration.zero).then((_) async{
      setState(() {
        _isLoading = true;
      });
     await Provider.of<Orders>(context, listen: false).fetchAndSetOrders();
     setState(() {
       _isLoading = false;
     });
    });
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    final orders = Provider.of<Orders>(context);
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text('Yours Orders'),
      ),
      drawer: AppDrawer(),
      body: _isLoading? Center(child: CircularProgressIndicator(),):ListView.builder(itemCount: orders.order.length,itemBuilder: (ctx, i) => OrderItemScreen(orders.order[i]),),
    );
  }

}
