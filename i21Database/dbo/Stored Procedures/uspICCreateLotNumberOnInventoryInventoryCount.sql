﻿CREATE PROCEDURE [dbo].[uspICCreateLotNumberOnInventoryInventoryCount]
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
			,[strLotAlias]
			,[intLotStatusId]
			,[intOwnershipType]
			,[intDetailId]
			,[strTransactionId]
			,[intWeightUOMId]
			,[dblWeight]
			,[dblGrossWeight]
			,[dblWeightPerQty]
	)
	SELECT	[intLotId]					= Detail.intLotId 
			,[intItemId]				= Detail.intItemId
			,[intItemLocationId]		= ISNULL(Detail.intItemLocationId, ItemLocation.intItemLocationId)
			,[intItemUOMId]				= Detail.intItemUOMId
			,[strLotNumber]				= Detail.strLotNo
			,[intSubLocationId]			= Detail.intSubLocationId
			,[intStorageLocationId]		= Detail.intStorageLocationId
			,[dblQty]					= Detail.dblPhysicalCount
			,[strLotAlias]				= Detail.strLotAlias
			,[intLotStatusId]			= 1
			,[intOwnershipType]			= 1
			,[intDetailId]				= Detail.intInventoryCountDetailId
			,[strTransactionId]			= Header.strCountNo
			,[intWeightUOMId]           = Detail.intWeightUOMId
			,[dblWeightQty]             = Detail.dblWeightQty
			,[dblGrossWeight]           = Detail.dblWeightQty
			,[dblWeightPerQty]          = Detail.dblWeightQty / Detail.dblPhysicalCount

	FROM tblICInventoryCount Header
		INNER JOIN tblICInventoryCountDetail Detail ON Detail.intInventoryCountId = Header.intInventoryCountId
		LEFT JOIN tblICItemLocation ItemLocation ON ItemLocation.intItemId = Detail.intItemId
			AND ItemLocation.intLocationId = Header.intLocationId
	WHERE Header.intInventoryCountId = @intTransactionId
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
	UPDATE	dbo.tblICInventoryCountDetail
	SET		intLotId = LotNumbers.intLotId
			,strLotNo = LotNumbers.strLotNumber
	FROM	dbo.tblICInventoryCountDetail Detail INNER JOIN #GeneratedLotItems LotNumbers
				ON Detail.intInventoryCountDetailId = LotNumbers.intDetailId
END 

IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#GeneratedLotItems')) 
	DROP TABLE #GeneratedLotItems

RETURN 0;