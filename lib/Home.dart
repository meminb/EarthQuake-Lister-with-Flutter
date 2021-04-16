import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:web_scraper/web_scraper.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Quake> quakes = [];
  @override
  initState() {
    initiate();
    super.initState();
  }

  @override
  build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Depremler'),
        ),
        body: quakes.length == 0
            ? Container()
            : ListView.builder(
                itemBuilder: (context, index) {
                  return myItem(index, context);
                },
              ));
  }

  Widget myItem(int index, dynamic context) {
    int a = (30 * quakes[index].magnitude).round();
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height / 14,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                      flex: 6,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(quakes[index].center),
                          SizedBox(
                            height: 4,
                          ),
                          Text(quakes[index].date)
                        ],
                      )),
                  Expanded(
                      flex: 1,
                      child: Container(
                          alignment: Alignment.center,
                          height: 30,
                          width: 35,
                          decoration: BoxDecoration(
                              color: Color.fromARGB(a, a, 0x00, 0x00),
                              borderRadius: BorderRadius.circular(5)),
                          child: Text(quakes[index].magnitude.toString())))
                ],
              )),
        ),
        Divider()
      ],
    );
  }

  initiate() async {
    final webScraper = WebScraper('http://www.koeri.boun.edu.tr');
    List<Map<String, dynamic>> elements;
    if (await webScraper.loadWebPage('/scripts/lst0.asp')) {
      elements = webScraper.getElement('pre', ['text']);

      String data = elements[0].toString();

      List<String> allData = data.split("\n");

      for (var i = 7; i < 500; i++) {
        var temp = allData[i].split(RegExp(r" +"));
        for (var i = 0; i < temp.length; i++) {
          print("$i  ${temp[i]}");
        }

        quakes.add(new Quake(
            center: temp[8] + " " + temp[9],
            date: temp[0] + " " + temp[1].substring(0, 5),
            magnitude: double.parse(temp[6]))); /**/
      }
      setState(() {});
    }
  }
}

class Quake {
  String center, date;
  double magnitude;
  Quake({this.center, this.date, this.magnitude});
}
