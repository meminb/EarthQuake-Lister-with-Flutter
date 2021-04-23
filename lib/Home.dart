import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:web_scraper/web_scraper.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Quake> quakes = [];

  bool isSearching = false;
  TextEditingController controller = TextEditingController();
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
          actions: [
            isSearching
                ? Expanded(
                    child: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: TextFormField(
                      enableInteractiveSelection: true,
                      enabled: isSearching,
                      autofocus: true,
                      controller: controller,
                      onChanged: (value) {
                        search(value);
                      },
                    ),
                  ))
                : Container(),
            ElevatedButton(
                onPressed: () {
                  setState(() {
                    isSearching = !isSearching;
                  });
                },
                child: Icon(isSearching ? Icons.close : Icons.search)),
            ElevatedButton(
                onPressed: () {
                  initiate();
                },
                child: Icon(Icons.refresh))
          ],
        ),
        body: quakes.length == 0
            ? Container(child: Text("Bu bölgede deprem kaydı bulunamadı."))
            : ListView.builder(
                itemBuilder: (context, index) {
                  return myItem(index, context);
                },
              ));
  }

  Widget myItem(int index, dynamic context) {
    //int hexColorCode = (30 * quakes[index].magnitude).round();
    double mag = quakes[index].magnitude;
    int r = 256 - (9 * mag).round();
    int g = 256 - (22 * mag).round();
    int b = 256 - (23 * mag).round();
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height / 16,
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
                              // color: Colors.red[quakes[index].magnitude.round() * 100],
                              color: Color.fromARGB(0xff, r, g, b),
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
      quakes.clear();
      for (var i = 6; i < 500; i++) {
        var temp = allData[i].split(RegExp(r" +"));
        for (var i = 0; i < temp.length; i++) {
          // print("$i  ${temp[i]}");
        }

        quakes.add(new Quake(
            center: temp[8] + " " + temp[9],
            date: temp[0] + " " + temp[1].substring(0, 5),
            magnitude: double.parse(temp[6]))); /**/
      }
      setState(() {});
    }
  }

  search(String text) {
    if (text.isEmpty) {
      initiate();
    } else {
      // quakes.clear();
      List<Quake> temp = [];
      for (var item in quakes) {
        // print(item.center.toLowerCase());
        if (item.center.toLowerCase().contains(text.toLowerCase())) {
          // temp.add(item);
          temp.insert(0, item);
        }
      }
      quakes.clear();
      quakes.addAll(temp);
      setState(() {});
    }
  }
}

class Quake {
  String center, date;
  double magnitude;
  Quake({this.center, this.date, this.magnitude});
}
