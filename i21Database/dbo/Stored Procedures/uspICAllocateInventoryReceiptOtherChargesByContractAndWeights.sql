CREATE PROCEDURE [dbo].[uspICAllocateInventoryReceiptOtherChargesByContractAndWeights]
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

-- Allocate cost by 'weight'
BEGIN 
	DECLARE @totalOtherChargesForContracts_AllocateByWeight AS NUMERIC(38,20)
			,@totalWeightOfAllItems AS NUMERIC(18,6) 

	-- Get the total other charges with 'allocate cost' set to 'weight'. 
	SELECT	@totalOtherChargesForContracts_AllocateByWeight = SUM(dblCalculatedAmount)
	FROM	dbo.tblICInventoryReceiptChargePerItem OtherCharge
	WHERE	OtherCharge.intInventoryReceiptId = @intInventoryReceiptId
			AND OtherCharge.intContractId = @intContractId
			AND OtherCharge.strAllocateCostBy = @ALLOCATE_COST_BY_Weight

	-- If there are no other charge to process, then exit.
	IF ISNULL(@totalOtherChargesForContracts_AllocateByWeight, 0) = 0 
		GOTO _Exit;

	-- Validate for non-weight unit type for all items that share the same contract id. 
	BEGIN 
		DECLARE @invalidItem AS NVARCHAR(50)
				,@intInvalidItemId AS INT 

		SELECT	TOP 1 
				@intInvalidItemId = Item.intItemId 
				,@invalidItem = Item.strItemNo
		FROM	dbo.tblICInventoryReceipt Receipt INNER JOIN dbo.tblICInventoryReceiptItem ReceiptItem 
					ON Receipt.intInventoryReceiptId = ReceiptItem.intInventoryReceiptId	
				INNER JOIN dbo.tblICItem Item 
					ON Item.intItemId = ReceiptItem.intItemId 
				INNER JOIN dbo.tblICItemUOM ItemUOM
					ON ItemUOM.intItemUOMId = ReceiptItem.intUnitMeasureId
				LEFT JOIN dbo.tblICItemUOM StockUOM
					ON StockUOM.intItemId = ReceiptItem.intItemId
					AND StockUOM.ysnStockUnit = 1
				INNER JOIN dbo.tblICUnitMeasure UOM
					ON UOM.intUnitMeasureId = StockUOM.intUnitMeasureId
					AND UOM.strUnitType = @UNIT_TYPE_Weight
		WHERE	Receipt.intInventoryReceiptId = @intInventoryReceiptId						
				AND Receipt.strReceiptType = @RECEIPT_TYPE_Purchase_Contract
				AND ReceiptItem.intOrderId = @intContractId
				AND StockUOM.intItemUOMId IS NULL 							

		IF @intInvalidItemId IS NOT NULL 
		BEGIN 
			-- Unable to continue. Cost allocation is by Weight but stock unit for {Item} is not a weight type.
			RAISERROR(51166, 11, 1, @invalidItem) 
			GOTO _Exit 
		END 
	END

	-- Get the total weights from the items that share the same contract id. 
	SELECT @totalWeightOfAllItems = SUM(dbo.fnCalculateStockUnitQty(ReceiptItem.dblOpenReceive, ItemUOM.dblUnitQty))
	FROM	dbo.tblICInventoryReceipt Receipt INNER JOIN dbo.tblICInventoryReceiptItem ReceiptItem 
				ON Receipt.intInventoryReceiptId = ReceiptItem.intInventoryReceiptId	
			INNER JOIN dbo.tblICItem Item 
				ON Item.intItemId = ReceiptItem.intItemId 
			INNER JOIN dbo.tblICItemUOM ItemUOM
				ON ItemUOM.intItemUOMId = ReceiptItem.intUnitMeasureId
			LEFT JOIN dbo.tblICItemUOM StockUOM
				ON StockUOM.intItemId = ReceiptItem.intItemId
				AND StockUOM.ysnStockUnit = 1
			INNER JOIN dbo.tblICUnitMeasure UOM
				ON UOM.intUnitMeasureId = StockUOM.intUnitMeasureId
				AND UOM.strUnitType = @UNIT_TYPE_Weight
	WHERE	Receipt.intInventoryReceiptId = @intInventoryReceiptId
			AND ReceiptItem.intOrderId = @intContractId
			AND StockUOM.intItemUOMId IS NOT NULL 

	-- Distribute the other charge by 'Weight'. 
	--IF ISNULL(@totalWeightOfAllItems, 0) <> 0
	--BEGIN 
	--	UPDATE	ReceiptItem
	--	SET		dblOtherCharges +=	(	@totalOtherChargesForContracts_AllocateByWeight
	--									* dbo.fnCalculateStockUnitQty(ReceiptItem.dblOpenReceive, ItemUOM.dblUnitQty)
	--									/ @totalWeightOfAllItems
	--								)				 
	--	FROM	dbo.tblICInventoryReceipt Receipt INNER JOIN dbo.tblICInventoryReceiptItem ReceiptItem 
	--				ON Receipt.intInventoryReceiptId = ReceiptItem.intInventoryReceiptId	
	--			INNER JOIN dbo.tblICItem Item 
	--				ON Item.intItemId = ReceiptItem.intItemId 
	--			INNER JOIN dbo.tblICItemUOM ItemUOM
	--				ON ItemUOM.intItemUOMId = ReceiptItem.intUnitMeasureId
	--			LEFT JOIN dbo.tblICItemUOM StockUOM
	--				ON StockUOM.intItemId = ReceiptItem.intItemId
	--				AND StockUOM.ysnStockUnit = 1
	--			INNER JOIN dbo.tblICUnitMeasure UOM
	--				ON UOM.intUnitMeasureId = StockUOM.intUnitMeasureId
	--				AND UOM.strUnitType = @UNIT_TYPE_Weight
	--	WHERE	Receipt.intInventoryReceiptId = @intInventoryReceiptId						
	--			AND Receipt.strReceiptType = @RECEIPT_TYPE_Purchase_Contract
	--			AND ReceiptItem.intOrderId = @intContractId
	--			AND StockUOM.intItemUOMId IS NOT NULL 
	--END
END 

_Exit: