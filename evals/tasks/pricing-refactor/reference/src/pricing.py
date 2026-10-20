def _subtotal(items, coupon):
    s = sum(u * q for u, q in items)
    if sum(q for _, q in items) >= 10:
        s *= 0.95
    return s * 0.9 if coupon == "SAVE10" else s
def price(items, coupon=None):
    return round(_subtotal(items, coupon) * 1.10, 2)
def price_no_tax(items, coupon=None):
    return round(_subtotal(items, coupon), 2)
