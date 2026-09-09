import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/pump_review.dart';
import '../providers/review_provider.dart';
import '../widgets/review_stars.dart';

class ReviewFormScreen extends StatefulWidget {
  final String pumpName;
  final PumpReview? review;

  const ReviewFormScreen({super.key, required this.pumpName, this.review});

  @override
  State<ReviewFormScreen> createState() => _ReviewFormScreenState();
}

class _ReviewFormScreenState extends State<ReviewFormScreen> {
  late int _rating;
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _rating = widget.review?.rating ?? 5;
    _controller = TextEditingController(text: widget.review?.comment ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final provider = context.read<ReviewProvider>();
    final success = widget.review == null
        ? await provider.add(rating: _rating, comment: _controller.text)
        : await provider.edit(reviewId: widget.review!.id, rating: _rating, comment: _controller.text);
    if (!mounted) return;
    if (success) {
      Navigator.pop(context, true);
    } else if (provider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(provider.errorMessage!)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final saving = context.watch<ReviewProvider>().isSaving;
    return Scaffold(
      appBar: AppBar(title: Text(widget.review == null ? 'Write a Review' : 'Edit Review')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(widget.pumpName, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          const Text('Your rating'),
          const SizedBox(height: 10),
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                5,
                (index) => IconButton(
                  onPressed: saving ? null : () => setState(() => _rating = index + 1),
                  iconSize: 36,
                  icon: Icon(index < _rating ? Icons.star : Icons.star_border),
                ),
              ),
            ),
          ),
          Center(child: ReviewStars(rating: _rating, showNumber: true)),
          const SizedBox(height: 24),
          TextField(
            controller: _controller,
            maxLines: 6,
            maxLength: 500,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Review',
              hintText: 'Share your experience with this petrol pump.',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: saving ? null : _submit,
            icon: saving ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.send),
            label: Text(saving ? 'Saving...' : 'Submit Review'),
          ),
        ],
      ),
    );
  }
}
