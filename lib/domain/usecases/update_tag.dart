import '../entities/tag.dart';
import '../repositories/tag_repository.dart';

class UpdateTag {
  final TagRepository repository;
  UpdateTag(this.repository);

  Future<void> call(Tag tag) => repository.updateTag(tag);
}
