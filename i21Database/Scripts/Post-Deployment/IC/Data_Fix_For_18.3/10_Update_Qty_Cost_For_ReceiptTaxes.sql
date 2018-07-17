GO
PRINT N'BEGIN - IC Data Fix for 18.3. #10'
GO

IF EXISTS (SELECT 1 FROM (SELECT TOP 1 dblVersion = CAST(LEFT(strVersionNo, 4) AS NUMERIC(18,1)) FROM tblSMBuildNumber ORDER BY intVersionID DESC) v WHERE v.dblVersion <= 18.3)
BEGIN 
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
			AND rc.dblAmount <> 0 

	-- Update the Quantity Billed for the other charges. 
	UPDATE	rc 
	SET		rc.dblQuantityBilled = 
				CASE 
					WHEN rc.strCostMethod = 'Per Unit' AND ISNULL(rc.dblRate, 0) <> 0 THEN
						dbo.fnDivide(
							rc.dblAmountBilled
							,rc.dblRate
						)
					ELSE 
						1
				END 	
	FROM	tblICInventoryReceiptCharge rc
	WHERE	ISNULL(rc.dblQuantityBilled, 0) = 0 
			AND rc.dblAmountBilled <> 0 
	
	-- Update the Quantity Priced for the other charges. 
	UPDATE	rc 
	SET		rc.dblQuantityPriced = 
				CASE 
					WHEN rc.strCostMethod = 'Per Unit' AND ISNULL(rc.dblRate, 0) <> 0 THEN
						dbo.fnDivide(
							rc.dblAmountPriced
							,rc.dblRate
						)
					ELSE 
						1
				END 	
	FROM	tblICInventoryReceiptCharge rc
	WHERE	ISNULL(rc.dblQuantityPriced, 0) = 0 
			AND rc.dblAmountPriced <> 0 
	
	-- After adding the dblQty and dblCost to tblICInventoryShipmentChargeTax, 
	-- the system needs to populate the data for the Qty and Cost. 
	UPDATE	sct
	SET		sct.dblCost = 
					CASE 
						WHEN sc.strCostMethod = 'Per Unit' THEN
							ISNULL(sc.dblRate, 0)
						ELSE 
							sc.dblAmount
					END 
			,sct.dblQty = 
					CASE 
						WHEN sc.strCostMethod = 'Per Unit' AND ISNULL(sc.dblRate, 0) <> 0 THEN
							dbo.fnDivide(
								sc.dblAmount
								,sc.dblRate
							)

						ELSE 
							1
					END 
	FROM	tblICInventoryShipmentChargeTax sct INNER JOIN tblICInventoryShipmentCharge sc
				ON sct.intInventoryShipmentChargeId = sc.intInventoryShipmentChargeId
	WHERE	ISNULL(sct.dblCost, 0) = 0 
			AND sc.dblAmount <> 0
	
	-- Update the Quantity of the other charges. 
	UPDATE	sc 
	SET		sc.dblQuantity = 
				CASE 
					WHEN sc.strCostMethod = 'Per Unit' AND ISNULL(sc.dblRate, 0) <> 0 THEN
						dbo.fnDivide(
							sc.dblAmount
							,sc.dblRate
						)

					ELSE 
						1
				END 	
	FROM	tblICInventoryShipmentCharge sc
	WHERE	ISNULL(sc.dblQuantity, 0) = 0 
			AND sc.dblAmount <> 0
	
	-- Update the Quantity Billed for the other charges. 
	UPDATE	sc 
	SET		sc.dblQuantityBilled = 
				CASE 
					WHEN sc.strCostMethod = 'Per Unit' AND ISNULL(sc.dblRate, 0) <> 0 THEN
						dbo.fnDivide(
							sc.dblAmountBilled
							,sc.dblRate
						)
					ELSE 
						1
				END 	
	FROM	tblICInventoryShipmentCharge sc
	WHERE	ISNULL(sc.dblQuantityBilled, 0) = 0 
			AND sc.dblAmountBilled <> 0

	-- Update the Quantity Priced for the other charges. 
	UPDATE	sc 
	SET		sc.dblQuantityPriced = 
				CASE 
					WHEN sc.strCostMethod = 'Per Unit' AND ISNULL(sc.dblRate, 0) <> 0 THEN
						dbo.fnDivide(
							sc.dblAmountPriced
							,sc.dblRate
						)
					ELSE 
						1
				END 	
	FROM	tblICInventoryShipmentCharge sc
	WHERE	ISNULL(sc.dblQuantityPriced, 0) = 0 
			AND sc.dblAmountPriced <> 0 

END 
GO

PRINT N'END - IC Data Fix for 18.3. #10'
GO
