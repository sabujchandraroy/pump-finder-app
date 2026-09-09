import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/pump_review.dart';
import '../providers/review_provider.dart';
import '../widgets/review_stars.dart';
import 'review_form_screen.dart';

class ReviewsScreen extends StatefulWidget {
  final String pumpId;
  final String pumpName;

  const ReviewsScreen({super.key, required this.pumpId, required this.pumpName});

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReviewProvider>().loadReviews(widget.pumpId);
    });
  }

  Future<void> _openForm([PumpReview? review]) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => ReviewFormScreen(pumpName: widget.pumpName, review: review)),
    );
    if (changed == true && mounted) {
      await context.read<ReviewProvider>().loadReviews(widget.pumpId);
    }
  }

  Future<void> _delete(PumpReview review) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Review'),
        content: const Text('Are you sure you want to delete this review?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final ok = await context.read<ReviewProvider>().remove(review.id);
    if (!mounted) return;
    if (!ok) {
      final error = context.read<ReviewProvider>().errorMessage;
      if (error != null) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReviewProvider>();
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;

    return Scaffold(
      appBar: AppBar(title: const Text('Reviews')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        icon: const Icon(Icons.rate_review_outlined),
        label: const Text('Write Review'),
      ),
      body: RefreshIndicator(
        onRefresh: () => provider.loadReviews(widget.pumpId),
        child: provider.isLoading && provider.reviews.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : provider.reviews.isEmpty
                ? ListView(children: const [SizedBox(height: 180), Center(child: Text('No reviews yet. Be the first to review this pump.'))])
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                    itemCount: provider.reviews.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final review = provider.reviews[index];
                      final mine = review.userId == currentUserId;
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(child: Text(review.userName.isEmpty ? '?' : review.userName[0].toUpperCase())),
                                  const SizedBox(width: 12),
                                  Expanded(child: Text(review.userName, style: const TextStyle(fontWeight: FontWeight.bold))),
                                  if (mine)
                                    PopupMenuButton<String>(
                                      onSelected: (value) {
                                        if (value == 'edit') _openForm(review);
                                        if (value == 'delete') _delete(review);
                                      },
                                      itemBuilder: (_) => const [
                                        PopupMenuItem(value: 'edit', child: Text('Edit')),
                                        PopupMenuItem(value: 'delete', child: Text('Delete')),
                                      ],
                                    )
                                  else
                                    IconButton(
                                      tooltip: 'Report review',
                                      onPressed: () => Navigator.pushNamed(context, '/report', arguments: {
                                        'reviewId': review.id,
                                        'pumpId': widget.pumpId,
                                        'pumpName': widget.pumpName,
                                      }),
                                      icon: const Icon(Icons.flag_outlined),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              ReviewStars(rating: review.rating, size: 18),
                              if (review.hasComment) ...[
                                const SizedBox(height: 10),
                                Text(review.comment),
                              ],
                              const SizedBox(height: 8),
                              Text(
                                _formatDate(review.createdAt),
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    return '$d/$m/${date.year}';
  }
}
