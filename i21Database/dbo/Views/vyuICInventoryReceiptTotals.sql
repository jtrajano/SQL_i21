CREATE VIEW [dbo].[vyuICInventoryReceiptTotals]
AS

SELECT	r1.intInventoryReceiptId
		,dblTotalCharge = ISNULL(receiptcharge.dblTotalCharge, 0)
		,dblTotalChargeTax = ISNULL(receiptcharge.dblTotalChargeTax, 0) 
		--,dblLotTotalGross = ISNULL(receiptLot.dblLotTotalGross, 0)
		--,dblLotTotalTare = ISNULL(receiptLot.dblLotTotalTare, 0)
		--,dblLotTotalNet = ISNULL(receiptLot.dblLotTotalNet, 0)
FROM	tblICInventoryReceipt r1
		OUTER APPLY (
			SELECT	rc.intInventoryReceiptId
					,dblTotalCharge = 
						SUM(
							CASE 
								WHEN COALESCE(rc.intCurrencyId, r2.intCurrencyId) = r2.intCurrencyId THEN
									CASE rc.ysnPrice 
										WHEN 1 THEN 
											-ISNULL(rc.dblAmount, 0.00) 
										ELSE
											CASE WHEN r2.intEntityVendorId = COALESCE(rc.intEntityVendorId, r2.intEntityVendorId) AND rc.ysnAccrue = 1 THEN ISNULL(rc.dblAmount, 0.00) ELSE 0.00 END 
									END
								ELSE 
									0.00
							END
						)
					,dblTotalChargeTax = 
						SUM(
							CASE 
								WHEN COALESCE(rc.intCurrencyId, r2.intCurrencyId) = r2.intCurrencyId THEN
									CASE rc.ysnPrice WHEN 1 THEN 
											-ISNULL(rc.dblTax, 0.00) 
										ELSE
											CASE WHEN r2.intEntityVendorId = COALESCE(rc.intEntityVendorId, r2.intEntityVendorId) AND rc.ysnAccrue = 1 THEN ISNULL(rc.dblTax, 0.00) ELSE 0.00 END 
									END
								ELSE 
									0.00 
							END
						)
			FROM	tblICInventoryReceiptCharge rc INNER JOIN tblICInventoryReceipt r2
						ON rc.intInventoryReceiptId = r2.intInventoryReceiptId
			WHERE	rc.intInventoryReceiptId = r1.intInventoryReceiptId
			GROUP BY rc.intInventoryReceiptId
		) receiptcharge
		--OUTER APPLY (
		--	SELECT	ri.intInventoryReceiptId
		--			,dblLotTotalGross = SUM(ISNULL(ril.dblGrossWeight, 0))
		--			,dblLotTotalTare = SUM(ISNULL(ril.dblTareWeight, 0))
		--			,dblLotTotalNet =  SUM(ISNULL(ril.dblGrossWeight, 0) - ISNULL(ril.dblTareWeight, 0))
		--	FROM	tblICInventoryReceiptItem ri INNER JOIN tblICInventoryReceiptItemLot ril
		--				ON ri.intInventoryReceiptItemId = ril.intInventoryReceiptItemId
		--	WHERE	ri.intInventoryReceiptId = r1.intInventoryReceiptId
		--	GROUP BY ri.intInventoryReceiptId
		--) receiptLot