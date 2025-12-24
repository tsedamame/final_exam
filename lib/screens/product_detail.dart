import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../models/product_comment.dart';
import '../provider/globalProvider.dart';
import '../widgets/product_comments.dart';

class ProductDetail extends StatelessWidget {
  final Product product;
  const ProductDetail({required this.product, super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GlobalProvider>(
      builder: (context, provider, child) {
        final isFavorite = provider.isFavorite(product.id);

        return Scaffold(
          appBar: AppBar(
            title: Text(product.title),
            actions: [
              IconButton(
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: Colors.red,
                ),
                onPressed: () {
                  if (provider.isLoggedIn) {
                    if (isFavorite) {
                      provider.removeFromFavorites(product.id);
                    } else {
                      provider.addToFavorites(product);
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Эхлээд нэвтэрнэ үү')),
                    );
                  }
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.network(
                  product.image,
                  width: double.infinity,
                  height: 250,
                  fit: BoxFit.cover,
                ),
                const SizedBox(height: 16),
                Text(
                  product.title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(product.description, style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 16),
                Text(
                  'PRICE: \$${product.price}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
                StreamBuilder<List<ProductComment>>(
                  stream: provider.productCommentsStream(product.id),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Text(
                          'Failed to load comments: ${snapshot.error}',
                        ),
                      );
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Padding(
                        padding: EdgeInsets.only(top: 16),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }

                    final comments = snapshot.data ?? const <ProductComment>[];
                    return ProductComments(
                      isLoggedIn: provider.isLoggedIn,
                      comments: comments,
                      addComment: (message) async {
                        if (!provider.isLoggedIn) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Нэвтэрч орно уу')),
                          );
                          return;
                        }

                        await provider.addProductComment(product.id, message);
                      },
                    );
                  },
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              if (provider.isLoggedIn) {
                await provider.addToCart(product);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Сагсанд нэмэгдлээ')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Эхлээд нэвтэрнэ үү')),
                );
              }
            },
            child: const Icon(Icons.shopping_bag),
          ),
        );
      },
    );
  }
}
