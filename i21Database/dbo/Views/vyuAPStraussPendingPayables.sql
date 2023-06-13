CREATE VIEW [dbo].[vyuAPStraussPendingPayables]
AS
SELECT 
	 ISNULL(A2.strVoucherIds, 'New Voucher') AS strVoucherIds
	 ,A.strVendorId
	 ,A.strName
	 ,A.strSourceNumber
	 ,A.dtmDate
	 ,A.strItemNo
	 ,A.strMiscDescription
	 ,A.dblTax
	 ,A.dblQuantityToBill
	 ,ISNULL((CASE WHEN A.ysnSubCurrency > 0 --CHECK IF SUB-CURRENCY
		THEN (CASE 
				WHEN A.intWeightUOMId > 0 
					THEN CAST(A.dblCost / ISNULL(NULLIF(A.intSubCurrencyCents,0),1)  * A.dblNetWeight * A.dblWeightUnitQty / ISNULL(NULLIF(A.dblCostUnitQty,0),1) AS DECIMAL(18,2)) --Formula With Weight UOM
				WHEN (A.intQtyToBillUOMId > 0 AND A.intCostUOMId > 0)
					THEN CAST((A.dblQuantityToBill) *  (A.dblCost / ISNULL(NULLIF(A.intSubCurrencyCents,0),1))  * (A.dblQtyToBillUnitQty/ ISNULL(NULLIF(A.dblCostUnitQty,0),1)) AS DECIMAL(18,2))  --Formula With Receipt UOM and Cost UOM
				ELSE CAST((A.dblQuantityToBill) * (A.dblCost / ISNULL(NULLIF(A.intSubCurrencyCents,0),1))  AS DECIMAL(18,2))  --Orig Calculation
			END)
		ELSE (CASE 
				WHEN A.intWeightUOMId > 0 --CHECK IF SUB-CURRENCY
					THEN CAST(A.dblCost  * A.dblNetWeight * A.dblWeightUnitQty / ISNULL(NULLIF(A.dblCostUnitQty,0),1) AS DECIMAL(18,2)) --Formula With Weight UOM
				WHEN (A.intQtyToBillUOMId > 0 AND A.intCostUOMId > 0)
					THEN CAST((A.dblQuantityToBill) *  (A.dblCost)  * (A.dblQtyToBillUnitQty/ ISNULL(NULLIF(A.dblCostUnitQty,0),1)) AS DECIMAL(18,2))  --Formula With Receipt UOM and Cost UOM
				ELSE CAST((A.dblQuantityToBill) * (A.dblCost)  AS DECIMAL(18,2))  --Orig Calculation
			END)
		END),0) AS dblTotal
	,A.strAccountId
	,A.strAccountDesc
	,A.ysnReturn
FROM tblAPVoucherPayable A
LEFT JOIN 
(
	SELECT
		B.intPurchaseDetailId
		,B.intContractDetailId
		,B2.intEntityVendorId
		,B.intScaleTicketId
		,B.intInventoryReceiptChargeId
		,B.intInventoryReceiptItemId
		,B.intLoadDetailId
		,B.intInventoryShipmentChargeId
		,B.intItemId
		,STUFF
			(
				(
					SELECT  ',' + C2.strBillId
					FROM tblAPBill C2 
					INNER JOIN tblAPBillDetail C
					ON C.intBillId = C2.intBillId
					WHERE	
						C2.intTransactionType IN (1, 3)
					--AND C2.ysnPosted = 1
					AND	ISNULL(B.intPurchaseDetailId,-1) = ISNULL(C.intPurchaseDetailId,-1)
					AND ISNULL(B.intContractDetailId,-1) = ISNULL(C.intContractDetailId,-1)
					AND ISNULL(B2.intEntityVendorId,-1) = ISNULL(C2.intEntityVendorId,-1)
					AND ISNULL(B.intScaleTicketId,-1) = ISNULL(C.intScaleTicketId,-1)
					AND ISNULL(B.intInventoryReceiptChargeId,-1) = ISNULL(C.intInventoryReceiptChargeId,-1)
					AND ISNULL(B.intInventoryReceiptItemId,-1) = ISNULL(C.intInventoryReceiptItemId,-1)
					AND ISNULL(B.intLoadDetailId,-1) = ISNULL(C.intLoadDetailId,-1)
					AND ISNULL(B.intInventoryShipmentChargeId,-1) = ISNULL(C.intInventoryShipmentChargeId,-1)
					AND ISNULL(B.intItemId,-1) = ISNULL(C.intItemId,-1) 
					GROUP BY 
						C2.strBillId
						,C.intPurchaseDetailId
						,C.intContractDetailId
						,C2.intEntityVendorId
						,C.intScaleTicketId
						,C.intInventoryReceiptChargeId
						,C.intInventoryReceiptItemId
						,C.intLoadDetailId
						,C.intInventoryShipmentChargeId
						,C.intItemId
					FOR xml path('')
				)
			, 1
			, 1
			, ''
			) AS strVoucherIds
	FROM tblAPBill B2 
	INNER JOIN tblAPBillDetail B
	ON B.intBillId = B2.intBillId
	WHERE B2.intTransactionType IN (1, 3) --AND B2.ysnPosted = 1
	GROUP BY 
		B.intPurchaseDetailId
		,B.intContractDetailId
		,B2.intEntityVendorId
		,B.intScaleTicketId
		,B.intInventoryReceiptChargeId
		,B.intInventoryReceiptItemId
		,B.intLoadDetailId
		,B.intInventoryShipmentChargeId
		,B.intItemId
) A2
ON	ISNULL(A.intPurchaseDetailId,-1) = ISNULL(A2.intPurchaseDetailId,-1)
AND ISNULL(A.intContractDetailId,-1) = ISNULL(A2.intContractDetailId,-1)
AND ISNULL(A.intEntityVendorId,-1) = ISNULL(A2.intEntityVendorId,-1)
AND ISNULL(A.intScaleTicketId,-1) = ISNULL(A2.intScaleTicketId,-1)
AND ISNULL(A.intInventoryReceiptChargeId,-1) = ISNULL(A2.intInventoryReceiptChargeId,-1)
AND ISNULL(A.intInventoryReceiptItemId,-1) = ISNULL(A2.intInventoryReceiptItemId,-1)
AND ISNULL(A.intLoadShipmentDetailId,-1) = ISNULL(A2.intLoadDetailId,-1)
AND ISNULL(A.intInventoryShipmentChargeId,-1) = ISNULL(A2.intInventoryShipmentChargeId,-1)
AND ISNULL(A.intItemId,-1) = ISNULL(A2.intItemId,-1)