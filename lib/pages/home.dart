import 'dart:io';

import 'package:band_names_app/models/band.dart';
import 'package:band_names_app/services/socket_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Band> bands = [];

  @override
  void initState() {
    final socketService = Provider.of<SocketService>(context, listen: false);
    socketService.socket.on('active-bands', _handleActiveBands);
    super.initState();
  }

  void _handleActiveBands(dynamic payload) {
    bands = (payload as List).map((band) => Band.fromMap(band)).toList();
    setState(() {});
  }

  @override
  void dispose() {
    final socketService = Provider.of<SocketService>(context, listen: false);
    socketService.socket.off('active-bands');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final socketService = Provider.of<SocketService>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'BandNames',
          style: TextStyle(color: Colors.black87),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          Container(
            margin: EdgeInsets.only(right: 10),
            child: socketService.serverStatus == ServerStatus.online
                ? Icon(
                    Icons.check_circle,
                    color: Colors.blue[300],
                  )
                : const Icon(
                    Icons.check_circle,
                    color: Colors.red,
                  ),
          ),
        ],
      ),
      body: Column(
        children: [
          _showGraph(),
          Expanded(
            child: ListView.builder(
              itemCount: bands.length,
              itemBuilder: (context, index) => _bandTile(bands[index]),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        elevation: 1,
        onPressed: () => addNewBand(context),
      ),
    );
  }

  Widget _bandTile(Band band) {
    final socketService = Provider.of<SocketService>(context, listen: false);

    return Dismissible(
      key: Key(band.id),
      direction: DismissDirection.startToEnd,
      onDismissed: (_) => socketService.emit('delete-band', {'id': band.id}),
      background: Container(
          padding: const EdgeInsets.only(left: 8.0),
          color: Colors.red,
          child: const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Delete band',
              style: TextStyle(color: Colors.white),
            ),
          )),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(band.name.substring(0, 2)),
          backgroundColor: Colors.blue[100],
        ),
        title: Text(band.name),
        trailing: Text(
          '${band.votes}',
          style: const TextStyle(fontSize: 20),
        ),
        onTap: () => socketService.socket.emit(
          'vote-band',
          {'id': band.id},
        ),
      ),
    );
  }

  addNewBand(BuildContext context) {
    final textController = TextEditingController();
    if (!Platform.isAndroid) {
      return showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('New band name: '),
          content: TextField(
            controller: textController,
          ),
          actions: [
            MaterialButton(
              child: const Text('Add'),
              elevation: 5,
              textColor: Colors.blue,
              onPressed: () => addBandToList(textController.text),
            ),
          ],
        ),
      );
    }
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text('New band name: '),
        content: CupertinoTextField(
          controller: textController,
        ),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            child: const Text('Add'),
            onPressed: () => addBandToList(textController.text),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text('Dismiss'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void addBandToList(String name) {
    if (name.length > 1) {
      final socketService = Provider.of<SocketService>(context, listen: false);
      socketService.emit('add-band', {'name': name});
    }
    Navigator.pop(context);
  }

  Widget _showGraph() {
    Map<String, double> dataMap = {};
    for (var band in bands) {
      dataMap.putIfAbsent(band.name, () => band.votes.toDouble());
    }

    final List<Color> colorList = [
      Colors.blue[50]!,
      Colors.blue[200]!,
      Colors.pink[50]!,
      Colors.pink[200]!,
      Colors.yellow[50]!,
      Colors.yellow[200]!,
    ];

    return Container(
      padding: const EdgeInsets.only(top: 15),
      width: double.infinity,
      height: 200,
      child: PieChart(
        dataMap: dataMap,
        animationDuration: const Duration(milliseconds: 800),
        colorList: colorList,
        initialAngleInDegree: 0,
        chartType: ChartType.ring,
        ringStrokeWidth: 32,
        legendOptions: const LegendOptions(
          showLegendsInRow: false,
          legendPosition: LegendPosition.right,
          showLegends: true,
          legendTextStyle: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        chartValuesOptions: const ChartValuesOptions(
          showChartValueBackground: true,
          showChartValues: true,
          showChartValuesInPercentage: true,
          showChartValuesOutside: false,
          decimalPlaces: 0,
        ),
        // gradientList: ---To add gradient colors---
        // emptyColorGradient: ---Empty Color gradient---
      ),
    );
  }
}
