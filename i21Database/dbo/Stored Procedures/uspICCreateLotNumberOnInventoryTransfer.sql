CREATE PROCEDURE [dbo].[uspICCreateLotNumberOnInventoryTransfer]
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
		FROM	dbo.tblICInventoryTransfer Transfer
				INNER JOIN dbo.tblICInventoryTransferDetail TransferItem
					ON Transfer.intInventoryTransferId = TransferItem.intInventoryTransferId
				INNER JOIN dbo.tblICItem Item
					ON TransferItem.intItemId = Item.intItemId
				INNER JOIN dbo.tblICItemUOM ItemUOM
					ON ItemUOM.intItemId = TransferItem.intItemId
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
		
	-- Check if the Item Transfer quantity matches the total Quantity in the Lot
	SET @strItemNo = NULL 
	SET @intItemId = NULL 

	SELECT	TOP 1 
			@strItemNo					= Item.strItemNo
			,@intItemId					= Item.intItemId
			,@OpenReceiveQty			= TransferItem.dblQuantity
			,@LotQty					= ItemLot.TotalLotQty
			,@LotQtyInItemUOM			= ItemLot.TotalLotQtyInItemUOM
			,@OpenReceiveQtyInItemUOM	= dbo.fnCalculateQtyBetweenUOM (
											TransferItem.intItemUOMId
											,TransferItem.intItemUOMId
											,TransferItem.dblQuantity
										)
	FROM	dbo.tblICInventoryTransfer Transfer INNER JOIN dbo.tblICInventoryTransferDetail TransferItem
				ON Transfer.intInventoryTransferId = TransferItem.intInventoryTransferId
			INNER JOIN dbo.tblICItem Item
				ON Item.intItemId = TransferItem.intItemId
			LEFT JOIN (
				SELECT  tblICInventoryTransferDetail.intInventoryTransferDetailId
						,TotalLotQtyInItemUOM = SUM(
							dbo.fnCalculateQtyBetweenUOM(
								ISNULL(tblICInventoryTransferDetail.intItemUOMId, tblICInventoryTransferDetail.intItemUOMId)
								,tblICInventoryTransferDetail.intItemUOMId
								,tblICInventoryTransferDetail.dblQuantity
							)
						)
						,TotalLotQty = SUM(ISNULL(tblICInventoryTransferDetail.dblQuantity, 0))
				FROM	dbo.tblICInventoryTransfer INNER JOIN dbo.tblICInventoryTransferDetail
							ON tblICInventoryTransfer.intInventoryTransferId = tblICInventoryTransferDetail.intInventoryTransferId
				WHERE	tblICInventoryTransfer.strTransferNo = @strTransactionId				
				GROUP BY tblICInventoryTransferDetail.intInventoryTransferDetailId
			) ItemLot
				ON ItemLot.intInventoryTransferDetailId = TransferItem.intInventoryTransferDetailId											
	WHERE	dbo.fnGetItemLotType(TransferItem.intItemId) IN (@LotType_Manual, @LotType_Serial)	
			AND Transfer.strTransferNo = @strTransactionId
			AND ROUND(ItemLot.TotalLotQtyInItemUOM, 2) <>
				ROUND(dbo.fnCalculateQtyBetweenUOM (
					TransferItem.intItemUOMId
					,TransferItem.intItemUOMId
					,TransferItem.dblQuantity
				), 2)

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
			,intGradeId
			,strBOLNo
			,strVessel
			,strReceiptNumber
			,strMarkings
			,strNotes
			,intEntityVendorId
			,strVendorLotNo
			,intVendorLocationId
			,intDetailId		
	)
	SELECT	intLotId				= TransferItem.intNewLotId
			,strLotNumber			= CASE WHEN ISNULL(TransferItem.strNewLotId, '') = '' THEN SourceLot.strLotNumber ELSE TransferItem.strNewLotId END 
			,strLotAlias			= SourceLot.strLotAlias
			,intItemId				= TransferItem.intItemId
			,intItemLocationId		= ItemLocation.intItemLocationId
			,intSubLocationId		= TransferItem.intToSubLocationId
			,intStorageLocationId	= TransferItem.intToStorageLocationId
			,dblQty					= TransferItem.dblQuantity * CASE WHEN @ysnPost = 0 THEN -1 ELSE 1 END 
			,intItemUOMId			= ISNULL(TransferItem.intItemUOMId, TransferItem.intItemUOMId) 
			,dblWeight				= SourceLot.dblWeightPerQty * ABS(TransferItem.dblQuantity) 
			,intWeightUOMId			= SourceLot.intWeightUOMId
			,dtmExpiryDate			= SourceLot.dtmExpiryDate
			,dtmManufacturedDate	= SourceLot.dtmManufacturedDate
			,intOriginId			= SourceLot.intOriginId
			,intGradeId				= SourceLot.intGradeId
			,strBOLNo				= SourceLot.strBOLNo
			,strVessel				= SourceLot.strVessel
			,strReceiptNumber		= Transfer.strTransferNo
			,strMarkings			= SourceLot.strMarkings
			,strNotes				= SourceLot.strNotes
			,intEntityVendorId		= SourceLot.intEntityVendorId
			,strVendorLotNo			= SourceLot.strVendorLotNo
			,intVendorLocationId	= SourceLot.intVendorLocationId
			,intDetailId			= TransferItem.intInventoryTransferDetailId
	FROM	dbo.tblICInventoryTransfer Transfer INNER JOIN dbo.tblICInventoryTransferDetail TransferItem
				ON Transfer.intInventoryTransferId = TransferItem.intInventoryTransferId
			INNER JOIN dbo.tblICItem Item
				ON TransferItem.intItemId = Item.intItemId		
			INNER JOIN dbo.tblICItemLocation ItemLocation
				ON TransferItem.intItemId = ItemLocation.intItemId
				AND Transfer.intToLocationId = ItemLocation.intLocationId	
			INNER JOIN tblICLot SourceLot 
				ON SourceLot.intLotId = TransferItem.intLotId
	WHERE	Transfer.strTransferNo = @strTransactionId

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

-- Assign the generated lot id's back to the inventory Transfer item-lot table. 
BEGIN 
	UPDATE	dbo.tblICInventoryTransferDetail
	SET		intNewLotId = LotNumbers.intLotId
			,strNewLotId = LotNumbers.strLotNumber		
	FROM	dbo.tblICInventoryTransferDetail Detail INNER JOIN #GeneratedLotItems LotNumbers
				ON Detail.intInventoryTransferDetailId = LotNumbers.intDetailId
END 

IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#GeneratedLotItems')) 
	DROP TABLE #GeneratedLotItems

RETURN 0; 
