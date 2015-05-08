CREATE PROCEDURE [dbo].[uspICCreateLotNumberOnInventoryAdjustmentSplitLot]
	@intTransactionId INT 
	,@intUserId INT = NULL 
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
			RAISERROR(51050, 11, 1, @strUnitMeasure, @strItemNo) 
			RETURN -1; 			 
		END 
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
			,strBOLNo
			,strVessel
			,strReceiptNumber
			,strMarkings
			,strNotes
			,intEntityVendorId
			,strVendorLotNo
			,intVendorLocationId
			,strVendorLocation
			,intDetailId		
	)
	SELECT	intLotId				= NULL 
			,strLotNumber			= Detail.strNewLotNumber
			,strLotAlias			= SourceLot.strLotAlias
			,intItemId				= Detail.intItemId
			,intItemLocationId		= ItemLocation.intItemLocationId
			,intSubLocationId		= Detail.intNewSubLocationId
			,intStorageLocationId	= Detail.intNewStorageLocationId
			,dblQty					= Detail.dblNewSplitLotQuantity
			,intItemUOMId			= ISNULL(Detail.intNewItemUOMId, Detail.intItemUOMId)
			,dblWeight				=	
										CASE	WHEN ISNULL(Detail.dblNewWeight, 0) = 0 THEN 
													ABS(
														ISNULL(SourceLot.dblWeightPerQty, 0) * 
														CASE	WHEN ISNULL(Detail.dblNewSplitLotQuantity, 0) = 0 THEN ISNULL(Detail.dblAdjustByQuantity, 0)
																ELSE Detail.dblNewSplitLotQuantity
														END 
													)
												ELSE Detail.dblNewWeight
										END 
			,intWeightUOMId			= ISNULL(Detail.intNewWeightUOMId, Detail.intWeightUOMId)
			,dtmExpiryDate			= SourceLot.dtmExpiryDate
			,dtmManufacturedDate	= SourceLot.dtmManufacturedDate
			,intOriginId			= SourceLot.intOriginId
			,strBOLNo				= SourceLot.strBOLNo
			,strVessel				= SourceLot.strVessel
			,strReceiptNumber		= Header.strAdjustmentNo
			,strMarkings			= SourceLot.strMarkings
			,strNotes				= SourceLot.strNotes
			,intEntityVendorId		= SourceLot.intEntityVendorId
			,strVendorLotNo			= SourceLot.strVendorLotNo
			,intVendorLocationId	= SourceLot.intVendorLocationId
			,strVendorLocation		= SourceLot.strVendorLocation
			,intDetailId			= Detail.intInventoryAdjustmentDetailId
	FROM	dbo.tblICInventoryAdjustment Header INNER JOIN dbo.tblICInventoryAdjustmentDetail Detail
				ON Header.intInventoryAdjustmentId = Detail.intInventoryAdjustmentId
			INNER JOIN dbo.tblICItemLocation ItemLocation
				ON ItemLocation.intItemId = Detail.intItemId
				AND ItemLocation.intLocationId = ISNULL(Detail.intNewLocationId, Header.intLocationId)
			INNER JOIN dbo.tblICLot SourceLot
				ON SourceLot.intLotId = Detail.intLotId
	WHERE	Header.intInventoryAdjustmentId = @intTransactionId
END 

-- Call the common stored procedure that will create or update the lot master table
BEGIN 
	DECLARE @intErrorFoundOnCreateUpdateLotNumber AS INT

	EXEC @intErrorFoundOnCreateUpdateLotNumber = dbo.uspICCreateUpdateLotNumber 
		@ItemsThatNeedLotId
		,@intUserId

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
