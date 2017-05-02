/*
	Used to validate the items when doing an unpost. When an error is found, it will execute a RAISERROR. 
	This stored procedure is internally used for validation and it will always be called. 
	
	If you wish to retrieve the errors prior to unposting and show it to the user, I suggest you use fnGetItemCostingOnUnpostErrors
	and return the result back to the user-interface. 

	These are the validations performed by this stored procedure
	1. Check for available stock quantity (for outbound stock)
	2. Check if negative stock is allowed (for outbound stock)
*/

CREATE PROCEDURE [dbo].[uspICValidateCostingOnUnpost]
	@ItemsToValidate UnpostItemsTableType READONLY
	,@ysnRecap BIT = 0 
	,@intTransactionId AS INT = NULL 
	,@strTransactionId AS NVARCHAR(40) = NULL 
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @strItemNo AS NVARCHAR(50)
		,@intItemId AS INT
		,@strLocationName AS NVARCHAR(MAX)
		,@intItemLocationId AS INT 
		,@strRelatedTransactionId AS NVARCHAR(50)

-- Create the variables for the internal transaction types used by costing. 
DECLARE @AUTO_NEGATIVE AS INT = 1
		,@WRITE_OFF_SOLD AS INT = 2
		,@REVALUE_SOLD AS INT = 3

		,@INV_TRANS_TYPE_Cost_Adjustment AS INT = 26
		,@INV_TRANS_TYPE_Revalue_WIP AS INT = 28
		,@INV_TRANS_TYPE_Revalue_Produced AS INT = 29
		,@INV_TRANS_TYPE_Revalue_Transfer AS INT = 30
		,@INV_TRANS_TYPE_Revalue_Build_Assembly AS INT = 31

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
-- Do not do the validation if doing a recap. 
INSERT INTO #FoundErrors
SELECT	Errors.intItemId
		,Errors.intItemLocationId
		,Item.intSubLocationId
		,Item.intStorageLocationId
		,Errors.strText
		,Errors.intErrorCode
		,Item.intTransactionTypeId
FROM	@ItemsToValidate Item CROSS APPLY dbo.fnGetItemCostingOnUnpostErrors(Item.intItemId, Item.intItemLocationId, Item.intItemUOMId, Item.intSubLocationId, Item.intStorageLocationId, Item.dblQty, Item.intLotId) Errors
WHERE	ISNULL(@ysnRecap, 0) = 0

-- If such error is found, raise the error to stop the costing and allow the caller code to do a rollback. 
-- Check for negative stock qty 
IF EXISTS (SELECT TOP 1 1 FROM #FoundErrors WHERE intErrorCode = 80003)
BEGIN 
	SELECT @strItemNo = NULL, @intItemId = NULL 

	SELECT TOP 1 
			@strItemNo = CASE WHEN ISNULL(Item.strItemNo, '') = '' THEN '(Item id: ' + CAST(Item.intItemId AS NVARCHAR(10)) + ')' ELSE Item.strItemNo END 
			,@intItemId = Item.intItemId
			,@strLocationName = 
				dbo.fnFormatMsg80003(
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
		@strItemNo = CASE WHEN ISNULL(Item.strItemNo, '') = '' THEN '(Item id: ' + CAST(Item.intItemId AS NVARCHAR(10)) + ')' ELSE Item.strItemNo END,
		@strLocationName = CASE WHEN ISNULL(Location.strLocationName, '') = '' THEN '(Item Location id: ' + CAST(ItemLocation.intItemLocationId AS NVARCHAR(10)) + ')' ELSE Location.strLocationName END 
		,@intItemId = Item.intItemId
FROM	#FoundErrors Errors INNER JOIN tblICItem Item ON Errors.intItemId = Item.intItemId
		INNER JOIN tblICItemLocation ItemLocation ON Errors.intItemLocationId = ItemLocation.intItemLocationId
		INNER JOIN tblSMCompanyLocation Location ON Location.intCompanyLocationId = ItemLocation.intLocationId
WHERE	intErrorCode = 80066
		AND Errors.intTransactionTypeId <> 23
		AND ISNULL(@ysnRecap, 0) = 0

IF @intItemId IS NOT NULL 
BEGIN 
	-- 'Inventory Count is ongoing for Item {Item Name} and is locked under Location {Location Name}.'
	EXEC uspICRaiseError 80066, @strItemNo, @strLocationName;
	RETURN -1
END 

-- Validate the unpost of the stock in. Do not allow unpost if it has cost adjustments. 
BEGIN 
	SELECT TOP 1 
			@strItemNo = Item.strItemNo
			,@strRelatedTransactionId = InvTrans.strTransactionId
	FROM	dbo.tblICInventoryTransaction InvTrans INNER JOIN dbo.tblICItem Item
				ON InvTrans.intItemId = Item.intItemId
	WHERE	InvTrans.intRelatedTransactionId = @intTransactionId
			AND InvTrans.strRelatedTransactionId = @strTransactionId
			AND InvTrans.intTransactionTypeId = @INV_TRANS_TYPE_Cost_Adjustment
			AND ISNULL(InvTrans.ysnIsUnposted, 0) = 0 
			AND ISNULL(@ysnRecap, 0) = 0

	IF @strRelatedTransactionId IS NOT NULL 
	BEGIN 
		-- 'Unable to unpost because {Item} has a cost adjustment from {Transaction Id}.'
		EXEC uspICRaiseError 80063, @strItemNo, @strRelatedTransactionId;  
		RETURN -1
	END 
END 

GO