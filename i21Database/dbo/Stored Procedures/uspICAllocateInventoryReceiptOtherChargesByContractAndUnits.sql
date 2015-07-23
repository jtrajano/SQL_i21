CREATE PROCEDURE [dbo].[uspICAllocateInventoryReceiptOtherChargesByContractAndUnits]
	@intInventoryReceiptId AS INT
	,@intContractId AS INT  
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

DECLARE	-- Receipt Types
		@RECEIPT_TYPE_Purchase_Contract AS NVARCHAR(50) = 'Purchase Contract'
		,@RECEIPT_TYPE_Purchase_Order AS NVARCHAR(50) = 'Purchase Order'
		,@RECEIPT_TYPE_Transfer_Order AS NVARCHAR(50) = 'Transfer Order'
		,@RECEIPT_TYPE_Direct AS NVARCHAR(50) = 'Direct'
		-- Source Types
		,@SOURCE_TYPE_None AS INT = 0
		,@SOURCE_TYPE_Scale AS INT = 1
		,@SOURCE_TYPE_Inbound_Shipment AS INT = 2
		,@SOURCE_TYPE_Transport AS INT = 3

-- Allocate cost by 'unit'
BEGIN 
	DECLARE @totalOtherChargesForContracts_AllocateByUnit AS NUMERIC(38,20)
			,@totalUnitOfAllItems AS NUMERIC(18, 6)

	-- Get the total other charges with 'allocate cost' set to 'unit'. 
	SELECT	@totalOtherChargesForContracts_AllocateByUnit = SUM(dblCalculatedAmount)
	FROM	dbo.tblICInventoryReceiptChargePerItem OtherCharge
	WHERE	OtherCharge.intInventoryReceiptId = @intInventoryReceiptId
			AND OtherCharge.intContractId = @intContractId
			AND OtherCharge.strAllocateCostBy = @ALLOCATE_COST_BY_Unit

	-- If there are no other charge to process, then exit.
	IF ISNULL(@totalOtherChargesForContracts_AllocateByUnit, 0) = 0 
		GOTO _Exit;

	-- Get the total units from the items that share the same contract id. 
	SELECT @totalUnitOfAllItems = SUM(dbo.fnCalculateStockUnitQty(ReceiptItem.dblOpenReceive, ItemUOM.dblUnitQty))
	FROM	dbo.tblICInventoryReceipt Receipt INNER JOIN dbo.tblICInventoryReceiptItem ReceiptItem
				ON Receipt.intInventoryReceiptId = ReceiptItem.intInventoryReceiptId
			INNER JOIN dbo.tblICItemUOM ItemUOM
				ON ItemUOM.intItemUOMId = ReceiptItem.intUnitMeasureId
	WHERE	Receipt.intInventoryReceiptId = @intInventoryReceiptId
			AND ReceiptItem.intOrderId = @intContractId

	-- Distribute the other charge by 'Unit'. 
	--IF ISNULL(@totalUnitOfAllItems, 0) <> 0
	--BEGIN 
	--	UPDATE	ReceiptItem
	--	SET		dblOtherCharges +=	(	@totalOtherChargesForContracts_AllocateByUnit
	--									* dbo.fnCalculateStockUnitQty(ReceiptItem.dblOpenReceive, ItemUOM.dblUnitQty)
	--									/ @totalUnitOfAllItems
	--								)				 
	--	FROM	dbo.tblICInventoryReceipt Receipt INNER JOIN dbo.tblICInventoryReceiptItem ReceiptItem 
	--				ON Receipt.intInventoryReceiptId = ReceiptItem.intInventoryReceiptId	
	--			INNER JOIN dbo.tblICItemUOM ItemUOM
	--				ON ItemUOM.intItemUOMId = ReceiptItem.intUnitMeasureId
	--	WHERE	Receipt.intInventoryReceiptId = @intInventoryReceiptId						
	--			AND Receipt.strReceiptType = @RECEIPT_TYPE_Purchase_Contract
	--			AND ReceiptItem.intOrderId = @intContractId
	--END
END 

_Exit: