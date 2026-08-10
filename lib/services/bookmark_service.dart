import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import '../models/bookmark_model.dart';

class BookmarkService {
  static const String _bookmarkKey = 'bookmarks';

  Future<List<BookmarkModel>> getBookmarks() async {
    final prefs = await SharedPreferences.getInstance();

    final String? data = prefs.getString(_bookmarkKey);

    if (data == null) {
      return [];
    }

    final List<dynamic> decoded = jsonDecode(data);

    return decoded
        .map((item) => BookmarkModel.fromJson(item))
        .toList();
  }


  Future<void> addBookmark(BookmarkModel bookmark) async {
    final prefs = await SharedPreferences.getInstance();

    final bookmarks = await getBookmarks();

    bookmarks.add(bookmark);

    final String encoded = jsonEncode(
      bookmarks.map((e) => e.toJson()).toList(),
    );

    await prefs.setString(
      _bookmarkKey,
      encoded,
    );
  }


  Future<void> removeBookmark(
      int surahNumber,
      int ayahNumber,
      ) async {

    final prefs = await SharedPreferences.getInstance();

    final bookmarks = await getBookmarks();

    bookmarks.removeWhere(
      (item) =>
          item.surahNumber == surahNumber &&
          item.ayahNumber == ayahNumber,
    );


    final String encoded = jsonEncode(
      bookmarks.map((e) => e.toJson()).toList(),
    );


    await prefs.setString(
      _bookmarkKey,
      encoded,
    );
  }


  Future<bool> isBookmarked(
      int surahNumber,
      int ayahNumber,
      ) async {

    final bookmarks = await getBookmarks();

    return bookmarks.any(
      (item) =>
          item.surahNumber == surahNumber &&
          item.ayahNumber == ayahNumber,
    );
  }
}