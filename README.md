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

## Why I choose Dart

At the very beginning, I planned to use Python because it was supported by extensive documentation and libraries. There were lots of good demo of achieving my goal.
But later I was told that doing Python was a little bit less challenging for me and I'd better use another tool or language to finish my project.
And also I took UI into consideration that time, so Dart was my final choice.

## How I make it

### Try sentiment_dart
Dart was very new for me and there was not enough reference I can take a look. However, I found a library called [sentiment_dart](https://pub.dev/packages/sentiment_dart) on [pub.dev](https://pub.dev/packages). It did led my project to success but not in a way that ML involved and again it was easy for me so I continued to find something else that could help building my project.

### Try follow a Python guide
Later, I found these packages: [ml_dataframe](https://pub.dev/packages/ml_dataframe), it provided a way to store and manipulate data; [ml_algo](https://pub.dev/packages/ml_algo), it provided lots of algorithms for ML; [stopwordies](https://pub.dev/packages/stopwordies), it provided English stop words, which could be used to identify relatively meaningless words in a sentence; [document_analysis](https://pub.dev/packages/document_analysis), it provided text vectorization method, which was very important when pre-processing text in data.

I was luck because I also found a [tutorial](https://www.kaggle.com/code/ashokkumarpalivela/sentiment-analysis-with-machine-learning/notebook) that provided guideline on how to apply ML in Sentiment Analysis, but in Python.
Then I started to follow it and write my own Dart code.

Every thing was fine but only the prediction result was bad. When I loaded a large amount of data to train with `tfIdfMatrix`(a method to vectorize text, provided by document_analysis), it took a large amount of time and RAM and I failed to build model because of the lack of memory.

Here, I want to simply explain the reason why TF-IDF martix algorithm took so much time. What TF-IDF martix algorithm did was to find out the frequency of each word appeared in each sentence. So, with the amount of words increasing, the dimension also increases, which will cause a rapid increase on calculation.

I also found a solution which is to vectorize text by using my own method, but the result was even worser.

In the case above, the classification algorithm was [DecisionTreeClassifier](https://pub.dev/documentation/ml_algo/latest/ml_algo/DecisionTreeClassifier-class.html). I fed the machine dataset like this:

```
flutter: DataFrame (159571 x 2)
comment_text   insult
explanation why the edits ...       0.0
...                                 ...
d aww  he matches this ba ...       0.0
```

where `comment_text` was the comment that user posted and `insult` indicated whether this content was insultable or not.

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

My key function was to make text to vector so that the machine could calculate and build the modle. And this was also the most difficult problem I encounted in my project.

### Struggle with TensorFlow
The fact was that there was no doc2vec libraries in Dart, and all I could found was about Python or something like that.
But later, I found there was a built model in [huggingface](https://huggingface.co/bert-base-uncased), but it was built for TenserFlow, which could be applied in Python rather than Dart. However, the official document provides a [guide](https://huggingface.co/docs/optimum/exporters/tflite/usage_guides/export_a_model) on how to convert it to TensorFlow Lite, and luckily there was a library called [tflite_flutter_plus](https://pub.dev/packages/tflite_flutter_plus) providing a interpreter between TensorFlow and Dart.

Things went badly at the last, I had some problems when following the doc, I searched and tried some solutions, but nothing got changed, so I gave up.

As I mentioned above, TensorFlow was built for Python, although there was a library called [python_ffi](https://pub.dev/packages/python_ffi) to invoked any Python module in Dart, but I had better not use Python. Well, but I considered that the difficulty of achieving that(doc2vec) by Dart language, I decided to use Python. But again, I failed, because it only supported pure Python code.

So I gave up? No, I then found another way to run Python code. I used Python to build up a [web server](https://github.com/founchoo/doc2vec_server), and in Dart application, I could invoke TensorFlow algorithm just by `GET` method. What a genius!

This time, I fed the machine almost the same dataset besides the size, which was 12689 x 2, but it showed different outcomes:

```
flutter: Pre-processing result:
flutter: DataFrame (12689 x 769)
insult                 fea_0                  fea_1                 fea_2                 fea_3                 fea_4   ...              fea_767
   0.0   -0.7947729229927063    -0.3663290739059448   -0.6826316714286804    0.5298082828521729   0.38561514019966125   ...   0.8614583015441895
   0.0   -0.6552587151527405    -0.5079750418663025   -0.9163077473640442    0.6903209686279297    0.7387704253196716   ...   0.6643986105918884
   0.0   -0.7848144173622131    -0.4483385980129242    -0.904833972454071    0.7669529914855957    0.7172573208808899   ...   0.7397924065589905
   0.0   -0.8217465281486511   -0.47220537066459656   -0.8824613690376282    0.7397663593292236    0.5861581563949585   ...   0.8556132316589355
   1.0   -0.5986714363098145    -0.2154504358768463    0.4265202283859253   0.27244287729263306   -0.1582547426223755   ...   0.6849899291992188
   ...                   ...                    ...                   ...                   ...                   ...   ...                  ...
   0.0   -0.8255961537361145    -0.4590681493282318   -0.5918567776679993    0.7359922528266907    0.3755975067615509   ...    0.901710569858551
   0.0    -0.731025218963623   -0.43930941820144653   -0.8263741135597229     0.638615608215332    0.3906306028366089   ...   0.7427312731742859
   0.0   -0.7566186189651489    -0.4142800569534302   -0.7555342316627502    0.5424911379814148   0.40552330017089844   ...   0.7499610781669617
   1.0   -0.7954379916191101   -0.47804439067840576     -0.79896080493927    0.6801205277442932    0.6424688100814819   ...   0.8404900431632996
   0.0   -0.7470123171806335    -0.5245763659477234   -0.8404871225357056    0.6709993481636047    0.7077993154525757   ...   0.7762796878814697
flutter: Pre-processing done in 0:43:46.870327
flutter: Building model...
flutter: Model built in 0:00:01.443429
```

Also, I changed the classification model to [KnnClassifier](https://pub.dev/documentation/ml_algo/latest/ml_algo/KnnClassifier-class.html).
