def price(items, coupon=None):
    """items: [(unit_price, qty)]. 戻り値は税込み合計（小数2桁に丸め）。"""
    subtotal = 0.0
    for unit, qty in items:
        subtotal += unit * qty
    if coupon == "SAVE10":
        subtotal = subtotal * 0.9
    total = subtotal * 1.10
    return round(total, 2)

def price_no_tax(items, coupon=None):
    subtotal = 0.0
    for unit, qty in items:
        subtotal += unit * qty
    if coupon == "SAVE10":
        subtotal = subtotal * 0.9
    return round(subtotal, 2)
