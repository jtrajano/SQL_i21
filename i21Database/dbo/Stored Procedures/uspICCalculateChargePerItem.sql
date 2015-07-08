﻿CREATE PROCEDURE [dbo].[uspICCalculateChargePerItem]
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

-- Calculate the cost method per Per Unit
BEGIN 
	INSERT INTO dbo.tblICInventoryReceiptChargePerItem (
			[intInventoryReceiptId]
			,[intInventoryReceiptChargeId] 
			,[intInventoryReceiptItemId] 
			,[intChargeId] 
			,[intEntityVendorId] 
			,[dblCalculatedAmount] 
	)
	SELECT	[intInventoryReceiptId]			= ReceiptItem.intInventoryReceiptId
			,[intInventoryReceiptChargeId]	= Charge.intInventoryReceiptChargeId
			,[intInventoryReceiptItemId]	= ReceiptItem.intInventoryReceiptItemId
			,[intChargeId]					= Charge.intChargeId
			,[intEntityVendorId]			= Charge.intEntityVendorId
			,[dblCalculatedAmount]			=	Charge.dblRate 
												* dbo.fnCalculateQtyBetweenUOM(ReceiptItem.intUnitMeasureId, dbo.fnGetMatchingItemUOMId(ReceiptItem.intItemId, Charge.intCostUOMId), ReceiptItem.dblOpenReceive) 
	FROM	dbo.tblICInventoryReceiptItem ReceiptItem INNER JOIN dbo.tblICInventoryReceiptCharge Charge	
				ON ReceiptItem.intInventoryReceiptId = Charge.intInventoryReceiptId
	WHERE	ReceiptItem.intInventoryReceiptId = @intInventoryReceiptId
			AND Charge.strCostMethod = @COST_METHOD_PER_UNIT

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
			RAISERROR(51154, 11, 1, @strUnitMeasure, @strItemNo)  
			GOTO _Exit
		END 
	END 
END 

-- Exit point
_Exit: