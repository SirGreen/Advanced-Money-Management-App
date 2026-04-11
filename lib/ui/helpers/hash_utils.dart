/// Stable hash function to generate a 32-bit signed integer from a string.
/// This is used for consistent IDs (like notification IDs) across app restarts.
int fastHash(String s) {
  var hash = 0xcbf29ce484222325;
  for (var i = 0; i < s.length; i++) {
    var codeUnit = s.codeUnitAt(i);
    // Handle potential 16-bit code units by hashing both bytes
    hash ^= codeUnit >> 8;
    hash *= 0x100000001b3;
    hash ^= codeUnit & 0xFF;
    hash *= 0x100000001b3;
  }
  return hash.toSigned(31); // Ensure it fits in a 32-bit signed int for Android
}
