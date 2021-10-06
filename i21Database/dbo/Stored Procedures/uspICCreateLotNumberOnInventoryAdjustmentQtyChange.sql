CREATE PROCEDURE [dbo].[uspICCreateLotNumberOnInventoryAdjustmentQtyChange]
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
			,[dblGrossWeight]
			,[dblWeightPerQty]
			,intContractHeaderId
			,intContractDetailId
			,ysnWeighed
			,strSealNo
	)
	SELECT	[intLotId]					= Detail.intLotId 
			,[intItemId]				= Detail.intItemId
			,[intItemLocationId]		= ItemLocation.intItemLocationId
			,[intItemUOMId]				= Detail.intItemUOMId
			,[strLotNumber]				= Detail.strNewLotNumber
			,[intSubLocationId]			= Detail.intSubLocationId
			,[intStorageLocationId]		= Detail.intStorageLocationId
			,[dblQty]					= Detail.dblAdjustByQuantity
			,[intLotStatusId]			= Detail.intLotStatusId
			,[intOwnershipType]			= 1
			,[intDetailId]				= Detail.intInventoryAdjustmentDetailId
			,[strTransactionId]			= Header.strAdjustmentNo 
			,[intWeightUOMId]           = case when 
													isnull(Detail.strNewLotNumber, '') <> '' and 
													intNewWeightUOMId is null and
													Detail.intLotId is null then Detail.intItemUOMId else Detail.intNewWeightUOMId end
			,[dblWeightQty]             = case when 
													isnull(Detail.strNewLotNumber, '') <> '' and 
													Detail.dblWeight  is null and 
													Detail.intLotId is null then Detail.dblNewWeight else Detail.dblWeight end
			,[dblGrossWeight]           = case when 
													isnull(Detail.strNewLotNumber, '') <> '' and 
													Detail.dblWeight  is null and 
													Detail.intLotId is null then Detail.dblNewWeight else Detail.dblWeight end
			,[dblWeightPerQty]          = case when 
													isnull(Detail.strNewLotNumber, '') <> '' and 
													Detail.dblWeightPerQty is null and 
													Detail.intLotId is null then Detail.dblNewWeightPerQty else Detail.dblWeightPerQty end
			,intContractHeaderId		= SourceLot.intContractHeaderId
			,intContractDetailId		= SourceLot.intContractDetailId
			,ysnWeighed					= SourceLot.ysnWeighed
			,strSealNo					= SourceLot.strSealNo
	FROM tblICInventoryAdjustment Header
		INNER JOIN tblICInventoryAdjustmentDetail Detail ON Detail.intInventoryAdjustmentId = Header.intInventoryAdjustmentId
		LEFT JOIN tblICItemLocation ItemLocation ON ItemLocation.intItemId = Detail.intItemId
			AND ItemLocation.intLocationId = Header.intLocationId
		LEFT JOIN tblICLot SourceLot
			ON SourceLot.intLotId = Detail.intLotId
	WHERE Header.intInventoryAdjustmentId = @intTransactionId
		AND NULLIF(Detail.strNewLotNumber, '') IS NOT NULL
        AND Detail.intLotId IS NULL
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
	SET		intLotId = LotNumbers.intLotId
	FROM	dbo.tblICInventoryAdjustmentDetail Detail INNER JOIN #GeneratedLotItems LotNumbers
				ON Detail.intInventoryAdjustmentDetailId = LotNumbers.intDetailId
END 

IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#GeneratedLotItems')) 
	DROP TABLE #GeneratedLotItems

RETURN 0;