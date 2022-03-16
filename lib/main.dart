import 'package:myapp/Screens/auth_screen.dart';
import 'package:myapp/Screens/edit_product_screen.dart';
import 'package:myapp/Screens/product_overview_screen.dart';
import 'package:myapp/Screens/splash_screen.dart';
import 'package:myapp/Screens/user_product_screen.dart';
import 'package:myapp/providers/product.dart';

import '../Screens/order_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Screens/product_detail_screen.dart';
import './providers/products.dart';
import '../providers/cart.dart';
import './Screens/card_screen.dart';
import './providers/orders.dart';
import './providers/auth.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => Auth(),
        ),
        ChangeNotifierProxyProvider<Auth, Products>(
          create: (_) => Products("", [], ""),
          update: (_, auth, previousData) => Products(
              auth.token == null ? "" : auth.token as String,
              previousData == null ? [] : previousData.items,
              auth.userId == null ? "" : auth.userId),
        ),
        ChangeNotifierProvider(
          create: (_) => Cart(),
        ),
        ChangeNotifierProxyProvider<Auth, Orders>(
          create: (_) => Orders("", [], ""),
          update: (_, auth, previousData) => Orders(
              auth.token == null ? "" : auth.token as String,
              previousData == null ? [] : previousData.orders,
              auth.userId == null ? "" : auth.userId),
        )
      ],
      child: Consumer<Auth>(
        builder: (ctx, auth, _) => MaterialApp(
            title: 'MyShop',
            theme: ThemeData(
              primarySwatch: Colors.purple,
              accentColor: Colors.deepOrange,
              fontFamily: 'Lato',
            ),
            home: auth.isAuth as bool
                ? ProductsOverviewScreen()
                : FutureBuilder(
                    future: auth.tryAutoLogin(),
                    builder: (ctx, authResultSnapshot) =>
                        authResultSnapshot.connectionState ==
                                ConnectionState.waiting
                            ? SplashScreen()
                            : AuthScreen()),
            routes: {
              EditProductScreen.routeName: (ctx) => EditProductScreen(),
              UserProductsScreen.routeName: (ctx) => UserProductsScreen(),
              OrdersScreen.routeName: (ctx) => OrdersScreen(),
              CartScreen.routeName: (ctx) => CartScreen(),
              ProductDetailScreen.routeName: (ctx) => ProductDetailScreen(),
            }),
      ),
    );
  }
}
