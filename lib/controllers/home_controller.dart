import '../models/truyen.dart';
import '../processors/story_processor.dart';
import '../services/firestore_service.dart';

class HomeController {
  HomeController({FirestoreService? firestoreService})
    : _firestoreService = firestoreService ?? FirestoreService();

  final FirestoreService _firestoreService;

  Stream<List<Story>> watchStories() => _firestoreService.getStories();

  String formatTimeAgo(DateTime date) => StoryProcessor.formatTimeAgo(date);
}
