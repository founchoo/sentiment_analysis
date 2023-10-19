import 'package:flutter/foundation.dart';
import 'package:ml_algo/ml_algo.dart';
import 'package:ml_dataframe/ml_dataframe.dart';

import '../../constant/english.dart';
import '../../constant/name.dart';
import '../../constant/path.dart';
import '../core.dart';

extension DataFrameExtension on DataFrame {
  Future<DataFrame> commentVectorization(DataFrame dataFrame) async {
    final stopWords = await Core.getStopWords();

    List<List<num>> matrix = [];
    final comments = dataFrame[textColumnName].data.toList();
    for (var i = 0; i < comments.length; i++) {
      final words = comments[i]
          .toString()
          .split(' ')
          .where((element) => !stopWords!.contains(element))
          .toList();
      List<num> list = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
      for (var j = 0; j < words.length; j++) {
        final word = words[j];
        if (english.containsKey(word)) {
          final score = english[word];
          list[score! + 6]++;
        }
      }
      matrix.add(list);
    }

    for (var i = 0; i < matrix[0].length; i++) {
      List<num> column = [];
      for (var j = 0; j < matrix.length; j++) {
        column.add(matrix[j][i]);
      }
      dataFrame = dataFrame.addSeries(Series('vec_$i', column));
    }
    dataFrame = dataFrame.dropSeries(names: [textColumnName]);

    return dataFrame;
  }

  Future<DataFrame> preProcessData() async {
    if (kDebugMode) {
      print('Pre-processing data...');
    }
    final dataFrame = await commentVectorization(this);
    if (kDebugMode) {
      print('Pre-processing result:');
      print(dataFrame);
    }
    return dataFrame;
  }

  Future<DecisionTreeClassifier> buildModel() async {
    final stopwatch = Stopwatch()..start();
    if (kDebugMode) {
      print('Building model...');
    }
    final classifier = DecisionTreeClassifier(this, targetColumnName);
    await classifier.saveAsJson(pathToJsonModel);
    await classifier.saveAsSvg(pathToSvgModel);
    stopwatch.stop();
    if (kDebugMode) {
      print('Model built in ${stopwatch.elapsed}');
    }
    return classifier;
  }
}
