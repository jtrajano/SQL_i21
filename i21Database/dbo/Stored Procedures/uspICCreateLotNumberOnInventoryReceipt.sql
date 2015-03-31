CREATE PROCEDURE [dbo].[uspICCreateLotNumberOnInventoryReceipt]
	@strTransactionId NVARCHAR(40) = NULL   
	,@intUserId INT
	,@ysnPost BIT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @ItemsThatNeedLotId AS dbo.ItemLotTableType

DECLARE @LotType_Manual AS INT = 1
		,@LotType_Serial AS INT = 2

-- Create the temp table 
CREATE TABLE #GeneratedLotItems (
	intLotId INT
	,strLotNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL
	,intDetailId INT 
)

------------------------------------------------------------------------------
-- Validation 
------------------------------------------------------------------------------
BEGIN 
	DECLARE @strItemNo AS NVARCHAR(50)
	DECLARE @strUnitMeasure AS NVARCHAR(50)
	DECLARE @intItemId AS INT
	DECLARE @OpenReceiveQty AS NUMERIC(18,6)
	DECLARE @LotQty AS NUMERIC(18,6)
	DECLARE @OpenReceiveQtyInItemUOM AS NUMERIC(18,6)
	DECLARE @LotQtyInItemUOM AS NUMERIC(18,6)

	DECLARE @FormattedReceivedQty AS NVARCHAR(50)
	DECLARE @FormattedLotQty AS NVARCHAR(50)
	DECLARE @FormattedDifference AS NVARCHAR(50)

	-- Check if the unit quantities on the UOM table are valid. 
	BEGIN 
		SELECT	TOP 1 
				@strItemNo = Item.strItemNo
				,@intItemId = Item.intItemId
				,@strUnitMeasure = UOM.strUnitMeasure
		FROM	dbo.tblICInventoryReceipt Receipt INNER JOIN dbo.tblICInventoryReceiptItem ReceiptItem
					ON Receipt.intInventoryReceiptId = ReceiptItem.intInventoryReceiptId
				INNER JOIN dbo.tblICItem Item
					ON ReceiptItem.intItemId = Item.intItemId
				INNER JOIN dbo.tblICItemUOM ItemUOM
					ON ItemUOM.intItemId = ReceiptItem.intItemId
				INNER JOIN dbo.tblICUnitMeasure UOM
					ON ItemUOM.intUnitMeasureId = UOM.intUnitMeasureId
		WHERE	ISNULL(ItemUOM.dblUnitQty, 0) <= 0

		IF @intItemId IS NOT NULL 
		BEGIN 
			IF ISNULL(@strItemNo, '') = '' 
				SET @strItemNo = 'an item with id ' + CAST(@intItemId AS NVARCHAR(50)) 

			-- 'Please correct the unit qty in UOM {UOM} on {Item}.'
			RAISERROR(51050, 11, 1, @strUnitMeasure, @strItemNo) 
			RETURN -1; 			 
		END 
	END 
		
	-- Check if the Item Receipt quantity matches the total Quantity in the Lot
	SET @strItemNo = NULL 
	SET @intItemId = NULL 

	SELECT	TOP 1 
			@strItemNo					= Item.strItemNo
			,@intItemId					= Item.intItemId
			,@OpenReceiveQty			= ReceiptItem.dblOpenReceive
			,@LotQty					= ItemLot.TotalLotQty
			,@LotQtyInItemUOM			= ItemLot.TotalLotQtyInItemUOM
			,@OpenReceiveQtyInItemUOM	= dbo.fnCalculateQtyBetweenUOM (
											ReceiptItem.intUnitMeasureId
											,ReceiptItem.intUnitMeasureId
											,ReceiptItem.dblOpenReceive
										)
	FROM	dbo.tblICInventoryReceipt Receipt INNER JOIN dbo.tblICInventoryReceiptItem ReceiptItem
				ON Receipt.intInventoryReceiptId = ReceiptItem.intInventoryReceiptId
			INNER JOIN dbo.tblICItem Item
				ON Item.intItemId = ReceiptItem.intItemId
			LEFT JOIN (
				SELECT  AggregrateLot.intInventoryReceiptItemId
						,TotalLotQtyInItemUOM = SUM(
							dbo.fnCalculateQtyBetweenUOM(
								ISNULL(AggregrateLot.intItemUnitMeasureId, tblICInventoryReceiptItem.intUnitMeasureId)
								,tblICInventoryReceiptItem.intUnitMeasureId
								,AggregrateLot.dblQuantity
							)
						)
						,TotalLotQty = SUM(ISNULL(AggregrateLot.dblQuantity, 0))
				FROM	dbo.tblICInventoryReceipt INNER JOIN dbo.tblICInventoryReceiptItem 
							ON tblICInventoryReceipt.intInventoryReceiptId = tblICInventoryReceiptItem.intInventoryReceiptId
						INNER JOIN dbo.tblICInventoryReceiptItemLot AggregrateLot
							ON tblICInventoryReceiptItem.intInventoryReceiptItemId = AggregrateLot.intInventoryReceiptItemId
				WHERE	tblICInventoryReceipt.strReceiptNumber = @strTransactionId				
				GROUP BY AggregrateLot.intInventoryReceiptItemId
			) ItemLot
				ON ItemLot.intInventoryReceiptItemId = ReceiptItem.intInventoryReceiptItemId											
	WHERE	dbo.fnGetItemLotType(ReceiptItem.intItemId) IN (@LotType_Manual, @LotType_Serial)	
			AND Receipt.strReceiptNumber = @strTransactionId
			AND ItemLot.TotalLotQtyInItemUOM <>
				dbo.fnCalculateQtyBetweenUOM (
					ReceiptItem.intUnitMeasureId
					,ReceiptItem.intUnitMeasureId
					,ReceiptItem.dblOpenReceive
				)

	IF @intItemId IS NOT NULL 
	BEGIN 
		IF ISNULL(@strItemNo, '') = '' 
			SET @strItemNo = 'Item with id ' + CAST(@intItemId AS NVARCHAR(50)) 

		-- The expected qty to receive for {Item} is {Open Receive Qty}. Lot Quantity is {Total Lot Qty}. The difference is {Calculated difference}.'
		SET @FormattedReceivedQty =  CONVERT(NVARCHAR, CAST(@OpenReceiveQty AS MONEY), 1)
		SET @FormattedLotQty =  CONVERT(NVARCHAR, CAST(@LotQtyInItemUOM AS MONEY), 1)
		SET @FormattedDifference =  CAST(ABS(@OpenReceiveQty - @LotQtyInItemUOM) AS NVARCHAR(50))

		RAISERROR(51038, 11, 1, @strItemNo, @FormattedReceivedQty, @FormattedLotQty, @FormattedDifference)  
		RETURN -1; 
	END 
END

-- Get the list of item that needs lot numbers
BEGIN 
	INSERT INTO @ItemsThatNeedLotId (
			intLotId
			,strLotNumber
			,strLotAlias
			,intItemId
			,intItemLocationId
			,intSubLocationId
			,intStorageLocationId
			,dblQty
			,intItemUOMId
			,dblWeight
			,intWeightUOMId
			,dtmExpiryDate
			,dtmManufacturedDate
			,intOriginId
			,strBOLNo
			,strVessel
			,strReceiptNumber
			,strMarkings
			,strNotes
			,intVendorId
			,strVendorLotNo
			,intVendorLocationId
			,strVendorLocation
			,intDetailId		
	)
	SELECT	intLotId				= ItemLot.intLotId
			,strLotNumber			= ItemLot.strLotNumber
			,strLotAlias			= ItemLot.strLotAlias
			,intItemId				= ReceiptItem.intItemId
			,intItemLocationId		= ItemLocation.intItemLocationId
			,intSubLocationId		= ItemLot.intSubLocationId
			,intStorageLocationId	= ItemLot.intStorageLocationId
			,dblQty					= ItemLot.dblQuantity * CASE WHEN @ysnPost = 0 THEN -1 ELSE 1 END 
			,intItemUOMId			= ReceiptItem.intUnitMeasureId
			,dblWeight				= ISNULL(ItemLot.dblGrossWeight, 0) - ISNULL(ItemLot.dblTareWeight, 0) * CASE WHEN @ysnPost = 0 THEN -1 ELSE 1 END
			,intWeightUOMId			= ReceiptItem.intWeightUOMId
			,dtmExpiryDate			= ItemLot.dtmExpiryDate
			,dtmManufacturedDate	= ItemLot.dtmManufacturedDate
			,intOriginId			= ItemLot.intOriginId
			,strBOLNo				= Receipt.strBillOfLading
			,strVessel				= Receipt.strVessel
			,strReceiptNumber		= Receipt.strReceiptNumber
			,strMarkings			= ItemLot.strMarkings
			,strNotes				= ItemLot.strRemarks
			,intVendorId			= ISNULL(ItemLot.intVendorId, Receipt.intVendorId)  
			,strVendorLotNo			= ItemLot.strVendorLotId
			,intVendorLocationId	= ItemLot.intVendorLocationId
			,strVendorLocation		= ItemLot.strVendorLocation
			,intDetailId			= ItemLot.intInventoryReceiptItemLotId
	FROM	dbo.tblICInventoryReceipt Receipt INNER JOIN dbo.tblICInventoryReceiptItem ReceiptItem
				ON Receipt.intInventoryReceiptId = ReceiptItem.intInventoryReceiptId
			INNER JOIN dbo.tblICItem Item
				ON ReceiptItem.intItemId = Item.intItemId		
			INNER JOIN dbo.tblICItemLocation ItemLocation
				ON ReceiptItem.intItemId = ItemLocation.intItemId
				AND Receipt.intLocationId = ItemLocation.intLocationId
			INNER JOIN dbo.tblICInventoryReceiptItemLot ItemLot 			
				ON ReceiptItem.intInventoryReceiptItemId = ItemLot.intInventoryReceiptItemId
	WHERE	Receipt.strReceiptNumber = @strTransactionId

END 

-- Call the common stored procedure that will create or updat the lot master table
BEGIN 
	DECLARE @intErrorFoundOnCreateUpdateLotNumber AS INT

	EXEC @intErrorFoundOnCreateUpdateLotNumber = dbo.uspICCreateUpdateLotNumber 
		@ItemsThatNeedLotId
		,@intUserId

	IF @intErrorFoundOnCreateUpdateLotNumber <> 0
		RETURN @intErrorFoundOnCreateUpdateLotNumber;
END

-- Assign the generated lot id's back to the inventory receipt item-lot table. 
BEGIN 
	UPDATE	dbo.tblICInventoryReceiptItemLot
	SET		intLotId = LotNumbers.intLotId
			,strLotNumber = LotNumbers.strLotNumber		
	FROM	dbo.tblICInventoryReceiptItemLot ItemLot INNER JOIN #GeneratedLotItems LotNumbers
				ON ItemLot.intInventoryReceiptItemLotId = LotNumbers.intDetailId
END 

IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#GeneratedLotItems')) 
	DROP TABLE #GeneratedLotItems

RETURN 0; 
