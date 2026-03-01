import '../entities/tag.dart';
import '../repositories/tag_repository.dart';

class GetAllTags {
  final TagRepository repository;
  GetAllTags(this.repository);

  Future<List<Tag>> call() => repository.getAllTags();
}
