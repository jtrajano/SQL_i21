/*
	Used to validate the items when doing an unpost. When an error is found, it will execute a RAISERROR. 
	This stored procedure is internally used for validation and it will always be called. 
	
	If you wish to retrieve the errors prior to unposting and show it to the user, I suggest you use fnGetItemCostingOnUnpostErrors
	and return the result back to the user-interface. 

	These are the validations performed by this stored procedure
	1. Check for available stock quantity (for outbound stock)
	2. Check if negative stock is allowed (for outbound stock)
*/

CREATE PROCEDURE [dbo].[uspICValidateCostingOnUnpostStorage]
	@ItemsToValidate UnpostItemsTableType READONLY
	,@ysnRecap BIT = 0 
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS ON

DECLARE @strItemNo AS NVARCHAR(50)
		,@intItemId AS INT 
		,@strLocationName AS NVARCHAR(2000)
		,@intErrorCode AS INT
		,@strText AS NVARCHAR(2000) 		

IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#FoundErrors')) 
	DROP TABLE #FoundErrors

CREATE TABLE #FoundErrors (
	intItemId INT
	,intItemLocationId INT
	,intSubLocationId INT
	,intStorageLocationId INT
	,strText NVARCHAR(MAX)
	,intErrorCode INT
	,intTransactionTypeId INT
)

-- Cross-check each items against the function that does the validation. 
-- Store the result in a temporary table. 
INSERT INTO #FoundErrors
SELECT	Errors.intItemId
		,Errors.intItemLocationId
		,Item.intSubLocationId
		,Item.intStorageLocationId
		,Errors.strText
		,Errors.intErrorCode
		,Item.intTransactionTypeId
FROM	@ItemsToValidate Item CROSS APPLY dbo.fnGetItemCostingOnUnpostStorageErrors(Item.intItemId, Item.intItemLocationId, Item.intItemUOMId, Item.intSubLocationId, Item.intStorageLocationId, Item.dblQty, Item.intLotId) Errors
WHERE	ISNULL(@ysnRecap, 0) = 0

-- If such error is found, raise the error to stop the costing and allow the caller code to do a rollback. 
-- Check for negative stock qty 
IF EXISTS (SELECT TOP 1 1 FROM #FoundErrors WHERE intErrorCode = 80003)
BEGIN 
	SELECT @strItemNo = NULL, @intItemId = NULL 

	SELECT TOP 1 
			@strItemNo = CASE WHEN ISNULL(Item.strItemNo, '') = '' THEN '(Item id: ' + CAST(Item.intItemId AS NVARCHAR(10)) + ')' ELSE Item.strItemNo END 
			,@strLocationName = 
				dbo.fnFormatMsg80003 (
					Errors.intItemLocationId
					,Errors.intSubLocationId
					,Errors.intStorageLocationId
				)			
	FROM	#FoundErrors Errors INNER JOIN tblICItem Item
				ON Errors.intItemId = Item.intItemId
	WHERE	intErrorCode = 80003

	--'Negative stock quantity is not allowed for {Item No} in {Location Name}.'
	EXEC uspICRaiseError 80003, @strItemNo, @strLocationName; 
	RETURN -1
END 

-- Check for the locked Items
SELECT @strItemNo = NULL, @intItemId = NULL
SELECT TOP 1 
		@intItemId = Errors.intItemId 
		,@intErrorCode = Errors.intErrorCode
		,@strText = Errors.strText
FROM	#FoundErrors Errors 
WHERE	intErrorCode IN (80066, 80239, 80240, 80241)
		AND Errors.intTransactionTypeId <> 23

IF @intItemId IS NOT NULL 
BEGIN 
	-- 'Inventory Count is ongoing for Item {Item Name} and is locked under Location {Location Name}.'
	EXEC uspICRaiseError @strText
	RETURN -@intErrorCode
END 
GO