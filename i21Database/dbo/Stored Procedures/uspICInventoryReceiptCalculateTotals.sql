CREATE PROCEDURE [dbo].[uspICInventoryReceiptCalculateTotals] (
	@ReceiptId INT = NULL,
	@ForceRecalc BIT = 0
)
AS

DECLARE @intMaxId INT = ISNULL(@ReceiptId, 2147483647)
DECLARE @intMinId INT = ISNULL(@ReceiptId, 1) -- if allows negative seeds -2147483647
DECLARE @Date DATETIME = GETUTCDATE()

UPDATE r
SET
	  r.dtmLastCalculateTotals = @Date
	, r.dblSubTotal = ISNULL(items.subTotal, 0)
	, r.dblTotalTax = ISNULL(items.totalTax, 0) + ISNULL(charges.totalChargesTax,0)
	, r.dblTotalCharges = ISNULL(charges.totalCharges,0)
	, r.dblTotalGross = ISNULL(items.totalGross,0)
	, r.dblTotalNet =  ISNULL(items.totalNet,0)
	, r.dblGrandTotal =  ISNULL(items.subTotal,0) + ISNULL(charges.totalCharges, 0) + ISNULL(items.totalTax, 0) + ISNULL(charges.totalChargesTax,0)
FROM 
	tblICInventoryReceipt r 
	OUTER APPLY (
		SELECT subTotal = SUM(ISNULL(ReceiptItem.dblLineTotal, 0))
			   ,totalTax = SUM(ISNULL(ReceiptItem.dblTax, 0))
			   ,totalGross = SUM(ISNULL(ReceiptItem.dblGross, 0))
			   ,totalNet = SUM(ISNULL(ReceiptItem.dblNet, 0))
		FROM	tblICInventoryReceiptItem ReceiptItem
		WHERE	ReceiptItem.intInventoryReceiptId = r.intInventoryReceiptId
	) items
	OUTER APPLY (
		SELECT totalCharges = SUM(
					CASE 
						WHEN Receipt.intCurrencyId = ISNULL(ReceiptCharge.intCurrencyId, Receipt.intCurrencyId) THEN 
							CASE 
								WHEN ReceiptCharge.ysnPrice = 1 THEN -ReceiptCharge.dblAmount 
								WHEN Receipt.intEntityVendorId = ISNULL(ReceiptCharge.intEntityVendorId, Receipt.intEntityVendorId) THEN ReceiptCharge.dblAmount 
								ELSE 0.00
							END 
						ELSE
							0.00
					END
				)
				,totalChargesTax = 
				SUM (
					CASE 
						WHEN Receipt.intCurrencyId = ISNULL(ReceiptCharge.intCurrencyId, Receipt.intCurrencyId) THEN 
							CASE 
								WHEN ReceiptCharge.ysnPrice = 1 THEN -ReceiptCharge.dblTax 
								WHEN ReceiptCharge.ysnAccrue = 1 AND Receipt.intEntityVendorId = ISNULL(ReceiptCharge.intEntityVendorId, Receipt.intEntityVendorId) THEN ReceiptCharge.dblTax 
								ELSE 0.00
							END 
						ELSE
							0.00
					END
				)
		FROM	tblICInventoryReceipt Receipt INNER JOIN tblICInventoryReceiptCharge ReceiptCharge
					ON Receipt.intInventoryReceiptId = ReceiptCharge.intInventoryReceiptId
		WHERE	ReceiptCharge.intInventoryReceiptId = r.intInventoryReceiptId
				AND ISNULL(Receipt.intCurrencyId, 1) = ISNULL(ReceiptCharge.intCurrencyId, ISNULL(Receipt.intCurrencyId, 1)) 	
	) charges
WHERE 
	--(r.intInventoryReceiptId = @ReceiptId OR @ReceiptId IS NULL)
	r.intInventoryReceiptId = @ReceiptId 
	AND (@ForceRecalc = 1 OR (r.dtmLastCalculateTotals IS NULL OR r.dtmDateModified > r.dtmLastCalculateTotals))
	
