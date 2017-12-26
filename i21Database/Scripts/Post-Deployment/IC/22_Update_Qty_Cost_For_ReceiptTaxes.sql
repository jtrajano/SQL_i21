﻿
-- After adding the dblQty and dblCost to tblICInventoryReceiptItemTax, 
-- the system needs to populate the data for the Qty and Cost. 
UPDATE	rt
SET		rt.dblCost = 
			CASE 
				WHEN ri.intWeightUOMId IS NOT NULL THEN 
					dbo.fnCalculateCostBetweenUOM(
						COALESCE(ri.intCostUOMId, ri.intUnitMeasureId)
						, ri.intWeightUOMId
						, CASE 
								WHEN ri.ysnSubCurrency = 1 AND ISNULL(r.intSubCurrencyCents, 0) <> 0 THEN 
									dbo.fnDivide(ri.dblUnitCost, r.intSubCurrencyCents) 
								ELSE
									ri.dblUnitCost
                          END 
					) 
				ELSE 
					dbo.fnCalculateCostBetweenUOM(
						COALESCE(ri.intCostUOMId, ri.intUnitMeasureId)
						, ri.intUnitMeasureId
						, CASE 
								WHEN ri.ysnSubCurrency = 1 AND ISNULL(r.intSubCurrencyCents, 0) <> 0 THEN 
									dbo.fnDivide(ri.dblUnitCost, r.intSubCurrencyCents) 
								ELSE
									ri.dblUnitCost
                          END 
					) 			
			END
		,rt.dblQty = 
			CASE	
				WHEN ri.intWeightUOMId IS NOT NULL THEN 
					ri.dblNet 
				ELSE 
					ri.dblOpenReceive 
			END
FROM	tblICInventoryReceiptItemTax rt INNER JOIN tblICInventoryReceiptItem ri
			ON rt.intInventoryReceiptItemId = ri.intInventoryReceiptItemId
		INNER JOIN tblICInventoryReceipt r
			ON r.intInventoryReceiptId = ri.intInventoryReceiptId
WHERE	ISNULL(rt.dblCost, 0) = 0 
		AND ri.dblUnitCost <> 0 
		AND ISNULL(rt.dblQty, 1) = 1
		AND 1 <> CASE WHEN ri.intWeightUOMId IS NOT NULL THEN ri.dblNet ELSE ri.dblOpenReceive END 
GO 

-- After adding the dblQty and dblCost to tblICInventoryReceiptChargeTax, 
-- the system needs to populate the data for the Qty and Cost. 
UPDATE	rct
SET		rct.dblCost = 
				CASE 
					WHEN rc.strCostMethod = 'Per Unit' THEN
						ISNULL(rc.dblRate, 0)
					ELSE 
						rc.dblAmount
				END 
		,rct.dblQty = 
				CASE 
					WHEN rc.strCostMethod = 'Per Unit' AND ISNULL(rc.dblRate, 0) <> 0 THEN
						dbo.fnDivide(
							rc.dblAmount
							,rc.dblRate
						)

					ELSE 
						1
				END 
FROM	tblICInventoryReceiptChargeTax rct INNER JOIN tblICInventoryReceiptCharge rc
			ON rct.intInventoryReceiptChargeId = rc.intInventoryReceiptChargeId
WHERE	ISNULL(rct.dblCost, 0) = 0 
		AND rc.dblAmount <> 0 

GO 

-- Update the Quantity of the other charges. 
UPDATE	rc 
SET		rc.dblQuantity = 
			CASE 
				WHEN rc.strCostMethod = 'Per Unit' AND ISNULL(rc.dblRate, 0) <> 0 THEN
					dbo.fnDivide(
						rc.dblAmount
						,rc.dblRate
					)

				ELSE 
					1
			END 
FROM	tblICInventoryReceiptCharge rc
WHERE	ISNULL(rc.dblQuantity, 0) = 0 
		--AND rc.strCostMethod = 'Per Unit' 
		--AND rc.dblRate <> 0 
		AND rc.dblAmount <> 0 

GO 