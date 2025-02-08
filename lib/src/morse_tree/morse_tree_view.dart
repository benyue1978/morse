import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show listEquals;
import 'morse_node.dart';

class MorseTreeView extends StatefulWidget {
  const MorseTreeView({super.key});

  @override
  State<MorseTreeView> createState() => _MorseTreeViewState();
}

class _MorseTreeViewState extends State<MorseTreeView> with SingleTickerProviderStateMixin {
  List<String> highlightPath = [];
  String currentLetter = '';
  String currentMorse = '';
  static const timeUnit = 200; // 一个时间单位为200毫秒

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: FocusNode()..requestFocus(),
      onKeyEvent: (event) {
        if (event is KeyDownEvent) {
          final key = event.logicalKey.keyLabel.toUpperCase();
          final path = findMorsePath(key);
          if (path.isNotEmpty) {
            setState(() {
              currentLetter = key;
              currentMorse = '';
            });
            _animateHighlight(path);
          }
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: const Text('莫尔斯电码', style: TextStyle(color: Colors.white)),
        ),
        body: Column(
          children: [
            Expanded(
              child: Center(
                child: CustomPaint(
                  painter: MorseTreePainter(highlightPath: highlightPath),
                  size: const Size(1200, 800),
                ),
              ),
            ),
            Container(
              height: 80,  // 固定高度
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(  // 固定宽度的容器
                    width: 120,
                    child: Text(
                      '按键: $currentLetter',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 40),
                  SizedBox(  // 固定宽度的容器
                    width: 200,
                    child: Text(
                      '摩斯码: $currentMorse',
                      style: const TextStyle(
                        color: Colors.amber,
                        fontSize: 24,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _animateHighlight(List<String> path) {
    setState(() {
      highlightPath = [];
      currentMorse = '';
    });
    
    for (int i = 0; i < path.length; i++) {
      Future.delayed(Duration(milliseconds: i * timeUnit * 2), () {
        setState(() {
          highlightPath = path.sublist(0, i + 1);
          currentMorse += path[i] == 'dit' ? '.' : '-';
        });
      });
    }

    // 清除高亮
    Future.delayed(Duration(milliseconds: path.length * timeUnit * 2 + timeUnit), () {
      setState(() => highlightPath = []);
    });
  }

  List<String> findMorsePath(String target) {
    List<String> path = [];
    MorseNode? current = MorseNode.buildTree();
    
    void search(MorseNode? node, List<String> currentPath) {
      if (node == null) return;
      if (node.value == target) {
        path = List.from(currentPath);
        return;
      }
      
      currentPath.add('dit');
      search(node.left, currentPath);
      currentPath.removeLast();
      
      currentPath.add('dah');
      search(node.right, currentPath);
      currentPath.removeLast();
    }
    
    search(current, []);
    return path;
  }
}

class MorseTreePainter extends CustomPainter {
  final MorseNode root = MorseNode.buildTree();
  static const double spacing = 60.0;
  static const double nodeSize = 12.0;
  final List<String> highlightPath;

  MorseTreePainter({this.highlightPath = const []});

  @override
  void paint(Canvas canvas, Size size) {
    final normalPaint = Paint()
      ..color = Colors.grey[600]!
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final highlightPaint = Paint()
      ..color = Colors.amber
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    drawNode(canvas, root, size.width / 2, 50, size.width / 4, normalPaint, highlightPaint, [], 0);
  }

  void drawNode(Canvas canvas, MorseNode node, double x, double y, double offset, 
      Paint normalPaint, Paint highlightPaint, List<String> currentPath, int depth) {
    // 只有当前路径完全匹配时才高亮
    final bool isHighlighted = highlightPath.isNotEmpty && 
        listEquals(currentPath, highlightPath);

    // 绘制字母
    if (node.value.isNotEmpty) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: node.value,
          style: TextStyle(
            color: isHighlighted ? Colors.amber : Colors.grey[400],
            fontSize: 14,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(x - textPainter.width / 2, y - textPainter.height / 2));
    }

    // 绘制左分支
    if (node.left != null) {
      final nextPath = [...currentPath, 'dit'];
      final bool isNextHighlighted = highlightPath.isNotEmpty && 
          highlightPath.length > currentPath.length &&
          listEquals(nextPath, highlightPath.sublist(0, nextPath.length));
      
      canvas.drawLine(Offset(x, y), Offset(x - offset, y + spacing), 
          isNextHighlighted ? highlightPaint : normalPaint);
      canvas.drawCircle(
        Offset(x - offset, y + spacing),
        nodeSize,
        isNextHighlighted ? highlightPaint : normalPaint,
      );
      drawNode(canvas, node.left!, x - offset, y + spacing, offset / 2, 
          normalPaint, highlightPaint, nextPath, depth + 1);
    }

    // 绘制右分支
    if (node.right != null) {
      final nextPath = [...currentPath, 'dah'];
      final bool isNextHighlighted = highlightPath.isNotEmpty && 
          highlightPath.length > currentPath.length &&
          listEquals(nextPath, highlightPath.sublist(0, nextPath.length));
      
      canvas.drawLine(Offset(x, y), Offset(x + offset, y + spacing), 
          isNextHighlighted ? highlightPaint : normalPaint);
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset(x + offset, y + spacing),
          width: nodeSize * 2,
          height: nodeSize,
        ),
        isNextHighlighted ? highlightPaint : normalPaint,
      );
      drawNode(canvas, node.right!, x + offset, y + spacing, offset / 2,
          normalPaint, highlightPaint, nextPath, depth + 1);
    }
  }

  @override
  bool shouldRepaint(covariant MorseTreePainter oldDelegate) {
    return oldDelegate.highlightPath != highlightPath;
  }
} 