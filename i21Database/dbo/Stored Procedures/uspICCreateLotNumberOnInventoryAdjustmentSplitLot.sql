CREATE PROCEDURE [dbo].[uspICCreateLotNumberOnInventoryAdjustmentSplitLot]
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
			,[dblWeightPerQty]
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
			,[intSeasonCropYear]
	)
	SELECT	[intLotId]					= TargetLot.intLotId 
			,[intItemId]				= Detail.intItemId
			,[intItemLocationId]		= ItemLocation.intItemLocationId
			,[intItemUOMId]				= ISNULL(Detail.intNewItemUOMId, Detail.intItemUOMId) --ISNULL(Detail.intNewItemUOMId, Detail.intItemUOMId)
			,[strLotNumber]				= Detail.strNewLotNumber
			,[intSubLocationId]			= ISNULL(Detail.intNewSubLocationId, SourceLot.intSubLocationId)
			,[intStorageLocationId]		= ISNULL(Detail.intNewStorageLocationId, SourceLot.intStorageLocationId)
			,[dblQty]					= CASE	WHEN ISNULL(Detail.dblNewSplitLotQuantity, 0) <> 0 THEN 
												Detail.dblNewSplitLotQuantity
											ELSE  
												1 
										  END 
			,[dtmExpiryDate]			= SourceLot.dtmExpiryDate
			,[strLotAlias]				= ISNULL(TargetLot.strLotAlias, SourceLot.strLotAlias) -- If target lot exists, keep the same alias. 
			,[intLotStatusId]			= SourceLot.intLotStatusId
										-- If target lot exists, and qty or weight is not zero, then do not overwrite the parent lot info. 
			,[intParentLotId]			= --ISNULL(TargetLot.intParentLotId, SourceLot.intParentLotId)
										CASE 
											WHEN TargetLot.dblQty = 0 OR (TargetLot.intWeightUOMId IS NOT NULL AND TargetLot.dblWeight = 0) THEN 
												SourceLot.intParentLotId
											ELSE 
												ISNULL(TargetLot.intParentLotId, SourceLot.intParentLotId)
										END 

			,[strParentLotNumber]		= --ISNULL(ParentLotTargetLot.strParentLotNumber, ParentLotSourceLot.strParentLotNumber)
										CASE 
											WHEN TargetLot.dblQty = 0 OR (TargetLot.intWeightUOMId IS NOT NULL AND TargetLot.dblWeight = 0) THEN 
												ParentLotSourceLot.strParentLotNumber
											ELSE 
												ISNULL(ParentLotTargetLot.strParentLotNumber, ParentLotSourceLot.strParentLotNumber)
										END 

			,[strParentLotAlias]		= --ISNULL(ParentLotTargetLot.strParentLotAlias, ParentLotSourceLot.strParentLotAlias)  
										CASE 
											WHEN TargetLot.dblQty = 0 OR (TargetLot.intWeightUOMId IS NOT NULL AND TargetLot.dblWeight = 0) THEN 
												ParentLotSourceLot.strParentLotAlias 
											ELSE 
												ISNULL(ParentLotTargetLot.strParentLotAlias, ParentLotSourceLot.strParentLotAlias)  
										END 

			,[intSplitFromLotId]		= SourceLot.intLotId
			,[dblGrossWeight]			= SourceLot.dblGrossWeight
			,[dblWeight]				=  
											CASE	WHEN ISNULL(Detail.dblNewWeight, 0) <> 0 THEN 
													-- when a new wgt is supplied, then use it`. 
													Detail.dblNewWeight
													
												WHEN Detail.intNewWeightUOMId IS NOT NULL THEN 
													-- when there is a new wgt uom, convert the exising wgt to the new Wgt UOM.
													dbo.fnCalculateQtyBetweenUOM(
														Detail.intWeightUOMId
														, Detail.intNewWeightUOMId
														, dbo.fnMultiply(																	
															SourceLot.dblWeightPerQty
															,dbo.fnMultiply(-1, (ISNULL(Detail.dblNewQuantity, 0) - ISNULL(Detail.dblQuantity, 0))) 
														) 
													)
													
												WHEN ISNULL(Detail.dblNewSplitLotQuantity, 0) <> 0 THEN
													-- when there is a new split lot qty, compute the original weight. 
													CASE	WHEN Detail.intItemUOMId = SourceLot.intWeightUOMId THEN 
																-- if new split lot qty is using the weight uom, then use it. 
																Detail.dblNewSplitLotQuantity
															ELSE
																-- if new split lot qty is not using the wgt uom, then compute the original wgt. 
																dbo.fnMultiply(																	
																	SourceLot.dblWeightPerQty
																	,dbo.fnMultiply(-1, (ISNULL(Detail.dblNewQuantity, 0) - ISNULL(Detail.dblQuantity, 0))) 
																) 
													END 
													
												WHEN ISNULL(Detail.intNewItemUOMId, Detail.intItemUOMId) = SourceLot.intWeightUOMId THEN 
													-- When cutting a bag into weights, then qty becomes wgt. 
													1 
													
												WHEN SourceLot.intWeightUOMId IS NULL AND TargetLot.intWeightUOMId = SourceLot.intItemUOMId THEN 
													-- When SourceLot.intWeightuOMId is empty but TargetLot.intWeightUOMId equals SourceLot.intItemUOMId,
													-- then weight and qty must be equal.
													1
													
												ELSE 
													-- Lot will still use the same qty, then use the same wgt-per-qty. 
													ISNULL(Detail.dblWeightPerQty, 0) 
													
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
			,[dblWeightPerQty]			=  CASE	WHEN ISNULL(Detail.dblNewWeight, 0) <> 0 THEN 
													-- Calculate a new weight per qty if the new wgt is supplied. 
													dbo.fnCalculateWeightUnitQty(ISNULL(Detail.dblNewSplitLotQuantity, 0), Detail.dblNewWeight) 
												WHEN Detail.intNewWeightUOMId IS NOT NULL THEN 
													-- Calculate a new weight per qty if there is a new wgt-per-uom. 
													dbo.fnCalculateWeightUnitQty(
														ISNULL(
															Detail.dblNewSplitLotQuantity
															, ISNULL(Detail.dblNewQuantity, 0) - ISNULL(Detail.dblQuantity, 0)
														)
														,dbo.fnCalculateQtyBetweenUOM(
															Detail.intWeightUOMId
															, Detail.intNewWeightUOMId
															, ISNULL(Detail.dblWeightPerQty, 0) * -1 * (ISNULL(Detail.dblNewQuantity, 0) - ISNULL(Detail.dblQuantity, 0))
														)
													)
												WHEN ISNULL(Detail.intNewItemUOMId, Detail.intItemUOMId) = SourceLot.intWeightUOMId THEN 
													-- When cutting a bag into wgt, then qty becomes wgt. 
													1
												WHEN SourceLot.intWeightUOMId IS NULL AND TargetLot.intWeightUOMId = SourceLot.intItemUOMId THEN 
													-- When SourceLot.intWeightuOMId is empty but TargetLot.intWeightUOMId equals SourceLot.intItemUOMId,
													-- use the TargetLot.dblWeightPerQty
													TargetLot.dblWeightPerQty
												ELSE 
													-- lot will still use the same qty. the use the same wgt-per-qty. 
													SourceLot.dblWeightPerQty
											END
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
			,[intSeasonCropYear]		= SourceLot.intSeasonCropYear
	FROM	dbo.tblICInventoryAdjustment Header INNER JOIN dbo.tblICInventoryAdjustmentDetail Detail
				ON Header.intInventoryAdjustmentId = Detail.intInventoryAdjustmentId
			INNER JOIN dbo.tblICItemLocation ItemLocation
				ON ItemLocation.intItemId = Detail.intItemId
				AND ItemLocation.intLocationId = ISNULL(Detail.intNewLocationId, Header.intLocationId)
			INNER JOIN dbo.tblICLot SourceLot
				ON SourceLot.intLotId = Detail.intLotId
			LEFT JOIN dbo.tblICItemUOM NewItemUOMId 
				ON NewItemUOMId.intItemUOMId = Detail.intNewItemUOMId
			LEFT JOIN dbo.tblICLot TargetLot
				ON TargetLot.strLotNumber = Detail.strNewLotNumber
				AND TargetLot.intItemId = Detail.intItemId
				AND TargetLot.intItemLocationId = ItemLocation.intItemLocationId
				AND ISNULL(TargetLot.intSubLocationId, 0) = ISNULL(Detail.intNewSubLocationId, 0)
				AND ISNULL(TargetLot.intStorageLocationId, 0) = ISNULL(Detail.intNewStorageLocationId, 0)				
			LEFT JOIN dbo.tblICParentLot ParentLotSourceLot
				ON ParentLotSourceLot.intParentLotId = SourceLot.intParentLotId
			LEFT JOIN dbo.tblICParentLot ParentLotTargetLot
				ON ParentLotTargetLot.intParentLotId = TargetLot.intParentLotId
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