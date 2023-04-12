import 'package:flutter/material.dart';
import 'package:mx_chart/src/ui/k_line_chart/chart_gesture/chart_gesture.dart';

import '../model/model.dart';
import '../widget/chart_painter/ui_style/chart_size_setting.dart';

class ChartPainterValueInfo {
  /// 資料總寬度
  double? _totalDataWidth;

  /// 最大滾動距離
  double? _maxScrollX;

  /// 資料
  late List<KLineData> _datas;

  /// 尺寸設定
  late ChartSizeSetting _sizeSetting;

  /// 元件的寬度
  late double _canvasWidth;

  /// 視圖中, 顯示的第一個以及最後一個data的index
  late int _startDataIndex, _endDataIndex;

  /// 視圖中, 顯示的x軸起始點以及結束點
  late double _startDisplayX, _endDisplayX;

  /// 長按的資料index, 資料
  int? _longPressDataIndex;
  KLineData? _longPressData;

  /// 資料總寬度
  double? get totalDataWidth => _totalDataWidth;

  /// 最大滾動距離
  double? get maxScrollX => _maxScrollX;

  /// 元件的寬度
  double get canvasWidth => _canvasWidth;

  /// 視圖中, 顯示的第一個以及最後一個data的index
  int get startDataIndex => _startDataIndex;
  int get endDataIndex => _endDataIndex;

  /// 視圖中, 顯示的x軸起始點以及結束點
  double get startDisplayX => _startDisplayX;
  double get endDisplayX => _endDisplayX;

  /// 長按的資料index, 資料
  int? get longPressDataIndex => chartGesture.isLongPress ? _longPressDataIndex : null;
  KLineData? get longPressData => chartGesture.isLongPress ? _longPressData : null;

  /// 資料
  List<KLineData> get datas => _datas;

  final ChartGesture chartGesture;

  /// 當取得最大滾動距離時回調
  final ValueChanged<DrawContentInfo>? onDrawInfo;

  /// 當取得長按對應的資料時回調
  final ValueChanged<LongPressData?>? onLongPressData;

  ChartPainterValueInfo({
    required this.chartGesture,
    required this.onDrawInfo,
    required this.onLongPressData,
  });

  /// 初始化圖表資料
  /// 關於最大滾動距離
  ///   - 因圖表是由右往左滑, 因此滑動的x是從0開始往下算, 但距離為正
  void initDataValue({
    required double canvasWidth,
    required ChartSizeSetting sizeSetting,
    required List<KLineData> datas,
  }) {
    _canvasWidth = canvasWidth;
    _datas = datas;
    _sizeSetting = sizeSetting;

    // 資料占用總寬度
    _totalDataWidth =
        datas.length * sizeSetting.dataWidth * chartGesture.scaleX;

    // 計算最大可滾動的距離
    // 還需要扣除右邊空出來顯示最新豎直的區塊
    final scrollX = _canvasWidth - _totalDataWidth! - sizeSetting.rightSpace;

    if (scrollX >= 0) {
      // 資料佔不滿元件, 因此無法滾動, 最大滾動距離為0
      _maxScrollX = 0;
    } else {
      _maxScrollX = scrollX.abs();
    }

    // 取得視圖中第一筆以及最後一筆顯示的資料
    _startDisplayX = realXToDisplayX(0);
    _endDisplayX = realXToDisplayX(_canvasWidth - sizeSetting.rightSpace);
    _startDataIndex = displayXToDataIndex(_startDisplayX);
    _endDataIndex = displayXToDataIndex(_endDisplayX);

    // print('開始: ${realXToDisplayX(0)}, 結束: ${realXToDisplayX(size.width)}');

    // 將繪製資訊拋出
    onDrawInfo?.call(DrawContentInfo(
      maxScrollX: _maxScrollX!,
      chartTotalWidth: _totalDataWidth! + sizeSetting.rightSpace,
      canvasWidth: _canvasWidth,
    ));

    // 將長按對應的資料拋出
    final dataIndex = getLongPressDataIndex();
    if (dataIndex != null) {
      final x = dataIndexToRealX(dataIndex);
      final data = datas[dataIndex];
      final prevIndex = dataIndex - 1;
      KLineData? prevData;
      if (prevIndex >= 0) {
        prevData = datas[prevIndex];
      }
      onLongPressData?.call(LongPressData(
        index: dataIndex,
        data: data,
        prevData: prevData,
        isLongPressAtLeft: x <= _canvasWidth / 2,
      ));
    } else {
      onLongPressData?.call(null);
    }
  }

  /// 將data的索引值轉換為畫布繪製的x軸座標(中間點)
  double dataIndexToRealX(int index) {
    final displayX = dataIndexToDisplayX(index);
    return displayXToRealX(displayX);
  }

  /// 將畫布繪製的x軸座標轉換為data的索引值
  int realXToDataIndex(double realX) {
    final displayX = realXToDisplayX(realX);
    return displayXToDataIndex(displayX);
  }

  /// 將data的索引值轉換為顯示的x軸座標(正中間)
  double dataIndexToDisplayX(int index) {
    final leftPoint = -(_totalDataWidth! + _sizeSetting.rightSpace);
    final dataWidth = _sizeSetting.dataWidth * chartGesture.scaleX;
    final dataPoint = dataWidth * index + (dataWidth / 2);
    return leftPoint + dataPoint;
  }

  /// 將顯示中的x轉化為資料的index
  int displayXToDataIndex(double displayX) {
    final dataWidth = _sizeSetting.dataWidth * chartGesture.scaleX;
    final leftPoint = -(_totalDataWidth! + _sizeSetting.rightSpace);
    final dataIndex = (displayX - leftPoint) ~/ dataWidth;
    if (dataIndex >= _datas.length) {
      return _datas.length - 1;
    } else if (dataIndex < 0) {
      return 0;
    }
    return dataIndex;
  }

  /// 將顯示中的x轉換為實際畫布上的x
  double displayXToRealX(double displayX) {
    return displayX - _startDisplayX;
  }

  /// 將實際畫布的index轉換成顯示中的x
  double realXToDisplayX(double realX) {
    return -chartGesture.scrollX - (_canvasWidth - realX);
  }

  /// 取得長案中的data index
  int? getLongPressDataIndex() {
    if (!chartGesture.isLongPress) {
      return null;
    }
    if (_datas.isEmpty) {
      return null;
    }
    final displayX = realXToDisplayX(chartGesture.longPressX);
    var index = displayXToDataIndex(displayX);
    index = index.clamp(_startDataIndex, _endDataIndex);
    _longPressDataIndex = index >= _datas.length ? _datas.length - 1 : index;
    return _longPressDataIndex;
  }

  /// 取得長按中的data
  KLineData? getLongPressData() {
    if (!chartGesture.isLongPress) {
      return null;
    }
    if (_longPressData != null) {
      return _longPressData;
    }
    final index = getLongPressDataIndex();
    if (index != null) {
      _longPressData = _datas[index];
      return _longPressData;
    }
    return null;
  }
}
