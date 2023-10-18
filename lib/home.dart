import 'package:flutter/material.dart';
import 'package:ml_dataframe/ml_dataframe.dart';
import 'package:sentiment_analysis/core.dart';
import 'package:sentiment_analysis/utils.dart';
import 'package:sentiment_dart/sentiment_dart.dart';

class Word {
  final String word;
  final num score;

  const Word(this.word, this.score);
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final myController = TextEditingController();
  dynamic _result;
  List<Word> goodWords = [];
  List<Word> badWords = [];

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    myController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        TextField(
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Enter something to analyze',
          ),
          controller: myController,
        ),
        FilledButton(
            onPressed: () async {
              setState(() async {
                Core core = Core();
                DataFrame dataFrame = await core.loadData('data/Emotion_classify_Data.csv');
                dataFrame = await core.preProcessData(dataFrame);
                await core.buildModel(dataFrame);
                await core.predict('I love you');
                _result = Sentiment.analysis(myController.text);
                goodWords = [];
                for (var element
                    in (_result.words.good as Map<String, num>).entries) {
                  goodWords.add(Word(element.key, element.value));
                }
                badWords = [];
                for (var element
                    in (_result.words.bad as Map<String, num>).entries) {
                  badWords.add(Word(element.key, element.value));
                }
              });
            },
            child: const Text("Analyze")),
        _result == null
            ? const Card(
                child: ListTile(
                  leading: Icon(Icons.info_outline),
                  title: Text("Result will be displayed here"),
                ),
              )
            : Column(
                children: [
                  Card(
                    child: ListTile(
                        leading: const Icon(Icons.numbers_outlined),
                        title: Text("Score: ${_result.score}"),
                        subtitle: Text("Comparative: ${_result.comparative}")),
                  ),
                  Card(
                    child: ListTile(
                        leading: const Icon(Icons.gpp_good_outlined),
                        title: const Text("Good Words"),
                        subtitle: goodWords.isEmpty
                            ? const Text("No good words found")
                            : Row(
                                children: [
                                  for (var word in goodWords)
                                    Chip(
                                        label: Text(
                                            "${word.word} (${word.score})"))
                                ],
                              )),
                  ),
                  Card(
                    child: ListTile(
                        leading: const Icon(Icons.gpp_bad_outlined),
                        title: const Text("Bad Words"),
                        subtitle: badWords.isEmpty
                            ? const Text("No bad words found")
                            : Row(
                                children: [
                                  for (var word in badWords)
                                    Text("${word.word} (${word.score})")
                                ],
                              )),
                  ),
                ],
              ),
      ].withSpaceBetween(height: 16),
    );
  }
}
