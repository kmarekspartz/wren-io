class Regex {}

class Error {
  static call {
    Fiber.abort(this.name)
  }
}

class NotImplementedError is Error {}


// Abstract Syntax Tree:

class RegexASTNode {
  to_nfa { NotImplementedError() }
}

class BinaryOperator is RegexASTNode {
  new(left, right) {
    _left = left
    _right = right
  }
}

class Alternative is BinaryOperator {
  to_nfa {
    _left.to_nfa.alternative(_right.to_nfa)
  }
}

class UnaryOperator is RegexASTNode {
  new(item) {
    _item = item
  }
}

class Star is UnaryOperator {
  to_nfa {
    _item.to_nfa.star
  }
}

class Plus is UnaryOperator {
  to_nfa {
    _item.to_nfa.plus
  }
}

class Optional is UnaryOperator {
  to_nfa {
    _item.to_nfa.optional
  }
}


// Finite State Automata:

class FSA {}

class Vertex {}

class Edge {}


// Non-deterministic FSA

class NFA is FSA {
  to_dfa {}
}

class NFAVertex is Vertex {}

class NFAEdge is Edge {}


// Deterministic FSA

class DFA is FSA {}

class DFAVertex is Vertex {}

class DFAEdge is Edge {}
