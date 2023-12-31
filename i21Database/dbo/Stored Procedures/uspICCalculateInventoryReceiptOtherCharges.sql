﻿CREATE PROCEDURE [dbo].[uspICCalculateInventoryReceiptOtherCharges]
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
			,@strOtherCharge AS NVARCHAR(50)
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

-- Get the functional currency
BEGIN 
	DECLARE @intFunctionalCurrencyId AS INT
	SET @intFunctionalCurrencyId = dbo.fnSMGetDefaultCurrency('FUNCTIONAL') 
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
			,[intContractDetailId]
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
			,[dblCalculatedAmount]			= ROUND (			
												Charge.dblRate 
												* dbo.fnCalculateQtyBetweenUOM(
													ISNULL(ReceiptItem.intWeightUOMId, ReceiptItem.intUnitMeasureId)
													, dbo.fnGetMatchingItemUOMId(ReceiptItem.intItemId, Charge.intCostUOMId)
													, CASE WHEN ReceiptItem.intWeightUOMId IS NOT NULL THEN ISNULL(ReceiptItem.dblNet, 0) ELSE ISNULL(ReceiptItem.dblOpenReceive, 0) END 
												)
												, 2
											 )
			,[intContractId]				= Charge.intContractId
			,[intContractDetailId]			= Charge.intContractDetailId
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
					AND ReceiptItem.intLineNo = Charge.intContractDetailId
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
				,@strOtherCharge = ItemOtherCharge.strItemNo
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
				--For Other Charge
				LEFT JOIN tblICItem ItemOtherCharge
					ON ItemOtherCharge.intItemId = ChargePerItem.intChargeId
		WHERE	ChargePerItem.intInventoryReceiptId = @intInventoryReceiptId 
				AND ChargePerItem.dblCalculatedAmount IS NULL

		IF @intItemId IS NOT NULL 
		BEGIN 
			-- 'Unable to calculate {Other Charge Item} as {Unit of Measure} is not found in {Item} > UOM setup.'
			EXEC uspICRaiseError 80050, @strOtherCharge, @strUnitMeasure, @strItemNo;
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
			,[intContractDetailId]
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
			,[dblCalculatedAmount]			= ROUND (
												(ISNULL(Charge.dblRate, 0) / 100)
												*  
												CASE 
													WHEN ISNULL(Receipt.intCurrencyId, @intFunctionalCurrencyId) <> @intFunctionalCurrencyId AND ISNULL(ReceiptItem.dblForexRate, 0) <> 0 THEN 
														-- Convert the line total to transaction currency. 
														ISNULL(ReceiptItem.dblLineTotal, 0) * ReceiptItem.dblForexRate
													ELSE 
														ISNULL(ReceiptItem.dblLineTotal, 0)
												END 
												* 
												-- and then convert the transaction currency to the other charge currency. 
												CASE WHEN ISNULL(Charge.intCurrencyId, Receipt.intCurrencyId) <> @intFunctionalCurrencyId AND ISNULL(Charge.dblForexRate, 0) <> 0 THEN 
														1 / Charge.dblForexRate
													ELSE 
														1
												END 
											
												--ISNULL(ReceiptItem.dblLineTotal, ReceiptItem.dblOpenReceive * ReceiptItem.dblUnitCost) 
												, 2
											)
			,[intContractId]				= Charge.intContractId
			,[intContractDetailId]			= Charge.intContractDetailId
			,[strAllocateCostBy]			= Charge.strAllocateCostBy
			,[ysnAccrue]					= Charge.ysnAccrue
			,[ysnPrice]						= Charge.ysnPrice
			,[ysnInventoryCost]				= Charge.ysnInventoryCost
	FROM	dbo.tblICInventoryReceiptItem ReceiptItem INNER JOIN dbo.tblICInventoryReceiptCharge Charge	
				ON ReceiptItem.intInventoryReceiptId = Charge.intInventoryReceiptId
			INNER JOIN dbo.tblICItem Item 
				ON Item.intItemId = Charge.intChargeId
			INNER JOIN tblICInventoryReceipt Receipt
				ON Receipt.intInventoryReceiptId = ReceiptItem.intInventoryReceiptId	
	WHERE	ReceiptItem.intInventoryReceiptId = @intInventoryReceiptId
			AND Charge.strCostMethod = @COST_METHOD_PERCENTAGE
			AND (
				Charge.intContractId IS NULL 
				OR (
					Charge.intContractId IS NOT NULL 
					AND ReceiptItem.intOrderId = Charge.intContractId
					AND ReceiptItem.intLineNo = Charge.intContractDetailId
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
			,[intContractDetailId]
			,[strAllocateCostBy]
			,[ysnAccrue]
			,[ysnPrice]
			,[ysnInventoryCost]
	)
	SELECT	[intInventoryReceiptId]			= Receipt.intInventoryReceiptId
			,[intInventoryReceiptChargeId]	= Charge.intInventoryReceiptChargeId
			,[intInventoryReceiptItemId]	= NULL 
			,[intChargeId]					= Charge.intChargeId
			,[intEntityVendorId]			= Charge.intEntityVendorId
			,[dblCalculatedAmount]			= ROUND(Charge.dblAmount, 2)
			,[intContractId]				= Charge.intContractId
			,[intContractDetailId]			= Charge.intContractDetailId
			,[strAllocateCostBy]			= Charge.strAllocateCostBy
			,[ysnAccrue]					= Charge.ysnAccrue
			,[ysnPrice]						= Charge.ysnPrice
			,[ysnInventoryCost]				= Charge.ysnInventoryCost
	FROM	dbo.tblICInventoryReceipt Receipt INNER JOIN dbo.tblICInventoryReceiptCharge Charge	
				ON Receipt.intInventoryReceiptId = Charge.intInventoryReceiptId
			INNER JOIN dbo.tblICItem Item 
				ON Item.intItemId = Charge.intChargeId				
	WHERE	Receipt.intInventoryReceiptId = @intInventoryReceiptId
			AND Charge.strCostMethod = @COST_METHOD_AMOUNT
			AND Item.intOnCostTypeId IS NULL 			
END 

-- Update the Other Charge amounts
-- If it is in sub-currency, convert it back to the currency amount.
BEGIN 
	UPDATE	Charge
	SET		dblAmount = ROUND(	
							ISNULL(CalculatedCharges.dblAmount, 0)
							/ 
							CASE	WHEN Charge.ysnSubCurrency = 1 THEN 
										CASE WHEN ISNULL(Charge.intCent, 1) <> 0 THEN ISNULL(Charge.intCent, 1) ELSE 1 END 
									ELSE 
										1
							END 
						, 2)						

	FROM	dbo.tblICInventoryReceipt Receipt INNER JOIN dbo.tblICInventoryReceiptCharge Charge 	
				ON Receipt.intInventoryReceiptId = Charge.intInventoryReceiptId
			INNER JOIN dbo.tblICItem Item 
				ON Item.intItemId = Charge.intChargeId		
			LEFT JOIN (
					SELECT	dblAmount = SUM(dblCalculatedAmount)
							,intInventoryReceiptChargeId
					FROM	dbo.tblICInventoryReceiptChargePerItem
					WHERE	intInventoryReceiptId = @intInventoryReceiptId
					GROUP BY intInventoryReceiptChargeId
			) CalculatedCharges
				ON CalculatedCharges.intInventoryReceiptChargeId = Charge.intInventoryReceiptChargeId
	WHERE	Receipt.intInventoryReceiptId = @intInventoryReceiptId
			AND Item.intOnCostTypeId IS NULL
			AND Charge.strCostMethod <> @COST_METHOD_AMOUNT
END 

-- Exit point
_Exit: