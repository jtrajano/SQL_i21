CREATE PROCEDURE [dbo].[uspICCalculateInventoryShipmentSurchargeOnOtherCharges]
	@intInventoryShipmentId AS INT 
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

			,@INVENTORY_SHIPMENT_TYPE AS INT = 4
			,@STARTING_NUMBER_BATCH AS INT = 3  
			,@ACCOUNT_CATEGORY_TO_COUNTER_INVENTORY AS NVARCHAR(255) = 'AP Clearing'
		
			,@OWNERSHIP_TYPE_Own AS INT = 1
			,@OWNERSHIP_TYPE_Storage AS INT = 2
			,@OWNERSHIP_TYPE_ConsignedPurchase AS INT = 3
			,@OWNERSHIP_TYPE_ConsignedSale AS INT = 4

	DECLARE @strItemNo AS NVARCHAR(50)
			,@strUnitMeasure AS NVARCHAR(50)
			,@intItemId AS INT
END 

-- Check if there are shipment charges to process
BEGIN 	
	IF NOT EXISTS (SELECT TOP 1 1 FROM tblICInventoryShipmentCharge WHERE intInventoryShipmentId = @intInventoryShipmentId)
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
	FROM	dbo.tblICInventoryShipmentCharge OtherCharges INNER JOIN dbo.tblICItem OtherChargesItem 
				ON OtherChargesItem.intItemId = OtherCharges.intChargeId

			LEFT JOIN dbo.tblICInventoryShipmentCharge Surcharge
				ON Surcharge.intChargeId = OtherChargesItem.intOnCostTypeId
			INNER JOIN dbo.tblICItem SurchargeItem 
				ON SurchargeItem.intItemId = Surcharge.intChargeId			
					
	WHERE	SurchargeItem.intOnCostTypeId = OtherChargesItem.intItemId -- If equal, there is a cyclic reference. 
			AND OtherCharges.intInventoryShipmentId = @intInventoryShipmentId
			
	IF @intOtherChargesItemId IS NOT NULL AND @intSurchargeItemId IS NOT NULL 
	BEGIN 
		-- 'Cyclic situation found. Unable to compute surcharge because {Item X} depends on {Item Y} and vice-versa.'
		RAISERROR('Cyclic situation found. Unable to compute surcharge because %s depends on %s and vice-versa.', 11, 1, @strSurchargeItem, @strOtherChargesItem)  
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
		FROM	dbo.tblICInventoryShipmentCharge Surcharge INNER JOIN dbo.tblICItem SurchargeItem 
					ON SurchargeItem.intItemId = Surcharge.intChargeId
				LEFT JOIN dbo.tblICInventoryShipmentChargePerItem SurchargedOtherCharges
					ON SurchargedOtherCharges.intChargeId = SurchargeItem.intOnCostTypeId
					AND ISNULL(SurchargedOtherCharges.intEntityVendorId, 0) = ISNULL(Surcharge.intEntityVendorId, 0)
					AND SurchargedOtherCharges.intInventoryShipmentId = Surcharge.intInventoryShipmentId	
				LEFT JOIN dbo.tblICInventoryShipmentChargePerItem CalculatedSurcharge
					ON CalculatedSurcharge.intChargeId = Surcharge.intChargeId
					AND CalculatedSurcharge.intInventoryShipmentChargeId = Surcharge.intInventoryShipmentChargeId
		WHERE	Surcharge.intInventoryShipmentId = @intInventoryShipmentId
				AND Surcharge.strCostMethod = @COST_METHOD_PERCENTAGE		-- cost method is limited to percentage
				AND SurchargedOtherCharges.intChargeId IS NOT NULL			-- it is a surcharge item
				AND SurchargedOtherCharges.dblCalculatedAmount IS NOT NULL	-- there is a surcharged amount
				AND CalculatedSurcharge.intInventoryShipmentChargeId IS NULL -- surcharge is not yet calculated. 
				AND (
					Surcharge.intContractId IS NULL 
					OR (
						Surcharge.intContractId IS NOT NULL 
						AND Surcharge.intContractId = SurchargedOtherCharges.intContractId
						--AND Surcharge.intContractDetailId = SurchargedOtherCharges.intContractDetailId //removing this because Shipment could have many contract details/sequences per contract
					)
				)
	)
	BEGIN 
		INSERT INTO dbo.tblICInventoryShipmentChargePerItem (
				[intInventoryShipmentId]
				,[intInventoryShipmentChargeId] 
				,[intInventoryShipmentItemId] 
				,[intChargeId] 
				,[intEntityVendorId] 
				,[dblCalculatedAmount] 
				,[intContractId]
				,[intContractDetailId]
				,[strAllocatePriceBy]
				,[ysnAccrue]
				,[ysnPrice]
		)
		SELECT	[intInventoryShipmentId]			= Surcharge.intInventoryShipmentId
				,[intInventoryShipmentChargeId]	= Surcharge.intInventoryShipmentChargeId
				,[intInventoryShipmentItemId]	= SurchargedOtherCharges.intInventoryShipmentItemId
				,[intChargeId]					= Surcharge.intChargeId
				,[intEntityVendorId]			= Surcharge.intEntityVendorId
				,[dblCalculatedAmount]			= (ISNULL(Surcharge.dblRate, 0) / 100) * SurchargedOtherCharges.dblCalculatedAmount
				,[intContractId]				= Surcharge.intContractId
				,[intContractDetailId]			= SurchargedOtherCharges.intContractDetailId
				,[strAllocatePriceBy]			= Surcharge.strAllocatePriceBy
				,[ysnAccrue]					= Surcharge.ysnAccrue
				,[ysnPrice]						= Surcharge.ysnPrice
		FROM	dbo.tblICInventoryShipmentCharge Surcharge INNER JOIN dbo.tblICItem SurchargeItem 
					ON SurchargeItem.intItemId = Surcharge.intChargeId
				LEFT JOIN dbo.tblICInventoryShipmentChargePerItem SurchargedOtherCharges
					ON SurchargedOtherCharges.intChargeId = SurchargeItem.intOnCostTypeId
					AND ISNULL(SurchargedOtherCharges.intEntityVendorId, 0) = ISNULL(Surcharge.intEntityVendorId, 0)
					AND SurchargedOtherCharges.intInventoryShipmentId = Surcharge.intInventoryShipmentId	
				LEFT JOIN dbo.tblICInventoryShipmentChargePerItem CalculatedSurcharge
					ON CalculatedSurcharge.intChargeId = Surcharge.intChargeId
					AND CalculatedSurcharge.intInventoryShipmentChargeId = Surcharge.intInventoryShipmentChargeId
		WHERE	Surcharge.intInventoryShipmentId = @intInventoryShipmentId
				AND Surcharge.strCostMethod = @COST_METHOD_PERCENTAGE		-- cost method is limited to percentage
				AND SurchargedOtherCharges.intChargeId IS NOT NULL			-- it is a surcharge item
				AND SurchargedOtherCharges.dblCalculatedAmount IS NOT NULL	-- there is a surcharged amount
				AND CalculatedSurcharge.intInventoryShipmentChargeId IS NULL -- surcharge is not yet calculated. 
				AND (
					Surcharge.intContractId IS NULL 
					OR (
						Surcharge.intContractId IS NOT NULL 
						AND Surcharge.intContractId = SurchargedOtherCharges.intContractId
						--AND Surcharge.intContractDetailId = SurchargedOtherCharges.intContractDetailId //removing this because Shipment could have many contract details/sequences per contract
					)
				)

		-- Check if the SP needs to break from an infinite loop
		BEGIN 
			SELECT	@intCount = COUNT(1) 
			FROM	tblICInventoryShipmentChargePerItem
			WHERE	intInventoryShipmentId = @intInventoryShipmentId

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
	FROM	dbo.tblICInventoryShipmentCharge Surcharge INNER JOIN dbo.tblICItem SurchargeItem 
				ON SurchargeItem.intItemId = Surcharge.intChargeId
			LEFT JOIN dbo.tblICInventoryShipmentChargePerItem CalculatedSurcharges
				ON CalculatedSurcharges.intChargeId = SurchargeItem.intItemId
				AND CalculatedSurcharges.intInventoryShipmentChargeId = Surcharge.intInventoryShipmentChargeId 
	WHERE	Surcharge.intInventoryShipmentId = @intInventoryShipmentId
			AND Surcharge.strCostMethod = @COST_METHOD_PERCENTAGE -- cost method is limited to percentage
			AND SurchargeItem.intOnCostTypeId IS NOT NULL -- it is a surcharge item
			AND CalculatedSurcharges.intInventoryShipmentChargePerItemId IS NULL -- if null, the surcharge was not calculated. 

	IF @surchargeId IS NOT NULL 
	BEGIN 
		-- 'Unable to compute the surcharge for %s. The On Cost for the surcharge could be missing. Also, the Vendor for both the surcharge and On Cost must match.'
		RAISERROR('Unable to compute the surcharge for %s. The On Cost for the surcharge could be missing. Also, the Vendor for both the surcharge and On Cost must match.', 11, 1, @surchargeName)  
		GOTO _Exit
	END 
END 

-- Update the Surcharge amounts
-- Also, the sub-currency amounts must be converted back the currency amounts.
BEGIN 
	UPDATE	Charge
	SET		dblAmount = ROUND(	
							ISNULL(CalculatedCharges.dblAmount, 0)
							/ CASE	WHEN Charge.ysnSubCurrency = 1 THEN 
										CASE WHEN ISNULL(Charge.intCent, 1) <> 0 THEN ISNULL(Charge.intCent, 1) ELSE 1 END 
									ELSE 
										1
							END 
						, 2)		
	FROM	dbo.tblICInventoryShipment Shipment INNER JOIN dbo.tblICInventoryShipmentCharge Charge 	
				ON Shipment.intInventoryShipmentId = Charge.intInventoryShipmentId
			INNER JOIN dbo.tblICItem Item 
				ON Item.intItemId = Charge.intChargeId		
			LEFT JOIN (
					SELECT	dblAmount = SUM(dblCalculatedAmount)
							,intInventoryShipmentChargeId
					FROM	dbo.tblICInventoryShipmentChargePerItem
					WHERE	intInventoryShipmentId = @intInventoryShipmentId
					GROUP BY intInventoryShipmentChargeId
			) CalculatedCharges
				ON CalculatedCharges.intInventoryShipmentChargeId = Charge.intInventoryShipmentChargeId
	WHERE	Charge.intInventoryShipmentId = @intInventoryShipmentId
			AND Item.intOnCostTypeId IS NOT NULL
END 

_Exit: