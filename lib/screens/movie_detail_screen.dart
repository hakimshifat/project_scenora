import 'package:flutter/material.dart';

import '../core/scenora_theme.dart';
import '../models/scenora_models.dart';
import '../widgets/scenora_widgets.dart';

class MovieDetailScreen extends StatefulWidget {
  const MovieDetailScreen({
    super.key,
    required this.movie,
    required this.isSaved,
    required this.onToggleSaved,
    required this.onWriteReview,
  });
  final Movie movie;
  final bool isSaved;
  final VoidCallback onToggleSaved;
  final VoidCallback onWriteReview;

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  late bool _saved = widget.isSaved;

  @override
  Widget build(BuildContext context) {
    final movie = widget.movie;
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            expandedHeight: 310,
            pinned: true,
            actions: [
              IconButton.filledTonal(
                onPressed: () {},
                icon: const Icon(Icons.ios_share_rounded),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: movie.colors,
                      ),
                    ),
                  ),
                  Positioned(
                    right: -70,
                    top: 15,
                    child: Text(
                      movie.initials,
                      style: TextStyle(
                        fontSize: 160,
                        fontWeight: FontWeight.w900,
                        color: Colors.white.withValues(alpha: .12),
                      ),
                    ),
                  ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Color(0xCC090B10)],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 20,
                    right: 20,
                    bottom: 20,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        PosterArt(
                          movie: movie,
                          width: 104,
                          height: 148,
                          radius: 14,
                          hero: true,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                movie.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 27,
                                  fontWeight: FontWeight.w900,
                                  height: 1.05,
                                ),
                              ),
                              const SizedBox(height: 7),
                              Text(
                                '${movie.year} · ${movie.genre}',
                                style: const TextStyle(color: Colors.white70),
                              ),
                              const SizedBox(height: 10),
                              FilledButton.tonalIcon(
                                onPressed: () =>
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Trailer playback will connect to TMDB/YouTube API.',
                                        ),
                                      ),
                                    ),
                                icon: const Icon(Icons.play_arrow_rounded),
                                label: const Text('Trailer'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _ScoreCard(
                          label: 'TMDB',
                          score: '${movie.score}',
                          suffix: '/10',
                          color: const Color(0xFF25B487),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _ScoreCard(
                          label: 'SCENORA',
                          score: '${movie.communityScore}',
                          suffix: '/5',
                          color: ScenoraTheme.crimson,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Storyline',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 9),
                  Text(
                    movie.synopsis,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.55,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 25),
                  Text(
                    'Top cast',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 13),
                  SizedBox(
                    height: 88,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: 5,
                      separatorBuilder: (_, _) => const SizedBox(width: 18),
                      itemBuilder: (_, i) => Column(
                        children: [
                          UserAvatar(
                            name: [
                              'Timothée Chalamet',
                              'Zendaya',
                              'Rebecca Ferguson',
                              'Javier Bardem',
                              'Josh Brolin',
                            ][i],
                            color: movie.colors[i % 2],
                            radius: 27,
                          ),
                          const SizedBox(height: 6),
                          SizedBox(
                            width: 65,
                            child: Text(
                              [
                                'Timothée',
                                'Zendaya',
                                'Rebecca',
                                'Javier',
                                'Josh',
                              ][i],
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 11),
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Text(
                        'Community reviews',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () {},
                        child: const Text('See all'),
                      ),
                    ],
                  ),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const UserAvatar(
                            name: 'Nadia Rahman',
                            color: Color(0xFF5F6BEA),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Nadia Rahman',
                                  style: TextStyle(fontWeight: FontWeight.w800),
                                ),
                                const StarRating(rating: 5, size: 14),
                                const SizedBox(height: 6),
                                const Text(
                                  'Spectacular world-building with a genuinely human core.',
                                  style: TextStyle(height: 1.4),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
          child: Row(
            children: [
              IconButton.filledTonal(
                onPressed: () {
                  setState(() => _saved = !_saved);
                  widget.onToggleSaved();
                },
                icon: Icon(
                  _saved
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_border_rounded,
                  color: _saved ? ScenoraTheme.crimson : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: widget.onWriteReview,
                  icon: const Icon(Icons.edit_rounded),
                  label: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 13),
                    child: Text(
                      'Write a review',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScoreCard extends StatelessWidget {
  const _ScoreCard({
    required this.label,
    required this.score,
    required this.suffix,
    required this.color,
  });
  final String label;
  final String score;
  final String suffix;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: color.withValues(alpha: .11),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Row(
      children: [
        Icon(Icons.star_rounded, color: color),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
            RichText(
              text: TextSpan(
                style: DefaultTextStyle.of(context).style,
                children: [
                  TextSpan(
                    text: score,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  TextSpan(
                    text: suffix,
                    style: TextStyle(
                      fontSize: 11,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
