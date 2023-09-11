import 'package:flutter/material.dart';
import 'package:mx_chart/mx_chart.dart';
import 'package:mx_chart_example/k_chart/view/k_chart_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int index = 0;

  Path? path;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: KChartPage(),
      // home: Scaffold(
      //   body: Padding(
      //     padding: const EdgeInsets.all(8.0),
      //     child: GestureDetector(
      //       behavior: HitTestBehavior.deferToChild,
      //       // onTap: () {
      //       //   print('點擊: ${index++}');
      //       // },
      //       onTapDown: (details) {
      //         final isContain = path?.contains(details.localPosition);
      //         print('點擊: ${index++}, isContain: $isContain');
      //       },
      //       child: SizedBox(
      //         width: 200,
      //         height: 200,
      //         // color: Colors.red,
      //         child: CustomPaint(
      //           size: const Size(200, 200),
      //           painter: CustomPathPainter(
      //             (value) {
      //               path = value;
      //             },
      //           ),
      //         ),
      //       ),
      //     ),
      //   ),
      // ),
    );
  }
}

class CustomPathPainter extends CustomPainter {
  final ValueChanged<Path>? onPathReady;

  CustomPathPainter(this.onPathReady);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final path1 = ReversiblePath();

    // path1.arcTo(Rect.fromLTWH(0, 0, 50, 100), pi * 4, pi, true);
    path1.moveTo(0, 30);
    path1.lineTo(100, 30);
    path1.lineTo(100, 100);
    path1.lineTo(0, 100);
    // path1.close();

    final path2 = path1.reverse().shift(const Offset(0, 0));
    final path3 = path1.shift(const Offset(0, -30));

    // canvas.drawPath(path3, paint);
    // final metrics = ;
    // for (var element in metrics) {
    //   print('線條長度: ${element.length}');
    //   final subPath2 = element.extractPath(0, 20, startWithMoveTo: false);
    //   canvas.drawPath(subPath2, paint);
    // }

    path3.extendWithPath(path2, Offset.zero);

    // path1.moveTo(0, 100);
    //
    // path1.close();

    canvas.drawPath(path3, paint);

    onPathReady?.call(path3);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
