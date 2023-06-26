﻿CREATE PROCEDURE [dbo].[uspICCreateLotNumberOnInventoryAdjustmentOpeningInventory]
	@intTransactionId INT 
	,@intEntityUserSecurityId INT = NULL 
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS ON

DECLARE @ItemsThatNeedLotId AS dbo.ItemLotTableType

DECLARE @LotType_Manual AS INT = 1
		,@LotType_Serial AS INT = 2

		,@INVENTORY_ADJUSTMENT_OpeningInventory AS INT = 47

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
	-- Check items if lot tracked
	BEGIN
		DECLARE @CountLottedItems AS INT = 0;

			SELECT @CountLottedItems = COUNT(Item.intItemId)
				FROM dbo.tblICInventoryAdjustment Header INNER JOIN dbo.tblICInventoryAdjustmentDetail Detail
				ON Header.intInventoryAdjustmentId = Detail.intInventoryAdjustmentId
			INNER JOIN dbo.tblICItem Item
				ON Item.intItemId = Detail.intItemId
			WHERE Item.strLotTracking != 'No' AND Header.intInventoryAdjustmentId = @intTransactionId

		IF(@CountLottedItems = 0)
			RETURN 0;
	END

------------------------------------------------------------------------------
-- Get the list of item that needs lot numbers
------------------------------------------------------------------------------

BEGIN 
	INSERT INTO @ItemsThatNeedLotId (
			[intItemId]
			,[intItemLocationId]
			,[intItemUOMId]
			,[strLotNumber]
			,[intSubLocationId]
			,[intStorageLocationId]
			,[dblQty]
			,[dblGrossWeight]
			,[dblWeight]
			,[dblTare]
			,[intWeightUOMId]
			,[strReceiptNumber]
			,[intOwnershipType]
			,[intDetailId]
			,[dblWeightPerQty]
			,[dblTarePerQty]
			,[strTransactionId]
			,[strSourceTransactionId]
			,[intSourceTransactionTypeId]
			,[strLotAlias] 
			,[strWarehouseRefNo]	
			,[intLotStatusId] 
			,[intOriginId] 
			,[strBOLNo] 
			,[strVessel] 
			,[strMarkings] 
			,[strNotes] 
			,[intEntityVendorId] 
			,[strVendorLotNo] 
			,[strGarden] 
			,[dtmManufacturedDate] 
			,[strContainerNo] 
			,[strCondition] 
			,[intSeasonCropYear] 
			,[intBookId] 
			,[intSubBookId] 
			,[strCertificate] 
			,[intProducerId] 
			,[strTrackingNumber]	
			,[strCargoNo] 
			,[strWarrantNo]
	)
	SELECT	[intItemId]					= Detail.intItemId
			,[intItemLocationId]		= ItemLocation.intItemLocationId
			,[intItemUOMId]				= Detail.intNewItemUOMId
			,[strLotNumber]				= Detail.strNewLotNumber
			,[intSubLocationId]			= Detail.intNewSubLocationId
			,[intStorageLocationId]		= Detail.intNewStorageLocationId
			,[dblQty]					= Detail.dblNewQuantity
			,[dblGrossWeight]			= CASE WHEN Detail.intNewWeightUOMId IS NOT NULL THEN Detail.dblGrossWeight ELSE 0 END
			,[dblWeight]				= CASE WHEN Detail.intNewWeightUOMId IS NOT NULL THEN Detail.dblNewWeight ELSE 0 END			
			,[dblTare]					= CASE WHEN Detail.intNewWeightUOMId IS NOT NULL THEN Detail.dblTareWeight ELSE 0 END			
			,[intWeightUOMId]			= CASE WHEN Detail.intNewWeightUOMId IS NOT NULL THEN ISNULL(Detail.intNewWeightUOMId, Detail.intNewItemUOMId) ELSE NULL END
			,[strReceiptNumber]			= Header.strAdjustmentNo
			,[intOwnershipType]			= ISNULL(NULLIF(Detail.intOwnershipType, 0), 1) 
			,[intDetailId]				= Detail.intInventoryAdjustmentDetailId
			,[dblWeightPerQty]			= CASE WHEN Detail.intNewWeightUOMId IS NOT NULL THEN dbo.fnCalculateWeightUnitQty(Detail.dblNewQuantity, Detail.dblNewWeight) ELSE NULL END
			,[dblTarePerQty]			= CASE WHEN Detail.intNewWeightUOMId IS NOT NULL THEN dbo.fnCalculateWeightUnitQty(Detail.dblNewQuantity, Detail.dblTareWeight) ELSE NULL END
			,[strTransactionId]			= Header.strAdjustmentNo
			,[strSourceTransactionId]	= Header.strAdjustmentNo
			,[intSourceTransactionTypeId]= @INVENTORY_ADJUSTMENT_OpeningInventory
			,[strLotAlias]				= Detail.strLotAlias
			,[strWarehouseRefNo]		= Detail.strWarehouseRefNo
			,[intLotStatusId]			= Detail.intNewLotStatusId
			,[intOriginId]				= Detail.intOriginId
			,[strBOLNo]					= Detail.strBOLNo
			,[strVessel]				= Detail.strVessel
			,[strMarkings]				= Detail.strMarkings
			,[strNotes]					= Detail.strNotes
			,[intEntityVendorId]		= Detail.intEntityVendorId
			,[strVendorLotNo]			= Detail.strVendorLotNo
			,[strGarden]				= Detail.strGarden
			,[dtmManufacturedDate]		= Detail.dtmManufacturedDate
			,[strContainerNo]			= Detail.strContainerNo
			,[strCondition]				= Detail.strCondition
			,[intSeasonCropYear]		= Detail.intSeasonCropYear
			,[intBookId]				= Detail.intBookId
			,[intSubBookId]				= Detail.intSubBookId
			,[strCertificate]			= Detail.strCertificate
			,[intProducerId]			= Detail.intProducerId
			,[strTrackingNumber]		= Detail.strTrackingNumber
			,[strCargoNo]				= Detail.strCargoNo
			,[strWarrantNumber]			= Detail.strWarrantNumber

	FROM	dbo.tblICInventoryAdjustment Header INNER JOIN dbo.tblICInventoryAdjustmentDetail Detail
				ON Header.intInventoryAdjustmentId = Detail.intInventoryAdjustmentId
			INNER JOIN dbo.tblICItem Item
				ON Item.intItemId = Detail.intItemId
			INNER JOIN dbo.tblICItemLocation ItemLocation
				ON ItemLocation.intItemId = Detail.intItemId
				AND ItemLocation.intLocationId = Header.intLocationId
			LEFT JOIN dbo.tblICItemUOM NewItemUOMId 
				ON NewItemUOMId.intItemUOMId = Detail.intNewItemUOMId
	WHERE	Header.intInventoryAdjustmentId = @intTransactionId
		AND Item.strLotTracking != 'No'
		AND NULLIF(Detail.strNewLotNumber, '') IS NOT NULL
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