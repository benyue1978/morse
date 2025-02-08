import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show listEquals;
import 'morse_node.dart';

class MorseTreePainter extends CustomPainter {
  static const double spacing = 60.0;
  static const double nodeSize = 12.0;

  final MorseNode root = MorseNode.buildTree();
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

    drawNode(canvas, root, size.width / 2, 50, size.width / 4, 
        normalPaint, highlightPaint, [], 0);
  }

  void drawNode(Canvas canvas, MorseNode node, double x, double y, double offset, 
      Paint normalPaint, Paint highlightPaint, List<String> currentPath, int depth) {
    final bool isHighlighted = highlightPath.isNotEmpty && 
        listEquals(currentPath, highlightPath);

    _drawNodeValue(canvas, node, x, y, isHighlighted);
    _drawBranches(canvas, node, x, y, offset, normalPaint, highlightPaint, 
        currentPath, depth);
  }

  void _drawNodeValue(Canvas canvas, MorseNode node, double x, double y, 
      bool isHighlighted) {
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
      textPainter.paint(canvas, 
          Offset(x - textPainter.width / 2, y - textPainter.height / 2));
    }
  }

  void _drawBranches(Canvas canvas, MorseNode node, double x, double y, 
      double offset, Paint normalPaint, Paint highlightPaint, 
      List<String> currentPath, int depth) {
    if (node.left != null) {
      _drawLeftBranch(canvas, node, x, y, offset, normalPaint, highlightPaint, 
          currentPath, depth);
    }
    if (node.right != null) {
      _drawRightBranch(canvas, node, x, y, offset, normalPaint, highlightPaint, 
          currentPath, depth);
    }
  }

  void _drawLeftBranch(Canvas canvas, MorseNode node, double x, double y, 
      double offset, Paint normalPaint, Paint highlightPaint, 
      List<String> currentPath, int depth) {
    final nextPath = [...currentPath, 'dit'];
    final bool isNextHighlighted = highlightPath.isNotEmpty && 
        highlightPath.length > currentPath.length &&
        listEquals(nextPath, highlightPath.sublist(0, nextPath.length));
    
    canvas.drawLine(
      Offset(x, y), 
      Offset(x - offset, y + spacing),
      isNextHighlighted ? highlightPaint : normalPaint,
    );
    canvas.drawCircle(
      Offset(x - offset, y + spacing),
      nodeSize,
      isNextHighlighted ? highlightPaint : normalPaint,
    );
    drawNode(canvas, node.left!, x - offset, y + spacing, offset / 2,
        normalPaint, highlightPaint, nextPath, depth + 1);
  }

  void _drawRightBranch(Canvas canvas, MorseNode node, double x, double y, 
      double offset, Paint normalPaint, Paint highlightPaint, 
      List<String> currentPath, int depth) {
    final nextPath = [...currentPath, 'dah'];
    final bool isNextHighlighted = highlightPath.isNotEmpty && 
        highlightPath.length > currentPath.length &&
        listEquals(nextPath, highlightPath.sublist(0, nextPath.length));
    
    canvas.drawLine(
      Offset(x, y), 
      Offset(x + offset, y + spacing),
      isNextHighlighted ? highlightPaint : normalPaint,
    );
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

  @override
  bool shouldRepaint(covariant MorseTreePainter oldDelegate) {
    return oldDelegate.highlightPath != highlightPath;
  }
} 