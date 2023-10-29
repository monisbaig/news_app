import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app/common/global_variables.dart';
import 'package:news_app/models/top_stories_model.dart';
import 'package:news_app/services/repository/stories_repository.dart';

class MockHTTPClient extends Mock implements Client {}

void main() {
  late StoriesRepository storiesRepository;
  late MockHTTPClient mockHTTPClient;

  setUp(() {
    mockHTTPClient = MockHTTPClient();
    storiesRepository = StoriesRepository(client: mockHTTPClient);
  });

  group('StoriesRepository - ', () {
    test(
        'Check if the status code is 200, and send the response to Top Stories Model',
        () async {
      when(
        () => mockHTTPClient.get(
          Uri.parse(
            'https://api.nytimes.com/svc/topstories/v2/$section.json?api-key=$apiKey',
          ),
        ),
      ).thenAnswer((invocation) async {
        return Response(
          """
            {
              "status": "OK",
              "copyright": "Copyright (c) 2023 The New York Times Company. All Rights Reserved.",
              "section": "home",
              "last_updated": "2023-10-29T04:29:03-04:00",
              "num_results": 24
            }
          """,
          200,
        );
      });

      final storyData =
          await storiesRepository.getStoriesData(section: section);
      expect(storyData, isA<TopStoriesModel>());
    });

    test(
        'Check if the status code is 429, and it should throw the quota limit error',
        () async {
      when(
        () => mockHTTPClient.get(
          Uri.parse(
            'https://api.nytimes.com/svc/topstories/v2/$section.json?api-key=$apiKey',
          ),
        ),
      ).thenAnswer((invocation) async {
        return Response(
          """
            {
              "fault": {
                "faultstring": "Rate limit quota violation. Quota limit  exceeded. Identifier : 7db253ea-6dd2-4ad2-886a-010b207e0eda",
                "detail": {
                  "errorcode": "policies.ratelimit.QuotaViolation"
                }
              }
            }
          """,
          429,
        );
      });

      final storyData = storiesRepository.getStoriesData(section: section);
      expect(storyData, throwsException);
    });
  });
}
