CREATE PROCEDURE [dbo].[uspICCreateLotNumberOnInventoryAdjustmentUOMChange]
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
	)
	SELECT	[intLotId]					= Detail.intLotId 
			,[intItemId]				= Detail.intItemId
			,[intItemLocationId]		= ItemLocation.intItemLocationId
			,[intItemUOMId]				= Detail.intNewItemUOMId
			,[strLotNumber]				= SourceLot.strLotNumber
			,[intSubLocationId]			= Detail.intSubLocationId
			,[intStorageLocationId]		= Detail.intStorageLocationId
			,[dblQty]					= Detail.dblNewQuantity
			,[intLotStatusId]			= Detail.intLotStatusId
			,[intOwnershipType]			= 1
			,[intDetailId]				= Detail.intInventoryAdjustmentDetailId
			,[strTransactionId]			= Header.strAdjustmentNo
			,[intWeightUOMId]           = Detail.intWeightUOMId
			,[dblWeightQty]             = Detail.dblWeight
	FROM tblICInventoryAdjustment Header
		INNER JOIN tblICInventoryAdjustmentDetail Detail 
			ON Detail.intInventoryAdjustmentId = Header.intInventoryAdjustmentId
		LEFT JOIN tblICItemLocation ItemLocation 
			ON ItemLocation.intItemId = Detail.intItemId AND ItemLocation.intLocationId = Header.intLocationId
		INNER JOIN tblICLot SourceLot
			ON SourceLot.intLotId = Detail.intLotId
		INNER JOIN tblICItemUOM WeightUOM
			ON WeightUOM.intItemUOMId = Detail.intNewItemUOMId
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