CREATE PROCEDURE [dbo].[uspICCalculateInventoryReceiptOtherCharges]
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

			,@INVENTORY_RECEIPT_TYPE AS INT = 4
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


-- Do the validation
BEGIN 
	-- Check if there are receipt charges to process
	IF NOT EXISTS (SELECT TOP 1 1 FROM tblICInventoryReceiptCharge WHERE intInventoryReceiptId = @intInventoryReceiptId)
	BEGIN
		-- Exit and do nothing. 
		GOTO _Exit
	END
END

-- Clear any existing records in the tblICInventoryReceiptChargePerItem table
BEGIN 
	DELETE tblICInventoryReceiptChargePerItem
	WHERE intInventoryReceiptId = @intInventoryReceiptId
END 

-- Calculate the cost method for "Per Unit"
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
			,[ysnAccrue]
			,[ysnPrice]
			,[ysnInventoryCost]
	)
	SELECT	[intInventoryReceiptId]			= ReceiptItem.intInventoryReceiptId
			,[intInventoryReceiptChargeId]	= Charge.intInventoryReceiptChargeId
			,[intInventoryReceiptItemId]	= ReceiptItem.intInventoryReceiptItemId
			,[intChargeId]					= Charge.intChargeId
			,[intEntityVendorId]			= Charge.intEntityVendorId
			,[dblCalculatedAmount]			= Charge.dblRate 
												* dbo.fnCalculateQtyBetweenUOM(ReceiptItem.intUnitMeasureId, dbo.fnGetMatchingItemUOMId(ReceiptItem.intItemId, Charge.intCostUOMId), ReceiptItem.dblOpenReceive) 
			,[intContractId]				= Charge.intContractId
			,[strAllocateCostBy]			= Charge.strAllocateCostBy
			,[ysnAccrue]					= Charge.ysnAccrue
			,[ysnPrice]						= Charge.ysnPrice
			,[ysnInventoryCost]				= Charge.ysnInventoryCost
	FROM	dbo.tblICInventoryReceiptItem ReceiptItem INNER JOIN dbo.tblICInventoryReceiptCharge Charge	
				ON ReceiptItem.intInventoryReceiptId = Charge.intInventoryReceiptId
			INNER JOIN dbo.tblICItem Item 
				ON Item.intItemId = Charge.intChargeId				
	WHERE	ReceiptItem.intInventoryReceiptId = @intInventoryReceiptId
			AND Charge.strCostMethod = @COST_METHOD_PER_UNIT
			AND (
				Charge.intContractId IS NULL 
				OR (
					Charge.intContractId IS NOT NULL 
					AND ReceiptItem.intOrderId = Charge.intContractId
				)	
			)
			AND Item.intOnCostTypeId IS NULL 
			AND ISNULL(ReceiptItem.intOwnershipType, @OWNERSHIP_TYPE_Own) = @OWNERSHIP_TYPE_Own

	-- Check if the calculated values are valid. 
	BEGIN 
		SET @intItemId = NULL 

		SELECT	TOP 1 
				@strItemNo = Item.strItemNo
				,@strUnitMeasure = UOM.strUnitMeasure
				,@intItemId = Item.intItemId
		FROM	dbo.tblICInventoryReceiptChargePerItem ChargePerItem INNER JOIN dbo.tblICInventoryReceiptItem ReceiptItem
					ON ChargePerItem.intInventoryReceiptItemId = ReceiptItem.intInventoryReceiptItemId		
				INNER JOIN dbo.tblICInventoryReceiptCharge Charge	
					ON Charge.intInventoryReceiptChargeId = ChargePerItem.intInventoryReceiptChargeId
				LEFT JOIN tblICItem Item
					ON Item.intItemId = ReceiptItem.intItemId					
				LEFT JOIN tblICItemUOM ChargeUOM
					ON ChargeUOM.intItemUOMId = Charge.intCostUOMId
				LEFT JOIN tblICUnitMeasure UOM
					ON UOM.intUnitMeasureId = ChargeUOM.intUnitMeasureId
		WHERE	ChargePerItem.intInventoryReceiptId = @intInventoryReceiptId 
				AND ChargePerItem.dblCalculatedAmount IS NULL

		IF @intItemId IS NOT NULL 
		BEGIN 
			-- 'Unable to calculate the Other Charges per unit. Please check if UOM {Unit of Measure} is assigned to item {Item}.'
			RAISERROR(51163, 11, 1, @strUnitMeasure, @strItemNo)  
			GOTO _Exit
		END 
	END 
END 

-- Calculate the cost method for "Percentage"
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
			,[ysnAccrue]
			,[ysnPrice]
			,[ysnInventoryCost]
	)
	SELECT	[intInventoryReceiptId]			= ReceiptItem.intInventoryReceiptId
			,[intInventoryReceiptChargeId]	= Charge.intInventoryReceiptChargeId
			,[intInventoryReceiptItemId]	= ReceiptItem.intInventoryReceiptItemId
			,[intChargeId]					= Charge.intChargeId
			,[intEntityVendorId]			= Charge.intEntityVendorId
			,[dblCalculatedAmount]			=	(ISNULL(Charge.dblRate, 0) / 100)
												* ReceiptItem.dblOpenReceive
												* ReceiptItem.dblUnitCost
			,[intContractId]				= Charge.intContractId
			,[strAllocateCostBy]			= Charge.strAllocateCostBy
			,[ysnAccrue]					= Charge.ysnAccrue
			,[ysnPrice]						= Charge.ysnPrice
			,[ysnInventoryCost]				= Charge.ysnInventoryCost
	FROM	dbo.tblICInventoryReceiptItem ReceiptItem INNER JOIN dbo.tblICInventoryReceiptCharge Charge	
				ON ReceiptItem.intInventoryReceiptId = Charge.intInventoryReceiptId
			INNER JOIN dbo.tblICItem Item 
				ON Item.intItemId = Charge.intChargeId				
	WHERE	ReceiptItem.intInventoryReceiptId = @intInventoryReceiptId
			AND Charge.strCostMethod = @COST_METHOD_PERCENTAGE
			AND (
				Charge.intContractId IS NULL 
				OR (
					Charge.intContractId IS NOT NULL 
					AND ReceiptItem.intOrderId = Charge.intContractId
				)
			)
			AND Item.intOnCostTypeId IS NULL 
			AND ISNULL(ReceiptItem.intOwnershipType, @OWNERSHIP_TYPE_Own) = @OWNERSHIP_TYPE_Own
END 

-- Calculate the cost method for "Amount" or Fixed Amount. 
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
			,[ysnAccrue]
			,[ysnPrice]
			,[ysnInventoryCost]
	)
	SELECT	[intInventoryReceiptId]			= ReceiptItem.intInventoryReceiptId
			,[intInventoryReceiptChargeId]	= Charge.intInventoryReceiptChargeId
			,[intInventoryReceiptItemId]	= ReceiptItem.intInventoryReceiptItemId
			,[intChargeId]					= Charge.intChargeId
			,[intEntityVendorId]			= Charge.intEntityVendorId
			,[dblCalculatedAmount]			= Charge.dblRate
			,[intContractId]				= Charge.intContractId
			,[strAllocateCostBy]			= Charge.strAllocateCostBy
			,[ysnAccrue]					= Charge.ysnAccrue
			,[ysnPrice]						= Charge.ysnPrice
			,[ysnInventoryCost]				= Charge.ysnInventoryCost
	FROM	dbo.tblICInventoryReceiptItem ReceiptItem INNER JOIN dbo.tblICInventoryReceiptCharge Charge	
				ON ReceiptItem.intInventoryReceiptId = Charge.intInventoryReceiptId
			INNER JOIN dbo.tblICItem Item 
				ON Item.intItemId = Charge.intChargeId				
	WHERE	ReceiptItem.intInventoryReceiptId = @intInventoryReceiptId
			AND Charge.strCostMethod = @COST_METHOD_AMOUNT
			AND (
				Charge.intContractId IS NULL 
				OR (
					Charge.intContractId IS NOT NULL 
					AND ReceiptItem.intOrderId = Charge.intContractId
				)	
			)
			AND Item.intOnCostTypeId IS NULL 
			AND ISNULL(ReceiptItem.intOwnershipType, @OWNERSHIP_TYPE_Own) = @OWNERSHIP_TYPE_Own
END 

-- Update the Other Charge amounts
BEGIN 
	UPDATE	Charge
	SET		dblAmount = ISNULL(CalculatedCharges.dblAmount, 0)
	FROM	dbo.tblICInventoryReceiptCharge Charge 	INNER JOIN dbo.tblICItem Item 
				ON Item.intItemId = Charge.intChargeId		
			LEFT JOIN (
					SELECT	dblAmount = SUM(dblCalculatedAmount)
							,intInventoryReceiptChargeId
					FROM	dbo.tblICInventoryReceiptChargePerItem
					WHERE	intInventoryReceiptId = @intInventoryReceiptId
					GROUP BY intInventoryReceiptChargeId
			) CalculatedCharges
				ON CalculatedCharges.intInventoryReceiptChargeId = Charge.intInventoryReceiptChargeId
	WHERE	Charge.intInventoryReceiptId = @intInventoryReceiptId
			AND Item.intOnCostTypeId IS NULL
END 

-- Exit point
_Exit: