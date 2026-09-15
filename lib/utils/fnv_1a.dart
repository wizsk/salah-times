int fnv1aHash(String input) {
  const int prime = 0x01000193; // FNV prime
  int hash = 0x811c9dc5; // FNV offset basis
  for (final byte in input.codeUnits) {
    hash ^= byte;
    hash = (hash * prime) & 0xFFFFFFFF;
  }
  return hash;
}
