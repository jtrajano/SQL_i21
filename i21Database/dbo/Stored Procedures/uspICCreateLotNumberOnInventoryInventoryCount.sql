CREATE PROCEDURE [dbo].[uspICCreateLotNumberOnInventoryInventoryCount]
	@intTransactionId INT 
	,@intEntityUserSecurityId INT = NULL 
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
			,[strLotAlias]
			,[intLotStatusId]
			,[intOwnershipType]
			,[intDetailId]
			,[strTransactionId]
			,[intWeightUOMId]
			,[dblWeight]
			,[dblGrossWeight]
			,[dtmExpiryDate]
			,[strParentLotNumber]
			,[strParentLotAlias]
	)
	SELECT	[intLotId]					= Detail.intLotId 
			,[intItemId]				= Detail.intItemId
			,[intItemLocationId]		= ISNULL(Detail.intItemLocationId, ItemLocation.intItemLocationId)
			,[intItemUOMId]				= Detail.intItemUOMId
			,[strLotNumber]				= Detail.strLotNo
			,[intSubLocationId]			= Detail.intSubLocationId
			,[intStorageLocationId]		= Detail.intStorageLocationId
			,[dblQty]					= 
					CASE 
						WHEN @ysnPost = 1 THEN 
							(Detail.dblPhysicalCount - Detail.dblSystemCount) 
						ELSE 
							-- Negate the qty when unposting.  
							-(Detail.dblPhysicalCount - Detail.dblSystemCount)
					END 
					
			,[strLotAlias]				= Detail.strLotAlias
			,[intLotStatusId]			= 1
			,[intOwnershipType]			= 1
			,[intDetailId]				= Detail.intInventoryCountDetailId
			,[strTransactionId]			= Header.strCountNo
			,[intWeightUOMId]           = 
					CASE 
						WHEN Item.ysnLotWeightsRequired = 1 THEN Detail.intWeightUOMId
						WHEN Detail.intWeightUOMId IS NOT NULL THEN Detail.intWeightUOMId
						ELSE NULL 
					END
			,[dblWeight]             = 
				CASE 
					WHEN @ysnPost = 1 THEN 
						Detail.dblNetQty - Detail.dblWeightQty 
					ELSE
						-- Negate the weight when unposting.  
						-(Detail.dblNetQty - Detail.dblWeightQty )
				END 
			,[dblGrossWeight]           = 
					CASE 
						WHEN @ysnPost = 1 THEN 
							Detail.dblNetQty - Detail.dblWeightQty 
						ELSE
							-- Negate the weight when unposting.  
							-(Detail.dblNetQty - Detail.dblWeightQty )
					END 

			,[dtmExpiryDate]			= dbo.fnICCalculateExpiryDate(Detail.intItemId, Header.dtmCountDate, Header.dtmCountDate)
			,[strParentLotNumber]		= Detail.strParentLotNo
			,[strParentLotAlias]		= Detail.strParentLotAlias
	FROM tblICInventoryCount Header
		INNER JOIN tblICInventoryCountDetail Detail ON Detail.intInventoryCountId = Header.intInventoryCountId
		INNER JOIN tblICItem Item ON Item.intItemId = Detail.intItemId
		LEFT JOIN tblICItemLocation ItemLocation ON ItemLocation.intItemId = Detail.intItemId
			AND ItemLocation.intLocationId = Header.intLocationId
	WHERE Header.intInventoryCountId = @intTransactionId
		AND (
			ISNULL(Detail.dblPhysicalCount, 0) - ISNULL(Detail.dblSystemCount, 0) <> 0 
			OR ISNULL(Detail.dblNetQty, 0) - ISNULL(Detail.dblWeightQty, 0) <> 0 
		)
		AND Item.strLotTracking <> 'No'
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
	UPDATE	dbo.tblICInventoryCountDetail
	SET		intLotId = LotNumbers.intLotId
			,strLotNo = LotNumbers.strLotNumber
			,intParentLotId = LotNumbers.intParentLotId
			,strParentLotNo = LotNumbers.strParentLotNumber
	FROM	dbo.tblICInventoryCountDetail Detail INNER JOIN #GeneratedLotItems LotNumbers
				ON Detail.intInventoryCountDetailId = LotNumbers.intDetailId
END 

IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#GeneratedLotItems')) 
	DROP TABLE #GeneratedLotItems

RETURN 0;