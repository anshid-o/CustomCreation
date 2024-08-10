import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:custom_creations/constants.dart';
import 'package:flutter/material.dart';

class OverallPage extends StatefulWidget {
  @override
  _OverallPageState createState() => _OverallPageState();
}

class _OverallPageState extends State<OverallPage> {
  Future<List<Map<String, dynamic>>> _fetchProductDetails() async {
    try {
      QuerySnapshot productSnapshot =
          await FirebaseFirestore.instance.collection('products').get();
      QuerySnapshot salesSnapshot =
          await FirebaseFirestore.instance.collection('sales').get();

      List<Map<String, dynamic>> productList = productSnapshot.docs.map((doc) {
        var data = doc.data() as Map<String, dynamic>;
        data['productId'] = doc.id;
        data['soldStock'] = 0;
        data['soldAmount'] = 0.0;
        data['totalProfit'] = 0.0;
        return data;
      }).toList();
      for (var sale in salesSnapshot.docs) {
        var saleData = sale.data() as Map<String, dynamic>;
        var productId = saleData['productId'];

        var product = productList.firstWhere((p) => p['productId'] == productId,
            orElse: () => {});
        if (product != null) {
          print(product.keys.toList());
          print(saleData.keys.toList());
          product['soldStock'] += saleData['itemCount'];
          product['soldAmount'] +=
              saleData['sellPrice'] * saleData['itemCount'];
          product['totalProfit'] +=
              ((saleData['sellPrice'] - product['price']) *
                  saleData['itemCount']);
        }
      }
      print('All done............');
      return productList;
    } catch (e) {
      print('Error fetching product details: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightWoodcol,
      appBar: AppBar(
        backgroundColor: lightWoodcol,
        title: const Text('Overall Economic Details'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchProductDetails(),
        builder: (context, snapshot) {
          print(snapshot.data);
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No data available'));
          }

          var productList = snapshot.data!;
          double companyTotalProfit = productList.fold(
              0.0, (sum, product) => sum + product['totalProfit']);
          double totalCostRemainingProducts = productList.fold(0.0,
              (sum, product) => sum + (product['price'] * product['stock']));
          int totalStockSold = productList
              .fold<num>(
                0,
                (sum, product) => sum + (product['soldStock'] ?? 0),
              )
              .toInt();

          int totalStockRemaining = productList
              .fold<num>(
                0,
                (sum, product) => sum + (product['stock'] ?? 0),
              )
              .toInt();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  color: lightWoodcol,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Company Total Profit: \$${companyTotalProfit.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Total Cost of Remaining Products: \$${totalCostRemainingProducts.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Total Stock Sold: $totalStockSold',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Total Stock Remaining: $totalStockRemaining',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: productList.length,
                  itemBuilder: (context, index) {
                    var product = productList[index];

                    return Card(
                      color: Colors.white,
                      margin: const EdgeInsets.all(10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 5,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            leading: InkWell(
                              onTap: () {
                                // Navigator.push(
                                //   context,
                                //   MaterialPageRoute(
                                //     builder: (context) => ImageViewPage(
                                //       imageUrl: product['url'],
                                //       heroTag: product['url'],
                                //     ),
                                //   ),
                                // );
                              },
                              child: Hero(
                                tag: product['url'] ?? '',
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  child: Image.network(
                                    product['url'] ?? '',
                                    fit: BoxFit.cover,
                                    width: 80,
                                    height: 80,
                                  ),
                                ),
                              ),
                            ),
                            title: Text(
                              product['name'] ?? 'No Name',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              'Purchase Price: \$${product['price'] ?? 0.0}',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Sold Stock: ${product['soldStock'] ?? 0}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  'Sold Amount: \$${(product['soldAmount'] ?? 0.0).toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  'Total Profit: \$${(product['totalProfit'] ?? 0.0).toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.green,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  'Total Cost of Remaining: \$${((product['stock'] ?? 0) * (product['price'] ?? 0.0)).toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.red,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  'Remaining Stock: ${product['stock'] ?? 0}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
