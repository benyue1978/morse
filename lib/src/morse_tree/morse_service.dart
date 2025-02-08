import 'morse_node.dart';

class MorseService {
  static const int timeUnit = 200;
  final MorseNode _root = MorseNode.buildTree();

  List<String> findPath(String target) {
    List<String> path = [];
    
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
    
    search(_root, []);
    return path;
  }
} 