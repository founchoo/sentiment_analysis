# Sentiment Analysis

## Introduction

This is a final project for Data Mining course.

### Project Goal
- Detect aggressive comments in public communities, like YouTube, Twitter, etc.
- Detect fake news in public media platform.

### Language
- Dart for both ML(Machine Learning) algorithm and UI(User Interface).

### Dataset
- [Hate speech and offensive language dataset](https://www.kaggle.com/datasets/mrmorj/hate-speech-and-offensive-language-dataset) from [Kaggle](https://www.kaggle.com/)

## Why we choose Dart

At the very beginning, we planned to use Python because it was supported by extensive documentation and libraries. There were lots of good demo of achieving our goal.
But later we were told that doing Python is a little bit less challenging for us and we'd better use another tool or language to finish our project.
And also we took UI into consideration that time, so Dart was our final choice.

## How we make it

### Try sentiment_dart
Dart was very new for us and there was not enough reference we can take a look. However, we found a library called [sentiment_dart](https://pub.dev/packages/sentiment_dart) on [pub.dev](https://pub.dev/packages). It did solve our project but not in a way that ML involved and again it was easy for us so we continued to find something else that could help building our project.

### Try override Python code
Later, we found these packages: [ml_dataframe](https://pub.dev/packages/ml_dataframe), it provided a way to store and manipulate data; [ml_algo](https://pub.dev/packages/ml_algo), it provided lots of algorithms for ML; [stopwordies](https://pub.dev/packages/stopwordies), it provided English stop words, which could be used to identify relatively meaningless words in a sentence; [document_analysis](https://pub.dev/packages/document_analysis), it provided text vectorization method, which was very important when pre-processing text in data.

We were luck because we also found a [tutorial](https://www.kaggle.com/code/ashokkumarpalivela/sentiment-analysis-with-machine-learning/notebook) that provided guideline on how to apply ML in Sentiment Analysis, but in Python.
Then we started to follow it and write our own Dart code.

Every thing was fine but only the prediction was bad. When we load a large amount of data to train with TFIDF martix function(a method to vectorize text), it took a large amount of time and ROM and we fail to build model because of the lack of memory. We also found a solution which is to vectorize text by using our own method, but the result was even worser.

In the case above, we feed the machine dataset like this:

```
flutter: DataFrame (159571 x 2)
comment_text   insult
explanation why the edits ...       0.0
...                                 ...
d aww  he matches this ba ...       0.0
```

`comment_text` was the comment that user posted and `insult` indicated whether this content was insultable or not.

And after pre-processing, the dataset was changed to:

```
flutter: DataFrame (159571 x 10001)
insult   vec_0   vec_1   vec_2   vec_3   vec_4   ...   vec_9999
   0.0     0.0     1.0     0.0     1.0     1.0   ...        0.0
   0.0     0.0     0.0     0.0     0.0     1.0   ...        0.0
   0.0     0.0     1.0     0.0     2.0     2.0   ...        0.0
   0.0     2.0     0.0     1.0     0.0     0.0   ...        0.0
   0.0     0.0     1.0     0.0     0.0     0.0   ...        0.0
   ...     ...     ...     ...     ...     ...   ...        ...
   0.0     0.0     0.0     0.0     0.0     0.0   ...        0.0
   0.0     0.0     1.0     0.0     0.0     1.0   ...        0.0
   0.0     1.0     0.0     0.0     0.0     0.0   ...        0.0
   0.0     0.0     0.0     0.0     0.0     0.0   ...        0.0
   0.0     0.0     0.0     0.0     0.0     0.0   ...        0.0
```

Our key function was to make text to vector so that the machine can calculate and build the modle. And this was also the most difficult problem we encounted in our project.

### Try TensorFlow Lite
We found there was a built model in [huggingface](https://huggingface.co/bert-base-uncased), but it was built for TenserFlow, not TenserFlow Lite. However, the official document provided a guide on how to convert it, here is the [doc](https://huggingface.co/docs/optimum/exporters/tflite/usage_guides/export_a_model).
