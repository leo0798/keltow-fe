import 'dart:convert';
import 'package:flutter_project/constants/error_handpling.dart';
import 'package:flutter_project/constants/global_variables.dart';
import 'package:flutter_project/constants/ultils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_project/models/cart.dart';
import 'package:flutter_project/models/product.dart';
import 'package:flutter_project/models/wishlist.dart';
import 'package:flutter_project/providers/user_provider.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ProductService {
  void addToCart({
    required BuildContext context,
    required Product product,
    required int jumlah,
  }) async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      var now = new DateTime.now();
      var formatter = new DateFormat('yyyy-MM-dd');
      String formattedDate = formatter.format(now);
      // khusus add to cart
      var status_barang = 0;
      Cart cart = Cart(
        id: 0,
        tanggal: formattedDate,
        itemId: product.id!,
        jumlah: jumlah,
        status_barang: status_barang,
        ratting: 0,
        status_pengiriman: 0,
        userId: 0,
      );

      http.Response res = await http.post(
        Uri.parse('$uri/api/cart'),
        body: cart.toJson(),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'auth': userProvider.user.access_token,
        },
      );
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString(), toastLength: Toast.LENGTH_LONG);
    }
  }

  void wishList({
    required BuildContext context,
    required String itemId,
    required bool status,
  }) async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      http.Response res = status
          ? await http.post(
              Uri.parse('$uri/api/wishlist'),
              body: jsonEncode({
                'itemId': itemId,
              }),
              headers: <String, String>{
                'Content-Type': 'application/json; charset=UTF-8',
                'auth': userProvider.user.access_token,
              },
            )
          : await http.delete(
              Uri.parse('$uri/api/wishlist'),
              body: jsonEncode({
                'itemId': itemId,
              }),
              headers: <String, String>{
                'Content-Type': 'application/json; charset=UTF-8',
                'auth': userProvider.user.access_token,
              },
            );
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString(), toastLength: Toast.LENGTH_LONG);
    }
  }

  wishListDetail({
    required BuildContext context,
    required String itemId,
  }) async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      http.Response res = await http.post(
        Uri.parse('$uri/api/wishlist/detail'),
        body: jsonEncode({
          'itemId': itemId,
        }),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'auth': userProvider.user.access_token,
        },
      );

      final status = res.body == "true" ? true : false;
      return status;
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString(), toastLength: Toast.LENGTH_LONG);
    }
  }

  Future<List<Cart>> fetchCartList(BuildContext context) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    List<Cart> cartList = [];
    try {
      http.Response res =
          await http.get(Uri.parse('$uri/api/cart/list'), headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'auth': userProvider.user.access_token,
      });
      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
          for (int i = 0; i < jsonDecode(res.body).length; i++) {
            cartList.add(
              Cart.fromJson(
                jsonEncode(
                  jsonDecode(res.body)[i],
                ),
              ),
            );
            // print(jsonDecode(jsonEncode(cartList)));
          }
        },
      );
    } catch (e) {
      // showSnackBar(context, e.toString());
      Fluttertoast.showToast(msg: e.toString(), toastLength: Toast.LENGTH_LONG);
    }
    return cartList;
  }

  Future<List<WishList>> fetchWishList(BuildContext context) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    List<WishList> wishList = [];
    try {
      http.Response res =
          await http.get(Uri.parse('$uri/api/wishlist/info'), headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'auth': userProvider.user.access_token,
      });
      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
          for (int i = 0; i < jsonDecode(res.body).length; i++) {
            wishList.add(
              WishList.fromJson(
                jsonEncode(
                  jsonDecode(res.body)[i],
                ),
              ),
            );
          }
        },
      );
    } catch (e) {
      // showSnackBar(context, e.toString());
      Fluttertoast.showToast(msg: e.toString(), toastLength: Toast.LENGTH_LONG);
    }
    return wishList;
  }
}
