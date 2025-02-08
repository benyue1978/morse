class MorseNode {
  final String value;
  MorseNode? left;  // dit (.)
  MorseNode? right; // dah (-)

  MorseNode(this.value);

  static MorseNode buildTree() {
    final root = MorseNode('');
    
    // 第一层
    root.left = MorseNode('E');
    root.right = MorseNode('T');

    // E 分支 (.)
    root.left!.left = MorseNode('I');
    root.left!.right = MorseNode('A');
    
    // T 分支 (-)
    root.right!.left = MorseNode('N');
    root.right!.right = MorseNode('M');

    // I 分支 (..)
    root.left!.left!.left = MorseNode('S');
    root.left!.left!.right = MorseNode('U');

    // A 分支 (.-)
    root.left!.right!.left = MorseNode('R');
    root.left!.right!.right = MorseNode('W');

    // N 分支 (-.)
    root.right!.left!.left = MorseNode('D');
    root.right!.left!.right = MorseNode('K');

    // M 分支 (--)
    root.right!.right!.left = MorseNode('G');
    root.right!.right!.right = MorseNode('O');

    // 继续添加更多层...
    // S 分支 (...)
    root.left!.left!.left!.left = MorseNode('H');
    root.left!.left!.left!.right = MorseNode('V');

    // U 分支 (..-）
    root.left!.left!.right!.left = MorseNode('F');
    
    // R 分支 (.-)
    root.left!.right!.left!.left = MorseNode('L');
    
    // W 分支 (.--)
    root.left!.right!.right!.left = MorseNode('P');
    root.left!.right!.right!.right = MorseNode('J');

    // D 分支 (-..)
    root.right!.left!.left!.left = MorseNode('B');
    root.right!.left!.left!.right = MorseNode('X');

    // K 分支 (-.-)
    root.right!.left!.right!.left = MorseNode('C');
    root.right!.left!.right!.right = MorseNode('Y');

    // G 分支 (--.)
    root.right!.right!.left!.left = MorseNode('Z');
    root.right!.right!.left!.right = MorseNode('Q');

    return root;
  }
} 