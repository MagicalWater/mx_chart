import 'dart:ui';

import '../../../model/model.dart';
import '../chart_painter.dart';

mixin ChartPainterValueMixin on ChartPainter {
  /// 資料總寬度
  double? totalDataWidth;

  /// 最大滾動距離
  double? maxScrollX;

  /// 元件的寬度
  late double canvasWidth;

  /// 視圖中, 顯示的第一個以及最後一個data的index
  @override
  late int startDataIndex, endDataIndex;

  /// 視圖中, 顯示的x軸起始點以及結束點
  late double startDisplayX, endDisplayX;

  /// 長按的資料index, 資料
  int? _longPressDataIndex;
  KLineData? _longPressData;

  /// 初始化圖表資料
  /// 關於最大滾動距離
  ///   - 因圖表是由右往左滑, 因此滑動的x是從0開始往下算, 但距離為正
  void initDataValue(Size size) {
    canvasWidth = size.width;

    // 資料占用總寬度
    totalDataWidth =
        datas.length * chartUiStyle.sizeSetting.dataWidth * chartGesture.scaleX;

    // 計算最大可滾動的距離
    // 還需要扣除右邊空出來顯示最新豎直的區塊
    final scrollX =
        canvasWidth - totalDataWidth! - chartUiStyle.sizeSetting.rightSpace;

    if (scrollX >= 0) {
      // 資料佔不滿元件, 因此無法滾動, 最大滾動距離為0
      maxScrollX = 0;
    } else {
      maxScrollX = scrollX.abs();
    }

    // 取得視圖中第一筆以及最後一筆顯示的資料
    startDisplayX = realXToDisplayX(0);
    endDisplayX =
        realXToDisplayX(size.width - chartUiStyle.sizeSetting.rightSpace);
    startDataIndex = displayXToDataIndex(startDisplayX);
    endDataIndex = displayXToDataIndex(endDisplayX);

    // print('開始: ${realXToDisplayX(0)}, 結束: ${realXToDisplayX(size.width)}');

    // 將繪製資訊拋出
    onDrawInfo?.call(DrawContentInfo(
      maxScrollX: maxScrollX!,
      chartTotalWidth: totalDataWidth! + chartUiStyle.sizeSetting.rightSpace,
      canvasWidth: size.width,
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
        isLongPressAtLeft: x <= size.width / 2,
      ));
    } else {
      onLongPressData?.call(null);
    }
  }

  /// 將data的索引值轉換為畫布繪製的x軸座標(中間點)
  @override
  double dataIndexToRealX(int index) {
    final displayX = dataIndexToDisplayX(index);
    return displayXToRealX(displayX);
  }

  /// 將畫布繪製的x軸座標轉換為data的索引值
  @override
  int realXToDataIndex(double realX) {
    final displayX = realXToDisplayX(realX);
    return displayXToDataIndex(displayX);
  }

  /// 將data的索引值轉換為顯示的x軸座標(正中間)
  double dataIndexToDisplayX(int index) {
    final sizeSetting = chartUiStyle.sizeSetting;
    final leftPoint = -(totalDataWidth! + sizeSetting.rightSpace);
    final dataWidth = sizeSetting.dataWidth * chartGesture.scaleX;
    final dataPoint = dataWidth * index + (dataWidth / 2);
    return leftPoint + dataPoint;
  }

  /// 將顯示中的x轉化為資料的index
  int displayXToDataIndex(double displayX) {
    final sizeSetting = chartUiStyle.sizeSetting;
    final dataWidth = sizeSetting.dataWidth * chartGesture.scaleX;
    final leftPoint = -(totalDataWidth! + sizeSetting.rightSpace);
    final dataIndex = (displayX - leftPoint) ~/ dataWidth;
    if (dataIndex >= datas.length) {
      return datas.length - 1;
    } else if (dataIndex < 0) {
      return 0;
    }
    return dataIndex;
  }

  /// 將顯示中的x轉換為實際畫布上的x
  double displayXToRealX(double displayX) {
    return displayX - startDisplayX;
  }

  /// 將實際畫布的index轉換成顯示中的x
  double realXToDisplayX(double realX) {
    return -chartGesture.scrollX - (canvasWidth - realX);
  }

  /// 取得長案中的data index
  @override
  int? getLongPressDataIndex() {
    if (!chartGesture.isLongPress) {
      return null;
    }
    if (_longPressDataIndex != null) {
      return _longPressDataIndex;
    }
    if (datas.isEmpty) {
      return null;
    }
    final displayX = realXToDisplayX(chartGesture.longPressX);
    var index = displayXToDataIndex(displayX);
    index = index.clamp(startDataIndex, endDataIndex);
    _longPressDataIndex = index >= datas.length ? datas.length - 1 : index;
    return _longPressDataIndex;
  }

  /// 取得長按中的data
  @override
  KLineData? getLongPressData() {
    if (!chartGesture.isLongPress) {
      return null;
    }
    if (_longPressData != null) {
      return _longPressData;
    }
    final index = getLongPressDataIndex();
    if (index != null) {
      _longPressData = datas[index];
      return _longPressData;
    }
    return null;
  }
}
