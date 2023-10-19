import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:ml_algo/ml_algo.dart';
import 'package:ml_dataframe/ml_dataframe.dart';
import 'package:stopwordies/stopwordies.dart';

import '../constant/path.dart';

class Core {
  Future<DataFrame> loadData() async {
    DataFrame dataFrame = await fromCsv(pathToData);
    if (kDebugMode) {
      print('Load data from $pathToData:');
      print(dataFrame);
    }
    return dataFrame;
  }

  static Future<List<String>> getStopWords() async {
    final stopWords = await StopWordies.getFor(locale: SWLocale.en);
    stopWords
        .removeWhere((word) => word.contains('n\'t') || word.contains('no'));
    return stopWords;
  }

  Future<DecisionTreeClassifier> loadModel() async {
    if (kDebugMode) {
      print('Loading model from $pathToJsonModel...');
    }
    return DecisionTreeClassifier.fromJson(
        await File(pathToJsonModel).readAsString());
  }
}
