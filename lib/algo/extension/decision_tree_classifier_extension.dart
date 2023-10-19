import 'package:flutter/foundation.dart';
import 'package:ml_algo/ml_algo.dart';
import 'package:ml_dataframe/ml_dataframe.dart';
import 'package:sentiment_analysis/algo/extension/data_frame_extension.dart';

import '../../constant/name.dart';
import '../../constant/sentiment.dart';

extension DecisionTreeClassifierExtension on DecisionTreeClassifier {
  Future<String> predictOne(String text) async {
    if (kDebugMode) {
      print('Predicting sentiment for \'$text\'...');
    }
    DataFrame testDataFrame = await DataFrame.fromSeries([
      Series(textColumnName, [text]),
      Series(targetColumnName, [999]),
    ]).preProcessData();
    final prediction = predict(testDataFrame);
    if (kDebugMode) {
      print('Predict result:');
      print(prediction);
    }
    final value = prediction[targetColumnName].data.last as num;
    return sentiment[value] ?? unknownSentiment;
  }

  Future<List<String>> predictBatch(List<String> texts) async {
    if (kDebugMode) {
      print('Predicting sentiment for:');
      print(texts);
    }
    DataFrame testDataFrame = await DataFrame.fromSeries([
      Series(textColumnName, texts),
      Series(targetColumnName, List<num>.filled(texts.length, 999)),
    ]).preProcessData();
    final prediction = predict(testDataFrame);
    if (kDebugMode) {
      print('Predict result:');
      print(prediction);
    }
    return prediction[targetColumnName]
        .data
        .map((value) => sentiment[value as num] ?? unknownSentiment)
        .toList();
  }
}
