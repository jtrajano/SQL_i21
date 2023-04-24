CREATE FUNCTION [dbo].[fnAPGetVoucherDetailDebitEntry]
(
	@billId INT
)
RETURNS TABLE AS RETURN
(
	SELECT
		B.intBillDetailId
		,B.strMiscDescription
		,CAST(
			CASE	WHEN A.intTransactionType IN (2, 3, 11, 13) THEN -B.dblTotal
						WHEN A.intTransactionType = 16 THEN (B.dblTotal * (B.dblProvisionalPercentage / 100)) 
					ELSE
						CASE	WHEN B.intCustomerStorageId > 0 THEN  --COST ADJUSTMENT FOR SETTLE STORAGE ITEM
									CASE WHEN B.dblOldCost IS NOT NULL
									THEN
										CASE WHEN B.dblOldCost = 0 THEN 0 ELSE round((ISNULL(storageOldCost.dblOldCost, B.dblOldCost) * B.dblQtyReceived), 2) END
									ELSE B.dblTotal - (CASE WHEN ISNULL(A.ysnFinalVoucher,0) = 1 THEN B.dblProvisionalPayment ELSE 0 END) 
									END
								WHEN B.intInventoryReceiptItemId IS NULL THEN (
									CASE WHEN B.intLoadShipmentCostId > 0 THEN ISNULL(B.dblOldCost, B.dblCost) ELSE B.dblTotal END
								)
								- (CASE WHEN ISNULL(A.ysnFinalVoucher,0) = 1 AND A.intTransactionType = 1 THEN B.dblProvisionalTotal ELSE 0 END) 
								ELSE 
									CASE	WHEN B.dblOldCost IS NOT NULL THEN  																				
												CASE	WHEN B.dblOldCost = 0 THEN 0 
														ELSE usingOldCost.dblTotal  - (CASE WHEN ISNULL(A.ysnFinalVoucher,0) = 1 THEN B.dblProvisionalPayment ELSE 0 END)  --COST ADJUSTMENT FOR RECEIPT ITEM
												END 
											ELSE 
												B.dblTotal - (CASE WHEN ISNULL(A.ysnFinalVoucher,0) = 1 THEN B.dblProvisionalPayment ELSE 0 END) 
									END																		
						END
					END
			* ISNULL(NULLIF(B.dblRate,0),1) AS DECIMAL(18,2)) AS dblTotal
		,CAST(
			CASE	WHEN A.intTransactionType IN (2, 3, 11, 13) THEN -B.dblTotal
					WHEN A.intTransactionType = 16 THEN (B.dblTotal * (B.dblProvisionalPercentage / 100)) 
					ELSE
						CASE	WHEN B.intCustomerStorageId > 0 THEN 
									CASE WHEN B.dblOldCost IS NOT NULL
									THEN
										CASE WHEN B.dblOldCost = 0 THEN 0 ELSE round((ISNULL(storageOldCost.dblOldCost, B.dblOldCost) * B.dblQtyReceived), 2) END
									ELSE B.dblTotal - (CASE WHEN ISNULL(A.ysnFinalVoucher,0) = 1 THEN B.dblProvisionalPayment ELSE 0 END)
									END
								WHEN B.intInventoryReceiptItemId IS NULL THEN (
									CASE WHEN B.intLoadShipmentCostId > 0 THEN ISNULL(B.dblOldCost, B.dblCost) ELSE B.dblTotal END
								)
								- (CASE WHEN ISNULL(A.ysnFinalVoucher,0) = 1 AND A.intTransactionType = 1 THEN B.dblProvisionalTotal ELSE 0 END) 
								ELSE 
									CASE	WHEN B.dblOldCost IS NOT NULL THEN  																				
												CASE	WHEN B.dblOldCost = 0 THEN 0 
														ELSE usingOldCost.dblTotal - (CASE WHEN ISNULL(A.ysnFinalVoucher,0) = 1 THEN B.dblProvisionalPayment ELSE 0 END) --COST ADJUSTMENT
												END 
											ELSE 
												B.dblTotal - (CASE WHEN ISNULL(A.ysnFinalVoucher,0) = 1 THEN B.dblProvisionalPayment ELSE 0 END) 
									END																		
						END
			END AS DECIMAL(18,2)) AS dblForeignTotal
		,(CASE WHEN F.intItemId IS NULL OR B.intInventoryReceiptChargeId > 0 OR F.strType NOT IN  ('Inventory','Finished Good', 'Raw Material') THEN B.dblQtyReceived
			   ELSE
		       --units is only of inventory item
			   dbo.fnCalculateQtyBetweenUOM((CASE WHEN B.intWeightUOMId > 0 
												  THEN B.intWeightUOMId ELSE B.intUnitOfMeasureId END), 
													itemUOM.intItemUOMId, CASE WHEN B.intWeightUOMId > 0 THEN B.dblNetWeight ELSE B.dblQtyReceived END)
					 
		END) * (CASE WHEN A.intTransactionType NOT IN (1,14) THEN 
		CASE WHEN A.intTransactionType = 16 THEN (B.dblProvisionalPercentage / 100)
		ELSE -1 END ELSE CASE WHEN A.ysnFinalVoucher = 1 THEN ((100 - B.dblProvisionalPercentage) / 100) ELSE 1 END END) as dblTotalUnits
		,CASE WHEN B.intInventoryShipmentChargeId IS NOT NULL 
				THEN dbo.[fnGetItemGLAccount](F.intItemId, loc.intItemLocationId, 'AP Clearing') --AP-3492 use AP Clearing if tansaction is From IS
				ELSE B.intAccountId
		END AS intAccountId
		,G.intCurrencyExchangeRateTypeId
		,G.strCurrencyExchangeRateType
		,ISNULL(NULLIF(B.dblRate,0),1) AS dblRate
		,B.strComment
	FROM tblAPBill A
	INNER JOIN tblAPBillDetail B ON A.intBillId = B.intBillId
	LEFT JOIN tblICInventoryReceiptItem E
		ON B.intInventoryReceiptItemId = E.intInventoryReceiptItemId
	LEFT JOIN tblICInventoryReceiptCharge charges
		ON B.intInventoryReceiptChargeId = charges.intInventoryReceiptChargeId
	-- LEFT JOIN tblICInventoryShipmentCharge shipmentCharges
	-- 	ON B.intInventoryShipmentChargeId = shipmentCharges.intInventoryShipmentChargeId
	LEFT JOIN dbo.tblSMCurrencyExchangeRateType G
		ON B.intCurrencyExchangeRateTypeId = G.intCurrencyExchangeRateTypeId
	LEFT JOIN tblICItem B2
		ON B.intItemId = B2.intItemId
	LEFT JOIN tblICItemLocation loc
		ON loc.intItemId = B.intItemId AND loc.intLocationId = A.intShipToId
	LEFT JOIN tblICItem F
		ON B.intItemId = F.intItemId
	LEFT JOIN tblLGLoadCost H
		ON H.intLoadCostId = B.intLoadShipmentCostId
	-- LEFT JOIN tblICItemUOM itemUOM ON F.intItemId = itemUOM.intItemId AND itemUOM.ysnStockUnit = 1	
	OUTER APPLY (
		SELECT TOP 1 stockUnit.*
		FROM tblICItemUOM stockUnit 
		WHERE 
			B.intItemId = stockUnit.intItemId 
		AND stockUnit.ysnStockUnit = 1
	) itemUOM
	OUTER APPLY (
		SELECT dblTotal = CAST (
				CASE 
				WHEN B.intInventoryReceiptChargeId > 0
					THEN charges.dblAmount
				-- WHEN B.intInventoryShipmentChargeId > 0
				-- 	THEN shipmentCharges.dblAmount (PENDING)
				ELSE (CASE	
						-- If there is a Gross/Net UOM, compute by the net weight. 
						WHEN E.intWeightUOMId IS NOT NULL THEN 
							-- Convert the Cost UOM to Gross/Net UOM. 
							dbo.fnCalculateCostBetweenUOM(
								ISNULL(E.intCostUOMId, E.intUnitMeasureId)
								, E.intWeightUOMId
								, E.dblUnitCost
							) 
							/ CASE WHEN B.ysnSubCurrency > 0 THEN ISNULL(NULLIF(A.intSubCurrencyCents, 0),1) ELSE 1 END 
							* B.dblNetWeight

						-- If Gross/Net UOM is missing: compute by the receive qty. 
						ELSE 
							-- Convert the Cost UOM to Gross/Net UOM. 
							dbo.fnCalculateCostBetweenUOM(
								ISNULL(E.intCostUOMId, E.intUnitMeasureId)
								, E.intUnitMeasureId
								, E.dblUnitCost
							) 
							/ CASE WHEN B.ysnSubCurrency > 0 THEN ISNULL(NULLIF(A.intSubCurrencyCents, 0),1) ELSE 1 END  
							* B.dblQtyReceived
					END)
				END				
				AS DECIMAL(18, 2)
			)
	) usingOldCost
	OUTER APPLY (
		SELECT TOP 1
			storageHistory.dblPaidAmount
			,storageHistory.dblOldCost
		FROM tblGRSettleStorage storage 
		INNER JOIN tblGRSettleStorageTicket storageTicket ON storage.intSettleStorageId = storageTicket.intSettleStorageId
		INNER JOIN tblGRCustomerStorage customerStorage ON storageTicket.intCustomerStorageId = customerStorage.intCustomerStorageId 
															AND B.intCustomerStorageId = customerStorage.intCustomerStorageId
		INNER JOIN tblGRStorageHistory storageHistory ON storageHistory.intCustomerStorageId = customerStorage.intCustomerStorageId 
													AND storageHistory.intSettleStorageId = storageTicket.intSettleStorageId
		WHERE B.intBillId = storage.intBillId
	) storageOldCost
	WHERE A.intBillId = @billId
	AND B.intInventoryReceiptChargeId IS NULL --EXCLUDE CHARGES
	AND ISNULL(H.ysnInventoryCost, 0) = 0 --EXCLUDE LS INVENTORIED CHAGES
	-- AND B.intInventoryShipmentChargeId IS NULL --EXCLUDE SHIPMENT CHARGES (PENDING IMPLEMENTATION)
)
