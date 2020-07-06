CREATE FUNCTION [dbo].[fnAPGetVoucherStorageItemCostAdjGLEntry]
(
	@billId INT
)
RETURNS TABLE AS RETURN
(
	SELECT
		B.intBillDetailId
		,B.strMiscDescription
		,CAST((CASE	WHEN A.intTransactionType IN (1) 
				THEN (B.dblTotal  - round((storageOldCost.dblOldCost * B.dblQtyReceived), 2)  * ISNULL(NULLIF(B.dblRate,0),1)) 
			ELSE 0 END) AS  DECIMAL(18, 2)) AS dblTotal
		,CAST((CASE	WHEN A.intTransactionType IN (1) 
				THEN (B.dblTotal - round((storageOldCost.dblOldCost * B.dblQtyReceived), 2) ) 
			ELSE 0 END) AS  DECIMAL(18, 2)) AS dblForeignTotal
		,0 as dblTotalUnits
		,[dbo].[fnGetItemGLAccount](B.intItemId, loc.intItemLocationId, 'AP Clearing') AS intAccountId
		,G.intCurrencyExchangeRateTypeId
		,G.strCurrencyExchangeRateType
		,ISNULL(NULLIF(B.dblRate,0),1) AS dblRate
	FROM tblAPBill A
	INNER JOIN tblAPBillDetail B ON A.intBillId = B.intBillId
	LEFT JOIN dbo.tblSMCurrencyExchangeRateType G
		ON B.intCurrencyExchangeRateTypeId = G.intCurrencyExchangeRateTypeId
	LEFT JOIN tblICItem B2
		ON B.intItemId = B2.intItemId
	LEFT JOIN tblICItemLocation loc
		ON loc.intItemId = B.intItemId AND loc.intLocationId = A.intShipToId
	LEFT JOIN tblICItem F
		ON B.intItemId = F.intItemId
	LEFT JOIN tblICItemUOM itemUOM ON F.intItemId = itemUOM.intItemId AND itemUOM.ysnStockUnit = 1	
	OUTER APPLY (
		SELECT TOP 1
			storageHistory.dblPaidAmount,
			storageHistory.dblOldCost
		FROM tblGRSettleStorage storage 
		INNER JOIN tblGRSettleStorageTicket storageTicket ON storage.intSettleStorageId = storageTicket.intSettleStorageId
		INNER JOIN tblGRCustomerStorage customerStorage ON storageTicket.intCustomerStorageId = customerStorage.intCustomerStorageId 
															AND B.intCustomerStorageId = customerStorage.intCustomerStorageId
		INNER JOIN tblGRStorageHistory storageHistory ON storageHistory.intCustomerStorageId = customerStorage.intCustomerStorageId 
													AND storageHistory.intSettleStorageId = storageTicket.intSettleStorageId
													AND B.intContractHeaderId = storageHistory.intContractHeaderId
		WHERE B.intBillId = storage.intBillId
	) storageOldCost 
	WHERE A.intBillId = @billId
	AND B.dblOldCost IS NOT NULL AND B.dblCost != B.dblOldCost
	AND B.intCustomerStorageId IS NOT NULL
)
