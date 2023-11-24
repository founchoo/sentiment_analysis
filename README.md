# Documentation for Sentiment Analysis

## Project Overview

This is a final project for Data Mining course.

### Project Goal
- Detect aggressive comments in public communities, like YouTube, Twitter, etc.
- Detect fake news in public media platform.

### Language
- Dart for both ML(Machine Learning) algorithm and UI(User Interface).

## Data Description

### Datasets (from [Kaggle](https://www.kaggle.com/))
- [Cleaned Toxic Comments](https://www.kaggle.com/datasets/fizzbuzz/cleaned-toxic-comments?select=train_preprocessed.csv)
- [Clean Fake News Dataset](https://www.kaggle.com/datasets/rakeshsahni/clean-fake-news-dataset?select=fake_news_train_clean.csv)

### Pre-processing

In this section, we will only give you an example for `Cleaned Toxic Comments` datasets since all the dataset have the same steps to be processed.

#### Select important columns

We only need `comment_text` and `insult` columns since the other columns(attributes) are not very important.

Below is the code:
```dart
DataFrame dataFrame = await fromCsv(
  'data/normal_offensive_data.csv',
  columns: [0, 3]);
```

where `0` is the index of `comment_text` column and `3` is the index of `insult` column.

#### Sampling

We only collect 10% of the whole dataset to train our model to speed up the time of building model.

Here is the code:
```dart
List<int> sampleCommentIndexes = [];
for (var i = 0; i < dataFrame.rows.length; i++) {
  if (i % sampleStep == 0) {
    sampleCommentIndexes.add(i);
  }
}
dataFrame = dataFrame.sampleFromRows(sampleCommentIndexes);
```

where `sampleStep` = 10.

#### Text vectorization

After reducing the dimensions of dataset, we feed machine dataset like this:

```
flutter: DataFrame (159571 x 2)
comment_text   insult
explanation why the edits ...       0.0
...                                 ...
d aww  he matches this ba ...       0.0
```

where `comment_text` is the comment that user posted and `insult` indicated whether this content was insult-able or not.

Then the content in every `comment_text` will be sent to a [Python program](https://github.com/founchoo/doc2vec_server)(written by ourselves) by HTTP `GET` method and the response will be like this:

```
[
    -0.7947729229927063,
    -0.3663290739059448,
    -0.6826316714286804,
    0.5298082828521729,
    0.38561514019966125,
    ...
    0.8614583015441895
]
```

This array is the vectorized result of the content in single `comment_text`.

Here, when the Python server receives the `GET` request, it will convert `String` text to `List<Double>` vector by using BERT model in [huggingface](https://huggingface.co/bert-base-uncased) with [TensorFlow](https://www.tensorflow.org/) framework.

After vectorization, the result will be like this:

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
```

## Data Mining Technologies

### Machine Learning

We use supervised learning that makes use of class labels to predict information.

## Model Building

We choose [KnnClassifier](https://pub.dev/documentation/ml_algo/latest/ml_algo/KnnClassifier-class.html) algorithm to build classification model.

To build model, just call:
```dart
model = await core.buildModel(dataFrame);
```

## Evaluation Metrics

Predict the dataset with training data removed, then calculate the correction rate.

## Results and Findings

According to the metric above, our model has a correction rate between 65% and 70%.

## Limitations

Because of the limitation of BERT model, we can only handle text with limited word size. We have tested that the size of 600(the length of a `String`) was acceptable.

## Reproducibility

> [!IMPORTANT]  
> Due to the limitation of size of files, we do not upload the files below:
> - normal_offensive_model.json
> - normal_offensive_data.csv
> - real_fake_model.json
> - real_fake_data.csv
> 
> to repository.
>
> Please do follow steps from 3 to 5 to ensure your `.csv` files are ready to be processed.
> The `.json` files are generated by program, those files will be generated when you finish traning your model.

1. Clone [doc2vec_server](https://github.com/founchoo/doc2vec_server) repository and run it in the background.
2. Clone this repository.
3. Create `data` folder in root directory of your cloned project.
4. Download datasets from [here](https://github.com/founchoo/sentiment_analysis?tab=readme-ov-file#datasets-from-kaggle) and put them in `data` folder.
5. Rename those two downloaded files to `normal_offensive_data.csv` and `real_fake_data.csv` respectively.
6. Run `flutter run` in the root directory.

## Data Privacy and Ethical Considerations

All datasets come from [Kaggle](https://www.kaggle.com/), which are public datasets.

The contents in dataset may contain some aggressive words.

## References

Thanks to the following libraries/websites, we could finish our project successfully.

- [sentiment_dart](https://pub.dev/packages/sentiment_dart), it gives us an inspiration on how to achieve our goal at the very beginning.
- [ml_dataframe](https://pub.dev/packages/ml_dataframe), it provides a way to store and manipulate data.
- [ml_algo](https://pub.dev/packages/ml_algo), it provides lots of algorithms for ML.
- [stopwordies](https://pub.dev/packages/stopwordies), it provides English stop words, which can be used to identify relatively meaningless words in a sentence.
- [document_analysis](https://pub.dev/packages/document_analysis), it provides text vectorization method and gives us some ideas on how to vectorize text at the first.
- [tutorial](https://www.kaggle.com/code/ashokkumarpalivela/sentiment-analysis-with-machine-learning/notebook), it provides guideline on how to apply ML in Python and gives us a structure to follow.

## Future Works

It is not very efficient to send every single `comment_text` to Python server and wait for the response. 

Although there is no doc2vec libraries in Dart, we find there is an official document provides a [guide](https://huggingface.co/docs/optimum/exporters/tflite/usage_guides/export_a_model) on how to convert TensorFlow model to TensorFlow Lite model, and luckily there is a library called [tflite_flutter_plus](https://pub.dev/packages/tflite_flutter_plus) providing a interpreter between TensorFlow Lite and Dart.

So maybe we can convert the doc2vec model to TensorFlow Lite model and use it in Dart directly.

## Presentation and Visualization

See PowerPoint file.
