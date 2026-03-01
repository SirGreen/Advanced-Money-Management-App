import '../entities/tag.dart';
import '../repositories/tag_repository.dart';

class AddTag {
  final TagRepository repository;
  AddTag(this.repository);

  Future<void> call(Tag tag) => repository.addTag(tag);
}
