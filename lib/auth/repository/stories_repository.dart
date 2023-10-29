import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart';

import '../../common/global_variables.dart';
import '../../models/top_stories_model.dart';

final storiesRepository = Provider((ref) {
  return StoriesRepository(
    client: Client(),
  );
});

class StoriesRepository {
  final Client client;

  StoriesRepository({
    required this.client,
  });

  Future<TopStoriesModel> getStoriesData({required String section}) async {
    final response = await client.get(
      Uri.parse(
        'https://api.nytimes.com/svc/topstories/v2/$section.json?api-key=$apiKey',
      ),
    );

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);

      return TopStoriesModel.fromJson(result);
    } else {
      throw Exception('Something went wrong!!!');
    }
  }
}
