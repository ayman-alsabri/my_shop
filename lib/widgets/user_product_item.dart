import 'package:flutter/material.dart';
import 'package:my_shop/providers/the_products.dart';
import 'package:my_shop/providers/theme.dart';
import 'package:my_shop/screens/product_editing_screen.dart';
import 'package:provider/provider.dart';

class UserProductItem extends StatelessWidget {
  final String id;
  final String imageUrl;
  final String title;
  const UserProductItem(
      {required this.id,
      required this.imageUrl,
      required this.title,
      super.key});

  @override
  Widget build(BuildContext context) {
    final scaffold= ScaffoldMessenger.of(context);
    final theme = Provider.of<AppTheme>(context, listen: false).currentTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      child: ListTile(
        tileColor: theme.colorScheme.outlineVariant,
        leading: CircleAvatar(
          backgroundColor: theme.scaffoldBackgroundColor,
          backgroundImage: NetworkImage(imageUrl),
        ),
        title: Text(title),
        trailing: SizedBox(
          width: 100,
          child: Row(
            children: [
              IconButton(
                onPressed: () {
                  Navigator.pushNamed(context, ProductEditScreen.route,
                      arguments: id);
                },
                icon: const Icon(Icons.edit),
                tooltip: "edit this product",
              ),
              IconButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text("Delete this product?"),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text("NO"),
                        ),
                        TextButton(
                          onPressed: () async {
                            try {
                              if (context.mounted) {
                              Navigator.pop(context);
                            }
                              await Provider.of<TheProducts>(context,
                                      listen: false)
                                  .deleteProduct(id);
                            } catch (_) {
                              
                              scaffold.showSnackBar(
                                  const SnackBar(
                                      content:  Text('could not delete')));
                            }
                            
                          },
                          child: const Text("YES"),
                        ),
                      ],
                    ),
                  );
                },
                icon: const Icon(Icons.delete),
                tooltip: "delete this product",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
