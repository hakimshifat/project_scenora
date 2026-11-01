import 'package:flutter/material.dart';

import '../core/scenora_theme.dart';
import '../models/scenora_models.dart';
import '../widgets/scenora_widgets.dart';
import 'movie_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.reviews,
    required this.onCreateReview,
    required this.watchlist,
    required this.onToggleWatchlist,
    required this.requireAuth,
    required this.onToggleLike,
    required this.addComment,
    required this.getComments,
    required this.onRefresh,
    required this.onOpenSearch,
    required this.onOpenMessages,
  });
  final List<Review> reviews;
  final ValueChanged<Movie?> onCreateReview;
  final Set<Movie> watchlist;
  final ValueChanged<Movie> onToggleWatchlist;
  final Future<bool> Function(String reason) requireAuth;
  final Future<({bool liked, int likeCount})?> Function(Review review)
  onToggleLike;
  final Future<String?> Function(Review review, String text) addComment;
  final Future<List<Map<String, dynamic>>> Function(Review review) getComments;
  final Future<void> Function() onRefresh;
  final VoidCallback onOpenSearch;
  final VoidCallback onOpenMessages;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _followingOnly = false;

  void _openMovie(Movie movie) => Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => MovieDetailScreen(
        movie: movie,
        isSaved: widget.watchlist.contains(movie),
        onToggleSaved: () => widget.onToggleWatchlist(movie),
        onWriteReview: () => widget.onCreateReview(movie),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const BrandMark(),
      actions: [
        IconButton(
          tooltip: 'Search',
          onPressed: widget.onOpenSearch,
          icon: const Icon(Icons.search_rounded),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: IconButton.filledTonal(
            tooltip: 'Messages',
            onPressed: widget.onOpenMessages,
            icon: const Icon(Icons.mail_outline_rounded),
          ),
        ),
      ],
    ),
    body: RefreshIndicator(
      onRefresh: widget.onRefresh,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 14),
              child: Row(
                children: [
                  _FeedPill(
                    label: 'For you',
                    selected: !_followingOnly,
                    onTap: () => setState(() => _followingOnly = false),
                  ),
                  const SizedBox(width: 8),
                  _FeedPill(
                    label: 'Following',
                    selected: _followingOnly,
                    onTap: () => setState(() => _followingOnly = true),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.tune_rounded,
                    size: 20,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
          if (widget.reviews.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text(
                    'No reviews yet. Search for a movie and write the first review!',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            )
          else
            SliverList.separated(
              itemCount: widget.reviews.length,
              separatorBuilder: (_, _) => const SizedBox(height: 14),
              itemBuilder: (context, index) => Padding(
                padding: EdgeInsets.fromLTRB(
                  12,
                  0,
                  12,
                  index == widget.reviews.length - 1 ? 100 : 0,
                ),
                child: ReviewCard(
                  review: widget.reviews[index],
                  onMovieTap: () => _openMovie(widget.reviews[index].movie),
                  requireAuth: widget.requireAuth,
                  onToggleLike: widget.onToggleLike,
                  addComment: widget.addComment,
                  getComments: widget.getComments,
                ),
              ),
            ),
        ],
      ),
    ),
  );
}

class _FeedPill extends StatelessWidget {
  const _FeedPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ChoiceChip(
    label: Text(label),
    selected: selected,
    showCheckmark: false,
    onSelected: (_) => onTap(),
    selectedColor: ScenoraTheme.crimson,
    labelStyle: TextStyle(
      color: selected ? Colors.white : null,
      fontWeight: FontWeight.w700,
    ),
  );
}

class ReviewCard extends StatefulWidget {
  const ReviewCard({
    super.key,
    required this.review,
    required this.onMovieTap,
    required this.requireAuth,
    required this.onToggleLike,
    required this.addComment,
    required this.getComments,
  });
  final Review review;
  final VoidCallback onMovieTap;
  final Future<bool> Function(String reason) requireAuth;
  final Future<({bool liked, int likeCount})?> Function(Review review)
  onToggleLike;
  final Future<String?> Function(Review review, String text) addComment;
  final Future<List<Map<String, dynamic>>> Function(Review review) getComments;

  @override
  State<ReviewCard> createState() => _ReviewCardState();
}

class _ReviewCardState extends State<ReviewCard> {
  Future<void> _toggleLike() async {
    final allowed = await widget.requireAuth(
      'Log in to like reviews and support other movie fans.',
    );
    if (!allowed || !mounted) return;
    final backendResult = await widget.onToggleLike(widget.review);
    if (!mounted) return;
    if (backendResult != null) {
      setState(() {
        widget.review.liked = backendResult.liked;
        widget.review.likes = backendResult.likeCount;
      });
      return;
    }
    setState(() {
      widget.review.liked = !widget.review.liked;
      widget.review.likes += widget.review.liked ? 1 : -1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final review = widget.review;
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                UserAvatar(
                  name: review.user,
                  color: review.avatarColor,
                  radius: 21,
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review.user,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      Text(
                        '${review.handle} · ${review.time}',
                        style: TextStyle(
                          fontSize: 12,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.more_horiz_rounded),
                ),
              ],
            ),
            const SizedBox(height: 14),
            InkWell(
              onTap: widget.onMovieTap,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest.withValues(alpha: .42),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    PosterArt(
                      movie: review.movie,
                      width: 54,
                      height: 76,
                      radius: 10,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            review.movie.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '${review.movie.year} · ${review.movie.genre}',
                            style: TextStyle(
                              fontSize: 12,
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 7),
                          StarRating(rating: review.rating),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 13),
            if (review.spoiler)
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: ScenoraTheme.crimson.withValues(alpha: .13),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: const Text(
                  'SPOILER',
                  style: TextStyle(
                    fontSize: 10,
                    color: ScenoraTheme.crimson,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            Text(
              review.text,
              style: const TextStyle(height: 1.5, fontSize: 15),
            ),
            const SizedBox(height: 12),
            Divider(color: scheme.outlineVariant.withValues(alpha: .5)),
            Row(
              children: [
                EmptyActionButton(
                  icon: review.liked
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  label: '${review.likes}',
                  onTap: _toggleLike,
                ),
                EmptyActionButton(
                  icon: Icons.chat_bubble_outline_rounded,
                  label: '${review.comments}',
                  onTap: _showComments,
                ),
                const Spacer(),
                IconButton(
                  tooltip: 'Share',
                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Share link copied')),
                  ),
                  icon: const Icon(Icons.ios_share_rounded, size: 20),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showComments() async {
    try {
      final comments = await widget.getComments(widget.review);
      if (!mounted) return;
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        builder: (_) => _CommentsSheet(
          review: widget.review,
          initialComments: comments,
          requireAuth: widget.requireAuth,
          getComments: widget.getComments,
          addComment: widget.addComment,
          onCountChanged: (count) {
            if (mounted) setState(() => widget.review.comments = count);
          },
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('$error')));
    }
  }
}

class _CommentsSheet extends StatefulWidget {
  const _CommentsSheet({
    required this.review,
    required this.initialComments,
    required this.requireAuth,
    required this.getComments,
    required this.addComment,
    required this.onCountChanged,
  });

  final Review review;
  final List<Map<String, dynamic>> initialComments;
  final Future<bool> Function(String reason) requireAuth;
  final Future<List<Map<String, dynamic>>> Function(Review review) getComments;
  final Future<String?> Function(Review review, String text) addComment;
  final ValueChanged<int> onCountChanged;

  @override
  State<_CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends State<_CommentsSheet> {
  late List<Map<String, dynamic>> _comments;
  final _controller = TextEditingController();
  bool _posting = false;

  @override
  void initState() {
    super.initState();
    _comments = List.of(widget.initialComments);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    final comments = await widget.getComments(widget.review);
    if (!mounted) return;
    setState(() => _comments = comments);
    widget.onCountChanged(comments.length);
  }

  Future<void> _submit() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _posting) return;
    final allowed = await widget.requireAuth(
      'Log in to add a comment to this review.',
    );
    if (!allowed || !mounted) return;
    setState(() => _posting = true);
    final error = await widget.addComment(widget.review, text);
    if (!mounted) return;
    if (error != null) {
      setState(() => _posting = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    _controller.clear();
    await _refresh();
    if (mounted) setState(() => _posting = false);
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.fromLTRB(
      20,
      14,
      20,
      MediaQuery.viewInsetsOf(context).bottom + 24,
    ),
    child: SizedBox(
      height: MediaQuery.sizeOf(context).height * .65,
      child: Column(
        children: [
          Container(
            width: 42,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Comments',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                ),
              ),
              IconButton(
                tooltip: 'Refresh comments',
                onPressed: _refresh,
                icon: const Icon(Icons.refresh_rounded),
              ),
            ],
          ),
          Expanded(
            child: _comments.isEmpty
                ? const Center(child: Text('No comments yet.'))
                : ListView.builder(
                    itemCount: _comments.length,
                    itemBuilder: (context, index) {
                      final comment = _comments[index];
                      final user =
                          comment['user'] as Map<String, dynamic>? ?? const {};
                      final name =
                          '${user['displayName'] ?? user['username'] ?? 'Member'}';
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: UserAvatar(
                          name: name,
                          color: const Color(0xFF5F6BEA),
                        ),
                        title: Text(
                          '$name  @${user['username'] ?? 'member'}',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        subtitle: Text('${comment['text'] ?? ''}'),
                      );
                    },
                  ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _controller,
            textInputAction: TextInputAction.send,
            onSubmitted: (_) => _submit(),
            decoration: InputDecoration(
              hintText: 'Add a thoughtful comment…',
              suffixIcon: IconButton(
                onPressed: _posting ? null : _submit,
                icon: _posting
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send_rounded),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
