import 'package:flutter/material.dart';

class BoggleGrid extends StatefulWidget {
  final List<String> letters;
  final List<int> highlightedPath;
  final bool isHighlightValid;
  final Function(List<int>)? onPathSelected;

  const BoggleGrid({
    super.key,
    required this.letters,
    this.highlightedPath = const [],
    this.isHighlightValid = true,
    this.onPathSelected,
  });

  @override
  State<BoggleGrid> createState() => _BoggleGridState();
}

class _BoggleGridState extends State<BoggleGrid> {
  List<int> _selectedPath = [];
  bool _isSelecting = false;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: GestureDetector(
        onPanStart: _handlePanStart,
        onPanUpdate: _handlePanUpdate,
        onPanEnd: _handlePanEnd,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.brown[100],
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.brown.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: 9,
            itemBuilder: (context, index) => _buildCell(index),
          ),
        ),
      ),
    );
  }

  Widget _buildCell(int index) {
    final isInPath = _selectedPath.contains(index);
    final isInHighlight = widget.highlightedPath.contains(index);
    final isSelected = isInPath || isInHighlight;

    Color cellColor;
    if (isInHighlight) {
      cellColor = widget.isHighlightValid ? Colors.green[300]! : Colors.red[300]!;
    } else if (isInPath) {
      cellColor = Colors.blue[300]!;
    } else {
      cellColor = Colors.amber[100]!;
    }

    return Container(
      key: ValueKey('cell_$index'),
      decoration: BoxDecoration(
        color: cellColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected ? Colors.brown[700]! : Colors.brown[400]!,
          width: isSelected ? 3 : 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.brown.withValues(alpha: 0.2),
            blurRadius: 2,
            offset: const Offset(1, 1),
          ),
        ],
      ),
      child: Center(
        child: Text(
          widget.letters[index],
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.brown[900],
          ),
        ),
      ),
    );
  }

  int? _getCellAtPosition(Offset position) {
    final RenderBox? box = context.findRenderObject() as RenderBox?;
    if (box == null) return null;

    final size = box.size;
    final cellWidth = (size.width - 16 - 16) / 3; // padding + spacing
    final cellHeight = (size.height - 16 - 16) / 3;

    final x = (position.dx - 8) / (cellWidth + 8);
    final y = (position.dy - 8) / (cellHeight + 8);

    if (x < 0 || x >= 3 || y < 0 || y >= 3) return null;

    final col = x.floor();
    final row = y.floor();

    return row * 3 + col;
  }

  bool _areAdjacent(int pos1, int pos2) {
    final row1 = pos1 ~/ 3;
    final col1 = pos1 % 3;
    final row2 = pos2 ~/ 3;
    final col2 = pos2 % 3;

    return (row1 - row2).abs() <= 1 && (col1 - col2).abs() <= 1;
  }

  void _handlePanStart(DragStartDetails details) {
    final cell = _getCellAtPosition(details.localPosition);
    if (cell != null) {
      setState(() {
        _isSelecting = true;
        _selectedPath = [cell];
      });
    }
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    if (!_isSelecting) return;

    final cell = _getCellAtPosition(details.localPosition);
    if (cell != null &&
        !_selectedPath.contains(cell) &&
        _areAdjacent(_selectedPath.last, cell)) {
      setState(() {
        _selectedPath.add(cell);
      });
    }
  }

  void _handlePanEnd(DragEndDetails details) {
    if (_isSelecting && _selectedPath.isNotEmpty) {
      widget.onPathSelected?.call(List.from(_selectedPath));
    }
    setState(() {
      _isSelecting = false;
      _selectedPath = [];
    });
  }
}
