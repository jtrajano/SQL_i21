CREATE PROCEDURE [dbo].[uspICInventoryReceiptCalculateTotals] (
	@ReceiptId INT = NULL,
	@ForceRecalc BIT = 0
)
AS

DECLARE @Date DATETIME = GETUTCDATE()

--UPDATE r
--SET
--	  r.dtmLastCalculateTotals = @Date
--	, r.dblSubTotal = ISNULL(dbo.fnICGetReceiptTotals(r.intInventoryReceiptId, 1),0)
--	, r.dblTotalTax = ISNULL(dbo.fnICGetReceiptTotals(r.intInventoryReceiptId, 2),0)
--	, r.dblTotalCharges = ISNULL(dbo.fnICGetReceiptTotals(r.intInventoryReceiptId, 3),0)
--	, r.dblTotalGross = ISNULL(dbo.fnICGetReceiptTotals(r.intInventoryReceiptId, 4),0)
--	, r.dblTotalNet =  ISNULL(dbo.fnICGetReceiptTotals(r.intInventoryReceiptId, 5),0)
--	, r.dblGrandTotal =  ISNULL(dbo.fnICGetReceiptTotals(r.intInventoryReceiptId, 6),0)
--FROM tblICInventoryReceipt r
--WHERE (@ForceRecalc = 1 OR (r.dtmLastCalculateTotals IS NULL OR r.dtmDateModified > r.dtmLastCalculateTotals))
--	AND (r.intInventoryReceiptId BETWEEN @intMinId AND @intMaxId)

-- Temporarily comment this out to resolve IC-7927 but will temporarily remove optimizations in IC-7893
--EXEC dbo.uspICUpdateInventoryReceiptDetail @ReceiptId, @ForceRecalc

UPDATE r
SET
	  r.dtmLastCalculateTotals = @Date
	, r.dblSubTotal = ISNULL(items.subTotal, 0)
	, r.dblTotalItemTax = ISNULL(items.totalTax, 0)
	, r.dblTotalReceiptTax = ISNULL(receiptTax.totalReceipTax, 0) 
	, r.dblTotalTax = ISNULL(items.totalTax, 0) + ISNULL(charges.totalChargesTax,0) + ISNULL(receiptTax.totalReceipTax, 0) 
	, r.dblTotalCharges = ISNULL(charges.totalCharges,0)
	, r.dblTotalGross = ISNULL(items.totalGross,0)
	, r.dblTotalTare = ISNULL(items.totalTare,0)
	, r.dblTotalLotQty = ISNULL(lots.totalLotQty, 0)	
	, r.dblTotalLotTare = ISNULL(lots.totalLotTare,0)
	, r.dblTotalNet =  ISNULL(items.totalNet,0)
	, r.dblGrandTotal =  ISNULL(items.subTotal,0) + ISNULL(charges.totalCharges, 0) + ISNULL(items.totalTax, 0) + ISNULL(charges.totalChargesTax,0)
	, r.dblAvgTarePerQty = CASE WHEN ISNULL(lots.totalLotQty, 0) <> 0 THEN ISNULL(lots.totalLotTare,0) / ISNULL(lots.totalLotQty, 0) ELSE 0 END 	
FROM 
	tblICInventoryReceipt r 
	OUTER APPLY (
		SELECT subTotal = SUM(ISNULL(ReceiptItem.dblLineTotal, 0))
			   ,totalTax = SUM(ISNULL(ReceiptItem.dblTax, 0))
			   ,totalGross = SUM(ISNULL(ReceiptItem.dblGross, 0))
			   ,totalNet = SUM(ISNULL(ReceiptItem.dblNet, 0))
			   ,totalTare = SUM(ISNULL(ReceiptItem.dblTare, 0))
		FROM	tblICInventoryReceiptItem ReceiptItem
		WHERE	ReceiptItem.intInventoryReceiptId = r.intInventoryReceiptId
	) items
	OUTER APPLY (
		SELECT 
			totalLotQty = SUM(ISNULL(ReceiptItemLot.dblQuantity, 0))
			,totalLotTare = SUM(ISNULL(ReceiptItemLot.dblTareWeight, 0))
		FROM 
			tblICInventoryReceiptItemLot ReceiptItemLot INNER JOIN tblICInventoryReceiptItem ReceiptItem 
				ON ReceiptItemLot.intInventoryReceiptItemId = ReceiptItem.intInventoryReceiptItemId
		WHERE
			ReceiptItem.intInventoryReceiptId = r.intInventoryReceiptId	
	) lots
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
	OUTER APPLY (
		SELECT 
			totalReceipTax = SUM(ReceiptTax.dblTax) 
		FROM 
			tblICInventoryReceiptTax ReceiptTax
		WHERE
			ReceiptTax.intInventoryReceiptId = r.intInventoryReceiptId
	) receiptTax
WHERE 
	--(r.intInventoryReceiptId = @ReceiptId OR @ReceiptId IS NULL)
	r.intInventoryReceiptId = @ReceiptId 
	AND (@ForceRecalc = 1 OR (r.dtmLastCalculateTotals IS NULL OR r.dtmDateModified > r.dtmLastCalculateTotals))
	