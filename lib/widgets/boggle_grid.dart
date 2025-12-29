import 'dart:math';

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

  int get gridSize => sqrt(letters.length).round();

  @override
  State<BoggleGrid> createState() => _BoggleGridState();
}

class _BoggleGridState extends State<BoggleGrid> {
  List<int> _selectedPath = [];
  final Map<int, GlobalKey> _cellKeys = {};
  bool _isDragging = false;
  Offset? _panStartPosition;
  int? _panStartCell;
  static const double _dragThreshold = 10.0; // Distance minimale pour considérer un drag

  int get _gridSize => widget.gridSize;

  @override
  void initState() {
    super.initState();
    // Créer les clés pour chaque cellule
    for (int i = 0; i < widget.letters.length; i++) {
      _cellKeys[i] = GlobalKey();
    }
  }

  bool _areAdjacent(int pos1, int pos2) {
    final row1 = pos1 ~/ _gridSize;
    final col1 = pos1 % _gridSize;
    final row2 = pos2 ~/ _gridSize;
    final col2 = pos2 % _gridSize;

    return (row1 - row2).abs() <= 1 && (col1 - col2).abs() <= 1;
  }

  // Vérifie si un point est dans la zone centrale (1/3) d'une cellule
  int? _getCellAtPosition(Offset globalPosition) {
    for (int i = 0; i < widget.letters.length; i++) {
      final key = _cellKeys[i];
      if (key?.currentContext != null) {
        final RenderBox box = key!.currentContext!.findRenderObject() as RenderBox;
        final cellPosition = box.localToGlobal(Offset.zero);
        final cellSize = box.size;

        // Zone centrale = 1/3 de la cellule au milieu
        final centerZoneSize = cellSize.width / 3;
        final centerOffset = (cellSize.width - centerZoneSize) / 2;

        final centerRect = Rect.fromLTWH(
          cellPosition.dx + centerOffset,
          cellPosition.dy + centerOffset,
          centerZoneSize,
          centerZoneSize,
        );

        if (centerRect.contains(globalPosition)) {
          return i;
        }
      }
    }
    return null;
  }

  void _onPanStart(DragStartDetails details) {
    _panStartPosition = details.globalPosition;
    _panStartCell = _getCellAtPositionAnywhere(details.globalPosition);
    _isDragging = false;

    // Si on a déjà un path et qu'on démarre sur une case du path ou adjacente
    if (_selectedPath.isNotEmpty && _panStartCell != null) {
      if (_panStartCell == _selectedPath.last) {
        // On démarre depuis la dernière case du path - prêt à continuer en drag
        _isDragging = true;
      } else if (_selectedPath.contains(_panStartCell!)) {
        // On démarre depuis une case déjà dans le path - revenir en arrière
        _isDragging = true;
        setState(() {
          final idx = _selectedPath.indexOf(_panStartCell!);
          _selectedPath = _selectedPath.sublist(0, idx + 1);
        });
      } else if (_areAdjacent(_selectedPath.last, _panStartCell!)) {
        // On démarre depuis une case adjacente - ajouter et continuer en drag
        _isDragging = true;
        setState(() {
          _selectedPath.add(_panStartCell!);
        });
      }
    }
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_panStartPosition == null) return;

    final distance = (details.globalPosition - _panStartPosition!).distance;

    // Si on a bougé suffisamment, c'est un drag
    if (!_isDragging && distance > _dragThreshold) {
      _isDragging = true;
      // Commencer le drag depuis la cellule de départ (zone centrale)
      final startCell = _getCellAtPosition(_panStartPosition!);
      if (startCell != null && _selectedPath.isEmpty) {
        setState(() {
          _selectedPath = [startCell];
        });
      }
    }

    if (_isDragging) {
      final cellIndex = _getCellAtPosition(details.globalPosition);
      if (cellIndex != null) {
        setState(() {
          // Si la cellule est déjà dans le chemin (mais pas la dernière), on revient en arrière
          if (_selectedPath.contains(cellIndex)) {
            final idx = _selectedPath.indexOf(cellIndex);
            if (idx < _selectedPath.length - 1) {
              _selectedPath = _selectedPath.sublist(0, idx + 1);
            }
            return;
          }

          // Ajouter si adjacent à la dernière cellule
          if (_selectedPath.isNotEmpty && _areAdjacent(_selectedPath.last, cellIndex)) {
            _selectedPath.add(cellIndex);
          }
        });
      }
    }
  }

  void _onPanEnd(DragEndDetails details) {
    final wasDragging = _isDragging;
    _isDragging = false;

    if (!wasDragging) {
      // C'était un tap - traiter comme un clic
      if (_panStartCell != null) {
        _onCellTap(_panStartCell!);
      }
    }
    // On garde le path pour valider avec le bouton vert

    _panStartPosition = null;
    _panStartCell = null;
  }

  // Trouve la cellule à une position (toute la cellule, pas juste le centre)
  int? _getCellAtPositionAnywhere(Offset globalPosition) {
    for (int i = 0; i < widget.letters.length; i++) {
      final key = _cellKeys[i];
      if (key?.currentContext != null) {
        final RenderBox box = key!.currentContext!.findRenderObject() as RenderBox;
        final cellPosition = box.localToGlobal(Offset.zero);
        final cellSize = box.size;

        final cellRect = Rect.fromLTWH(
          cellPosition.dx,
          cellPosition.dy,
          cellSize.width,
          cellSize.height,
        );

        if (cellRect.contains(globalPosition)) {
          return i;
        }
      }
    }
    return null;
  }

  @override
  void didUpdateWidget(BoggleGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Quand le highlightedPath change, effacer notre sélection locale
    if (widget.highlightedPath != oldWidget.highlightedPath) {
      _selectedPath = [];
    }
  }

  void _onCellTap(int index) {
    // Le tap fonctionne sur toute la case (pas de zone centrale)
    setState(() {
      // Si la cellule est déjà dans le chemin, on la désélectionne (et tout ce qui suit)
      if (_selectedPath.contains(index)) {
        final idx = _selectedPath.indexOf(index);
        _selectedPath = _selectedPath.sublist(0, idx); // Exclure cette case
        return;
      }

      // Si le chemin est vide, on commence
      if (_selectedPath.isEmpty) {
        _selectedPath = [index];
        return;
      }

      // Sinon, on ajoute si adjacent
      if (_areAdjacent(_selectedPath.last, index)) {
        _selectedPath.add(index);
      }
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedPath = [];
    });
  }

  void _submitWord() {
    if (_selectedPath.length >= 3) {
      final pathToSubmit = List<int>.from(_selectedPath);
      setState(() {
        _selectedPath = [];
      });
      widget.onPathSelected?.call(pathToSubmit);
    }
    // Si moins de 3 lettres, on ne fait rien (on garde la sélection)
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculer la taille de la grille (carrée, max possible)
        final availableHeight = constraints.maxHeight;
        final availableWidth = constraints.maxWidth;
        final gridSize = min(availableHeight, availableWidth);

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Grille carrée avec gestion du drag et tap
            GestureDetector(
              onPanStart: _onPanStart,
              onPanUpdate: _onPanUpdate,
              onPanEnd: _onPanEnd,
              child: SizedBox(
                width: gridSize,
                height: gridSize,
                child: Container(
                  padding: const EdgeInsets.all(6),
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
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: _gridSize,
                      crossAxisSpacing: 6,
                      mainAxisSpacing: 6,
                    ),
                    itemCount: _gridSize * _gridSize,
                    itemBuilder: (context, index) => _buildCell(index),
                  ),
                ),
              ),
            ),
            // Boutons valider/annuler en bas de la grille (espace toujours réservé)
            const SizedBox(height: 20),
            Opacity(
              opacity: _selectedPath.isNotEmpty ? 1.0 : 0.0,
              child: IgnorePointer(
                ignoring: _selectedPath.isEmpty,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Bouton valider (check vert)
                    GestureDetector(
                      onTap: _submitWord,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.green[500],
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.green.withValues(alpha: 0.4),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 48,
                        ),
                      ),
                    ),
                    const SizedBox(width: 40),
                    // Bouton annuler (croix rouge)
                    GestureDetector(
                      onTap: _clearSelection,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.red[500],
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red.withValues(alpha: 0.4),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 48,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCell(int index) {
    final isInPath = _selectedPath.contains(index);
    final isLastInPath =
        _selectedPath.isNotEmpty && _selectedPath.last == index;
    final isInHighlight = widget.highlightedPath.contains(index);
    final isSelected = isInPath || isInHighlight;

    // Numéro dans le chemin
    final pathIndex = _selectedPath.indexOf(index);

    Color cellColor;
    if (isInHighlight) {
      cellColor = widget.isHighlightValid
          ? Colors.green[300]!
          : Colors.red[300]!;
    } else if (isLastInPath) {
      cellColor = Colors.blue[400]!;
    } else if (isInPath) {
      cellColor = Colors.blue[200]!;
    } else {
      cellColor = Colors.amber[100]!;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final cellSize = constraints.maxWidth;
        final fontSize = cellSize * 0.5;

        return Container(
            key: _cellKeys[index],
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
            child: Stack(
              children: [
                Center(
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: Text(
                      widget.letters[index],
                      style: TextStyle(
                        fontSize: fontSize,
                        fontWeight: FontWeight.bold,
                        color: Colors.brown[900],
                      ),
                    ),
                  ),
                ),
                // Numéro de position dans le chemin
                if (isInPath && pathIndex >= 0)
                  Positioned(
                    top: 2,
                    right: 2,
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        color: Colors.blue[700],
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${pathIndex + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
        );
      },
    );
  }
}
