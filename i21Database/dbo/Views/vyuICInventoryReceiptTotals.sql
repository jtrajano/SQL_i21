CREATE VIEW [dbo].[vyuICInventoryReceiptTotals]
AS

SELECT r.intInventoryReceiptId,
	dblTotalCharge = SUM(CASE WHEN COALESCE(rc.intCurrencyId, r.intCurrencyId) = r.intCurrencyId THEN
		CASE rc.ysnPrice WHEN 1 THEN -ISNULL(rc.dblAmount, 0.00) 
			ELSE
				CASE WHEN r.intEntityVendorId = COALESCE(rc.intEntityVendorId, r.intEntityVendorId) AND rc.ysnAccrue = 1 THEN ISNULL(rc.dblAmount, 0.00) ELSE 0.00 END 
		END
	ELSE 0.00
	END)
	, dblTotalChargeTax = SUM(CASE WHEN COALESCE(rc.intCurrencyId, r.intCurrencyId) = r.intCurrencyId THEN
		CASE rc.ysnPrice WHEN 1 THEN -ISNULL(rc.dblTax, 0.00) 
			ELSE
				CASE WHEN r.intEntityVendorId = COALESCE(rc.intEntityVendorId, r.intEntityVendorId) AND rc.ysnAccrue = 1 THEN ISNULL(rc.dblTax, 0.00) ELSE 0.00 END 
		END
	ELSE 0.00 
	END)
FROM tblICInventoryReceiptCharge rc
	INNER JOIN tblICInventoryReceipt r ON r.intInventoryReceiptId = rc.intInventoryReceiptId
GROUP BY r.intInventoryReceiptId