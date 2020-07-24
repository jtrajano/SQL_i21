CREATE PROCEDURE [dbo].[uspICCreateLotNumberOnInventoryAdjustmentItemChange]
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
	DECLARE @OpenReceiveQty AS NUMERIC(18,6)
	DECLARE @LotQty AS NUMERIC(18,6)
	DECLARE @OpenReceiveQtyInItemUOM AS NUMERIC(18,6)
	DECLARE @LotQtyInItemUOM AS NUMERIC(18,6)

	DECLARE @FormattedReceivedQty AS NVARCHAR(50)
	DECLARE @FormattedLotQty AS NVARCHAR(50)
	DECLARE @FormattedDifference AS NVARCHAR(50)

	-- Check items if lot tracked
	BEGIN
		DECLARE @CountLottedItems AS INT = 0;

			SELECT @CountLottedItems = COUNT(Item.intItemId)
				FROM dbo.tblICInventoryAdjustment Header INNER JOIN dbo.tblICInventoryAdjustmentDetail Detail
				ON Header.intInventoryAdjustmentId = Detail.intInventoryAdjustmentId
			INNER JOIN dbo.tblICItem Item
				ON Item.intItemId = Detail.intNewItemId
			WHERE Item.strLotTracking != 'No' AND Header.intInventoryAdjustmentId = @intTransactionId

		IF(@CountLottedItems = 0)
			RETURN 0;
	END

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
				AND Header.intInventoryAdjustmentId = @intTransactionId

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
			,[strContainerNo]
			,[strCondition]
			,[intBookId]
			,[intSubBookId]
			,[strCertificate]
			,[intProducerId]
			,[strCertificateId]
			,[strTrackingNumber]
	)
	SELECT	[intLotId]					= Detail.intNewLotId 
			,[intItemId]				= Detail.intNewItemId
			,[intItemLocationId]		= NewItemLocation.intItemLocationId
			,[intItemUOMId]				= NewItemUOM.intItemUOMId
			,[strLotNumber]				= ISNULL(Detail.strNewLotNumber, SourceLot.strLotNumber)
			,[intSubLocationId]			= SourceLot.intSubLocationId
			,[intStorageLocationId]		= SourceLot.intStorageLocationId
			,[dblQty]					= 1 --SourceLot.dblQty
			,[dtmExpiryDate]			= SourceLot.dtmExpiryDate
			,[strLotAlias]				= SourceLot.strLotAlias
			,[intLotStatusId]			= SourceLot.intLotStatusId
			,[intParentLotId]			= SourceLot.intParentLotId
			,[strParentLotNumber]		= NULL -- ParentLotSourceLot.strParentLotNumber
			,[strParentLotAlias]		= NULL -- ParentLotSourceLot.strParentLotAlias
			,[intSplitFromLotId]		= SourceLot.intLotId
			,[dblGrossWeight]			= SourceLot.dblGrossWeight
			,[dblWeight]				= -- SourceLot.dblWeight
											CASE	WHEN Detail.intItemUOMId = SourceLot.intWeightUOMId THEN 
														-- When cutting a bag into weights, then qty becomes wgt. 
														1 
													ELSE 
														-- Lot will still use the same qty, then use the same wgt-per-qty. 
														ISNULL(Detail.dblWeightPerQty, 0) 
											END

			,[intWeightUOMId]			= NewWeightUOM.intItemUOMId
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
			,[strContainerNo]			= SourceLot.strContainerNo
			,[strCondition]				= SourceLot.strCondition
			,[intBookId]				= SourceLot.intBookId
			,[intSubBookId]				= SourceLot.intSubBookId
			,[strCertificate]			= SourceLot.strCertificate
			,[intProducerId]			= SourceLot.intProducerId
			,[strCertificateId]			= SourceLot.strCertificateId
			,[strTrackingNumber]		= SourceLot.strTrackingNumber 

	FROM	dbo.tblICInventoryAdjustment Header INNER JOIN dbo.tblICInventoryAdjustmentDetail Detail
				ON Header.intInventoryAdjustmentId = Detail.intInventoryAdjustmentId

			INNER JOIN dbo.tblICItemLocation NewItemLocation
				ON NewItemLocation.intItemId = Detail.intNewItemId
				AND NewItemLocation.intLocationId = Header.intLocationId

			INNER JOIN dbo.tblICLot SourceLot
				ON SourceLot.intLotId = Detail.intLotId			

			LEFT JOIN dbo.tblICItemUOM NewItemUOM
				ON NewItemUOM.intItemId = Detail.intNewItemId
				AND NewItemUOM.intItemUOMId = dbo.fnGetMatchingItemUOMId(Detail.intNewItemId, Detail.intItemUOMId)-- SourceLot.intItemUOMId)

			LEFT JOIN dbo.tblICItemUOM NewWeightUOM
				ON NewWeightUOM.intItemId = Detail.intNewItemId
				AND NewWeightUOM.intItemUOMId = dbo.fnGetMatchingItemUOMId(Detail.intNewItemId, SourceLot.intWeightUOMId)

			--LEFT JOIN dbo.tblICParentLot ParentLotSourceLot
			--	ON ParentLotSourceLot.intParentLotId = SourceLot.intParentLotId
	WHERE	Header.intInventoryAdjustmentId = @intTransactionId
END 

-- Call the common stored procedure that will create or update the lot master table
BEGIN 
	DECLARE @intErrorFoundOnCreateUpdateLotNumber AS INT

	EXEC @intErrorFoundOnCreateUpdateLotNumber = dbo.uspICCreateUpdateLotNumber 
		@ItemsThatNeedLotId
		,@intEntityUserSecurityId
		,NULL
		,1

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