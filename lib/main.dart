import 'dart:js';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ncross/logic/crosssections_model.dart';
import 'package:ncross/painter/crosssections_painter.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => CrosssectionsModel(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Breinbaas NCross',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  MyHomePage({Key? key}) : super(key: key);

  final _limitLeftControler = TextEditingController(text: '0');
  final _limitRightControler = TextEditingController(text: '30');
  final _startController = TextEditingController(text: '0');
  final _endController = TextEditingController(text: '10000');

  void upload(BuildContext context) async {
    Provider.of<CrosssectionsModel>(context, listen: false)
        .uploadCrosssections();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      appBar: AppBar(
        title: const Text("Normative crosssection calculator"),
      ),
      body: Consumer<CrosssectionsModel>(
        builder: (context, crosssectionsModel, child) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Row(
                  children: [
                    const SizedBox(
                      width: 10,
                    ),
                    Consumer<CrosssectionsModel>(
                      builder: (context, crosssectionsModel, child) {
                        if (crosssectionsModel.crosssections.isEmpty) {
                          return const Text(
                              'Please upload some crosssection data');
                        } else {
                          return Text(
                              'Currrently ${crosssectionsModel.crosssections.length} entries');
                        }
                      },
                    ),
                    const SizedBox(
                      width: 40,
                    ),
                    const Text(
                      'start',
                    ),
                    SizedBox(
                      width: 100.0,
                      child: TextFormField(
                        textAlign: TextAlign.right,
                        controller: _startController,
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                        ],
                        onChanged: (value) {
                          if (value.isNotEmpty) {
                            crosssectionsModel.startChainage = int.parse(value);
                          }
                        },
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    const Text(
                      'end',
                    ),
                    SizedBox(
                      width: 100.0,
                      child: TextFormField(
                        textAlign: TextAlign.right,
                        controller: _endController,
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                        ],
                        onChanged: (value) {
                          if (value.isNotEmpty) {
                            crosssectionsModel.endChainage = int.parse(value);
                          }
                        },
                      ),
                    ),
                    const SizedBox(
                      width: 40,
                    ),
                    const Text(
                      'left',
                    ),
                    SizedBox(
                      width: 100.0,
                      child: TextFormField(
                        textAlign: TextAlign.right,
                        controller: _limitLeftControler,
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.allow(
                              RegExp(r'-?[0-9]{0,10}')),
                        ],
                        onChanged: (value) {
                          try {
                            int iValue = int.parse(value);
                            crosssectionsModel.limitLeft = iValue;
                          } catch (_) {}
                        },
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    const Text(
                      'right',
                      style: TextStyle(color: Colors.yellow),
                    ),
                    SizedBox(
                      width: 100.0,
                      child: TextFormField(
                        style: const TextStyle(color: Colors.yellow),
                        textAlign: TextAlign.right,
                        controller: _limitRightControler,
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                        ],
                        onChanged: (value) {
                          if (value.isNotEmpty) {
                            crosssectionsModel.limitRight = int.parse(value);
                          }
                        },
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        crosssectionsModel.calculateNormative();
                      },
                      child: const Text('Start'),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        crosssectionsModel.reset();
                      },
                      child: const Text('Restart'),
                    ),
                  ],
                ),
                Expanded(
                  child: CustomPaint(
                    painter: CrosssectionsPainter(crosssectionsModel),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: () {
          upload(context);
        },
        tooltip: 'Upload',
        child: const Icon(Icons.upload),
      ),
    );
  }
}
