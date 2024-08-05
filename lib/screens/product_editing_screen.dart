import 'package:flutter/material.dart';
import 'package:my_shop/providers/product.dart';
import 'package:my_shop/providers/the_products.dart';
import 'package:my_shop/providers/theme.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class ProductEditScreen extends StatefulWidget {
  const ProductEditScreen({super.key});
  static const route = 'product_edit';

  @override
  State<ProductEditScreen> createState() => _ProductEditScreenState();
}

class _ProductEditScreenState extends State<ProductEditScreen> {
  final _sizedBox = const SizedBox(height: 5);
  final _imageController = TextEditingController();
  final _priceNode = {
    'node': FocusNode(),
    'notInit': true,
    'controller': TextEditingController()
  };
  final _imageNode = FocusNode();
  final _formGlobalKey = GlobalKey<FormState>();
  // final productsProvider = Provider.of<TheProducts>(context,listen: false);
  AutovalidateMode _autovalidation = AutovalidateMode.disabled;
  Product _editedProduct =
      Product(description: "", id: null, imageUrl: '', price: 0, title: '');
  List _initialLabels = ["", ""];
  bool _firstinit = false;
  bool _isLoading = false;
  bool _isValidImageUrl =false;

  @override
  void initState() {
    _imageNode.addListener(_updateImageUrl);
    ((_priceNode['node']) as FocusNode).addListener(_updatePrice);

    super.initState();
  }

  @override
  void dispose() {
    _imageController.dispose();
    _imageNode.dispose();
    _imageNode.removeListener(_updateImageUrl);
    ((_priceNode['node']) as FocusNode).removeListener(_updatePrice);

    super.dispose();
  }

  @override
  void didChangeDependencies() {
    if (!_firstinit) {
      final id = ModalRoute.of(context)!.settings.arguments as String?;
      if (id != null) {
        _editedProduct =
            Provider.of<TheProducts>(context, listen: false).productWithId(id);
        _initialLabels = [
          _editedProduct.title,
          _editedProduct.description,
        ];
        _imageController.text = _editedProduct.imageUrl;
        ((_priceNode['controller']) as TextEditingController).text =
            _editedProduct.price.toString();
        _priceNode.update('notInit', (value) => false);
      }

      _firstinit = true;
    }
    super.didChangeDependencies();
  }

  Future<bool> _isValidUrl(String url) async {
    try{
     final response= await http.head(Uri.parse(url));
      if(response.statusCode==200){return true;} return false;
    }catch(error){
      RegExp regExp = RegExp(
      r"^https?:\/\/.*",
      caseSensitive: false,
    );
    return regExp.hasMatch(url);
     }
    

   
  }

  void _updateImageUrl() async {
    if (!_imageNode.hasFocus) {
    _isValidImageUrl= await _isValidUrl(_imageController.text);
      setState(() {

      });
    }
  }

//this function minus the submetted number by 0.01 and checks if the price field is first used
//then when user finishes using it chickes if and only entered a valid double then it changes [_priceNode['notInit']]
  void _updatePrice() {
    if (!((_priceNode['node']) as FocusNode).hasFocus &&
        ((_priceNode['notInit']) as bool)) {
      try {
        final newValue = (double.parse(
                    ((_priceNode['controller']) as TextEditingController)
                        .text) -
                0.01)
            .toString();
        ((_priceNode['controller']) as TextEditingController).text = newValue;
      } catch (error) {
        _priceNode.update('notInit', (value) => true);
        return;
      }

      _priceNode.update('notInit', (value) => false);
    }
  }

  void _submet() async {
    if (!_formGlobalKey.currentState!.validate()) {
      setState(() {
        _autovalidation = AutovalidateMode.onUserInteraction;
      });
      return;
    }
    _formGlobalKey.currentState!.save();
    if (_editedProduct.id == null) {
      setState(() {
        _isLoading = true;
      });
      try {
        await Provider.of<TheProducts>(context, listen: false)
            .addProduct(_editedProduct);
      } catch (error) {
        if (!mounted) return;
        await showDialog<void>(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text("ERROR"),
                content: const Text("something went wrong"),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("OK"),
                  ),
                ],
              );
            });
      } finally {
        if (mounted) {
          Navigator.pop(context);
        }
      }
    } else {
      Provider.of<TheProducts>(context, listen: false)
          .editProduct(_editedProduct, _editedProduct.id!);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<AppTheme>(context, listen: false).currentTheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit product"),
        actions: [
          IconButton(
            onPressed: _submet,
            icon: const Icon(Icons.save),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Form(
              key: _formGlobalKey,
              autovalidateMode: _autovalidation,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      TextFormField(
                        initialValue: _initialLabels[0],
                        decoration: InputDecoration(
                          labelText: "Title",
                          hintText: "Product's name",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          icon: Icon(Icons.title,
                              color: theme.colorScheme.secondary),
                        ),
                        textCapitalization: TextCapitalization.words,
                        textInputAction: TextInputAction.next,
                        onSaved: (newValue) => _editedProduct = Product(
                            description: _editedProduct.description,
                            id: _editedProduct.id,
                            imageUrl: _editedProduct.imageUrl,
                            price: _editedProduct.price,
                            title: newValue!,
                            isFavorite: _editedProduct.isFavorite),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Please enter a title";
                          }
                          return null;
                        },
                      ),
                      _sizedBox,
                      TextFormField(
                        controller:
                            (_priceNode['controller']) as TextEditingController,
                        decoration: InputDecoration(
                          suffix: const Text("\$"),
                          labelText: "Price",
                          hintText: "Product's cost",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          icon: Icon(Icons.price_change_outlined,
                              color: theme.colorScheme.secondary),
                        ),
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        focusNode: (_priceNode['node']) as FocusNode,
                        onSaved: (newValue) => _editedProduct = Product(
                            description: _editedProduct.description,
                            id: _editedProduct.id,
                            imageUrl: _editedProduct.imageUrl,
                            price: double.parse(newValue!),
                            title: _editedProduct.title,
                            isFavorite: _editedProduct.isFavorite),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Please enter a number";
                          }
                          if (double.tryParse(value) == null) {
                            return "Please enter a valid number";
                          }

                          return null;
                        },
                      ),
                      _sizedBox,
                      TextFormField(
                        initialValue: _initialLabels[1],
                        textCapitalization: TextCapitalization.sentences,
                        decoration: InputDecoration(
                          alignLabelWithHint: true,
                          labelText: "Description",
                          hintText: "A brief descreption about the product",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          icon: Icon(
                            Icons.description,
                            color: theme.colorScheme.secondary,
                          ),
                        ),
                        maxLines: 4,
                        keyboardType: TextInputType.multiline,
                        onSaved: (newValue) => _editedProduct = Product(
                            description: newValue!,
                            id: _editedProduct.id,
                            imageUrl: _editedProduct.imageUrl,
                            price: _editedProduct.price,
                            title: _editedProduct.title,
                            isFavorite: _editedProduct.isFavorite),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Please enter a description";
                          }
                          if (value.length < 10) {
                            return "Please enter a longer description";
                          }
                          return null;
                        },
                      ),
                      _sizedBox,
                      TextFormField(
                        focusNode: _imageNode,
                        controller: _imageController,
                        decoration: InputDecoration(
                          labelText: "Image URL",
                          hintText: "Image URL",
                          prefix: (_imageController.text.isNotEmpty &&
                                  _isValidImageUrl)
                              ? SizedBox(
                                  height: 100,
                                  width: 100,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0),
                                    child: Image.network(_imageController.text,
                                        fit: BoxFit.cover),
                                  ),
                                )
                              : const Text(""),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          icon: Icon(
                            Icons.image,
                            color: theme.colorScheme.secondary,
                          ),
                        ),
                        textInputAction: TextInputAction.send,
                        onSaved: (newValue) => _editedProduct = Product(
                            description: _editedProduct.description,
                            id: _editedProduct.id,
                            imageUrl: newValue!,
                            price: _editedProduct.price,
                            title: _editedProduct.title,
                            isFavorite: _editedProduct.isFavorite),
                        onFieldSubmitted: (_) => _submet(),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter an image URL.';
                          }
                          if (!_isValidImageUrl) {
                            return 'Please enter a valid URL or check network connection.';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
