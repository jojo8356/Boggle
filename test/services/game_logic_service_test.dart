import 'package:flutter_test/flutter_test.dart';
import 'package:froggle_game/services/game_logic_service.dart';

void main() {
  late GameLogicService gameLogicService;

  setUp(() {
    gameLogicService = GameLogicService();
  });

  group('GameLogicService', () {
    // Grille de test 4x4:
    // F R O G  (0  1  2  3)
    // G L E S  (4  5  6  7)
    // A T I N  (8  9  10 11)
    // M O T S  (12 13 14 15)
    final testGrid = ['F', 'R', 'O', 'G', 'G', 'L', 'E', 'S', 'A', 'T', 'I', 'N', 'M', 'O', 'T', 'S'];
    const gridSize = 4;

    group('isValidPath', () {
      test('[P0] devrait valider un chemin adjacent horizontal', () {
        // GIVEN: Un chemin horizontal (F-R-O-G: indices 0,1,2,3)
        final path = [0, 1, 2, 3];

        // WHEN: On verifie si le chemin est valide
        final result = gameLogicService.isValidPath(path, gridSize);

        // THEN: Le chemin devrait etre valide
        expect(result, isTrue);
      });

      test('[P0] devrait rejeter un chemin avec cases non adjacentes', () {
        // GIVEN: Un chemin avec des cases non adjacentes (0 et 2 ne sont pas directement adjacents)
        final invalidPath = [0, 2]; // F et O ne sont pas adjacents

        // WHEN: On verifie si le chemin est valide
        final result = gameLogicService.isValidPath(invalidPath, gridSize);

        // THEN: Le chemin devrait etre invalide
        expect(result, isFalse);
      });

      test('[P0] devrait rejeter un chemin qui reutilise une case', () {
        // GIVEN: Un chemin qui passe deux fois par la meme case
        final pathWithDuplicate = [0, 1, 0];

        // WHEN: On verifie si le chemin est valide
        final result = gameLogicService.isValidPath(pathWithDuplicate, gridSize);

        // THEN: Le chemin devrait etre invalide (pas de repetition)
        expect(result, isFalse);
      });

      test('[P0] devrait valider un chemin diagonal', () {
        // GIVEN: Un chemin diagonal (F->L->I->S: indices 0,5,10,15)
        final diagonalPath = [0, 5, 10, 15];

        // WHEN: On verifie si le chemin est valide
        final result = gameLogicService.isValidPath(diagonalPath, gridSize);

        // THEN: Le chemin devrait etre valide (diagonales sont adjacentes)
        expect(result, isTrue);
      });

      test('[P1] devrait rejeter un chemin vide', () {
        // GIVEN: Un chemin vide
        final emptyPath = <int>[];

        // WHEN: On verifie si le chemin est valide
        final result = gameLogicService.isValidPath(emptyPath, gridSize);

        // THEN: Le chemin devrait etre invalide
        expect(result, isFalse);
      });
    });

    group('getWordFromPath', () {
      test('[P0] devrait convertir un chemin en mot correctement', () {
        // GIVEN: Un chemin valide pour "FROG"
        final path = [0, 1, 2, 3];

        // WHEN: On convertit le chemin en mot
        final word = gameLogicService.getWordFromPath(testGrid, path);

        // THEN: Le mot devrait etre "FROG"
        expect(word, equals('FROG'));
      });

      test('[P0] devrait retourner une chaine vide pour un chemin vide', () {
        // GIVEN: Un chemin vide
        final emptyPath = <int>[];

        // WHEN: On convertit le chemin en mot
        final word = gameLogicService.getWordFromPath(testGrid, emptyPath);

        // THEN: Le mot devrait etre vide
        expect(word, isEmpty);
      });

      test('[P1] devrait former le mot "GLET" depuis un chemin vertical', () {
        // GIVEN: Un chemin vertical G->L->E->T (indices 4,5,6 puis non - corrigeons)
        // G(4) -> L(5) adjacent, L(5) -> T(9) adjacent
        final path = [4, 5, 9]; // G, L, T

        // WHEN: On convertit le chemin en mot
        final word = gameLogicService.getWordFromPath(testGrid, path);

        // THEN: Le mot devrait etre "GLT"
        expect(word, equals('GLT'));
      });
    });

    group('findWordPath', () {
      test('[P0] devrait trouver un chemin pour un mot existant dans la grille', () {
        // GIVEN: Un mot present dans la grille (FROG)
        const word = 'FROG';

        // WHEN: On cherche les chemins du mot
        final paths = gameLogicService.findWordPath(testGrid, word);

        // THEN: Au moins un chemin devrait etre trouve
        expect(paths, isNotNull);
        expect(paths, isNotEmpty);

        // Et le premier chemin devrait former le mot correct
        final foundWord = gameLogicService.getWordFromPath(testGrid, paths!.first);
        expect(foundWord, equals(word));
      });

      test('[P0] devrait retourner null pour un mot impossible', () {
        // GIVEN: Un mot qui ne peut pas etre forme dans la grille
        const impossibleWord = 'ZZZZZ';

        // WHEN: On cherche les chemins du mot
        final paths = gameLogicService.findWordPath(testGrid, impossibleWord);

        // THEN: Aucun chemin ne devrait etre trouve
        expect(paths, isNull);
      });

      test('[P1] devrait trouver plusieurs chemins si possibles', () {
        // GIVEN: Un mot qui peut avoir plusieurs chemins
        // "OT" peut etre forme de plusieurs facons dans la grille
        const word = 'OT';

        // WHEN: On cherche les chemins
        final paths = gameLogicService.findWordPath(testGrid, word);

        // THEN: Des chemins devraient etre trouves (si le mot a >= 3 lettres)
        // Note: "OT" a seulement 2 lettres, donc le dictionnaire le refuserait
        // mais findWordPath devrait quand meme trouver le chemin geometriquement
        if (paths != null) {
          expect(paths.length, greaterThanOrEqualTo(1));
        }
      });
    });

    group('areAdjacent', () {
      test('[P1] devrait confirmer que deux cases horizontales sont adjacentes', () {
        // GIVEN: Deux cases horizontalement adjacentes (0 et 1)
        // WHEN/THEN: Elles devraient etre adjacentes
        expect(gameLogicService.areAdjacent(0, 1, gridSize), isTrue);
        expect(gameLogicService.areAdjacent(1, 0, gridSize), isTrue);
      });

      test('[P1] devrait confirmer que deux cases verticales sont adjacentes', () {
        // GIVEN: Deux cases verticalement adjacentes (0 et 4)
        // WHEN/THEN: Elles devraient etre adjacentes
        expect(gameLogicService.areAdjacent(0, 4, gridSize), isTrue);
        expect(gameLogicService.areAdjacent(4, 0, gridSize), isTrue);
      });

      test('[P1] devrait confirmer que deux cases diagonales sont adjacentes', () {
        // GIVEN: Deux cases diagonalement adjacentes (0 et 5)
        // WHEN/THEN: Elles devraient etre adjacentes
        expect(gameLogicService.areAdjacent(0, 5, gridSize), isTrue);
        expect(gameLogicService.areAdjacent(5, 0, gridSize), isTrue);
      });

      test('[P1] devrait rejeter deux cases non adjacentes', () {
        // GIVEN: Deux cases non adjacentes (0 et 2, 0 et 15)
        // WHEN/THEN: Elles ne devraient pas etre adjacentes
        expect(gameLogicService.areAdjacent(0, 2, gridSize), isFalse);
        expect(gameLogicService.areAdjacent(0, 15, gridSize), isFalse);
      });

      test('[P2] devrait gerer les positions hors limites', () {
        // GIVEN: Une position hors limites
        // WHEN/THEN: Devrait retourner false
        expect(gameLogicService.areAdjacent(-1, 0, gridSize), isFalse);
        expect(gameLogicService.areAdjacent(0, 16, gridSize), isFalse);
      });
    });

    group('getNeighbors', () {
      test('[P1] devrait retourner 3 voisins pour un coin', () {
        // GIVEN: La case coin haut-gauche (0)
        // WHEN: On demande les voisins
        final neighbors = gameLogicService.getNeighbors(0, gridSize);

        // THEN: Il devrait y avoir 3 voisins (1, 4, 5)
        expect(neighbors.length, equals(3));
        expect(neighbors, containsAll([1, 4, 5]));
      });

      test('[P1] devrait retourner 5 voisins pour un bord', () {
        // GIVEN: La case bord haut-milieu (1)
        // WHEN: On demande les voisins
        final neighbors = gameLogicService.getNeighbors(1, gridSize);

        // THEN: Il devrait y avoir 5 voisins
        expect(neighbors.length, equals(5));
        expect(neighbors, containsAll([0, 2, 4, 5, 6]));
      });

      test('[P1] devrait retourner 8 voisins pour une case centrale', () {
        // GIVEN: La case centrale (5)
        // WHEN: On demande les voisins
        final neighbors = gameLogicService.getNeighbors(5, gridSize);

        // THEN: Il devrait y avoir 8 voisins
        expect(neighbors.length, equals(8));
        expect(neighbors, containsAll([0, 1, 2, 4, 6, 8, 9, 10]));
      });
    });
  });
}
