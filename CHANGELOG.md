## 2.1.3+1
- Adjusted behavior for when long press is disabled. If the current state is already in a disabled long press state, onLongPressCancel() will not be triggered again.

KLineChartController:
- Added parameter markerState to retrieve current marker-related state.

## 2.1.2+1
KLineChartController:
- Added variable `hasClient` to indicate whether it is already bound to the view.
- Modified all methods below to return a `bool` indicating the success of execution.

## 2.1.2+1
KLineChartController:
- Added variable `hasClient` to indicate whether it is already bound to the view.
- Modified all methods below to return a `bool` indicating the success of execution.

## 2.1.1+2
- Add parameter onMarkerModeChanged: Callback triggered when the Marker mode is changed.

## 2.1.0+1
- New Feature: Chart Marker

## 2.0.3+1
- KLineDataInfoTooltip adds a variable layoutBuilder

## 2.0.2+1
- Fixed the wrong y-axis position of long press when the position of the main chart is not at the first

## 2.0.1+1
- dart sdk: update to '>=2.19.0 <3.0.0' 
- package: intl update to ^0.18.0

## 2.0.0+3
- Fixed an error in calculating technical indicators when oriData is empty 

## 2.0.0+2
- Fixed the disappearance of the dividing line in the value block on the right

## 2.0.0+1
- Remove the componentSort parameter, use layoutBuilder for custom component sorting.

- Separate all components, easy to adjust the position and insert components.

## 1.1.0+3
- RSIChartUiStyle, WRChartUiStyle adds copyWith method

## 1.1.0+2
- MainChartUiStyle adds copyWith method

## 1.1.0+1
- Variable renaming
  * Rename the 'scrollBar' to 'dragBar' to highlight the meaning of dragging the Bar.
  * Rename 'bottomTime' to 'timeline', because the timeline that can be sorted by the component is not necessarily at the bottom.

- Add 'bottomDivider' and 'topDivider' to the size and color settings of the chart.
- Add 'componentSort' to set the component sorting of the chart.
- Add the 'dragBar' variable to indicate whether to display the drag bar.
- Add 'gridEnabled' at uiStyle of all components to set whether to display the grid.

## 1.0.7+1
- Added MainChartState.none, which means hidden.
- Added grid line stroke setting.
- Fixed the problem that the height proportional dragging bar was not centered.
- Added the color setting of the top line of the timeline.
- Fixed the problem that volumeFormatter was invalid.

## 1.0.6+1
- Add web platform support.

## 1.0.5+1
- Fix init error in some case.

## 1.0.4+1
- Fix Tooltip 'Change Value' value error.  

## 1.0.3+1
- Add param 'coverExist' to indicator calculate method

## 1.0.2+1
- Add indicator calculate Add Last Method

## 1.0.1+2
- Fix KDJ indicator calculate no apply period.

## 1.0.1+1
- Tech Indicator Calculator separate.

## 1.0.0+1

- K-line Chart init version(from [Base-APP-Core](https://github.com/MagicalWater/Base-APP-Core))
