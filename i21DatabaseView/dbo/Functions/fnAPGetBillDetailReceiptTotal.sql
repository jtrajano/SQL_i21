CREATE FUNCTION [dbo].[fnAPGetBillDetailReceiptTotal]
(
	@receiptId INT
)
RETURNS DECIMAL(18,6)
AS
BEGIN
	DECLARE @total DECIMAL(18,6);

	SELECT @total =  ABS(CASE WHEN B.ysnSubCurrency > 0 --CHECK IF SUB-CURRENCY
						 THEN (CASE WHEN B.intWeightUOMId > 0 
									THEN CAST(CASE WHEN (E1.dblCashPrice > 0 AND B.dblUnitCost = 0) 
												   THEN E1.dblCashPrice 
												   ELSE B.dblUnitCost 
											  END / ISNULL(A.intSubCurrencyCents,1)  * B.dblNet * ItemWeightUOM.dblUnitQty / ISNULL(ItemCostUOM.dblUnitQty,1) AS DECIMAL(18,2)) --Formula With Weight UOM
									WHEN (B.intUnitMeasureId > 0 AND B.intCostUOMId > 0)
									THEN CAST((B.dblOpenReceive - B.dblBillQty) * (CASE WHEN E1.dblCashPrice > 0 THEN E1.dblCashPrice ELSE B.dblUnitCost END / ISNULL(A.intSubCurrencyCents,1)) *  (ItemUOM.dblUnitQty/ ISNULL(ItemCostUOM.dblUnitQty,1)) AS DECIMAL(18,2))  --Formula With Receipt UOM and Cost UOM
									ELSE CAST((B.dblOpenReceive - B.dblBillQty) * (CASE WHEN E1.dblCashPrice > 0 THEN E1.dblCashPrice ELSE B.dblUnitCost END / ISNULL(A.intSubCurrencyCents,1))  AS DECIMAL(18,2))  --Orig Calculation
							   END) 
						 ELSE (CASE WHEN B.intWeightUOMId > 0
									THEN CAST(CASE WHEN (E1.dblCashPrice > 0 AND B.dblUnitCost = 0) 
												   THEN E1.dblCashPrice 
												   ELSE B.dblUnitCost 
											  END * B.dblNet * ItemWeightUOM.dblUnitQty / ISNULL(ItemCostUOM.dblUnitQty,1) AS DECIMAL(18,2)) --Formula With Weight UOM
									WHEN (B.intUnitMeasureId > 0  AND B.intCostUOMId > 0)
									THEN CAST((B.dblOpenReceive - B.dblBillQty) * CASE WHEN E1.dblCashPrice > 0 THEN E1.dblCashPrice ELSE B.dblUnitCost END * (ItemUOM.dblUnitQty/ ISNULL(ItemCostUOM.dblUnitQty,1))  AS DECIMAL(18,2))  --Formula With Receipt UOM and Cost UOM
									ELSE CAST((B.dblOpenReceive - B.dblBillQty) * CASE WHEN E1.dblCashPrice > 0 THEN E1.dblCashPrice ELSE B.dblUnitCost END  AS DECIMAL(18,2))  --Orig Calculation
							   END)
						 END)
	FROM tblICInventoryReceipt A
	INNER JOIN tblICInventoryReceiptItem B
		ON A.intInventoryReceiptId = B.intInventoryReceiptId
	INNER JOIN tblICItem C
		ON B.intItemId = C.intItemId
	INNER JOIN tblICItemLocation D
		ON A.intLocationId = D.intLocationId AND B.intItemId = D.intItemId
	LEFT JOIN (tblCTContractHeader E INNER JOIN tblCTContractDetail E1 ON E.intContractHeaderId = E1.intContractHeaderId) 
		ON E.intEntityId = A.intEntityVendorId 
				AND E.intContractHeaderId = B.intOrderId 
				AND E1.intContractDetailId = B.intLineNo	
	LEFT JOIN tblICItemUOM ItemWeightUOM 
		ON ItemWeightUOM.intItemUOMId = B.intWeightUOMId
	LEFT JOIN tblICUnitMeasure WeightUOM 
		ON WeightUOM.intUnitMeasureId = ItemWeightUOM.intUnitMeasureId
	LEFT JOIN tblICItemUOM ItemCostUOM 
		ON ItemCostUOM.intItemUOMId = B.intCostUOMId
	LEFT JOIN tblICUnitMeasure CostUOM 
		ON CostUOM.intUnitMeasureId = ItemCostUOM.intUnitMeasureId
	LEFT JOIN tblICItemUOM ItemUOM 
		ON ItemUOM.intItemUOMId = B.intUnitMeasureId
	LEFT JOIN tblICUnitMeasure UOM 
		ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId
	WHERE A.intInventoryReceiptId = @receiptId AND A.ysnPosted = 1 AND B.dblUnitCost != 0

	RETURN @total;
END