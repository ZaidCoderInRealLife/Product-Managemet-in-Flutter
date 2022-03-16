import 'package:flutter/material.dart';
import 'package:myapp/Screens/user_product_screen.dart';
import 'package:provider/provider.dart';
import '../Screens/order_screen.dart';
import '../providers/auth.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          AppBar(
            title: Text("Hello Friend"),
            automaticallyImplyLeading: false,
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.shop),
            title: Text("Shop"),
            onTap: () {
              Navigator.of(context).pushNamed("/");
            },
          ),
          Divider(),
          ListTile(
              leading: Icon(Icons.shop),
              title: Text("Order"),
              onTap: () {
                Navigator.of(context).pushNamed(OrdersScreen.routeName);
              }),
          Divider(),
          ListTile(
              leading: Icon(Icons.edit),
              title: Text("Manage Products"),
              onTap: () {
                Navigator.of(context).pushNamed(UserProductsScreen.routeName);
              }),
          Divider(),
          ListTile(
              leading: Icon(Icons.exit_to_app),
              title: Text("LogOut"),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushReplacementNamed("/");
                Provider.of<Auth>(context, listen: false).logout();
                //Navigator.of(context).pushNamed(UserProductsScreen.routeName);
              })
        ],
      ),
    );
  }
}
