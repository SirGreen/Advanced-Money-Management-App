import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'data/data_sources/tag_local_data_source.dart';
import 'data/repositories/tag_repository_impl.dart';
import 'domain/usecases/add_tag.dart';
import 'domain/usecases/get_all_tags.dart';
import 'domain/usecases/update_tag.dart';
import 'ui/tags/manage_tags_page.dart';
import 'ui/tags/tag_view_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ===== TAG DEPENDENCIES =====
    final tagLocalDataSource = TagLocalDataSource();
    final tagRepository = TagRepositoryImpl(tagLocalDataSource);

    final getAllTags = GetAllTags(tagRepository);
    final addTag = AddTag(tagRepository);
    final updateTag = UpdateTag(tagRepository);
    // ===========================

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => TagViewModel(
            getAllTags: getAllTags,
            addTag: addTag,
            updateTag: updateTag,
          ),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Tag Management',
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: Colors.blue,
        ),
        home: ManageTagsPage(),
      ),
    );
  }
}