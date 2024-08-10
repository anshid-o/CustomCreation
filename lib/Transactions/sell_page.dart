import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:quickalert/quickalert.dart';

class SellPage extends StatefulWidget {
  @override
  _SellPageState createState() => _SellPageState();
}

class _SellPageState extends State<SellPage> {
  String dropValue = 'Sofas'; // Default category
  TextEditingController dateController = TextEditingController();
  TextEditingController customerNameController = TextEditingController();
  TextEditingController customerPhoneController = TextEditingController();
  TextEditingController customerPlaceController = TextEditingController();
  TextEditingController itemCountController = TextEditingController();
  String? selectedProductId;
  int remainingStock = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sell Product'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildDropdown(
              'Select Category',
              ['Sofas', 'Curtains', 'Headboards', 'Beds', 'Custom Pieces'],
              dropValue, (value) {
            setState(() {
              dropValue = value!;
              _showProductSelectionDialog();
            });
          }),
          _buildTextField('Customer Name', customerNameController),
          _buildTextField('Customer Phone', customerPhoneController,
              keyboardType: TextInputType.phone),
          _buildTextField('Customer Place', customerPlaceController),
          _buildItemCountField(
              'Item Count (Up to $remainingStock)', itemCountController),
          _buildDateField('Select Date', dateController),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: size.width * .2),
            child: ElevatedButton(
              onPressed: _sellProduct,
              child: const Text('Sell Product'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(String label, List<String> items, String value,
      ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.black38)),
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
                .map((item) => DropdownMenuItem(value: item, child: Text(item)))
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
              hintStyle: const TextStyle(height: 0),
            ),
            onTap: () async {
              DateTime? dateTime = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2101),
              );
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
              hintStyle: const TextStyle(height: 0),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildItemCountField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.black38)),
        Container(
          height: 50,
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              hintText: label,
              hintStyle: const TextStyle(height: 0),
            ),
          ),
        ),
      ],
    );
  }

  void _sellProduct() async {
    if (dateController.text.isEmpty ||
        customerNameController.text.isEmpty ||
        customerPhoneController.text.isEmpty ||
        customerPlaceController.text.isEmpty ||
        itemCountController.text.isEmpty) {
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

    // Fetch the current stock
    DocumentSnapshot snapshot = await productRef.get();

    if (snapshot.exists) {
      int currentStock = snapshot['stock'];
      int newStock = currentStock - itemCount;

      // Update the stock value
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

    // Clear fields after selling
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
                        leading: Image.network(product['url'],
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
}
