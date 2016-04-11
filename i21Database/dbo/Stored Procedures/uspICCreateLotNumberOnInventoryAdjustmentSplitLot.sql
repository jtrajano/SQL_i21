﻿CREATE PROCEDURE [dbo].[uspICCreateLotNumberOnInventoryAdjustmentSplitLot]
	@intTransactionId INT 
	,@intEntityUserSecurityId INT = NULL 
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
		FROM	dbo.tblICInventoryAdjustment Header INNER JOIN dbo.tblICInventoryAdjustmentDetail Detail
					ON Header.intInventoryAdjustmentId = Detail.intInventoryAdjustmentId
				INNER JOIN dbo.tblICItem Item
					ON Item.intItemId = Detail.intItemId
				INNER JOIN dbo.tblICItemUOM ItemUOM
					ON ItemUOM.intItemId = Detail.intItemId
				INNER JOIN dbo.tblICUnitMeasure UOM
					ON ItemUOM.intUnitMeasureId = UOM.intUnitMeasureId
		WHERE	ISNULL(ItemUOM.dblUnitQty, 0) <= 0

		IF @intItemId IS NOT NULL 
		BEGIN 
			IF ISNULL(@strItemNo, '') = '' 
				SET @strItemNo = 'an item with id ' + CAST(@intItemId AS NVARCHAR(50)) 

			-- 'Please correct the unit qty in UOM {UOM} on {Item}.'
			RAISERROR(80017, 11, 1, @strUnitMeasure, @strItemNo) 
			RETURN -1; 			 
		END 
	END 
END

-- Get the list of item that needs lot numbers
BEGIN 
	INSERT INTO @ItemsThatNeedLotId (
			[intLotId]
			,[intItemId]
			,[intItemLocationId]
			,[intItemUOMId]
			,[strLotNumber]
			,[intSubLocationId]
			,[intStorageLocationId]
			,[dblQty]
			,[dtmExpiryDate]
			,[strLotAlias]
			,[intLotStatusId]
			,[intParentLotId]
			,[strParentLotNumber]
			,[strParentLotAlias]
			,[intSplitFromLotId]
			,[dblGrossWeight]
			,[dblWeight]
			,[intWeightUOMId]
			,[intOriginId]
			,[strBOLNo]
			,[strVessel]
			,[strReceiptNumber]
			,[strMarkings]
			,[strNotes]
			,[intEntityVendorId]
			,[strVendorLotNo]
			,[strGarden]
			,[strContractNo]
			,[dtmManufacturedDate]
			,[ysnReleasedToWarehouse]
			,[ysnProduced]
			,[ysnStorage]
			,[intOwnershipType]
			,[intGradeId]
			,[intDetailId]
			,[strTransactionId]
			,[strSourceTransactionId]
			,[intSourceTransactionTypeId]
	)
	SELECT	[intLotId]					= NewLot.intLotId 
			,[intItemId]				= Detail.intItemId
			,[intItemLocationId]		= ItemLocation.intItemLocationId
			,[intItemUOMId]				= ISNULL(Detail.intNewItemUOMId, Detail.intItemUOMId)
			,[strLotNumber]				= Detail.strNewLotNumber
			,[intSubLocationId]			= ISNULL(Detail.intNewSubLocationId, Detail.intSubLocationId)
			,[intStorageLocationId]		= ISNULL(Detail.intNewStorageLocationId, Detail.intStorageLocationId)
			,[dblQty]					= CASE	WHEN ISNULL(Detail.dblNewSplitLotQuantity, 0) <> 0 THEN 
												Detail.dblNewSplitLotQuantity
											ELSE  
												-1 * (ISNULL(Detail.dblNewQuantity, 0) - ISNULL(Detail.dblQuantity, 0))
										END 
			,[dtmExpiryDate]			= SourceLot.dtmExpiryDate
			,[strLotAlias]				= SourceLot.strLotAlias
			,[intLotStatusId]			= SourceLot.intLotStatusId
			,[intParentLotId]			= SourceLot.intParentLotId
			,[strParentLotNumber]		= ParentLotSourceLot.strParentLotNumber
			,[strParentLotAlias]		= ParentLotSourceLot.strParentLotAlias
			,[intSplitFromLotId]		= SourceLot.intLotId
			,[dblGrossWeight]			= SourceLot.dblGrossWeight
			,[dblWeight]				= CASE	WHEN ISNULL(Detail.dblNewWeight, 0) <> 0 THEN 
													Detail.dblNewWeight
												WHEN Detail.intNewWeightUOMId IS NOT NULL THEN 
													-- Convert the weight into the new Weight UOM.
													dbo.fnCalculateQtyBetweenUOM(
														Detail.intWeightUOMId
														, Detail.intNewWeightUOMId
														, ISNULL(Detail.dblWeightPerQty, 0) * -1 * (ISNULL(Detail.dblNewQuantity, 0) - ISNULL(Detail.dblQuantity, 0))
													)
												ELSE 
													ISNULL(Detail.dblWeightPerQty, 0) 
													* -1 * (ISNULL(Detail.dblNewQuantity, 0) - ISNULL(Detail.dblQuantity, 0))
											END
			,[intWeightUOMId]			= ISNULL(Detail.intNewWeightUOMId, Detail.intWeightUOMId)
			,[intOriginId]				= SourceLot.intOriginId
			,[strBOLNo]					= SourceLot.strBOLNo
			,[strVessel]				= SourceLot.strVessel
			,[strReceiptNumber]			= Header.strAdjustmentNo
			,[strMarkings]				= SourceLot.strMarkings
			,[strNotes]					= SourceLot.strNotes
			,[intEntityVendorId]		= SourceLot.intEntityVendorId
			,[strVendorLotNo]			= SourceLot.strVendorLotNo
			,[strGarden]				= SourceLot.strGarden
			,[strContractNo]			= SourceLot.strContractNo
			,[dtmManufacturedDate]		= SourceLot.dtmManufacturedDate
			,[ysnReleasedToWarehouse]	= SourceLot.ysnReleasedToWarehouse
			,[ysnProduced]				= SourceLot.ysnProduced
			,[ysnStorage]				= SourceLot.ysnStorage
			,[intOwnershipType]			= SourceLot.intOwnershipType
			,[intGradeId]				= SourceLot.intGradeId
			,[intDetailId]				= Detail.intInventoryAdjustmentDetailId
			,[strTransactionId]			= Header.strAdjustmentNo
			,[strSourceTransactionId]	= SourceLot.strTransactionId
			,[intSourceTransactionTypeId] = SourceLot.intSourceTransactionTypeId

	FROM	dbo.tblICInventoryAdjustment Header INNER JOIN dbo.tblICInventoryAdjustmentDetail Detail
				ON Header.intInventoryAdjustmentId = Detail.intInventoryAdjustmentId
			INNER JOIN dbo.tblICItemLocation ItemLocation
				ON ItemLocation.intItemId = Detail.intItemId
				AND ItemLocation.intLocationId = ISNULL(Detail.intNewLocationId, Header.intLocationId)
			INNER JOIN dbo.tblICLot SourceLot
				ON SourceLot.intLotId = Detail.intLotId
			LEFT JOIN dbo.tblICItemUOM NewItemUOMId 
				ON NewItemUOMId.intItemUOMId = Detail.intNewItemUOMId
			LEFT JOIN dbo.tblICLot NewLot
				ON NewLot.strLotNumber = Detail.strNewLotNumber
				AND NewLot.intItemId = Detail.intItemId
				AND NewLot.intItemLocationId = ItemLocation.intItemLocationId
				AND ISNULL(NewLot.intSubLocationId, 0) = ISNULL(Detail.intNewSubLocationId, 0)
				AND ISNULL(NewLot.intStorageLocationId, 0) = ISNULL(Detail.intNewStorageLocationId, 0)				
			LEFT JOIN dbo.tblICParentLot ParentLotSourceLot
				ON ParentLotSourceLot.intParentLotId = SourceLot.intParentLotId
	WHERE	Header.intInventoryAdjustmentId = @intTransactionId
END 

-- Call the common stored procedure that will create or update the lot master table
BEGIN 
	DECLARE @intErrorFoundOnCreateUpdateLotNumber AS INT

	EXEC @intErrorFoundOnCreateUpdateLotNumber = dbo.uspICCreateUpdateLotNumber 
		@ItemsThatNeedLotId
		,@intEntityUserSecurityId

	IF @intErrorFoundOnCreateUpdateLotNumber <> 0
		RETURN @intErrorFoundOnCreateUpdateLotNumber;
END

-- Assign the generated lot id's back to the inventory adjustment detail table. 
BEGIN 
	UPDATE	dbo.tblICInventoryAdjustmentDetail
	SET		intNewLotId = LotNumbers.intLotId
			,strNewLotNumber = LotNumbers.strLotNumber
	FROM	dbo.tblICInventoryAdjustmentDetail Detail INNER JOIN #GeneratedLotItems LotNumbers
				ON Detail.intInventoryAdjustmentDetailId = LotNumbers.intDetailId
END 

IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#GeneratedLotItems')) 
	DROP TABLE #GeneratedLotItems

RETURN 0;