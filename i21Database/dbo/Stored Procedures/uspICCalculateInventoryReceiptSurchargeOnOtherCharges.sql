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
	DECLARE @intOtherChargesItemId AS INT 
			,@strOtherChargesItem AS NVARCHAR(50)
			,@intSurchargeItemId AS INT
			,@strSurchargeItem AS NVARCHAR(50)

	SELECT	@intOtherChargesItemId = OtherChargesItem.intItemId
			,@strOtherChargesItem = OtherChargesItem.strItemNo
			,@intSurchargeItemId = SurchargeItem.intItemId
			,@strSurchargeItem = SurchargeItem.strItemNo
	FROM	dbo.tblICInventoryReceiptCharge OtherCharges INNER JOIN dbo.tblICItem OtherChargesItem 
				ON OtherChargesItem.intItemId = OtherCharges.intChargeId

			LEFT JOIN dbo.tblICInventoryReceiptCharge Surcharge
				ON Surcharge.intChargeId = OtherChargesItem.intOnCostTypeId
			INNER JOIN dbo.tblICItem SurchargeItem 
				ON SurchargeItem.intItemId = Surcharge.intChargeId			
					
	WHERE	SurchargeItem.intOnCostTypeId = OtherChargesItem.intItemId -- If equal, there is a cyclic reference. 
			AND OtherCharges.intInventoryReceiptId = @intInventoryReceiptId
			
	IF @intOtherChargesItemId IS NOT NULL AND @intSurchargeItemId IS NOT NULL 
	BEGIN 
		-- 'Cyclic situation found. Unable to compute surcharge because {Item X} depends on {Item Y} and vice-versa.'
		RAISERROR(51164, 11, 1, @strSurchargeItem, @strOtherChargesItem)  
		GOTO _Exit  
	END 
END 

-- Calculate the surcharge
BEGIN 
	DECLARE @intCount AS INT = 0
			,@intLastCount AS INT 
			,@intInfiniteLoopStopper AS INT = 1

	-- Do a loop until all the surcharges are calculated. 
	WHILE EXISTS (
		SELECT TOP 1 1 
		FROM	dbo.tblICInventoryReceiptCharge Surcharge INNER JOIN dbo.tblICItem SurchargeItem 
					ON SurchargeItem.intItemId = Surcharge.intChargeId
				LEFT JOIN dbo.tblICInventoryReceiptChargePerItem SurchargedOtherCharges
					ON SurchargedOtherCharges.intChargeId = SurchargeItem.intOnCostTypeId
					AND SurchargedOtherCharges.intEntityVendorId = Surcharge.intEntityVendorId	
					AND SurchargedOtherCharges.intInventoryReceiptId = Surcharge.intInventoryReceiptId	
				LEFT JOIN dbo.tblICInventoryReceiptChargePerItem CalculatedSurcharge
					ON CalculatedSurcharge.intChargeId = Surcharge.intChargeId
					AND CalculatedSurcharge.intInventoryReceiptChargeId = Surcharge.intInventoryReceiptChargeId
		WHERE	Surcharge.intInventoryReceiptId = @intInventoryReceiptId
				AND Surcharge.strCostMethod = @COST_METHOD_PERCENTAGE		-- cost method is limited to percentage
				AND SurchargedOtherCharges.intChargeId IS NOT NULL			-- it is a surcharge item
				AND SurchargedOtherCharges.dblCalculatedAmount IS NOT NULL	-- there is a surcharged amount
				AND CalculatedSurcharge.intInventoryReceiptChargeId IS NULL -- surcharge is not yet calculated. 
				AND (
					Surcharge.intContractId IS NULL 
					OR (
						Surcharge.intContractId IS NOT NULL 
						AND Surcharge.intContractId = SurchargedOtherCharges.intContractId
					)
				)
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
				,[strAllocateCostBy]
				,[strCostBilledBy]
				,[ysnInventoryCost]
		)
		SELECT	[intInventoryReceiptId]			= Surcharge.intInventoryReceiptId
				,[intInventoryReceiptChargeId]	= Surcharge.intInventoryReceiptChargeId
				,[intInventoryReceiptItemId]	= SurchargedOtherCharges.intInventoryReceiptItemId
				,[intChargeId]					= Surcharge.intChargeId
				,[intEntityVendorId]			= Surcharge.intEntityVendorId
				,[dblCalculatedAmount]			= (ISNULL(Surcharge.dblRate, 0) / 100) * SurchargedOtherCharges.dblCalculatedAmount
				,[intContractId]				= Surcharge.intContractId
				,[strAllocateCostBy]			= Surcharge.strAllocateCostBy
				,[strCostBilledBy]				= Surcharge.strCostBilledBy
				,[ysnInventoryCost]				= Surcharge.ysnInventoryCost
		FROM	dbo.tblICInventoryReceiptCharge Surcharge INNER JOIN dbo.tblICItem SurchargeItem 
					ON SurchargeItem.intItemId = Surcharge.intChargeId
				LEFT JOIN dbo.tblICInventoryReceiptChargePerItem SurchargedOtherCharges
					ON SurchargedOtherCharges.intChargeId = SurchargeItem.intOnCostTypeId
					AND SurchargedOtherCharges.intEntityVendorId = Surcharge.intEntityVendorId
					AND SurchargedOtherCharges.intInventoryReceiptId = Surcharge.intInventoryReceiptId	
				LEFT JOIN dbo.tblICInventoryReceiptChargePerItem CalculatedSurcharge
					ON CalculatedSurcharge.intChargeId = Surcharge.intChargeId
					AND CalculatedSurcharge.intInventoryReceiptChargeId = Surcharge.intInventoryReceiptChargeId
		WHERE	Surcharge.intInventoryReceiptId = @intInventoryReceiptId
				AND Surcharge.strCostMethod = @COST_METHOD_PERCENTAGE		-- cost method is limited to percentage
				AND SurchargedOtherCharges.intChargeId IS NOT NULL			-- it is a surcharge item
				AND SurchargedOtherCharges.dblCalculatedAmount IS NOT NULL	-- there is a surcharged amount
				AND CalculatedSurcharge.intInventoryReceiptChargeId IS NULL -- surcharge is not yet calculated. 
				AND (
					Surcharge.intContractId IS NULL 
					OR (
						Surcharge.intContractId IS NOT NULL 
						AND Surcharge.intContractId = SurchargedOtherCharges.intContractId
					)
				)

		-- Check if the SP needs to break from an infinite loop
		BEGIN 
			SELECT	@intCount = COUNT(1) 
			FROM	tblICInventoryReceiptChargePerItem
			WHERE	intInventoryReceiptId = @intInventoryReceiptId

			IF ISNULL(@intCount, 0) = ISNULL(@intLastCount, 0)
			BEGIN
				SET @intInfiniteLoopStopper += 1
			END 

			SET @intLastCount = @intCount

			IF @intInfiniteLoopStopper > 3 
			BEGIN
				GOTO _BreakLoop
			END 
		END 
	END 

	_BreakLoop: 

	-- Check if there are missing calculations for surcharges. 
	DECLARE @surchargeName AS NVARCHAR(50)
			,@surchargeId AS INT 

	SELECT TOP 1 
			@surchargeId = SurchargeItem.intItemId
			,@surchargeName = SurchargeItem.strItemNo
	FROM	dbo.tblICInventoryReceiptCharge Surcharge INNER JOIN dbo.tblICItem SurchargeItem 
				ON SurchargeItem.intItemId = Surcharge.intChargeId
			LEFT JOIN dbo.tblICInventoryReceiptChargePerItem CalculatedSurcharges
				ON CalculatedSurcharges.intChargeId = SurchargeItem.intItemId
				AND CalculatedSurcharges.intInventoryReceiptChargeId = Surcharge.intInventoryReceiptChargeId 
	WHERE	Surcharge.intInventoryReceiptId = @intInventoryReceiptId
			AND Surcharge.strCostMethod = @COST_METHOD_PERCENTAGE -- cost method is limited to percentage
			AND SurchargeItem.intOnCostTypeId IS NOT NULL -- it is a surcharge item
			AND CalculatedSurcharges.intInventoryReceiptChargePerItemId IS NULL -- if null, the surcharge was not calculated. 

	IF @surchargeId IS NOT NULL 
	BEGIN 
		-- 'Unable to compute the surcharge for %s.'
		RAISERROR(51165, 11, 1, @surchargeName)  
		GOTO _Exit
	END 
END 


_Exit: