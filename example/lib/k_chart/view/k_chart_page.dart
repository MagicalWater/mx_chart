import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mx_chart/mx_chart.dart';
import 'package:mx_chart_example/k_chart/bloc/k_chart_bloc.dart';
import 'package:mx_chart_example/repository/chart_repository.dart';

class KChartPage extends StatefulWidget {
  const KChartPage({super.key});

  @override
  State<KChartPage> createState() => _KChartPageState();
}

class _KChartPageState extends State<KChartPage> with TickerProviderStateMixin {
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
          chartUiStyle: const KLineChartUiStyle(
            colorSetting: ChartColorSetting(),
            sizeSetting: ChartSizeSetting(),
            heightRatioSetting: ChartHeightRatioSetting(
              mainFixed: 300,
              volumeFixed: 80,
              indicatorFixed: 80,
            ),
          ),
          mainChartUiStyle: const MainChartUiStyle(
            colorSetting: MainChartColorSetting(),
            sizeSetting: MainChartSizeSetting(),
          ),
          volumeChartUiStyle: const VolumeChartUiStyle(
            colorSetting: VolumeChartColorSetting(),
            sizeSetting: VolumeChartSizeSetting(),
          ),
          macdChartUiStyle: const MACDChartUiStyle(
            colorSetting: MACDChartColorSetting(),
            sizeSetting: MACDChartSizeSetting(),
          ),
          rsiChartUiStyle: const RSIChartUiStyle(
            colorSetting: RSIChartColorSetting(),
            sizeSetting: RSIChartSizeSetting(),
          ),
          wrChartUiStyle: const WRChartUiStyle(
            colorSetting: WRChartColorSetting(),
            sizeSetting: WRChartSizeSetting(),
          ),
          kdjChartUiStyle: const KDJChartUiStyle(
            colorSetting: KDJChartColorSetting(),
            sizeSetting: KDJChartSizeSetting(),
          ),
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
            print('加載更多: $value');
          },
          tooltipBuilder: (context, longPressData) {
            return KLineDataInfoTooltip(
              longPressData: longPressData,
            );
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
      appBar: AppBar(title: const Text('行情圖表'),),
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
        child: Text(text, style: TextStyle(color: Colors.white),),
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
      ],
    );
  }
}
