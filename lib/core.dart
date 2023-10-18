import 'package:ml_preprocessing/ml_preprocessing.dart';
import 'package:ml_algo/ml_algo.dart';
import 'package:ml_dataframe/ml_dataframe.dart';
import 'package:stopwordies/stopwordies.dart';
import 'package:document_analysis/document_analysis.dart';

class Core {
  DecisionTreeClassifier? classifier;
  List<String>? stopWords;
  DataFrame? originalDataFrame;

  Future<DataFrame> loadData(String path) async {
    DataFrame dataFrame = await fromCsv(path, headerExists: true);
    originalDataFrame = dataFrame;
    return dataFrame;
  }

  Future<List<String>> getStopWords() async {
    final stopWords = await StopWordies.getFor(locale: SWLocale.en);
    stopWords
        .removeWhere((word) => word.contains('n\'t') || word.contains('no'));
    return stopWords;
  }

  Future<DataFrame> commentVectorization(DataFrame dataFrame) async {
    stopWords ??= await getStopWords();

    // Remove stop words
    dataFrame = dataFrame.mapSeries(
        (comment) => (comment as String)
            .split(' ')
            .where((element) => stopWords!.contains(element))
            .join(' '),
        name: 'Comment');

    // Text vectorization
    final wordFrequencyMap = wordFrequencyMatrix(
        dataFrame['Comment'].data.map((e) => e.toString()).toList());
    for (var i = 0; i < wordFrequencyMap[0].length && i < 1000; i++) {
      List<double> column = [];
      for (var j = 0; j < wordFrequencyMap.length; j++) {
        column.add(wordFrequencyMap[j][i]);
      }
      dataFrame = dataFrame.addSeries(Series('Vector$i', column));
    }
    dataFrame = dataFrame.dropSeries(names: ['Comment']);
    return dataFrame;
  }

  DataFrame emotionNumeralization(DataFrame dataFrame) {
    dataFrame = dataFrame.mapSeries((emotion) {
      switch (emotion) {
        case 'joy':
          return 0;
        case 'anger':
          return 1;
        case 'fear':
          return 2;
        default:
          return 3;
      }
    }, name: 'Emotion');
    return dataFrame;
  }

  String getEmotion(num value) {
    switch (value) {
      case 0:
        return 'joy';
      case 1:
        return 'anger';
      case 2:
        return 'fear';
      default:
        return '';
    }
  }

  Future<DataFrame> preProcessData(DataFrame dataFrame) async {
    dataFrame = await commentVectorization(dataFrame);
    dataFrame = emotionNumeralization(dataFrame);
    return dataFrame;
  }

  Future buildModel(DataFrame dataFrame) async {
    print(dataFrame);
    classifier = DecisionTreeClassifier(dataFrame, 'Emotion');
    await classifier!.saveAsJson('data/model.json');
  }

  void loadModel() {
    classifier = DecisionTreeClassifier.fromJson('data/model.json');
  }

  Future<String> predict(String text) async {
    DataFrame predictDataFrame;
    if (originalDataFrame == null) {
      throw Exception('Original data frame is null');
    } else {
      predictDataFrame = DataFrame.fromSeries([
        Series('Comment', originalDataFrame!['Comment'].data.toList() + [text]),
        Series('Emotion', originalDataFrame!['Emotion'].data.toList() + ['']),
      ]);
    }
    if (classifier != null) {
      predictDataFrame = await preProcessData(predictDataFrame);
      print(predictDataFrame);
      final prediction = classifier!.predict(predictDataFrame);
      final value = prediction['Emotion'].data.first;
      print('Emotion for \'$text\' is \'${getEmotion(value)}\'');
      return getEmotion(value);
    } else {
      throw Exception('Classifier is null');
    }
  }
}
