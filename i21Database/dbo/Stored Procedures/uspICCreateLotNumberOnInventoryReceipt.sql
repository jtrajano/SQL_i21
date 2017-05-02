CREATE PROCEDURE [dbo].[uspICCreateLotNumberOnInventoryReceipt]
	@strTransactionId NVARCHAR(40) = NULL   
	,@intEntityUserSecurityId INT
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
		,@LotType_ManualSerial AS INT = 3

		,@InventoryTransactionType_InventoryReceipt AS INT = 4

-- Create the temp table 
CREATE TABLE #GeneratedLotItems (
	intLotId INT
	,strLotNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL
	,intDetailId INT 
	,intParentLotId INT
	,strParentLotNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL

)

------------------------------------------------------------------------------
-- Validation 
------------------------------------------------------------------------------
BEGIN 
	DECLARE @strItemNo AS NVARCHAR(50)
	DECLARE @strUnitMeasure AS NVARCHAR(50)
	DECLARE @intItemId AS INT
	DECLARE @OpenReceiveQty AS NUMERIC(38,20)
	DECLARE @LotQty AS NUMERIC(38,20)
	DECLARE @OpenReceiveQtyInItemUOM AS NUMERIC(38,20)
	DECLARE @LotQtyInItemUOM AS NUMERIC(38,20)
	DECLARE @ReceiptItemNet  AS NUMERIC(38,20)

	DECLARE @CleanWgtCount AS INT = 0
	DECLARE @FormattedReceivedQty AS NVARCHAR(50)
	DECLARE @FormattedLotQty AS NVARCHAR(50)
	DECLARE @FormattedDifference AS NVARCHAR(50)
	DECLARE @FormattedReceiptItemNet AS NVARCHAR(50)

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
			EXEC uspICRaiseError 80017, @strUnitMeasure, @strItemNo;
			RETURN -1; 			 
		END 
	END 
		
	-- Check if the Item Receipt Open Receive matches with the total Quantity from the Lots
	SET @strItemNo = NULL 
	SET @intItemId = NULL 

	SELECT	TOP 1 
			@strItemNo					= Item.strItemNo
			,@intItemId					= Item.intItemId
			,@OpenReceiveQty			= ReceiptItem.dblOpenReceive
			,@LotQty					= ISNULL(ItemLot.TotalLotQty, 0)
			,@LotQtyInItemUOM			= ISNULL(ItemLot.TotalLotQtyInItemUOM, 0)
			,@OpenReceiveQtyInItemUOM	= ReceiptItem.dblOpenReceive
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
	WHERE	dbo.fnGetItemLotType(ReceiptItem.intItemId) <> 0 
			AND Receipt.strReceiptNumber = @strTransactionId
			AND ROUND(ISNULL(ItemLot.TotalLotQtyInItemUOM, 0), 6) <> ROUND(ReceiptItem.dblOpenReceive,6)
			
	IF @intItemId IS NOT NULL 
	BEGIN 
		IF ISNULL(@strItemNo, '') = '' 
			SET @strItemNo = 'Item with id ' + CAST(@intItemId AS NVARCHAR(50)) 

		-- 'The Qty to Receive for {Item} is {Open Receive Qty}. Total Lot Quantity is {Total Lot Qty}. The difference is {Calculated difference}.'
		DECLARE @difference AS NUMERIC(18, 6) = ABS(@OpenReceiveQty - @LotQtyInItemUOM);
		EXEC uspICRaiseError 80006, @strItemNo, @OpenReceiveQty, @LotQtyInItemUOM, @difference;
		RETURN -1; 
	END 

	-------------------------------------------------------------------------------------
	-- Note: Need to change this validation as a settable configuration in IC. 
	-- Dallmayr seems to use Item Net weight as the "received weight". 
	-- They clean the coffee per lot. Net wgt at Lot is the actual wgt. 
	-- See IC-2176 and IC-2341 for more info. 
	-------------------------------------------------------------------------------------		
	---- Check if the Item Receipt Net qty matches with the total Net qty from the lots. 
	--SET @strItemNo = NULL 
	--SET @intItemId = NULL 

	SELECT	TOP 1 
			@strItemNo					= Item.strItemNo
			,@intItemId					= Item.intItemId
			,@OpenReceiveQty			= ReceiptItem.dblOpenReceive
			,@ReceiptItemNet			= ReceiptItem.dblNet
			,@LotQty					= ISNULL(ItemLot.TotalLotQty, 0)
			,@LotQtyInItemUOM			= ISNULL(ItemLot.TotalLotQtyInItemUOM, 0)
			,@OpenReceiveQtyInItemUOM	= ReceiptItem.dblNet
			,@CleanWgtCount				= ISNULL(clean.CleanCount, 0)
	FROM	dbo.tblICInventoryReceipt Receipt INNER JOIN dbo.tblICInventoryReceiptItem ReceiptItem
				ON Receipt.intInventoryReceiptId = ReceiptItem.intInventoryReceiptId
			INNER JOIN dbo.tblICItem Item
				ON Item.intItemId = ReceiptItem.intItemId
			LEFT JOIN (
				SELECT  AggregrateLot.intInventoryReceiptItemId
						,TotalLotQtyInItemUOM = SUM(ISNULL(AggregrateLot.dblGrossWeight, 0) - ISNULL(AggregrateLot.dblTareWeight, 0))
						,TotalLotQty = SUM(ISNULL(AggregrateLot.dblGrossWeight, 0) - ISNULL(AggregrateLot.dblTareWeight, 0))
				FROM	dbo.tblICInventoryReceipt INNER JOIN dbo.tblICInventoryReceiptItem 
							ON tblICInventoryReceipt.intInventoryReceiptId = tblICInventoryReceiptItem.intInventoryReceiptId
						INNER JOIN dbo.tblICInventoryReceiptItemLot AggregrateLot
							ON tblICInventoryReceiptItem.intInventoryReceiptItemId = AggregrateLot.intInventoryReceiptItemId
				WHERE	tblICInventoryReceipt.strReceiptNumber = @strTransactionId				
				GROUP BY AggregrateLot.intInventoryReceiptItemId
			) ItemLot
				ON ItemLot.intInventoryReceiptItemId = ReceiptItem.intInventoryReceiptItemId
			LEFT OUTER JOIN (
					SELECT COUNT(intInventoryReceiptItemLotId) CleanCount, intInventoryReceiptItemId
					FROM dbo.tblICInventoryReceiptItemLot
					WHERE strCondition = 'Clean Wgt'
					GROUP BY intInventoryReceiptItemId
			) clean ON clean.intInventoryReceiptItemId = ReceiptItem.intInventoryReceiptItemId										
	WHERE	dbo.fnGetItemLotType(ReceiptItem.intItemId) <> 0 
			AND Receipt.strReceiptNumber = @strTransactionId
			AND ROUND(ItemLot.TotalLotQtyInItemUOM,6) <> ROUND(ReceiptItem.dblNet,6)
			AND ReceiptItem.intWeightUOMId IS NOT NULL -- There is a Gross/Net UOM. 
			
	IF @intItemId IS NOT NULL AND @CleanWgtCount = 0
	BEGIN 
		
		IF ISNULL(@strItemNo, '') = '' 
			SET @strItemNo = 'Item with id ' + CAST(@intItemId AS NVARCHAR(50)) 

		SET @FormattedReceiptItemNet =  CONVERT(NVARCHAR, CAST(@ReceiptItemNet AS MONEY), 1)
		SET @FormattedLotQty =  CONVERT(NVARCHAR, CAST(@LotQtyInItemUOM AS MONEY), 1)
		SET @FormattedDifference =  CAST(ABS(@ReceiptItemNet - @LotQtyInItemUOM) AS NVARCHAR(50))

		-- 'Net quantity mismatch. It is {@FormattedReceiptItemNet} on item {@strItemNo} but the total net from the lot(s) is {@FormattedLotQty}.'
		EXEC uspICRaiseError 80081, @ReceiptItemNet, @strItemNo, @LotQtyInItemUOM; 
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
			,intGradeId
			,strBOLNo
			,strVessel
			,strReceiptNumber
			,strMarkings
			,strNotes
			,intEntityVendorId
			,strVendorLotNo
			,strGarden
			,intDetailId
			,intOwnershipType
			,dblGrossWeight	
			,strParentLotNumber
			,strParentLotAlias
			,strTransactionId
			,strSourceTransactionId
			,intSourceTransactionTypeId
	)
	SELECT	intLotId				= ItemLot.intLotId
			,strLotNumber			= ItemLot.strLotNumber
			,strLotAlias			= ItemLot.strLotAlias
			,intItemId				= ReceiptItem.intItemId
			,intItemLocationId		= ItemLocation.intItemLocationId
			,intSubLocationId		= ISNULL(ReceiptItem.intSubLocationId, StorageLocation.intSubLocationId) 										
			,intStorageLocationId	= StorageLocation.intStorageLocationId
			,dblQty					=	CASE WHEN @ysnPost = 0 THEN -1 ELSE 1 END 
										* ItemLot.dblQuantity
			,intItemUOMId			= ItemLot.intItemUnitMeasureId
			,dblWeight				= CASE WHEN @ysnPost = 0 THEN -1 ELSE 1 END
										* CASE	WHEN ISNULL(ReceiptItem.intWeightUOMId, 0) <> 0	THEN 
													ISNULL(ItemLot.dblGrossWeight, 0) - ISNULL(ItemLot.dblTareWeight, 0) 
												ELSE 
													0
										END 

			,intWeightUOMId			= ReceiptItem.intWeightUOMId
			,dtmExpiryDate			= ItemLot.dtmExpiryDate
			,dtmManufacturedDate	= ItemLot.dtmManufacturedDate
			,intOriginId			= ItemLot.intOriginId
			,intGradeId				= ISNULL(ItemLot.intGradeId, ReceiptItem.intGradeId)
			,strBOLNo				= Receipt.strBillOfLading
			,strVessel				= Receipt.strVessel
			,strReceiptNumber		= Receipt.strReceiptNumber
			,strMarkings			= ItemLot.strMarkings
			,strNotes				= ItemLot.strRemarks
			,intEntityVendorId		= ISNULL(ItemLot.intEntityVendorId, Receipt.intEntityVendorId)  
			,strVendorLotNo			= ItemLot.strVendorLotId
			,strGarden				= ItemLot.strGarden
			,intDetailId			= ItemLot.intInventoryReceiptItemLotId
			,intOwnershipType		= ReceiptItem.intOwnershipType
			,dblGrossWeight			= ItemLot.dblGrossWeight
			,strParentLotNumber		= ItemLot.strParentLotNumber
			,strParentLotAlias		= ItemLot.strParentLotAlias
			,strTransactionId			= Receipt.strReceiptNumber
			,strSourceTransactionId		= Receipt.strReceiptNumber
			,intSourceTransactionTypeId = @InventoryTransactionType_InventoryReceipt

	FROM	dbo.tblICInventoryReceipt Receipt INNER JOIN dbo.tblICInventoryReceiptItem ReceiptItem
				ON Receipt.intInventoryReceiptId = ReceiptItem.intInventoryReceiptId
			INNER JOIN dbo.tblICItem Item
				ON ReceiptItem.intItemId = Item.intItemId		
			INNER JOIN dbo.tblICItemLocation ItemLocation
				ON ReceiptItem.intItemId = ItemLocation.intItemId
				AND Receipt.intLocationId = ItemLocation.intLocationId
			INNER JOIN dbo.tblICInventoryReceiptItemLot ItemLot 			
				ON ReceiptItem.intInventoryReceiptItemId = ItemLot.intInventoryReceiptItemId
			LEFT JOIN dbo.tblICStorageLocation StorageLocation 
				ON StorageLocation.intStorageLocationId = ISNULL(ItemLot.intStorageLocationId, ReceiptItem.intStorageLocationId)
	WHERE	Receipt.strReceiptNumber = @strTransactionId

END 

-- Call the common stored procedure that will create or updat the lot master table
BEGIN 
	DECLARE @intErrorFoundOnCreateUpdateLotNumber AS INT

	EXEC @intErrorFoundOnCreateUpdateLotNumber = dbo.uspICCreateUpdateLotNumber 
		@ItemsThatNeedLotId
		,@intEntityUserSecurityId

	IF @intErrorFoundOnCreateUpdateLotNumber <> 0
		RETURN @intErrorFoundOnCreateUpdateLotNumber;
END

-- Assign the generated lot id's back to the inventory receipt item-lot table. 
BEGIN 
	UPDATE	dbo.tblICInventoryReceiptItemLot
	SET		intLotId = LotNumbers.intLotId
			,strLotNumber = LotNumbers.strLotNumber		
			,intParentLotId = LotNumbers.intParentLotId
			,strParentLotNumber = LotNumbers.strParentLotNumber
	FROM	dbo.tblICInventoryReceiptItemLot ItemLot INNER JOIN #GeneratedLotItems LotNumbers
				ON ItemLot.intInventoryReceiptItemLotId = LotNumbers.intDetailId
END 

IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#GeneratedLotItems')) 
	DROP TABLE #GeneratedLotItems

RETURN 0; 
