import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:mx_chart/mx_chart.dart';

class ChartRepository {
  Future<List<KLineData>> getData() async {
    String result;
    result =
        await rootBundle.loadString('assets/jsons/chart_example/kline.json');
    var parseJson = json.decode(result);
    List list = parseJson['data'];
    var datas = list.map((json) {
      final milliSecond = DateTime.parse(json['datetime']).millisecondsSinceEpoch;
      return KLineData(
        open: (json['open'] as num).toDouble(),
        high: (json['high'] as num).toDouble(),
        low: (json['low'] as num).toDouble(),
        close: (json['close'] as num).toDouble(),
        volume: (json['volume'] as num).toDouble(),
        amount: 0,
        dateTime: DateTime.fromMillisecondsSinceEpoch(milliSecond),
      );
    }).toList();
    datas.calculateAllIndicator();
    return datas;
  }
}
