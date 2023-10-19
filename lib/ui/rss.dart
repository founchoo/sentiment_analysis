import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';

class RssPage extends StatefulWidget {
  const RssPage({Key? key}) : super(key: key);

  @override
  State<RssPage> createState() => _RssPageState();
}

class _RssPageState extends State<RssPage> {
  Future<List> getRssList() async {
    var response = await http.get(Uri.parse("https://hnrss.org/newcomments"));
    var xmlDoc = XmlDocument.parse(response.body);
    var items = xmlDoc.findAllElements("item").toList();
    return items;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getRssList(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              var item = snapshot.data![index] as XmlElement;
              var title = item.findElements("title").first.innerText;
              var desc = item.findElements("description").first.innerText;
              return ListTile(
                title: Text(title),
                subtitle: Text(desc),
              );
            },
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
