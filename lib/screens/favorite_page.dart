import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../provider/globalProvider.dart';

class FavoritePage extends StatelessWidget {
  const FavoritePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Consumer<GlobalProvider>(
      builder: (context, provider, child) {
        if (!provider.isLoggedIn) {
          return const Scaffold(
            body: Center(child: Text('Нэвтэрж байж харна уу')),
          );
        }

        return Scaffold(
          appBar: AppBar(title: const Text('Favorites')),
          body: StreamBuilder<QuerySnapshot>(
            stream: provider.favoritesStream(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final docs = snapshot.data?.docs ?? const [];
              if (docs.isEmpty) {
                return const Center(child: Text('No favorites yet'));
              }

              return ListView.separated(
                itemCount: docs.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final doc = docs[index];
                  final data = doc.data() as Map<String, dynamic>;
                  final title = (data['title'] as String?) ?? 'Item';
                  final image = (data['image'] as String?) ?? '';
                  final price = (data['price'] as num?)?.toDouble() ?? 0;
                  final productId = (data['id'] as num?)?.toInt();

                  return ListTile(
                    leading: image.isNotEmpty
                        ? Image.network(
                            image,
                            width: 56,
                            height: 56,
                            fit: BoxFit.cover,
                          )
                        : const SizedBox(width: 56, height: 56),
                    title: Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text('\$${price.toStringAsFixed(2)}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.favorite, color: Colors.red),
                      onPressed: productId == null
                          ? null
                          : () async {
                              await provider.removeFromFavorites(productId);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Хасагдлаа')),
                                );
                              }
                            },
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}
