import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../models/article.dart';
import '../providers/news_provider.dart';
import '../providers/theme_provider.dart';
import 'article_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const List<String> categories = [
    'General',
    'Business',
    'Technology',
    'Sports',
    'Entertainment',
    'Health',
    'Science',
  ];

  int _currentCarouselIndex = 0;
  bool _isSearchActive = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDarkMode
                ? [
              Colors.blueGrey.shade900,
              Colors.blueGrey.shade800.withOpacity(0.9),
              Colors.blueGrey.shade900.withOpacity(0.8),
            ]
                : [
              Colors.blue.shade50,
              Colors.blue.shade100.withOpacity(0.9),
              Colors.blue.shade200.withOpacity(0.8),
            ],
          ),
        ),
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // AppBar with Animated Search Bar
            SliverAppBar(
              pinned: true,
              flexibleSpace: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDarkMode
                        ? [Colors.blueGrey.shade800, Colors.blueGrey.shade600]
                        : [Colors.blue.shade600, Colors.blue.shade400],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
              title: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: child,
                ),
                child: _isSearchActive
                    ? _buildSearchBar(theme)
                    : const Text(
                  'News Hub',
                  key: ValueKey('title'),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    color: Colors.white,
                  ),
                ),
              ),
              actions: [
                IconButton(
                  icon: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Icon(
                      _isSearchActive ? Icons.close : Icons.search,
                      key: ValueKey(_isSearchActive),
                      color: Colors.white,
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      if (_isSearchActive) {
                        _searchController.clear();
                        Provider.of<NewsProvider>(context, listen: false)
                            .fetchNews(); // Reset to default news
                      }
                      _isSearchActive = !_isSearchActive;
                    });
                  },
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: Consumer<ThemeProvider>(
                    builder: (context, themeProvider, _) => IconButton(
                      icon: Icon(
                        themeProvider.isDarkMode
                            ? Icons.wb_sunny
                            : Icons.nightlight_round,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        themeProvider.toggleTheme();
                      },
                    ),
                  ),
                ),
              ],
              elevation: 0,
            ),
            // Main Content
            SliverToBoxAdapter(
              child: Consumer<NewsProvider>(
                builder: (context, provider, _) {
                  if (provider.isLoading && provider.articles.isEmpty) {
                    return SizedBox(
                      height: screenSize.height * 0.5,
                      child: const Center(child: CircularProgressIndicator()),
                    );
                  }
                  if (provider.error.isNotEmpty) {
                    return SizedBox(
                      height: screenSize.height * 0.5,
                      child: Center(child: Text('Error: ${provider.error}')),
                    );
                  }
                  if (provider.articles.isEmpty) {
                    return SizedBox(
                      height: screenSize.height * 0.5,
                      child: const Center(child: Text('No articles found')),
                    );
                  }

                  final heroArticles = provider.articles.take(5).toList();
                  final otherArticles = provider.articles.skip(5).toList();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Hero Carousel
                      _buildHeroCarousel(
                          heroArticles, theme, isDarkMode, screenSize),
                      const SizedBox(height: 16),
                      // Category Chips
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          'Categories',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: screenSize.width * 0.05,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildCategoryChips(provider, theme, isDarkMode),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          'Latest News',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: screenSize.width * 0.05,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  );
                },
              ),
            ),
            // Article List
            SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  final article = Provider.of<NewsProvider>(context, listen: false)
                      .articles
                      .skip(5)
                      .toList()[index];
                  return _buildArticleCard(
                      article, theme, isDarkMode, screenSize);
                },
                childCount: Provider.of<NewsProvider>(context, listen: false)
                    .articles
                    .length -
                    5,
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: [
            theme.primaryColor.withOpacity(0.3),
            theme.primaryColor.withOpacity(0.5),
          ],
        ),
      ),
      child: TextField(
        controller: _searchController,
        autofocus: true,
        decoration: InputDecoration(
          hintText: 'Search news...',
          hintStyle: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontStyle: FontStyle.italic,
          ),
          prefixIcon: const Icon(Icons.search, color: Colors.white),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
            icon: const Icon(Icons.clear, color: Colors.white)
                .animate()
                .fadeIn(duration: 200.ms),
            onPressed: () {
              _searchController.clear();
              Provider.of<NewsProvider>(context, listen: false)
                  .fetchNews(); // Reset to default news
            },
          )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        style: const TextStyle(color: Colors.white),
        onSubmitted: (value) {
          if (value.isNotEmpty) {
            Provider.of<NewsProvider>(context, listen: false).search(value);
            setState(() {
              _isSearchActive = false;
            });
          }
        },
      ),
    ).animate().slideX(
      begin: 0.5,
      end: 0,
      duration: 300.ms,
      curve: Curves.easeOut,
    ).scaleXY(
      begin: 0.8,
      end: 1.0,
      duration: 300.ms,
      curve: Curves.easeOut,
    );
  }

  Widget _buildHeroCarousel(
      List<Article> articles, ThemeData theme, bool isDarkMode, Size screenSize) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        CarouselSlider(
          options: CarouselOptions(
            height: screenSize.height * 0.3,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 5),
            enlargeCenterPage: true,
            viewportFraction: 0.9,
            onPageChanged: (index, reason) {
              setState(() {
                _currentCarouselIndex = index;
              });
            },
          ),
          items: articles.map((article) {
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ArticlePage(url: article.url),
                  ),
                );
              },
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: CachedNetworkImage(
                      imageUrl: article.imageUrl ?? '',
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: isDarkMode
                            ? Colors.blueGrey.shade800
                            : Colors.blue.shade100,
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: isDarkMode
                            ? Colors.blueGrey.shade800
                            : Colors.blue.shade100,
                        child: const Icon(Icons.broken_image, size: 50),
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: isDarkMode
                            ? [
                          Colors.black.withOpacity(0.3),
                          Colors.black.withOpacity(0.8),
                        ]
                            : [
                          Colors.blue.shade700.withOpacity(0.3),
                          Colors.blue.shade900.withOpacity(0.8),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          article.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: screenSize.width * 0.04,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          article.description,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.white70,
                            fontSize: screenSize.width * 0.03,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
        Positioned(
          bottom: 8,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: articles.asMap().entries.map((entry) {
              return Container(
                width: _currentCarouselIndex == entry.key ? 12 : 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentCarouselIndex == entry.key
                      ? theme.primaryColor
                      : Colors.white.withOpacity(0.5),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryChips(
      NewsProvider provider, ThemeData theme, bool isDarkMode) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: categories.map((category) {
          final isSelected = (provider.selectedCategory.isEmpty &&
              category == 'General') ||
              provider.selectedCategory.toLowerCase() == category.toLowerCase();
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () {
                provider.setCategory(category);
              },
              child: Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    colors: isSelected
                        ? isDarkMode
                        ? [Colors.blue.shade700, Colors.blue.shade500]
                        : [Colors.blue.shade400, Colors.blue.shade600]
                        : isDarkMode
                        ? [Colors.blueGrey.shade800, Colors.blueGrey.shade600]
                        : [Colors.blueGrey.shade400, Colors.blueGrey.shade200],
                  ),
                ),
                child: Text(
                  category,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.white70,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 14,
                  ),
                ),
              ),
            ).animate().scaleXY(
              begin: isSelected ? 1.1 : 1.0,
              end: isSelected ? 1.1 : 1.0,
              duration: 200.ms,
              curve: Curves.easeOut,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildArticleCard(
      Article article, ThemeData theme, bool isDarkMode, Size screenSize) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ArticlePage(url: article.url),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDarkMode
                ? [
              Colors.blueGrey.shade800.withOpacity(0.2),
              Colors.blueGrey.shade700.withOpacity(0.2),
            ]
                : [
              Colors.blue.shade50.withOpacity(0.2),
              Colors.blue.shade100.withOpacity(0.2),
            ],
          ),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
              child: CachedNetworkImage(
                imageUrl: article.imageUrl ?? '',
                width: screenSize.width * 0.3,
                height: screenSize.height * 0.12,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: isDarkMode
                      ? Colors.blueGrey.shade800
                      : Colors.blue.shade100,
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  color: isDarkMode
                      ? Colors.blueGrey.shade800
                      : Colors.blue.shade100,
                  child: const Icon(Icons.broken_image),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      article.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: screenSize.width * 0.04,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      article.description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: screenSize.width * 0.03,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isDarkMode
                              ? [Colors.blue.shade700, Colors.blue.shade500]
                              : [Colors.blue.shade400, Colors.blue.shade600],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        article.url.split('/')[2],
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.white,
                          fontSize: screenSize.width * 0.025,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(
      begin: 0.2,
      end: 0,
      duration: 500.ms,
      curve: Curves.easeOut,
    );
  }
}