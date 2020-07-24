CREATE PROCEDURE [dbo].[uspICCreateLotNumberOnAdjustStockFromSAP]
	@strTransactionId NVARCHAR(40) = NULL   
	,@intLocationId AS INT 
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

		,@InventoryTransactionType_InventoryAdjustment AS INT = 10 

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
		FROM	dbo.tblICInventoryAdjustment Adj INNER JOIN dbo.tblICInventoryAdjustmentDetail AdjItem
					ON Adj.intInventoryAdjustmentId = AdjItem.intInventoryAdjustmentId
				INNER JOIN dbo.tblICItem Item
					ON AdjItem.intItemId = Item.intItemId
				INNER JOIN dbo.tblICItemUOM ItemUOM
					ON ItemUOM.intItemId = AdjItem.intItemId
				INNER JOIN dbo.tblICUnitMeasure UOM
					ON ItemUOM.intUnitMeasureId = UOM.intUnitMeasureId
		WHERE	ISNULL(ItemUOM.dblUnitQty, 0) <= 0
				AND Adj.strAdjustmentNo = @strTransactionId

		IF @intItemId IS NOT NULL 
		BEGIN 
			IF ISNULL(@strItemNo, '') = '' 
				SET @strItemNo = 'an item with id ' + CAST(@intItemId AS NVARCHAR(50)) 

			-- 'Please correct the unit qty in UOM {UOM} on {Item}.'
			EXEC uspICRaiseError 80017, @strUnitMeasure, @strItemNo;
			RETURN -1; 			 
		END 
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
			,dblWeightPerQty
	)
	SELECT	intLotId				= AdjItem.intLotId
			,strLotNumber			= NULL 
			,strLotAlias			= NULL 
			,intItemId				= AdjItem.intItemId
			,intItemLocationId		= ItemLocation.intItemLocationId
			,intSubLocationId		= ISNULL(AdjItem.intSubLocationId, StorageLocation.intSubLocationId) 										
			,intStorageLocationId	= StorageLocation.intStorageLocationId
			,dblQty					= CASE WHEN @ysnPost = 1 THEN AdjItem.dblAdjustByQuantity ELSE -AdjItem.dblAdjustByQuantity END 
			,intItemUOMId			= AdjItem.intItemUOMId
			,dblWeight				= CASE WHEN @ysnPost = 1 THEN AdjItem.dblAdjustByQuantity ELSE -AdjItem.dblAdjustByQuantity END 
			,intWeightUOMId			= AdjItem.intItemUOMId 
			,dtmExpiryDate			= NULL 
			,dtmManufacturedDate	= NULL 
			,intOriginId			= NULL 
			,intGradeId				= NULL 
			,strBOLNo				= NULL 
			,strVessel				= NULL 
			,strReceiptNumber		= Adj.strAdjustmentNo
			,strMarkings			= NULL 
			,strNotes				= NULL 
			,intEntityVendorId		= NULL 
			,strVendorLotNo			= NULL 
			,strGarden				= NULL 
			,intDetailId			= AdjItem.intInventoryAdjustmentDetailId
			,intOwnershipType		= 1 
			,dblGrossWeight			= NULL 
			,strParentLotNumber		= NULL 
			,strParentLotAlias		= NULL 
			,strTransactionId			= Adj.strAdjustmentNo
			,strSourceTransactionId		= Adj.strAdjustmentNo
			,intSourceTransactionTypeId = @InventoryTransactionType_InventoryAdjustment
			,dblWeightPerQty		= 1
	FROM	dbo.tblICInventoryAdjustment Adj INNER JOIN dbo.tblICInventoryAdjustmentDetail AdjItem
				ON Adj.intInventoryAdjustmentId = AdjItem.intInventoryAdjustmentId
			INNER JOIN dbo.tblICItem Item
				ON AdjItem.intItemId = Item.intItemId		
			INNER JOIN dbo.tblICItemLocation ItemLocation
				ON AdjItem.intItemId = ItemLocation.intItemId
				AND ItemLocation.intLocationId = @intLocationId
			LEFT JOIN dbo.tblICStorageLocation StorageLocation 
				ON StorageLocation.intStorageLocationId = AdjItem.intStorageLocationId
	WHERE	Adj.strAdjustmentNo = @strTransactionId
			AND AdjItem.intLotId IS NULL 
			AND AdjItem.dblAdjustByQuantity > 0 
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
	UPDATE	dbo.tblICInventoryAdjustmentDetail
	SET		intLotId = LotNumbers.intLotId
	FROM	dbo.tblICInventoryAdjustmentDetail AdjItem INNER JOIN #GeneratedLotItems LotNumbers
				ON AdjItem.intInventoryAdjustmentDetailId = LotNumbers.intDetailId
END 

IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#GeneratedLotItems')) 
	DROP TABLE #GeneratedLotItems

RETURN 0; 
