import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:food_ordering_system/models/product_models.dart';
import 'package:get/get.dart';

import '../../controllers/favorite_controller.dart';
import '../../helpers/firebase_helper.dart';
import '../../utils/colors.dart';

class VegesPage extends StatefulWidget {
  const VegesPage({Key? key}) : super(key: key);

  @override
  State<VegesPage> createState() => _VegesPageState();
}

class _VegesPageState extends State<VegesPage> {
  FavoriteController favoriteController = Get.find<FavoriteController>();

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: CloudFirestoreHelper.cloudFirestoreHelper.selectVegesRecord(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: SelectableText("${snapshot.error}"),
            );
          } else if (snapshot.hasData) {
            QuerySnapshot? data = snapshot.data;
            List<QueryDocumentSnapshot> documents = data!.docs;
            List<Veg> veg = documents.map((e) => Veg.fromMap(data: e)).toList();
            return GridView.builder(
              itemCount: veg.length,
              physics: const BouncingScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 13,
                mainAxisExtent: 270,
                childAspectRatio: 0.10,
              ),
              itemBuilder: (context, i) {
                return Column(
                  children: [
                    InkWell(
                      onTap: () {
                        Get.toNamed('/detail_page', arguments: veg[i]);
                      },
                      child: Container(
                        height: height * 0.2958,
                        width: width * 45,
                        decoration: BoxDecoration(
                          color: colorWhite,
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(10),
                            topLeft: Radius.circular(10),
                            bottomRight: Radius.circular(25),
                            bottomLeft: Radius.circular(10),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.25),
                              offset: const Offset(0, 0),
                              spreadRadius: 1,
                              blurRadius: 10,
                            )
                          ],
                        ),
                        child: Column(
                          children: [
                            Align(
                              alignment: Alignment.topRight,
                              child: GestureDetector(
                                onTap: () {
                                  favoriteController.addOrRemoveVegesFavorite(
                                    veg: veg[i],
                                    id: documents[i].id,
                                  );
                                },
                                child: (veg[i].isFav)
                                    ? const Icon(
                                        Icons.favorite,
                                        color: Colors.red,
                                      )
                                    : const Icon(
                                        Icons.favorite_border,
                                        color: Colors.grey,
                                      ),
                              ),
                            ),
                            Container(
                              height: 140,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: NetworkImage(veg[i].productImage),
                                ),
                              ),
                            ),
                            Align(
                              alignment: Alignment.center,
                              child: Text(
                                veg[i].name,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(width: 10),
                                const Text(
                                  "20 min",
                                  style: TextStyle(
                                    fontSize: 17,
                                    color: Colors.grey,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  "${veg[i].rate} ⭐",
                                  style: const TextStyle(
                                    fontSize: 17,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(width: 10),
                              ],
                            ),
                            const SizedBox(height: 1),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(width: 10),
                                Text(
                                  "\$ ${veg[i].price}.00",
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  height: 50,
                                  width: 50,
                                  decoration: const BoxDecoration(
                                    color: primaryColor,
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(25),
                                      bottomRight: Radius.circular(25),
                                    ),
                                  ),
                                  child: IconButton(
                                    onPressed: () async {
                                      Get.snackbar(
                                        "Your item add in cart successfully",
                                        "",
                                        showProgressIndicator: true,
                                        icon: const Icon(
                                          Icons.add_shopping_cart,
                                          size: 30,
                                        ),
                                        snackStyle: SnackStyle.FLOATING,
                                        colorText: primaryColor,
                                        dismissDirection:
                                            DismissDirection.horizontal,
                                        forwardAnimationCurve:
                                            Curves.easeInOutBack,
                                        leftBarIndicatorColor: Colors.green,
                                        progressIndicatorBackgroundColor:
                                            Colors.green,
                                        shouldIconPulse: true,
                                        mainButton: TextButton(
                                            onPressed: () {},
                                            child: const Text("Dismiss")),
                                      );
                                      Map<String, dynamic> cartData = {
                                        'name': veg[i].name,
                                        'productImage': veg[i].productImage,
                                        'price': veg[i].price,
                                        'rate': veg[i].rate,
                                        'isFav': veg[i].isFav,
                                      };
                                      await CloudFirestoreHelper
                                          .cloudFirestoreHelper
                                          .insertCartRecord(cartData: cartData);
                                    },
                                    icon: const Icon(
                                      Icons.add,
                                      color: colorWhite,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          } else {
            return const Center(
              child: CupertinoActivityIndicator(
                color: Colors.deepPurple,
                radius: 50,
              ),
            );
          }
        },
      ),
    );
  }
}
