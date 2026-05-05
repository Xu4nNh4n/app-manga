import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/truyen.dart';
import '../models/chuong.dart';
import '../models/category.dart';
import '../services/firestore_service.dart';
import '../utils/constants.dart';

// === MÀN HÌNH ADMIN - QUẢN LÝ TRUYỆN & THỂ LOẠI ===
class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final _fs = FirestoreService();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Quản Trị'),
          centerTitle: true,
          bottom: TabBar(
            indicatorColor: AppColors.gradientStart,
            labelColor: AppColors.gradientStart,
            unselectedLabelColor: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            tabs: const [
              Tab(icon: Icon(Icons.book), text: 'Truyện'),
              Tab(icon: Icon(Icons.category), text: 'Thể loại'),
            ],
          ),
        ),
        body: TabBarView(children: [_buildStoriesTab(isDark), _buildCategoriesTab(isDark)]),
      ),
    );
  }

  // === TAB 1: TRUYỆN ===
  Widget _buildStoriesTab(bool isDark) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddStoryDialog(isDark),
        backgroundColor: AppColors.gradientStart,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: StreamBuilder<List<Story>>(
        stream: _fs.getStories(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          final stories = snapshot.data ?? [];
          if (stories.isEmpty) {
            return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.library_books, size: 64, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text('Chưa có truyện nào', style: TextStyle(fontSize: AppFontSizes.medium, color: Colors.grey.shade500)),
            ]));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.lg),
            itemCount: stories.length,
            itemBuilder: (context, index) {
              final story = stories[index];
              return Container(
                margin: const EdgeInsets.only(bottom: AppSpacing.md),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark : Colors.white,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(AppSpacing.md),
                  leading: Container(
                    width: 50, height: 70,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(AppRadius.sm), color: AppColors.gradientStart.withValues(alpha: 0.1)),
                    child: story.coverImage.isNotEmpty
                        ? ClipRRect(borderRadius: BorderRadius.circular(AppRadius.sm),
                            child: story.coverImage.startsWith('http') ? Image.network(story.coverImage, fit: BoxFit.cover) : Image.asset(story.coverImage, fit: BoxFit.cover))
                        : const Center(child: Icon(Icons.book, color: AppColors.gradientStart)),
                  ),
                  title: Text(story.title, style: TextStyle(fontWeight: FontWeight.w700, color: isDark ? Colors.white : AppColors.primaryDark)),
                  subtitle: Text('${story.chapterCount} chương • ${story.views} views • ⭐ ${story.rating}',
                      style: TextStyle(fontSize: AppFontSizes.small, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600)),
                  trailing: PopupMenuButton<String>(
                    onSelected: (v) {
                      if (v == 'edit') _showEditStoryDialog(story, isDark);
                      if (v == 'add_chapter') _showAddChapterDialog(story, isDark);
                      if (v == 'delete') _confirmDeleteStory(story, isDark);
                    },
                    itemBuilder: (_) => [
                      const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, size: 18), SizedBox(width: 8), Text('Sửa truyện')])),
                      const PopupMenuItem(value: 'add_chapter', child: Row(children: [Icon(Icons.add_circle, size: 18), SizedBox(width: 8), Text('Thêm chương')])),
                      const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, size: 18, color: Colors.red), SizedBox(width: 8), Text('Xóa truyện', style: TextStyle(color: Colors.red))])),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // === TAB 2: THỂ LOẠI ===
  Widget _buildCategoriesTab(bool isDark) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddCategoryDialog(isDark),
        backgroundColor: AppColors.gradientEnd,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: StreamBuilder<List<StoryCategory>>(
        stream: _fs.getCategories(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          final cats = snapshot.data ?? [];
          if (cats.isEmpty) {
            return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.category_outlined, size: 64, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text('Chưa có thể loại nào', style: TextStyle(fontSize: AppFontSizes.medium, color: Colors.grey.shade500)),
              const SizedBox(height: 8),
              Text('Nhấn + để thêm', style: TextStyle(fontSize: AppFontSizes.body, color: Colors.grey.shade400)),
            ]));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.lg),
            itemCount: cats.length,
            itemBuilder: (context, index) {
              final cat = cats[index];
              return Container(
                margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark : Colors.white,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6, offset: const Offset(0, 2))],
                ),
                child: ListTile(
                  leading: Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: [AppColors.gradientStart.withValues(alpha: 0.15), AppColors.gradientEnd.withValues(alpha: 0.15)])),
                    child: const Center(child: Icon(Icons.label, color: AppColors.gradientStart, size: 20)),
                  ),
                  title: Text(cat.name, style: TextStyle(fontWeight: FontWeight.w600, color: isDark ? Colors.white : AppColors.primaryDark)),
                  trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                    IconButton(icon: Icon(Icons.edit, size: 20, color: Colors.blue.shade400), onPressed: () => _showEditCategoryDialog(cat, isDark)),
                    IconButton(icon: Icon(Icons.delete, size: 20, color: Colors.red.shade400), onPressed: () => _confirmDeleteCategory(cat, isDark)),
                  ]),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // === DIALOG: THÊM TRUYỆN ===
  void _showAddStoryDialog(bool isDark) {
    final t = TextEditingController(), a = TextEditingController(), d = TextEditingController();
    final c = TextEditingController(), g = TextEditingController();
    final fc = TextEditingController(text: '3'), cc = TextEditingController(text: '5');
    _showStoryForm(isDark, 'Thêm Truyện Mới', t, a, d, c, g, fc, cc, 'Thêm', () async {
      if (t.text.trim().isEmpty) return;
      final story = Story(id: '', title: t.text.trim(), author: a.text.trim().isEmpty ? 'Unknown' : a.text.trim(),
        coverImage: c.text.trim(), description: d.text.trim(),
        genres: g.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
        chapterCount: 0, rating: 0.0, status: 'Đang ra', lastUpdated: DateTime.now(), chapters: [],
        freeChapters: int.tryParse(fc.text) ?? 3, coinPerChapter: int.tryParse(cc.text) ?? 5, createdAt: DateTime.now());
      Navigator.pop(context);
      await _fs.addStory(story);
      if (mounted) _snack('✅ Đã thêm truyện mới!', AppColors.success);
    });
  }

  // === DIALOG: SỬA TRUYỆN ===
  void _showEditStoryDialog(Story s, bool isDark) {
    final t = TextEditingController(text: s.title), a = TextEditingController(text: s.author);
    final d = TextEditingController(text: s.description), c = TextEditingController(text: s.coverImage);
    final g = TextEditingController(text: s.genres.join(', '));
    final fc = TextEditingController(text: '${s.freeChapters}'), cc = TextEditingController(text: '${s.coinPerChapter}');
    _showStoryForm(isDark, 'Sửa Truyện', t, a, d, c, g, fc, cc, 'Lưu', () async {
      if (t.text.trim().isEmpty) return;
      final updated = Story(id: s.id, title: t.text.trim(), author: a.text.trim().isEmpty ? 'Unknown' : a.text.trim(),
        coverImage: c.text.trim(), description: d.text.trim(),
        genres: g.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
        chapterCount: s.chapterCount, rating: s.rating, status: s.status, lastUpdated: DateTime.now(), chapters: s.chapters,
        freeChapters: int.tryParse(fc.text) ?? 3, coinPerChapter: int.tryParse(cc.text) ?? 5,
        createdAt: s.createdAt, views: s.views, isHot: s.isHot);
      Navigator.pop(context);
      await _fs.updateStoryFull(updated);
      if (mounted) _snack('✅ Đã cập nhật truyện!', AppColors.success);
    });
  }

  void _showStoryForm(bool isDark, String title, TextEditingController t, TextEditingController a,
      TextEditingController d, TextEditingController c, TextEditingController g,
      TextEditingController fc, TextEditingController cc, String action, VoidCallback onSubmit) {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      backgroundColor: isDark ? AppColors.cardDark : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
      title: Text(title, style: TextStyle(color: isDark ? Colors.white : AppColors.primaryDark, fontWeight: FontWeight.w700)),
      content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        _field(t, 'Tên truyện', isDark), _field(a, 'Tác giả', isDark),
        _field(d, 'Mô tả', isDark, maxLines: 3), _field(c, 'URL ảnh bìa', isDark),
        _field(g, 'Thể loại (cách nhau bởi dấu ,)', isDark),
        _field(fc, 'Số chương miễn phí', isDark), _field(cc, 'Giá xu / chương', isDark),
      ])),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
        ElevatedButton(onPressed: onSubmit, style: ElevatedButton.styleFrom(backgroundColor: AppColors.gradientStart, foregroundColor: Colors.white), child: Text(action)),
      ],
    ));
  }

  // === DIALOG: THÊM CHƯƠNG ===
  void _showAddChapterDialog(Story story, bool isDark) {
    final t = TextEditingController(), n = TextEditingController(text: '${story.chapterCount + 1}'), p = TextEditingController();
    showDialog(context: context, builder: (ctx) => AlertDialog(
      backgroundColor: isDark ? AppColors.cardDark : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
      title: Text('Thêm Chương - ${story.title}', style: TextStyle(color: isDark ? Colors.white : AppColors.primaryDark, fontWeight: FontWeight.w700, fontSize: AppFontSizes.medium)),
      content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        _field(n, 'Số chương', isDark), _field(t, 'Tiêu đề chương', isDark),
        _field(p, 'URLs ảnh trang (mỗi dòng 1 URL)', isDark, maxLines: 5),
      ])),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
        ElevatedButton(
          onPressed: () async {
            if (t.text.trim().isEmpty) return;
            final pages = p.text.split('\n').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
            final ch = Chapter(chapterNumber: int.tryParse(n.text) ?? story.chapterCount + 1, title: t.text.trim(), pages: pages, publishDate: DateTime.now());
            Navigator.pop(ctx);
            await _fs.addChapter(story.id, ch);
            if (mounted) _snack('✅ Đã thêm chương mới!', AppColors.success);
          },
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.gradientStart, foregroundColor: Colors.white),
          child: const Text('Thêm'),
        ),
      ],
    ));
  }

  void _confirmDeleteStory(Story story, bool isDark) {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      backgroundColor: isDark ? AppColors.cardDark : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
      title: Text('Xóa "${story.title}"?', style: TextStyle(color: isDark ? Colors.white : AppColors.primaryDark, fontWeight: FontWeight.w700)),
      content: Text('Hành động này không thể hoàn tác!', style: TextStyle(color: isDark ? Colors.grey.shade300 : Colors.grey.shade700)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
        ElevatedButton(
          onPressed: () async {
            Navigator.pop(ctx);
            await FirebaseFirestore.instance.collection('stories').doc(story.id).delete();
            if (mounted) _snack('🗑️ Đã xóa truyện', AppColors.accent);
          },
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent, foregroundColor: Colors.white),
          child: const Text('Xóa'),
        ),
      ],
    ));
  }

  // === DIALOGS: THỂ LOẠI ===
  void _showAddCategoryDialog(bool isDark) {
    final ctrl = TextEditingController();
    showDialog(context: context, builder: (ctx) => AlertDialog(
      backgroundColor: isDark ? AppColors.cardDark : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
      title: Text('Thêm Thể Loại', style: TextStyle(color: isDark ? Colors.white : AppColors.primaryDark, fontWeight: FontWeight.w700)),
      content: _field(ctrl, 'Tên thể loại', isDark),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
        ElevatedButton(
          onPressed: () async {
            if (ctrl.text.trim().isEmpty) return;
            Navigator.pop(ctx);
            await _fs.addCategory(ctrl.text.trim());
            if (mounted) _snack('✅ Đã thêm thể loại!', AppColors.success);
          },
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.gradientEnd, foregroundColor: Colors.white),
          child: const Text('Thêm'),
        ),
      ],
    ));
  }

  void _showEditCategoryDialog(StoryCategory cat, bool isDark) {
    final ctrl = TextEditingController(text: cat.name);
    showDialog(context: context, builder: (ctx) => AlertDialog(
      backgroundColor: isDark ? AppColors.cardDark : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
      title: Text('Sửa Thể Loại', style: TextStyle(color: isDark ? Colors.white : AppColors.primaryDark, fontWeight: FontWeight.w700)),
      content: _field(ctrl, 'Tên thể loại', isDark),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
        ElevatedButton(
          onPressed: () async {
            if (ctrl.text.trim().isEmpty) return;
            Navigator.pop(ctx);
            await _fs.updateCategory(cat.id, ctrl.text.trim());
            if (mounted) _snack('✅ Đã cập nhật!', AppColors.success);
          },
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.gradientEnd, foregroundColor: Colors.white),
          child: const Text('Lưu'),
        ),
      ],
    ));
  }

  void _confirmDeleteCategory(StoryCategory cat, bool isDark) {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      backgroundColor: isDark ? AppColors.cardDark : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
      title: Text('Xóa "${cat.name}"?', style: TextStyle(color: isDark ? Colors.white : AppColors.primaryDark, fontWeight: FontWeight.w700)),
      content: Text('Thể loại sẽ bị xóa vĩnh viễn.', style: TextStyle(color: isDark ? Colors.grey.shade300 : Colors.grey.shade700)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
        ElevatedButton(
          onPressed: () async {
            Navigator.pop(ctx);
            await _fs.deleteCategory(cat.id);
            if (mounted) _snack('🗑️ Đã xóa thể loại', AppColors.accent);
          },
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent, foregroundColor: Colors.white),
          child: const Text('Xóa'),
        ),
      ],
    ));
  }

  // === HELPERS ===
  void _snack(String msg, Color c) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: c, behavior: SnackBarBehavior.floating));

  Widget _field(TextEditingController ctrl, String label, bool isDark, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: TextField(
        controller: ctrl, maxLines: maxLines,
        style: TextStyle(color: isDark ? Colors.white : AppColors.primaryDark),
        decoration: InputDecoration(
          labelText: label, labelStyle: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600, fontSize: AppFontSizes.body),
          filled: true, fillColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade50,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.sm), borderSide: BorderSide(color: isDark ? Colors.white12 : Colors.grey.shade300)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.sm), borderSide: BorderSide(color: isDark ? Colors.white12 : Colors.grey.shade300)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.sm), borderSide: const BorderSide(color: AppColors.gradientStart, width: 2)),
          isDense: true,
        ),
      ),
    );
  }
}
