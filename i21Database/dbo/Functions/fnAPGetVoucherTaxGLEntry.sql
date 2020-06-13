CREATE FUNCTION [dbo].[fnAPGetVoucherTaxGLEntry]
(
	@billId INT
)
RETURNS TABLE AS RETURN
(
	SELECT
		B.intBillDetailId
		,D.intBillDetailTaxId
		,B.strMiscDescription
		,CAST((D.dblTax * ISNULL(NULLIF(B.dblRate,0),1)) 
			* (CASE WHEN A.intTransactionType != 1 THEN -1 ELSE 1 END) 
			-- * (CASE WHEN charges.ysnPrice = 1 THEN -1 ELSE 1 END) 
			-- * (CASE WHEN D.ysnCheckOffTax = 1 THEN -1 ELSE 1 END) 
			AS DECIMAL(18,2)) AS dblTotal
		,CAST((D.dblTax) 
			* (CASE WHEN A.intTransactionType != 1 THEN -1 ELSE 1 END) 
			-- * (CASE WHEN charges.ysnPrice = 1 THEN -1 ELSE 1 END) 
			-- * (CASE WHEN D.ysnCheckOffTax = 1 THEN -1 ELSE 1 END) 
			AS DECIMAL(18,2)) AS dblForeignTotal
		,0 as dblTotalUnits
		,CASE WHEN ((B.intInventoryReceiptItemId IS NOT NULL 
						AND receiptItem.intTaxGroupId > 0 
						AND receiptTax.intInventoryReceiptItemTaxId IS NOT NULL) --has tax details
				 OR (B.intInventoryReceiptChargeId IS NOT NULL AND chargeTax.intInventoryReceiptChargeId IS NOT NULL) 
				 OR (B.intInventoryShipmentChargeId IS NOT NULL AND shipmentChargeTax.intInventoryShipmentChargeId IS NOT NULL))
			THEN  dbo.[fnGetItemGLAccount](F.intItemId, ISNULL(detailloc.intItemLocationId, loc.intItemLocationId), 'AP Clearing')
			ELSE D.intAccountId
		END AS intAccountId
		,G.intCurrencyExchangeRateTypeId
		,G.strCurrencyExchangeRateType
		,ISNULL(NULLIF(B.dblRate,0),1) AS dblRate
	FROM tblAPBill A
	INNER JOIN tblAPBillDetail B ON A.intBillId = B.intBillId
	INNER JOIN tblAPBillDetailTax D
		ON B.intBillDetailId = D.intBillDetailId
	LEFT JOIN tblICInventoryReceiptItem receiptItem
		ON B.intInventoryReceiptItemId = receiptItem.intInventoryReceiptItemId
	LEFT JOIN tblICInventoryReceiptCharge charges
		ON B.intInventoryReceiptChargeId = charges.intInventoryReceiptChargeId
	LEFT JOIN tblICInventoryReceipt receipts
		ON charges.intInventoryReceiptId = receipts.intInventoryReceiptId
	LEFT JOIN dbo.tblSMCurrencyExchangeRateType G
		ON G.intCurrencyExchangeRateTypeId = B.intCurrencyExchangeRateTypeId
	LEFT JOIN tblICItem B2
		ON B.intItemId = B2.intItemId
	LEFT JOIN tblICItemLocation loc
		ON loc.intItemId = B.intItemId AND loc.intLocationId = A.intShipToId
	LEFT JOIN tblICItemLocation detailloc
		ON detailloc.intItemId = B.intItemId AND detailloc.intLocationId = B.intLocationId
	LEFT JOIN tblICItem F
		ON B.intItemId = F.intItemId
	OUTER APPLY (
		SELECT TOP 1 intInventoryReceiptItemTaxId FROM tblICInventoryReceiptItemTax receiptTax
		WHERE receiptTax.intInventoryReceiptItemId = B.intInventoryReceiptItemId
	) receiptTax
	OUTER APPLY (
		SELECT TOP 1 intInventoryReceiptChargeId FROM tblICInventoryReceiptChargeTax receiptChargeTax
		WHERE receiptChargeTax.intInventoryReceiptChargeId = B.intInventoryReceiptChargeId
	) chargeTax
	OUTER APPLY (
		SELECT TOP 1 intInventoryShipmentChargeId FROM tblICInventoryShipmentChargeTax shipmentChargeTax
		WHERE shipmentChargeTax.intInventoryShipmentChargeId = B.intInventoryShipmentChargeId
	) shipmentChargeTax
	WHERE A.intBillId = @billId
	AND A.intTransactionType IN (1,3)
	-- AND D.dblTax != 0
	-- AND ROUND(CASE WHEN charges.intInventoryReceiptChargeId > 0 
	-- 			THEN (ISNULL(D.dblAdjustedTax, D.dblTax) / B.dblTax) * B.dblTax
	-- 				* (CASE WHEN A.intEntityVendorId = receipts.intEntityVendorId AND charges.ysnPrice = 1 THEN -1 ELSE 1 END)
	-- 	ELSE (ISNULL(D.dblAdjustedTax, D.dblTax) / B.dblTax) * B.dblTax END * ISNULL(NULLIF(B.dblRate,0),1) * (CASE WHEN A.intTransactionType != 1 THEN -1 ELSE 1 END), 2) != 0
)
