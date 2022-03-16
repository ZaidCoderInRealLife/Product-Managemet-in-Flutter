import 'package:flutter/material.dart';
import 'package:myapp/widgets/app_drawer.dart';
import 'package:provider/provider.dart';
import '../providers/products.dart';
import '../widgets/user_product_item.dart';
import 'edit_product_screen.dart';

class UserProductsScreen extends StatelessWidget {
  static const routeName = "/user-products";

  Future _refreshProducts(BuildContext context) async {
    await Provider.of<Products>(context, listen: false)
        .fetchAddSetProducts(true);
  }

  @override
  Widget build(BuildContext context) {
    //final prodctsData = Provider.of<Products>(context);
    return Scaffold(
        drawer: AppDrawer(),
        appBar: AppBar(
          title: const Text("Your Products"),
          actions: [
            IconButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(EditProductScreen.routeName);
                },
                icon: const Icon(Icons.add))
          ],
        ),
        body: FutureBuilder(
          future: _refreshProducts(context),
          builder: (_, snapshots) =>
              snapshots.connectionState == ConnectionState.waiting
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : RefreshIndicator(
                      onRefresh: () => _refreshProducts(context),
                      child: Consumer<Products>(
                        builder: (_, productsData, __) => Padding(
                          padding: EdgeInsets.all(8),
                          child: ListView.builder(
                            itemCount: productsData.items.length,
                            itemBuilder: (_, i) => Column(
                              children: [
                                UserProductItem(
                                    productsData.items[i].id as String,
                                    productsData.items[i].title as String,
                                    productsData.items[i].imageUrl as String),
                                Divider(
                                  height: 5,
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
        ));
  }
}
