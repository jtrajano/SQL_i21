CREATE PROCEDURE [dbo].[uspICCreateLotNumberOnInventoryTransfer]
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
			EXEC uspICRaiseError 80017, @strUnitMeasure, @strItemNo;
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
	WHERE	dbo.fnGetItemLotType(TransferItem.intItemId) <> 0 
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
		DECLARE @difference AS NUMERIC(18, 6) = ABS(@OpenReceiveQty - @LotQtyInItemUOM);
		EXEC uspICRaiseError 80006, @strItemNo, @OpenReceiveQty, @LotQtyInItemUOM, @difference;
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
			,intSplitFromLotId
			,intOwnershipType
			,dblGrossWeight
			,strParentLotNumber
			,strParentLotAlias
			,strTransactionId
			,strSourceTransactionId
			,intSourceTransactionTypeId
	)
	SELECT	intLotId				= TransferItem.intNewLotId
			,strLotNumber			= CASE WHEN ISNULL(TransferItem.strNewLotId, '') = '' THEN SourceLot.strLotNumber ELSE TransferItem.strNewLotId END 
			,strLotAlias			= SourceLot.strLotAlias
			,intItemId				= TransferItem.intItemId
			,intItemLocationId		= ItemLocation.intItemLocationId
			,intSubLocationId		= TransferItem.intToSubLocationId
			,intStorageLocationId	= TransferItem.intToStorageLocationId
			,dblQty					=	CASE WHEN @ysnPost = 0 THEN -1 ELSE 1 END 
										* TransferItem.dblQuantity 
			,intItemUOMId			= TransferItem.intItemUOMId
			,dblWeight				= CASE WHEN @ysnPost = 0 THEN -1 ELSE 1 END
										* CASE	WHEN SourceLot.intWeightUOMId IS NOT NULL AND SourceLot.intWeightUOMId <> TransferItem.intItemUOMId THEN 
													-- Transfer qty is in bags. Convert it to wgt. 
													dbo.fnMultiply(
														ISNULL(TransferItem.dblQuantity, 0)
														, ISNULL(SourceLot.dblWeightPerQty, 0) 
													) 
												WHEN SourceLot.intWeightUOMId IS NOT NULL AND SourceLot.intWeightUOMId = TransferItem.intItemUOMId THEN 
													-- Transfer qty is in wgt. No need to convert it. 
													ISNULL(TransferItem.dblQuantity, 0)
												ELSE 
													0
										END 
			,intWeightUOMId			= SourceLot.intWeightUOMId
			,dtmExpiryDate			= SourceLot.dtmExpiryDate
			,dtmManufacturedDate	= SourceLot.dtmManufacturedDate
			,intOriginId			= SourceLot.intOriginId
			,intGradeId				= SourceLot.intGradeId
			,strBOLNo				= SourceLot.strBOLNo
			,strVessel				= SourceLot.strVessel
			,strReceiptNumber		= [Transfer].strTransferNo
			,strMarkings			= SourceLot.strMarkings
			,strNotes				= SourceLot.strNotes
			,intEntityVendorId		= SourceLot.intEntityVendorId
			,strVendorLotNo			= SourceLot.strVendorLotNo
			,strGarden				= SourceLot.strGarden
			,intDetailId			= TransferItem.intInventoryTransferDetailId
			,intSplitFromLotId		= SourceLot.intLotId
			,intOwnershipType		= TransferItem.intOwnershipType
			,dblGrossWeight			= SourceLot.dblGrossWeight
			,strParentLotNumber		= ParentLotSourceLot.strParentLotNumber
			,strParentLotAlias		= ParentLotSourceLot.strParentLotAlias
			,strTransactionId			= [Transfer].strTransferNo
			,strSourceTransactionId		= SourceLot.strTransactionId
			,intSourceTransactionTypeId = SourceLot.intSourceTransactionTypeId

	FROM	dbo.tblICInventoryTransfer [Transfer] INNER JOIN dbo.tblICInventoryTransferDetail TransferItem
				ON [Transfer].intInventoryTransferId = TransferItem.intInventoryTransferId
			INNER JOIN dbo.tblICItem Item
				ON TransferItem.intItemId = Item.intItemId		
			INNER JOIN dbo.tblICItemLocation ItemLocation
				ON TransferItem.intItemId = ItemLocation.intItemId
				AND [Transfer].intToLocationId = ItemLocation.intLocationId	
			INNER JOIN tblICLot SourceLot 
				ON SourceLot.intLotId = TransferItem.intLotId
			LEFT JOIN dbo.tblICParentLot ParentLotSourceLot
				ON ParentLotSourceLot.intParentLotId = SourceLot.intParentLotId
	WHERE	[Transfer].strTransferNo = @strTransactionId

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
