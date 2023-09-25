import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:ui' as ui;
import 'package:mx_chart/mx_chart.dart';
import 'package:mx_chart_example/k_chart/bloc/k_chart_bloc.dart';
import 'package:mx_chart_example/repository/chart_repository.dart';

class KChartPage extends StatefulWidget {
  const KChartPage({super.key});

  @override
  State<KChartPage> createState() => _KChartPageState();
}

class _KChartPageState extends State<KChartPage> with TickerProviderStateMixin {
  /// 圖表控制器
  final _chartController = KLineChartController();

  int klineIndex = 1;
  bool waitBuild = false;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) =>
          KChartBloc(ChartRepository())..add(KChartInitEvent(klineIndex)),
      child: _view(),
    );
  }

  Widget _view() {
    Widget _content(KChartState state) {
      const heightSetting = ChartHeightRatioSetting(
          // mainFixed: 100,
          mainFixed: 60,
          volumeRatio: 0.8,
          indicatorRatio: 0.2,
          timelineFixed: 0);
      final compute = heightSetting.computeChartHeight(
        totalHeight: 100,
        mainChartState: MainChartState.kLine,
        volumeChartState: VolumeChartState.volume,
        indicatorChartState: IndicatorChartState.kdj,
        dragOffset: 0,
        canDragBarShow: false,
        dragBar: false,
      );
      print('高度: ${compute.main} => ${compute.volume} => ${compute.indicator}');
      if (state.isLoading) {
        return Container(
          height: 200,
          alignment: Alignment.center,
        );
      } else {
        return KLineChart(
          datas: state.datas,
          mainChartState: state.mainChartState,
          mainChartIndicatorState: state.mainChartIndicatorState,
          volumeChartState: state.volumeChartState,
          indicatorChartState: state.indicatorChartState,
          controller: _chartController,
          chartUiStyle: const KLineChartUiStyle(
            colorSetting: ChartColorSetting(),
            sizeSetting: ChartSizeSetting(
              timelineTopDivider: 1,
              timelineBottomDivider: 2,
            ),
            heightRatioSetting: ChartHeightRatioSetting(
                mainFixed: 300, volumeFixed: 80, indicatorFixed: 80),
          ),
          mainChartUiStyle: const MainChartUiStyle(
            colorSetting: MainChartColorSetting(),
            sizeSetting: MainChartSizeSetting(
              bottomDivider: 0,
            ),
          ),
          volumeChartUiStyle: const VolumeChartUiStyle(
            colorSetting: VolumeChartColorSetting(),
            sizeSetting: VolumeChartSizeSetting(
              bottomDivider: 1,
              topDivider: 0,
            ),
            gridEnabled: false,
          ),
          macdChartUiStyle: const MACDChartUiStyle(
            colorSetting: MACDChartColorSetting(),
            sizeSetting: MACDChartSizeSetting(),
            gridEnabled: false,
          ),
          rsiChartUiStyle: const RSIChartUiStyle(
            colorSetting: RSIChartColorSetting(),
            sizeSetting: RSIChartSizeSetting(),
            gridEnabled: false,
          ),
          wrChartUiStyle: const WRChartUiStyle(
            colorSetting: WRChartColorSetting(),
            sizeSetting: WRChartSizeSetting(),
            gridEnabled: false,
          ),
          kdjChartUiStyle: const KDJChartUiStyle(
            colorSetting: KDJChartColorSetting(),
            sizeSetting: KDJChartSizeSetting(),
            gridEnabled: false,
          ),
          dragBarBackgroundUiStyle: const DragBarBackgroundUiStyle(
            gridEnabled: false,
          ),
          dragBar: false,
          priceFormatter: (price) => price.toStringAsFixed(2),
          volumeFormatter: (volume) {
            if (volume > 10000 && volume < 999999) {
              final d = volume / 1000;
              return '${d.toStringAsFixed(2)}K';
            } else if (volume > 1000000) {
              final d = volume / 1000000;
              return '${d.toStringAsFixed(2)}M';
            }
            return volume.toStringAsFixed(2);
          },
          onLoadMore: (value) {
            if (kDebugMode) {
              print('加載更多: $value');
            }
          },
          tooltipBuilder: (context, longPressData, mainRect) {
            return KLineDataInfoTooltip(
              longPressData: longPressData,
              mainRect: mainRect,
            );
          },
          layoutBuilder: (context, main, volume, indicator, timeline) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [volume, main, indicator, timeline],
            );
          },
          onMarkerModeChanged: (mode) {
            print('marker模式變更: $mode');
          },
          initMarkers: klineIndex == 1 ? [markerData1] : [markerData2],

          dataPeriod: const Duration(minutes: 1),

          onMarkerAdd: (marker) {
            print('Marker新增成功: ${marker.id}');
          },

          onMarkerAddProgress: (type, point, totalPoint) {
            print('Marker新增進度: $type, $point, $totalPoint');
          },

          onMarkerUpdate: (markers) {
            print('Marker更新: ${markers.length}');
            // final jsonData = markers.map((e) => e.toMap()).toList();
            // final jsonString = json.encode(jsonData);
            // print(jsonString);
          },

          onMarkerRemove: (marker) {
            print('Marker刪除: ${marker.id}');
          },
          // priceTagBuilder: (context, position) {
          //   return Stack(
          //     children: [
          //       CustomPriceLineTag(
          //         gridColumns: const ChartSizeSetting().gridColumns,
          //         price: state.datas.last.close,
          //         position: position,
          //         priceFormatter: (value) => value.toStringAsFixed(2),
          //         tag: '現價',
          //         onTapGlobalTag: () {
          //           print('點點');
          //         },
          //       ),
          //     ],
          //   );
          // },
        );
      }
    }

    return Scaffold(
      // backgroundColor: Color(0xff1e2129),
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('行情圖表'),
      ),
      body: BlocBuilder<KChartBloc, KChartState>(
        builder: (context, state) {
          // print('是線條嗎: ${stateIsLine}');
          return ListView(
            children: <Widget>[
              Stack(children: <Widget>[
                SizedBox(
                  width: double.infinity,
                  child: AnimatedSize(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.fastOutSlowIn,
                    alignment: Alignment.topCenter,
                    child: waitBuild ? SizedBox() : _content(state),
                  ),
                ),
                if (state.isLoading)
                  Container(
                    width: double.infinity,
                    height: 450,
                    alignment: Alignment.center,
                    child: const CircularProgressIndicator(),
                  ),
              ]),
              _buttons(context, state),
              const SizedBox(height: 500),
            ],
          );
        },
      ),
    );
  }

  Widget _buttons(BuildContext context, KChartState state) {
    KChartBloc bloc() => context.read<KChartBloc>();

    Widget button(String text, {VoidCallback? onPressed}) {
      return TextButton(
        onPressed: () {
          if (onPressed != null) {
            onPressed();
            setState(() {});
          }
        },
        style: TextButton.styleFrom(
          backgroundColor: Colors.blue,
        ),
        child: Text(
          text,
          style: const TextStyle(color: Colors.white),
        ),
      );
    }

    return Wrap(
      alignment: WrapAlignment.spaceEvenly,
      children: <Widget>[
        button(
          "分時",
          onPressed: () {
            bloc().add(KChartMainStateEvent(state: MainChartState.lineIndex));
          },
        ),
        button(
          "k線",
          onPressed: () {
            bloc().add(KChartMainStateEvent(state: MainChartState.kLine));
          },
        ),
        button(
          "無主圖表",
          onPressed: () {
            bloc().add(KChartMainStateEvent(state: MainChartState.none));
          },
        ),
        button(
          "買賣量",
          onPressed: () {
            bloc().add(KChartVolumeChartStateEvent(
                state: state.volumeChartState == VolumeChartState.none
                    ? VolumeChartState.volume
                    : VolumeChartState.none));
          },
        ),
        button(
          "MA",
          onPressed: () {
            bloc().add(KChartMainIndicatorStateEvent(
                state: MainChartIndicatorState.ma));
          },
        ),
        button(
          "BOLL",
          onPressed: () {
            bloc().add(KChartMainIndicatorStateEvent(
                state: MainChartIndicatorState.boll));
          },
        ),
        button(
          "MACD",
          onPressed: () {
            bloc().add(KChartIndicatorChartStateEvent(
                state: IndicatorChartState.macd));
          },
        ),
        button(
          "KDJ",
          onPressed: () {
            bloc().add(
                KChartIndicatorChartStateEvent(state: IndicatorChartState.kdj));
          },
        ),
        button(
          "RSI",
          onPressed: () {
            bloc().add(
                KChartIndicatorChartStateEvent(state: IndicatorChartState.rsi));
          },
        ),
        button(
          "WR",
          onPressed: () {
            bloc().add(
                KChartIndicatorChartStateEvent(state: IndicatorChartState.wr));
          },
        ),
        button(
          "隱藏技術線視圖",
          onPressed: () {
            bloc().add(KChartIndicatorChartStateEvent(
                state: IndicatorChartState.none));
          },
        ),
        button(
          "update",
          onPressed: () {
            //更新最後一條數據
            bloc().add(KChartUpdateLastEvent());
          },
        ),
        button(
          "addData",
          onPressed: () {
            //拷貝一個對象，修改數據
            bloc().add(KChartAddDataEvent());
          },
        ),
        button(
          "標記新增模式",
          onPressed: () {
            bool result = _chartController.setMarkerMode(
              MarkerMode.add,
              markerTypeIfAdd: MarkerType.trendLine,
            );
            print('變更狀態完成: $result');
          },
        ),
        button(
          "標記可編輯瀏覽模式",
          onPressed: () {
            _chartController.setMarkerMode(MarkerMode.editableView);
          },
        ),
        button(
          "清除所有標記",
          onPressed: () {
            _chartController.setMarkers([]);
          },
        ),
        button(
          "變更資料",
          onPressed: () {
            if (klineIndex == 1) {
              klineIndex = 2;
              // waitBuild = true;
            } else {
              klineIndex = 1;
              // waitBuild = true;
            }
            // Future.delayed(Duration(seconds: 2)).then((value) {
            //   waitBuild = false;
            //   setState(() {});
            // });
            context.read<KChartBloc>().add(KChartInitEvent(klineIndex));
          },
        ),
      ],
    );
  }
}

const markerIndex1 = '''
[{"id":"1695612744118","name":"1695612744118","positions":[{"dateTime":"2023-09-25 02:43:00.000","xRate":0.5416660308837891,"price":90.15646153846154},{"dateTime":"2023-09-25 02:54:00.000","xRate":0.7916660308837891,"price":90.23994872107873}],"type":"trendLine","color":4294961979,"strokeWidth":1.0,"anchorPointRadius":5.0,"dashArray":[]}]
''';

MarkerData get markerData1 {
  final jsonData = json.decode(markerIndex1);
  final markers = jsonData
      .map<MarkerData>((e) => MarkerData.fromMap(e as Map<String, dynamic>))
      .toList();
  return markers.first;
}

const markerIndex2 = '''
[{"id":"1695612744118","name":"1695612744118","positions":[{"dateTime":"2023-09-25 02:43:00.000","xRate":0.5416660308837891,"price":90.15646153846154},{"dateTime":"2023-09-25 02:54:00.000","xRate":0.7916660308837891,"price":90.23994872107873}],"type":"trendLine","color":4294961979,"strokeWidth":1.0,"anchorPointRadius":5.0,"dashArray":[]},{"id":"1695612778173","name":"1695612778173","positions":[{"dateTime":"2023-09-22 05:00:00.000","xRate":0.6666660308837891,"price":89.24834615384616},{"dateTime":"2023-09-22 10:00:00.000","xRate":0.04166603088378906,"price":91.02494876509446}],"type":"trendLine","color":4288423856,"strokeWidth":4.0,"anchorPointRadius":5.0,"dashArray":[]}]
''';

MarkerData get markerData2 {
  final jsonData = json.decode(markerIndex2);
  final markers = jsonData
      .map<MarkerData>((e) => MarkerData.fromMap(e as Map<String, dynamic>))
      .toList();
  return markers.first;
}
