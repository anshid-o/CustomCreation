import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:custom_creations/constants.dart';
import 'package:flutter/material.dart';
import 'package:quickalert/quickalert.dart';

class TransactionPage extends StatefulWidget {
  @override
  _TransactionPageState createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  String dropValue = categories[0];
  TextEditingController dateController = TextEditingController();
  TextEditingController customerNameController = TextEditingController();

  TextEditingController sellPriceController = TextEditingController();

  TextEditingController customerPhoneController = TextEditingController();
  TextEditingController customerPlaceController = TextEditingController();
  TextEditingController itemCountController = TextEditingController();
  String? selectedProductId;
  int remainingStock = 0;
  bool isclearFilter = false;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: cngreen,
          title: const Text(
            'Manage Products',
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: col30),
          ),
          centerTitle: true,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(40),
            child: Container(
              height: 40,
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.blue[50],
              ),
              child: TabBar(
                indicatorSize: TabBarIndicatorSize.tab,
                indicator: BoxDecoration(
                  color: cdgreen,
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                labelColor: Colors.white,
                unselectedLabelColor: Colors.black54,
                tabs: [
                  Tab(text: 'Sell'),
                  Tab(text: 'History'),
                ],
              ),
            ),
          ),
        ),
        body: TabBarView(
          children: [
            _buildSellTab(size),
            _buildHistoryTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildSellTab(Size size) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildDropdown('Select Category', categories, dropValue, (value) {
          setState(() {
            dropValue = value!;
            _showProductSelectionDialog();
          });
        }),
        _buildTextField('Customer Name', customerNameController),
        _buildTextField('Sell Price', sellPriceController),
        _buildTextField('Customer Phone', customerPhoneController,
            keyboardType: TextInputType.phone),
        _buildTextField('Customer Place', customerPlaceController),
        _buildItemCountField(
            'Item Count (Up to $remainingStock)', itemCountController),
        _buildDateField('Select Date', dateController),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: size.width * .2),
          child: ElevatedButton(
            style:
                ButtonStyle(backgroundColor: WidgetStatePropertyAll(cngreen)),
            onPressed: _sellProduct,
            child: const Text(
              'Sell Product',
              style: TextStyle(color: col30),
            ),
          ),
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * .15,
        )
      ],
    );
  }

  Widget _buildDropdown(String label, List<String> items, String value,
      ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: TextStyle(color: Colors.black38)),
            TextButton(
                onPressed: () {
                  setState(() {
                    isclearFilter = true;
                  });
                },
                child: Text('Clear Filters'))
          ],
        ),
        Container(
          width: double.infinity,
          height: 50,
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          decoration: BoxDecoration(
              border: Border.all(), borderRadius: BorderRadius.circular(10)),
          child: DropdownButton<String>(
            value: value,
            icon: const Icon(Icons.arrow_drop_down_rounded),
            isExpanded: true,
            items: items
                .map((item) => DropdownMenuItem(
                      value: item,
                      child: Text(item),
                    ))
                .toList(),
            onChanged: onChanged,
            underline: const SizedBox(),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.black38)),
        Container(
          height: 50,
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          child: TextField(
            controller: controller,
            readOnly: true,
            decoration: InputDecoration(
                prefixIcon: const Icon(Icons.calendar_today_rounded),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                hintText: 'Select Date',
                hintStyle: const TextStyle(height: 0)),
            onTap: () async {
              DateTime? dateTime = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2101));
              if (dateTime != null) {
                controller.text =
                    '${dateTime.day}/${dateTime.month}/${dateTime.year}';
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {TextInputType keyboardType = TextInputType.text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.black38)),
        Container(
          height: 50,
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            decoration: InputDecoration(
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                hintText: label,
                hintStyle: const TextStyle(height: 0)),
          ),
        ),
      ],
    );
  }

  Widget _buildItemCountField(String label, TextEditingController controller,
      {TextInputType keyboardType = TextInputType.number}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.black38)),
        Container(
          height: 50,
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            decoration: InputDecoration(
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                hintText: label,
                hintStyle: const TextStyle(height: 0)),
          ),
        ),
      ],
    );
  }

  void _sellProduct() async {
    if (dateController.text == '' ||
        customerNameController.text == '' ||
        customerPhoneController.text == '' ||
        customerPlaceController.text == '' ||
        itemCountController.text == '') {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'Oops...',
        text: 'Please fill all fields.',
      );
      return;
    }

    if (selectedProductId == null) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'Oops...',
        text: 'Please select a product.',
      );
      return;
    }

    int itemCount = int.parse(itemCountController.text);
    if (itemCount > remainingStock) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'Oops...',
        text: 'Item count exceeds remaining stock.',
      );
      return;
    }

    FirebaseFirestore.instance.collection('sales').add({
      'category': dropValue,
      'date': dateController.text,
      'customerName': customerNameController.text,
      'customerPhone': customerPhoneController.text,
      'customerPlace': customerPlaceController.text,
      'itemCount': itemCount,
      'productId': selectedProductId,
    });

    final productRef = FirebaseFirestore.instance
        .collection('products')
        .doc(selectedProductId);

    DocumentSnapshot snapshot = await productRef.get();

    if (snapshot.exists) {
      int currentStock = snapshot['stock'];
      int newStock = currentStock - itemCount;

      await productRef.update({'stock': newStock});
    } else {
      throw Exception("Product does not exist!");
    }

    QuickAlert.show(
      context: context,
      type: QuickAlertType.success,
      title: 'Success',
      text: 'Product sold successfully.',
    );

    dateController.clear();
    customerNameController.clear();
    customerPhoneController.clear();
    customerPlaceController.clear();
    itemCountController.clear();
    selectedProductId = null;
  }

  Future<void> _showProductSelectionDialog() async {
    final products = await FirebaseFirestore.instance
        .collection('products')
        .where('category', isEqualTo: dropValue)
        .get();

    if (products.docs.isEmpty) {
      setState(() {
        remainingStock = 0;
      });
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Select Product'),
          content: Container(
            width: double.maxFinite,
            child: products.docs.isEmpty
                ? const Text('There are no products')
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: products.docs.length,
                    itemBuilder: (context, index) {
                      var product = products.docs[index];
                      return ListTile(
                        leading: Image.network(product['imageUrl'],
                            width: 50, height: 50),
                        title: Text(product['name']),
                        onTap: () async {
                          selectedProductId = product.id;
                          remainingStock = product['stock'];
                          setState(() {
                            itemCountController.text = '';
                          });
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
          ),
        );
      },
    );
  }

  Widget _buildHistoryTab() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          _buildDropdown('Filter by Category', categories, dropValue, (value) {
            setState(() {
              isclearFilter = false;
              dropValue = value!;
            });
          }),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: isclearFilter
                  ? FirebaseFirestore.instance.collection('sales').snapshots()
                  : FirebaseFirestore.instance
                      .collection('sales')
                      .where('category', isEqualTo: dropValue)
                      .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }
                var sales = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: sales.length,
                  itemBuilder: (context, index) {
                    var sale = sales[index];
                    print(sale.data());
                    return FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance
                          .collection('products')
                          .doc(sale['productId'])
                          .get(),
                      builder: (context, productSnapshot) {
                        if (!productSnapshot.hasData) {
                          return Center(child: CircularProgressIndicator());
                        }

                        var product = productSnapshot.data!;
                        double profit = double.parse(
                            ((product['price'] - sale['sellPrice']) *
                                    sale['itemCount'])
                                .toString());

                        return Card(
                          color: Colors.white,
                          margin: const EdgeInsets.all(10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 5,
                          child: ExpansionTile(
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                product['imageUrl'],
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                              ),
                            ),
                            title: Text(
                              'Product: ${product['name']}',
                              style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              sale['date'],
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            trailing: Text(
                              '+ \$${profit.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.green,
                              ),
                            ),
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0, vertical: 8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Customer Name: ${sale['customerName']}',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      'Sold Price: \$${sale['sellPrice']}',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      'Cost: \$${product['price']}',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      'Stock Sold: ${sale['itemCount']}',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      'Place: ${sale['customerPlace']}',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      'Customer Phone: ${sale['customerPhone']}',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      'Product Description: ${product['description']}',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    product['customization'] != null
                                        ? Text(
                                            'Measures: ${product['customization']}',
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.grey[700],
                                            ),
                                          )
                                        : SizedBox(),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
