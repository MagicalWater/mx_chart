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

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) =>
          KChartBloc(ChartRepository())..add(KChartInitEvent()),
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
          initMarkers: [
            // MarkerData(
            //   id: '1',
            //   name: '1',
            //   positions: [
            //     MarkerPosition(
            //       dateTime: DateTime.parse('2023-06-23T13:00:00'),
            //       xRate: 0.5,
            //       price: 68.20,
            //     ),
            //     MarkerPosition(
            //       dateTime: DateTime.parse('2023-06-26T00:00:00'),
            //       xRate: 0.5,
            //       price: 69.9,
            //     ),
            //     MarkerPosition(
            //       dateTime: DateTime.parse('2023-06-28T00:00:00'),
            //       xRate: 0.8,
            //       price: 67.9,
            //     ),
            //   ],
            //   type: MarkerType.waveLine3,
            //   color: Colors.yellow,
            //   strokeWidth: 2,
            //   anchorPointRadius: 5,
            // ),
          ],

          dataPeriod: const Duration(minutes: 1),

          onMarkerAdd: (marker) {
            print('Marker新增成功: ${marker.id}');
          },

          onMarkerAddProgress: (type, point, totalPoint) {
            print('Marker新增進度: $type, $point, $totalPoint');
          },

          onMarkerUpdate: (markers) {
            print('Marker更新: ${markers.length}');
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
                    child: _content(state),
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
            _chartController.setMarkerMode(
              MarkerMode.add,
              markerTypeIfAdd: MarkerType.values[9],
            );
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
      ],
    );
  }
}
