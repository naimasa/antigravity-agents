import os, sys
ws = sys.argv[1]; sys.path.insert(0, os.path.join(ws, "src"))
from pricing import price, price_no_tax
cases = [
  (price([(100, 2)]), 220.0), (price([(100, 2)], "SAVE10"), 198.0), (price_no_tax([(50, 1)]), 50.0),
  (price_no_tax([(10, 10)]), 95.0), (price([(10, 10)]), 104.5), (price_no_tax([(10, 10)], "SAVE10"), 85.5),
  (price([(10, 9)]), 99.0), (price([(2, 4), (2, 3), (2, 3)]), 20.9),
]
bad = [(g, w) for g, w in cases if abs(g - w) > 0.005]
if bad: print("FAIL", bad); sys.exit(1)
src = open(os.path.join(ws, "src/pricing.py")).read()
if src.count("for unit, qty in items") + src.count("sum(") > 2 and src.count("SAVE10") > 1: print("FAIL duplication remains"); sys.exit(1)
print("PASS")
