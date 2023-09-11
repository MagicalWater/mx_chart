/// marker的模式
enum MarkerMode {
  /// 新增模式
  add,

  /// 編輯模式
  edit,

  /// 瀏覽模式(只可瀏覽不可點擊)
  view,

  /// 預備進入編輯模式的瀏覽模式(此時若點擊Marker路徑或者錨點會轉換成編輯模式)
  editableView,
}

extension MarkerModeExtension on MarkerMode {
  bool get isAdd => this == MarkerMode.add;

  bool get isEdit => this == MarkerMode.edit;

  bool get isView => this == MarkerMode.view;
}