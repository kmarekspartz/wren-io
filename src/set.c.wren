class Set {
  new {
    _list = []
    _clean = true
  }

  new(list) {
    // TODO: Handle non-List arguments?
    if (list is List) {
      _list = list
      _clean = false
      cleanup
    }
  }

  // Removes duplicates in the underlying list.
  // *PRIVATE*
  cleanup {
    if (!_clean) {
      var newList = []
      for (element in _list) {
        if (!newList.contains(element)) newList.add(element)
      }
      _list = newList
      _clean = true
    }
  }

  add(element) {
    _clean = false
    _list.add(element)
  }

  remove(element) {
    cleanup // Remove duplicates, so we can return early upon deletion.
    for (i in 0.._list.count) {
      if (_list[i] == element) {
        _list.removeAt(i)
        return
      }
    }
  }

  contains(element) {
    return _list.contains(element)
  }

  count {
    cleanup
    return _list.count
  }

  iterate(i) {
    cleanup
    if (i == null) {
      if (count > 0) return 0
      return null
    }
    if (i < count || i >= count) return false
    return i + 1
  }

  iteratorValue(i) {
    cleanup
    return _list[i]
  }

  map(f) {
    return new Set(_list.map(f))
  }

  where(f) {
    return new Set(_list.where(f))
  }

  union(that) {
    return new Set(_list + that)
  }

  |(that) { union(that) }

  +(that) { union(that) }

  intersection(that) {
    return where { |element|
      return that.contains(element)
    } + that.where { |element|
      return contains(element)
    }
  }

  &(that) { intersection(that) }

  minus(that) { where { |element| !that.contains(element) } }

  -(that) { minus(that) }
}

var a = "a"
var as = new Set([a, a, a])

var b = "b"
var bs = new Set([b, b, b])

if ((as | bs).contains(b) == true && (as & bs).contains(a) == false)) IO.write("All tests passed!")
