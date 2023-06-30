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
  int? get longPressDataIndex =>
      chartGesture.isLongPress ? _longPressDataIndex : null;

  KLineData? get longPressData =>
      chartGesture.isLongPress ? _longPressData : null;

  /// 資料
  List<KLineData> get datas => _datas;

  /// 尺寸設定
  ChartSizeSetting get sizeSetting => _sizeSetting;

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

  /// 將時間轉化為顯示的x軸座標
  /// 當time時間小於或超過當前資料的首尾時間時, 則無法判斷, 因此回傳null
  /// 但可以改調用[estimateTimeToDisplayX]來預測時間對應的x軸座標
  /// [time] 時間
  /// [percent] 在一筆資料中的百分比位置(例如中間點則是0.5)
  double? timeToDisplayX(DateTime time, {double percent = 0.5}) {
    // 若time沒有處於開始與結束時間之間, 則無法判斷
    final firstTime = datas.first.dateTime;
    final lastTime = datas.last.dateTime;
    if (time.isBefore(firstTime) || time.isAfter(lastTime)) {
      return null;
    } else {
      // 從第一筆資料開始搜索有沒有時間相符的資料
      for (var i = 0; i < datas.length; i++) {
        final data = datas[i];
        if (data.dateTime == time) {
          return dataIndexToDisplayX(i, percent: percent);
        } else if (data.dateTime.isAfter(time)) {
          // 資料大於time, 代表沒有相符的資料, 因此只能夠取這筆資料的開始位置以及上一筆資料的結束位置中間值
          if (i > 0) {
            final prevEndX = dataIndexToDisplayX(i - 1, percent: 1);
            final currentStartX = dataIndexToDisplayX(i, percent: 0);
            return (prevEndX + currentStartX) / 2;
          } else {
            // 若i為0, 代表沒有上一筆資料, 因此改取起始位置
            final currentStartX = dataIndexToDisplayX(i, percent: 0);
            return currentStartX;
          }
        }
      }
      // 若都沒有找到, 則回傳null
      return null;
    }
  }

  /// 預測時間對應的x軸座標
  /// [time] 時間
  /// [percent] 在一筆資料中的百分比位置(例如中間點則是0.5)
  /// [period] 每筆資料的時間間隔
  double? estimateTimeToDisplayX(
    DateTime time, {
    required Duration period,
    double percent = 0.5,
  }) {
    // 計算時間差
    // 若time處於最早一筆資料之前, 則以最早資料為主
    // 若time處於最後一筆資料之後, 則以最後資料為主
    final firstTime = datas.first.dateTime;
    final lastTime = datas.last.dateTime;
    if (time.isBefore(firstTime)) {
      // 計算出時間差
      final diff = firstTime.difference(time);
      // 計算出時間差為幾個period, 必定為整數
      final diffCount = diff.inMilliseconds ~/ period.inMilliseconds;
      // 取得應該往前推的x軸寬度
      final diffWidth =
          diffCount * _sizeSetting.dataWidth * chartGesture.scaleX;

      // 取得目前已有資料的最左側的座標
      final leftPoint = -(_totalDataWidth! + _sizeSetting.rightSpace);

      // 最左側座標減去往前推的x軸寬度即為預測的x軸座標
      return leftPoint - diffWidth;
    } else if (time.isAfter(lastTime)) {
      // 計算出時間差
      final diff = time.difference(lastTime);
      // 計算出時間差為幾個period, 必定為整數
      final diffCount = diff.inMilliseconds ~/ period.inMilliseconds;
      // 取得應該往後推的x軸寬度
      final diffWidth =
          diffCount * _sizeSetting.dataWidth * chartGesture.scaleX;

      // 取得目前已有資料的最右側的座標
      final rightPoint = dataIndexToDisplayX(datas.length - 1, percent: 1);

      // 最右側座標加上往後推的x軸寬度即為預測的x軸座標
      return rightPoint + diffWidth;
    } else {
      // 時間位於兩個點之間
      // 用預估的會不準確, 因此不進行預測
      return null;
    }
  }

  /// 將data的索引值轉換為畫布繪製的x軸座標(默認為中間點)
  /// [index] 資料的索引值
  /// [percent] 在一筆資料中的百分比位置(例如中間點則是0.5)
  double dataIndexToRealX(int index, {double percent = 0.5}) {
    final displayX = dataIndexToDisplayX(index, percent: percent);
    return displayXToRealX(displayX);
  }

  /// 將畫布繪製的x軸座標轉換為data的索引值
  int realXToDataIndex(double realX) {
    final displayX = realXToDisplayX(realX);
    return displayXToDataIndex(displayX);
  }

  /// 將data的索引值轉換為顯示的x軸座標(默認為中間點)
  /// [index] 資料的索引值
  /// [percent] 在一筆資料中的百分比位置(例如中間點則是0.5)
  double dataIndexToDisplayX(int index, {double percent = 0.5}) {
    final leftPoint = -(_totalDataWidth! + _sizeSetting.rightSpace);
    final dataWidth = _sizeSetting.dataWidth * chartGesture.scaleX;
    final dataPoint = dataWidth * index + (dataWidth * percent);
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
