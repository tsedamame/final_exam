import 'dart:async';

import 'package:flutter/material.dart';
import '../models/product_comment.dart';

class ProductComments extends StatefulWidget {
  const ProductComments({
    super.key,
    required this.addComment,
    required this.comments,
    required this.isLoggedIn,
  });

  final FutureOr<void> Function(String message) addComment;
  final List<ProductComment> comments;
  final bool isLoggedIn;

  @override
  State<ProductComments> createState() => _ProductCommentsState();
}

class _ProductCommentsState extends State<ProductComments> {
  final _formKey = GlobalKey<FormState>(debugLabel: '_ProductCommentsState');
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text(
          'Comments',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        if (widget.isLoggedIn)
          Form(
            key: _formKey,
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Write a comment',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Enter your comment to continue';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      await widget.addComment(_controller.text.trim());
                      _controller.clear();
                    }
                  },
                  child: const Text('SEND'),
                ),
              ],
            ),
          )
        else
          const Text('Log in to write a comment.'),
        const SizedBox(height: 12),
        if (widget.comments.isEmpty)
          const Text('No comments yet.')
        else
          ...widget.comments.map(
            (c) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Text('${c.name}: ${c.message}'),
            ),
          ),
      ],
    );
  }
}
