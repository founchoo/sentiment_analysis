# Sentiment Analysis

## Introduction

This is a final project for Data Mining course.

### Project Goal
- Detect aggressive comments in public communities, like YouTube, Twitter, etc.
- Detect fake news in public media platform.

### Language
- Dart for both ML(machine learning) algorithm and UI(User Interface).

## Why we choose Dart

At the very beginning, we planned to use Python because it was supported by extensive documentation and libraries. There were lots of good demo of achieving our goal.
But later we were told that doing Python is a little bit less challenging for us and we'd better use another tool or language to finish our project.
And also we took UI into consideration that time, so Dart was our final choice.

## How we make it

### Stage 1
Dart was very new for us and there was not enough reference we can take a look. However, we found a library called [sentiment_dart](https://pub.dev/packages/sentiment_dart) on [pub.dev](https://pub.dev/packages). It did solve our project but not in a way that ML involved and again it was easy for us so we continued to find something else that could help building our project.

### Stage 2
Later, we found these packages: [ml_dataframe](https://pub.dev/packages/ml_dataframe), it provided a way to store and manipulate data; [ml_algo](https://pub.dev/packages/ml_algo), it provided lots of algorithms for ML; [stopwordies](https://pub.dev/packages/stopwordies), it provided English stop words, which could be used to identify relatively meaningless words in a sentence; [document_analysis](https://pub.dev/packages/document_analysis), it provided text vectorization method, which was very important when pre-processing text in data.
