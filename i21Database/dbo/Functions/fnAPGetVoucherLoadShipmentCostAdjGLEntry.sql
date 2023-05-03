CREATE FUNCTION [dbo].[fnAPGetVoucherLoadShipmentCostAdjGLEntry]
(
	@billId INT
)
RETURNS TABLE AS RETURN
(
	SELECT
		B.intBillDetailId
		,B.strMiscDescription
		,CAST((
				CASE WHEN A.intTransactionType IN (1) 
					THEN (B.dblTotal - (C.dblAmount * (CASE WHEN (A.intEntityVendorId = C.intVendorId) AND C.ysnPrice = 1 THEN -1 ELSE 1 END))) 
						* ISNULL(NULLIF(B.dblRate, 0), 1) 
					ELSE 0 
				END
		) AS  DECIMAL(18, 2)) AS dblTotal
		,CAST((
				CASE WHEN A.intTransactionType IN (1) 
					THEN (B.dblTotal - (C.dblAmount * (CASE WHEN (A.intEntityVendorId = C.intVendorId) AND C.ysnPrice = 1 THEN -1 ELSE 1 END))) 
					ELSE 0 
				END
		) AS  DECIMAL(18, 2)) AS dblForeignTotal
		,0 AS dblTotalUnits
		,[dbo].[fnGetItemGLAccount](B.intItemId, E.intItemLocationId, 'Other Charge Expense') AS intAccountId
		,D.intCurrencyExchangeRateTypeId
		,D.strCurrencyExchangeRateType
		,ISNULL(NULLIF(B.dblRate, 0), 1) AS dblRate
	FROM tblAPBill A
	INNER JOIN tblAPBillDetail B ON A.intBillId = B.intBillId
	INNER JOIN tblLGLoadCost C ON C.intLoadCostId = B.intLoadShipmentCostId
	LEFT JOIN tblSMCurrencyExchangeRateType D ON D.intCurrencyExchangeRateTypeId = B.intCurrencyExchangeRateTypeId
	LEFT JOIN tblICItemLocation E ON E.intItemId = B.intItemId AND E.intLocationId = A.intShipToId
	WHERE A.intBillId = @billId
	AND B.dblOldCost IS NOT NULL 
	AND B.dblCost != B.dblOldCost 
	AND B.intInventoryReceiptChargeId IS NULL
	AND B.intInventoryReceiptItemId IS NULL
	AND B.intCustomerStorageId IS NULL
	AND ISNULL(C.ysnInventoryCost, 0) = 0
)