import sys, unittest
sys.path.insert(0, "src")
from pricing import price, price_no_tax
class T(unittest.TestCase):
    def test_basic(self): self.assertEqual(price([(100, 2)]), 220.0)
    def test_coupon(self): self.assertEqual(price([(100, 2)], "SAVE10"), 198.0)
    def test_no_tax(self): self.assertEqual(price_no_tax([(50, 1)]), 50.0)
if __name__ == "__main__": unittest.main()
