import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import '../models/product.dart';
import '../models/product_comment.dart';

class GlobalProvider extends ChangeNotifier {
  int _currentIdx = 0;
  int get currentIdx => _currentIdx;

  void changeCurrentIdx(int idx) {
    _currentIdx = idx;
    notifyListeners();
  }

  // List of products
  List<Product> _products = [];
  List<Product> get products => _products;

  void setProducts(List<Product> products) {
    _products = products;
    notifyListeners();
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
  _favoritesSubscription;
  final Set<int> _favoriteIds = <int>{};

  bool get isLoggedIn => _auth.currentUser != null;

  // COMMENTS
  Future<DocumentReference> addProductComment(int productId, String message) {
    if (!isLoggedIn) {
      throw Exception('Must be logged in');
    }

    final user = _auth.currentUser!;
    return _firestore
        .collection('products')
        .doc(productId.toString())
        .collection('comments')
        .add(<String, dynamic>{
          'text': message,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
          'name': user.displayName ?? user.email ?? 'Anonymous',
          'userId': user.uid,
        });
  }

  Stream<List<ProductComment>> productCommentsStream(int productId) {
    return _firestore
        .collection('products')
        .doc(productId.toString())
        .collection('comments')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => ProductComment.fromFirestore(
                  id: doc.id,
                  data: doc.data(),
                ),
              )
              .toList(),
        );
  }

  // CART
  Future<void> addToCart(Product product) async {
    if (!isLoggedIn) throw Exception('Must be logged in');
    final user = _auth.currentUser!;
    final docRef = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('cart')
        .doc(product.id.toString());

    final snapshot = await docRef.get();
    if (snapshot.exists) {
      final currentQty = snapshot['quantity'] ?? 1;
      await docRef.update({'quantity': currentQty + 1});
    } else {
      await docRef.set({
        'id': product.id,
        'title': product.title,
        'price': product.price,
        'description': product.description,
        'category': product.category,
        'image': product.image,
        'quantity': 1,
      });
    }

    notifyListeners();
  }

  Future<void> removeFromCart(int productId) async {
    if (!isLoggedIn) throw Exception('Must be logged in');
    final user = _auth.currentUser!;
    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('cart')
        .doc(productId.toString())
        .delete();
    notifyListeners();
  }

  // FAVORITES
  Future<void> addToFavorites(Product product) async {
    if (!isLoggedIn) throw Exception('Must be logged in');
    final user = _auth.currentUser!;
    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .doc(product.id.toString())
        .set({
          'id': product.id,
          'title': product.title,
          'price': product.price,
          'description': product.description,
          'category': product.category,
          'image': product.image,
        });
    _favoriteIds.add(product.id);
    notifyListeners();
  }

  Future<void> removeFromFavorites(int productId) async {
    if (!isLoggedIn) throw Exception('Must be logged in');
    final user = _auth.currentUser!;
    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .doc(productId.toString())
        .delete();
    _favoriteIds.remove(productId);
    notifyListeners();
  }

  // Check if product is favorite
  bool isFavorite(int productId) {
    if (!isLoggedIn) return false;

    _ensureFavoritesSubscription();
    return _favoriteIds.contains(productId);
  }

  void _ensureFavoritesSubscription() {
    if (_favoritesSubscription != null) return;
    if (!isLoggedIn) return;

    _favoritesSubscription = _firestore
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .collection('favorites')
        .snapshots()
        .listen((snapshot) {
          _favoriteIds
            ..clear()
            ..addAll(
              snapshot.docs
                  .map((d) => (d.data()['id'] as num?)?.toInt())
                  .whereType<int>(),
            );
          notifyListeners();
        });
  }

  // Optional: streams for cart/favorites
  Stream<QuerySnapshot> cartStream() {
    if (!isLoggedIn) throw Exception('Must be logged in');
    return _firestore
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .collection('cart')
        .snapshots();
  }

  Stream<QuerySnapshot> favoritesStream() {
    if (!isLoggedIn) throw Exception('Must be logged in');
    return _firestore
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .collection('favorites')
        .snapshots();
  }
}
