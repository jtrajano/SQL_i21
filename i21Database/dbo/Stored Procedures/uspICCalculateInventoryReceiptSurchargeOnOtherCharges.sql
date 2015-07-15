CREATE PROCEDURE [dbo].[uspICCalculateInventoryReceiptSurchargeOnOtherCharges]
	@intInventoryReceiptId AS INT 
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

-- Declare the variables
BEGIN
	-- Constants
	DECLARE @COST_METHOD_PER_UNIT AS NVARCHAR(50) = 'Per Unit'
			,@COST_METHOD_PERCENTAGE AS NVARCHAR(50) = 'Percentage'
			,@COST_METHOD_AMOUNT AS NVARCHAR(50) = 'Amount'

	DECLARE @strItemNo AS NVARCHAR(50)
			,@strUnitMeasure AS NVARCHAR(50)
			,@intItemId AS INT
END 

-- Check if there are receipt charges to process
BEGIN 	
	IF NOT EXISTS (SELECT TOP 1 1 FROM tblICInventoryReceiptCharge WHERE intInventoryReceiptId = @intInventoryReceiptId)
	BEGIN
		-- Exit and do nothing. 
		GOTO _Exit
	END
END

-- Validate for cyclic computations
BEGIN 
	DECLARE @intCyclicOtherChargesItemId AS INT 
			,@strCyclicOtherChargesItem AS NVARCHAR(50)
			,@intCyclicSurchargeOnOtherChargesItemId AS INT
			,@strCyclicSurchargeOnOtherChargesItem AS NVARCHAR(50)

	SELECT	@intCyclicOtherChargesItemId = OtherChargesItem.intItemId
			,@strCyclicOtherChargesItem = OtherChargesItem.strItemNo
			,@intCyclicSurchargeOnOtherChargesItemId = SurchargeOnOtherChargesItem.intItemId
			,@strCyclicSurchargeOnOtherChargesItem = SurchargeOnOtherChargesItem.strItemNo
			--,CyclicSurchargeOnOtherChargesItem.intItemId			
	FROM	dbo.tblICInventoryReceiptItem ReceiptItem INNER JOIN dbo.tblICInventoryReceiptCharge OtherCharges
				ON ReceiptItem.intInventoryReceiptId = OtherCharges.intInventoryReceiptId
			INNER JOIN dbo.tblICItem OtherChargesItem 
				ON OtherChargesItem.intItemId = OtherCharges.intChargeId
			LEFT JOIN dbo.tblICItem SurchargeOnOtherChargesItem
				ON SurchargeOnOtherChargesItem.intItemId = OtherChargesItem.intOnCostTypeId				
			LEFT JOIN dbo.tblICInventoryReceiptCharge CyclicOtherCharges
				ON CyclicOtherCharges.intChargeId = SurchargeOnOtherChargesItem.intOnCostTypeId
			LEFT JOIN dbo.tblICItem CyclicSurchargeOnOtherChargesItem 
				ON CyclicSurchargeOnOtherChargesItem.intItemId = CyclicOtherCharges.intChargeId
	WHERE	CyclicSurchargeOnOtherChargesItem.intItemId IS NOT NULL 
			AND ReceiptItem.intInventoryReceiptId = @intInventoryReceiptId
			
	IF @intCyclicOtherChargesItemId IS NOT NULL 
	BEGIN 
		-- 'Cyclic situation found. Unable to compute surcharge because {Item X} depends on {Item Y} and vice-versa.'
		RAISERROR(51156, 11, 1, @strCyclicOtherChargesItem, @strCyclicSurchargeOnOtherChargesItem)  
		GOTO _Exit  
	END 
END 

-- Calculate the surcharge
BEGIN 
	-- Do a loop until all the surcharges are calculated. 
	WHILE EXISTS (
		SELECT TOP 1 1 
		FROM	dbo.tblICInventoryReceiptItem ReceiptItem INNER JOIN dbo.tblICInventoryReceiptCharge Surcharge	
					ON ReceiptItem.intInventoryReceiptId = Charge.intInventoryReceiptId
				INNER JOIN dbo.tblICItem SurchargeItem 
					ON SurchargeItem.intItemId = Surcharge.intChargeId
				LEFT JOIN dbo.tblICInventoryReceiptChargePerItem SurchargedOtherCharges
					ON SurchargedOtherCharges.intChargeId = SurchargeItem.intOnCostTypeId
					AND SurchargedOtherCharges.intEntityVendorId = Surcharge.intEntityVendorId	
					AND SurchargedOtherCharges.intInventoryReceiptId = Surcharge.intInventoryReceiptId	
		WHERE	ReceiptItem.intInventoryReceiptId = @intInventoryReceiptId
				AND Surcharge.strCostMethod = @COST_METHOD_PERCENTAGE -- cost method is limited to percentage
				AND SurchargeItem.intOnCostTypeId IS NOT NULL -- it is a surcharge item
				AND SurchargedOtherCharges.dblCalculatedAmount IS NOT NULL -- there is a surcharged amount
	)
	BEGIN 
		INSERT INTO dbo.tblICInventoryReceiptChargePerItem (
				[intInventoryReceiptId]
				,[intInventoryReceiptChargeId] 
				,[intInventoryReceiptItemId] 
				,[intChargeId] 
				,[intEntityVendorId] 
				,[dblCalculatedAmount] 
				,[intContractId]
		)
		SELECT	[intInventoryReceiptId]			= ReceiptItem.intInventoryReceiptId
				,[intInventoryReceiptChargeId]	= Surcharge.intInventoryReceiptChargeId
				,[intInventoryReceiptItemId]	= ReceiptItem.intInventoryReceiptItemId
				,[intChargeId]					= Charge.intChargeId
				,[intEntityVendorId]			= Charge.intEntityVendorId
				,[dblCalculatedAmount]			= (ISNULL(Charge.dblRate, 0) / 100) * SurchargedOtherCharges.dblCalculatedAmount
				,[intContractId]				= Surcharge.intContractId
		FROM	dbo.tblICInventoryReceiptItem ReceiptItem INNER JOIN dbo.tblICInventoryReceiptCharge Surcharge	
					ON ReceiptItem.intInventoryReceiptId = Charge.intInventoryReceiptId
				INNER JOIN dbo.tblICItem SurchargeItem 
					ON SurchargeItem.intItemId = Surcharge.intChargeId
				LEFT JOIN dbo.tblICInventoryReceiptChargePerItem SurchargedOtherCharges
					ON SurchargedOtherCharges.intChargeId = SurchargeItem.intOnCostTypeId
					AND SurchargedOtherCharges.intEntityVendorId = Surcharge.intEntityVendorId
					AND SurchargedOtherCharges.intInventoryReceiptId = Surcharge.intInventoryReceiptId	
		WHERE	ReceiptItem.intInventoryReceiptId = @intInventoryReceiptId
				AND Surcharge.strCostMethod = @COST_METHOD_PERCENTAGE -- cost method is limited to percentage
				AND SurchargeItem.intOnCostTypeId IS NOT NULL -- it is a surcharge item
				AND SurchargedOtherCharges.dblCalculatedAmount IS NOT NULL -- there is a surcharged amount
				AND (
					Surcharge.intContractId IS NULL 
					OR (
						Surcharge.intContractId IS NOT NULL 
						AND Surcharge.intContractId = SurchargedOtherCharges.intContractId
					)
				)
	END 

	-- Check if there are missing calculations for surcharges. 
	DECLARE @surchargeName AS NVARCHAR(50)
			,@surchargeId AS INT 

	SELECT TOP 1 
			@surchargeId = SurchargeItem.intItemId
			,@surchargeName = SurchargeItem.strItemNo
	FROM	dbo.tblICInventoryReceiptItem ReceiptItem INNER JOIN dbo.tblICInventoryReceiptCharge Surcharge	
				ON ReceiptItem.intInventoryReceiptId = Charge.intInventoryReceiptId
			INNER JOIN dbo.tblICItem SurchargeItem 
				ON SurchargeItem.intItemId = Surcharge.intChargeId
			LEFT JOIN dbo.tblICInventoryReceiptChargePerItem CalculatedSurcharges
				ON CalculatedSurcharges.intChargeId = SurchargeItem.intItemId
				AND CalculatedSurcharges.intInventoryReceiptChargeId = Surcharge.intInventoryReceiptChargeId 
	WHERE	ReceiptItem.intInventoryReceiptId = @intInventoryReceiptId
			AND Surcharge.strCostMethod = @COST_METHOD_PERCENTAGE -- cost method is limited to percentage
			AND SurchargeItem.intOnCostTypeId IS NOT NULL -- it is a surcharge item
			AND CalculatedSurcharges.intInventoryReceiptChargePerItemId IS NULL -- if null, the surcharge was not calculated. 

	IF @surchargeId IS NOT NULL 
	BEGIN 
		-- 'Unable to compute the surcharge for %s.'
		RAISERROR(51157, 11, 1, @surchargeName)  
		GOTO _Exit
	END 
END 


_Exit: