
module.exports =
  strip: (str) -> str.replace(/\s+/g, '')
  clamp: (n) -> Math.min(1, Math.max(0, n))
  clampInt: (n, max=100) -> Math.min(max, Math.max(0, n))
