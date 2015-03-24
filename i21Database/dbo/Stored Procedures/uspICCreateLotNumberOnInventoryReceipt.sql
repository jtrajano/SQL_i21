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
	-- Check if all lot items and their quantities are valid. 
	-- Get the top record and tell the user about it. 
	-- Msg: The lot Quantity(ies) on %s must match its Open Receive Quantity.
	DECLARE @strItemNo AS NVARCHAR(50)
	SET @strItemNo = NULL 
	SELECT	TOP 1 
			@strItemNo = Item.strItemNo
	FROM	dbo.tblICInventoryReceipt Receipt INNER JOIN dbo.tblICInventoryReceiptItem ReceiptItem
				ON Receipt.intInventoryReceiptId = ReceiptItem.intInventoryReceiptId
			INNER JOIN dbo.tblICItem Item
				ON Item.intItemId = ReceiptItem.intItemId
			LEFT JOIN dbo.tblICInventoryReceiptItemLot ItemLot
				ON ReceiptItem.intInventoryReceiptItemId = ItemLot.intInventoryReceiptItemId	
	WHERE	dbo.fnGetItemLotType(ReceiptItem.intItemId) IN (@LotType_Manual, @LotType_Serial)	
			AND Receipt.strReceiptNumber = @strTransactionId
	GROUP BY  ReceiptItem.intInventoryReceiptItemId, Item.strItemNo, ReceiptItem.dblOpenReceive
	HAVING SUM(ISNULL(ItemLot.dblQuantity, 0)) <> ReceiptItem.dblOpenReceive

	IF @strItemNo IS NOT NULL 
	BEGIN 
		-- The lot Quantity(ies) on %s must match its Open Receive Quantity.
		RAISERROR(51038, 11, 1, @strItemNo)  
		RETURN; 
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
	EXEC dbo.uspICCreateUpdateLotNumber 
		@ItemsThatNeedLotId
		,@intUserId
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