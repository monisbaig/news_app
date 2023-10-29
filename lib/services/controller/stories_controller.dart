import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/global_variables.dart';
import '../../models/top_stories_model.dart';
import '../repository/stories_repository.dart';

final storiesController = Provider((ref) {
  return StoriesController(
    storiesRepository: ref.watch(storiesRepository),
    ref: ref,
  );
});

final storiesProvider = FutureProvider((ref) {
  return ref.watch(storiesController).getStoriesData(section: section);
});

class StoriesController {
  final StoriesRepository storiesRepository;
  final ProviderRef ref;

  StoriesController({
    required this.storiesRepository,
    required this.ref,
  });

  Future<TopStoriesModel> getStoriesData({required String section}) {
    return storiesRepository.getStoriesData(section: section);
  }
}
