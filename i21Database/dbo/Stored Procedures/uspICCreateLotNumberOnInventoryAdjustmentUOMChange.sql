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
	DECLARE @strLotNumber AS NVARCHAR(50)

	DECLARE @FormattedReceivedQty AS NVARCHAR(50)
	DECLARE @FormattedLotQty AS NVARCHAR(50)
	DECLARE @FormattedDifference AS NVARCHAR(50)

	-- Check if the lot change is full.
	BEGIN 
		SELECT	TOP 1 
				@strUnitMeasure = iUOM.strUnitMeasure 
				,@strLotNumber = Lot.strLotNumber
		FROM	dbo.tblICInventoryAdjustment Header INNER JOIN dbo.tblICInventoryAdjustmentDetail Detail
					ON Header.intInventoryAdjustmentId = Detail.intInventoryAdjustmentId
				INNER JOIN tblICLot Lot
					ON Lot.intLotId = Detail.intLotId
				INNER JOIN tblICInventoryLot LotTrans
					ON LotTrans.intLotId = Detail.intLotId
				INNER JOIN (
					tblICItemUOM ItemUOM INNER JOIN tblICUnitMeasure iUOM
						ON ItemUOM.intUnitMeasureId = iUOM.intUnitMeasureId
				)	ON ItemUOM.intItemUOMId = Detail.intNewItemUOMId
		WHERE	LotTrans.dblStockOut <> 0
			AND Header.intInventoryAdjustmentId = @intTransactionId 

		IF @strLotNumber IS NOT NULL 
		BEGIN 
			-- 'Cannot change UOM to {New UOM} . {Lot Number} is partially allocated.'
			EXEC uspICRaiseError 80215, @strUnitMeasure, @strLotNumber;
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