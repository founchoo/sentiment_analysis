import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:ml_algo/ml_algo.dart';
import 'package:ml_dataframe/ml_dataframe.dart';
import 'package:sentiment_analysis/constant/solution.dart';
import 'package:http/http.dart' as http;

class Core {
  late Solution solution;

  Core(Solution s) {
    solution = s;
  }

  String shortenText(String value, {int maxLength = 1000}) {
    if (value.length <= maxLength) {
      return value;
    } else {
      return value.toString().substring(0, maxLength);
    }
  }

  DataFrame sample(DataFrame dataFrame, {int sampleStep = 10}) {
    if (kDebugMode) {
      print('Dataframe size: ${dataFrame.rows.length}');
    }

    List<int> sampleCommentIndexes = [];
    for (var i = 0; i < dataFrame.rows.length; i++) {
      if (i % sampleStep == 0) {
        sampleCommentIndexes.add(i);
      }
    }
    dataFrame = dataFrame.sampleFromRows(sampleCommentIndexes);

    if (kDebugMode) {
      print('Dataframe size after sampling: ${dataFrame.rows.length}');
    }

    return dataFrame;
  }

  /// Load model from local file, return null if file is empty.
  Future<KnnClassifier?> loadModel() async {
    if (kDebugMode) {
      print('Loading model from ${solution.pathToJsonModel}...');
    }
    final context = await File(solution.pathToJsonModel).readAsString();
    if (context == '') {
      return null;
    } else {
      return KnnClassifier.fromJson(context);
    }
  }

  Future<DataFrame> loadData() async {
    DataFrame dataFrame = await fromCsv(solution.pathToData,
        columns: solution.selectedColumnIndexes);
    if (kDebugMode) {
      print('Load data from ${solution.pathToData}:');
      print(dataFrame);
    }
    return dataFrame;
  }

  Future<void> saveModel(KnnClassifier classifier) async {
    await classifier.saveAsJson(solution.pathToJsonModel);
  }

  Future<DataFrame> commentVectorization(DataFrame dataFrame,
      {isTrain = true}) async {
    List<List<double>> matrix = [];

    if (isTrain) {
      dataFrame = sample(dataFrame);
    }

    var comments = dataFrame[solution.textColumnName]
        .data
        .map((value) => shortenText(value.toString(), maxLength: 600))
        .toList();

    final docSize = comments.length;

    for (var i = 0; i < docSize; i++) {
      if (kDebugMode) {
        if (i % 1000 == 0) {
          print('Vectorizing comment at index $i of $docSize...');
        }
      }
      final comment = comments[i];
      await http
          .get(Uri.parse('http://localhost:8080/text=$comment'))
          .then((response) {
        final vector = response.body
            .substring(1, response.body.length - 1)
            .split(',')
            .map((e) => double.parse(e))
            .toList();
        matrix.add(vector);
      });
    }

    final featureSize = matrix[0].length;

    if (kDebugMode) {
      print('Feature size: $featureSize');
      print('Document size: $docSize');
    }

    for (var i = 0; i < featureSize; i++) {
      List<double> column = [];
      for (var j = 0; j < docSize; j++) {
        column.add(matrix[j][i]);
      }
      dataFrame = dataFrame.addSeries(Series('fea_$i', column));
    }
    dataFrame = dataFrame.dropSeries(names: [solution.textColumnName]);

    return dataFrame;
  }

  Future<DataFrame> preProcessData(DataFrame dataFrame,
      {isTrain = true}) async {
    final stopwatch = Stopwatch()..start();
    if (kDebugMode) {
      print('Pre-processing data...');
    }

    dataFrame = await commentVectorization(dataFrame, isTrain: isTrain);

    stopwatch.stop();

    if (kDebugMode) {
      print('Pre-processing result:');
      print(dataFrame);
      print('Pre-processing done in ${stopwatch.elapsed}');
    }

    return dataFrame;
  }

  Future<KnnClassifier> buildModel(DataFrame dataFrame) async {
    final stopwatch = Stopwatch()..start();
    if (kDebugMode) {
      print('Building model...');
    }
    final classifier = KnnClassifier(dataFrame, solution.targetColumnName, 5);
    stopwatch.stop();
    if (kDebugMode) {
      print('Model built in ${stopwatch.elapsed}');
    }
    return classifier;
  }

  Future<String> predictOne(KnnClassifier classifier, String text) async {
    if (kDebugMode) {
      print('Predicting sentiment for \'$text\'...');
    }
    DataFrame testDataFrame = DataFrame.fromSeries([
      Series(solution.textColumnName, [text]),
      // Series(solution.targetColumnName, [999]),
    ]);
    testDataFrame = await preProcessData(testDataFrame, isTrain: false);
    final prediction = classifier.predict(testDataFrame);
    if (kDebugMode) {
      print('Predict result:');
      print(prediction);
    }
    final value = prediction[solution.targetColumnName].data.last as num;
    return solution.target[value] ?? unknownTarget;
  }

  Future<List<String>> predictBatch(
      KnnClassifier classifier, List<String> texts) async {
    if (kDebugMode) {
      print('Predicting sentiment for:');
      print(texts);
    }
    DataFrame testDataFrame = DataFrame.fromSeries([
      Series(solution.textColumnName, texts),
      // Series(solution.targetColumnName, List<num>.filled(texts.length, 999)),
    ]);
    testDataFrame = await preProcessData(testDataFrame, isTrain: false);
    final prediction = classifier.predict(testDataFrame);
    if (kDebugMode) {
      print('Predict result:');
      print(prediction);
    }
    return prediction[solution.targetColumnName]
        .data
        .map((value) => solution.target[value as num] ?? unknownTarget)
        .toList();
  }
}
