CREATE PROCEDURE [dbo].[uspICCreateLotNumberOnInventoryAdjustmentChangeLotWeight]
	@intTransactionId INT 
	,@ysnPost BIT
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
			,[intLotStatusId]
			,[intOwnershipType]
			,[intDetailId]
			,[strTransactionId]
			,[intWeightUOMId]
			,[dblWeight]
			-- Get defaulting values
			,[dtmExpiryDate]
			,[intParentLotId]
			,[strLotAlias]
			,[intOriginId]
			,[intGradeId]
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
			,[intSplitFromLotId]
			,[intNoPallet]
			,[intUnitPallet]
			,[strContainerNo]
			,[strCondition]
			,[intSeasonCropYear]
	)
	SELECT	[intLotId]					= Detail.intLotId 
			,[intItemId]				= Detail.intItemId
			,[intItemLocationId]		= ItemLocation.intItemLocationId
			,[intItemUOMId]				= Detail.intItemUOMId
			,[strLotNumber]				= SourceLot.strLotNumber
			,[intSubLocationId]			= Detail.intSubLocationId
			,[intStorageLocationId]		= Detail.intStorageLocationId
			,[dblQty]					= Detail.dblQuantity
			,[intLotStatusId]			= Detail.intLotStatusId
			,[intOwnershipType]			= 1
			,[intDetailId]				= Detail.intInventoryAdjustmentDetailId
			,[strTransactionId]			= Header.strAdjustmentNo
			,[intWeightUOMId]           = CASE WHEN @ysnPost = 1 THEN Detail.intNewWeightUOMId ELSE Detail.intWeightUOMId END
			,[dblWeight]				= CASE WHEN @ysnPost = 1 THEN Detail.dblNewWeight ELSE Detail.dblWeight END
			-- Get defaulting values
			,[dtmExpiryDate]			= SourceLot.dtmExpiryDate
			,[intParentLotId]			= SourceLot.intParentLotId
			,[strLotAlias]				= SourceLot.strLotAlias
			,[intOriginId]				= SourceLot.intOriginId
			,[intGradeId]				= SourceLot.intGradeId
			,[strBOLNo]					= SourceLot.strBOLNo
			,[strVessel]				= SourceLot.strVessel
			,[strReceiptNumber]			= SourceLot.strReceiptNumber
			,[strMarkings]				= SourceLot.strMarkings
			,[strNotes]					= SourceLot.strNotes
			,[intEntityVendorId]		= SourceLot.intEntityVendorId
			,[strVendorLotNo]			= SourceLot.strVendorLotNo
			,[strGarden]				= SourceLot.strGarden
			,[strContractNo]			= SourceLot.strContractNo
			,[dtmManufacturedDate]		= SourceLot.dtmManufacturedDate
			,[intSplitFromLotId]		= SourceLot.intSplitFromLotId
			,[intNoPallet]				= SourceLot.intNoPallet
			,[intUnitPallet]			= SourceLot.intUnitPallet
			,[strContainerNo]			= SourceLot.strContainerNo
			,[strCondition]				= SourceLot.strCondition
			,[intSeasonCropYear]		= SourceLot.intSeasonCropYear
	FROM tblICInventoryAdjustment Header
		INNER JOIN tblICInventoryAdjustmentDetail Detail 
			ON Detail.intInventoryAdjustmentId = Header.intInventoryAdjustmentId
		LEFT JOIN tblICItemLocation ItemLocation 
			ON ItemLocation.intItemId = Detail.intItemId AND ItemLocation.intLocationId = Header.intLocationId
		INNER JOIN tblICLot SourceLot
			ON SourceLot.intLotId = Detail.intLotId
	WHERE Header.intInventoryAdjustmentId = @intTransactionId
        AND Detail.intLotId IS NOT NULL
	

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