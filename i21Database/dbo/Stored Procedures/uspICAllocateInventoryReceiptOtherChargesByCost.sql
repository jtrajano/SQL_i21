CREATE PROCEDURE [dbo].[uspICAllocateInventoryReceiptOtherChargesByCost]
	@intInventoryReceiptId AS INT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

-- Constants
DECLARE @COST_METHOD_Per_Unit AS NVARCHAR(50) = 'Per Unit'
		,@COST_METHOD_Percentage AS NVARCHAR(50) = 'Percentage'
		,@COST_METHOD_Amount AS NVARCHAR(50) = 'Amount'

		,@ALLOCATE_COST_BY_Unit AS NVARCHAR(50) = 'Unit'
		,@ALLOCATE_COST_BY_Stock_Unit AS NVARCHAR(50) = 'Stock Unit'
		,@ALLOCATE_COST_BY_Weight AS NVARCHAR(50) = 'Weight'
		,@ALLOCATE_COST_BY_Cost AS NVARCHAR(50) = 'Cost'

		,@UNIT_TYPE_Weight AS NVARCHAR(50) = 'Weight'

-- Allocate by 'cost'
BEGIN 
	DECLARE @totalOtherCharges_AllocateByCost AS NUMERIC(38,20)
			,@totalCostOfAllItems AS NUMERIC(18,2)

	-- Get the total other charges with 'allocate cost' set to 'cost'. 
	SELECT	@totalOtherCharges_AllocateByCost = SUM(dblCalculatedAmount)
	FROM	dbo.tblICInventoryReceiptChargePerItem OtherCharge
	WHERE	OtherCharge.intInventoryReceiptId = @intInventoryReceiptId
			AND OtherCharge.intContractId IS NULL 
			AND OtherCharge.strAllocateCostBy = @ALLOCATE_COST_BY_Cost

	-- If there are no other charge to process, then exit.
	IF ISNULL(@totalOtherCharges_AllocateByCost, 0) = 0 
		GOTO _Exit;

	-- Get the total cost from all items (with or without contract)
	SELECT @totalCostOfAllItems = SUM(ISNULL(ReceiptItem.dblOpenReceive, 0) * ISNULL(ReceiptItem.dblUnitCost, 0))
	FROM	dbo.tblICInventoryReceipt Receipt INNER JOIN dbo.tblICInventoryReceiptItem ReceiptItem
				ON Receipt.intInventoryReceiptId = ReceiptItem.intInventoryReceiptId
			INNER JOIN dbo.tblICItemUOM ItemUOM
				ON ItemUOM.intItemUOMId = ReceiptItem.intUnitMeasureId
	WHERE	Receipt.intInventoryReceiptId = @intInventoryReceiptId

	-- Distribute the other charge by 'Cost'. 
	--IF ISNULL(@totalCostOfAllItems, 0) <> 0 
	--BEGIN 
	--	UPDATE	ReceiptItem
	--	SET		dblOtherCharges +=	(	@totalOtherCharges_AllocateByCost
	--									* (ISNULL(ReceiptItem.dblOpenReceive, 0) * ISNULL(ReceiptItem.dblUnitCost, 0))
	--									/ @totalCostOfAllItems
	--								)				 
	--	FROM	dbo.tblICInventoryReceipt Receipt INNER JOIN dbo.tblICInventoryReceiptItem ReceiptItem 
	--				ON Receipt.intInventoryReceiptId = ReceiptItem.intInventoryReceiptId	
	--			INNER JOIN dbo.tblICItemUOM ItemUOM
	--				ON ItemUOM.intItemUOMId = ReceiptItem.intUnitMeasureId
	--	WHERE	Receipt.intInventoryReceiptId = @intInventoryReceiptId						
	--END 
END 

_Exit: