const unknownTarget = 'unknown';

abstract class Solution {
  late String targetColumnName;
  late String textColumnName;

  late List<int> selectedColumnIndexes;

  late String pathToJsonModel;
  late String pathToData;

  late Map<num, String> target;
}

class NormalOffensiveSolution implements Solution {
  @override
  String targetColumnName = 'insult';

  @override
  String textColumnName = 'comment_text';

  @override
  List<int> selectedColumnIndexes = [0, 3];

  @override
  String pathToJsonModel = 'data/normal_offensive_model.json';

  @override
  String pathToData = 'data/normal_offensive_data.csv';

  @override
  Map<num, String> target = {
    0.0: 'normal',
    1.0: 'offensive',
  };
}

class RealFakeSolution implements Solution {
  @override
  String targetColumnName = 'label';

  @override
  String textColumnName = 'title_txt';

  @override
  List<int> selectedColumnIndexes = [1, 2];

  @override
  String pathToJsonModel = 'data/real_fake_model.json';

  @override
  String pathToData = 'data/real_fake_data.csv';

  @override
  Map<num, String> target = {
    0: 'real',
    1: 'fake',
  };
}
