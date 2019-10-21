﻿/*
	Used to validate the items when doing a post. When an error is found, it will execute a RAISERROR. 
	This stored procedure is internally used for validation and it will always be called. 
	
	If you wish to retrieve the errors prior to posting and show it to the user, I suggest you use fnGetItemCostingOnPostStorageErrors
	and return the result back to the user-interface. 

	These are the validations performed by this stored procedure
	1. Check if item id is valid
	2. Check if location is valid
	3. Check for available stock quantity (for outbound stock)
	4. Check if negative stock is allowed (for outbound stock)

	These are the validations outside this stored procedure. 
	1. Check for closed period. 
	2. Check for invalid G/L Account Ids - Do this inside the uspICPostCosting
	
*/

CREATE PROCEDURE [dbo].[uspICValidateCostingOnPostStorage]
	@ItemsToValidate ItemCostingTableType READONLY
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @strItemNo AS NVARCHAR(50)
		,@intItemId AS INT 
		,@intItemLocationId AS INT 
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
FROM	@ItemsToValidate Item CROSS APPLY dbo.fnGetItemCostingOnPostStorageErrors(
			Item.intItemId
			, Item.intItemLocationId
			, Item.intItemUOMId
			, Item.intSubLocationId
			, Item.intStorageLocationId
			, Item.dblQty
			, Item.intLotId
			, Item.dblCost
		) Errors

-- Check for invalid items in the temp table. 
-- If such error is found, raise the error to stop the costing and allow the caller code to do a rollback. 
IF EXISTS (SELECT TOP 1 1 FROM #FoundErrors WHERE intErrorCode = 80001)
BEGIN 
	EXEC uspICRaiseError 80001;
	RETURN -1
END 

-- Check for invalid location in the item-location setup. 
IF EXISTS (SELECT TOP 1 1 FROM #FoundErrors WHERE intErrorCode = 80002)
BEGIN 
	SELECT TOP 1 
			@strItemNo = CASE WHEN ISNULL(i.strItemNo, '') = '' THEN '(Item id: ' + CAST(i.intItemId AS NVARCHAR(10)) + ')' ELSE i.strItemNo END 
			,@intItemId = i.intItemId
	FROM	#FoundErrors e INNER JOIN tblICItem i 
				ON e.intItemId = i.intItemId
	WHERE	e.intErrorCode = 80002

	-- 'Item Location is invalid or missing for {Item}.'
	EXEC uspICRaiseError 80002, @strItemNo;
	RETURN -1
END 

-- Check for negative stock qty 
-- 'Negative stock quantity is not allowed for {Item Name} on {Location Name}, {Sub Location Name}, and {Storage Location Name}.'								
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

-- Check for Missing Costing Method
SELECT TOP 1 
		@strItemNo = CASE WHEN ISNULL(Item.strItemNo, '') = '' THEN '(Item id: ' + CAST(Item.intItemId AS NVARCHAR(10)) + ')' ELSE Item.strItemNo END 
FROM	#FoundErrors Errors INNER JOIN tblICItem Item
			ON Errors.intItemId = Item.intItemId
WHERE	intErrorCode = 80023

IF @strItemNo IS NOT NULL 
BEGIN 
	-- 'Missing costing method setup for item {Item}.'
	EXEC uspICRaiseError 80023, @strItemNo
	RETURN -1
END 

-- Check for "Discontinued" status
SELECT TOP 1 
		@strItemNo = CASE WHEN ISNULL(Item.strItemNo, '') = '' THEN '(Item id: ' + CAST(Item.intItemId AS NVARCHAR(10)) + ')' ELSE Item.strItemNo END 
FROM	#FoundErrors Errors INNER JOIN tblICItem Item
			ON Errors.intItemId = Item.intItemId
WHERE	intErrorCode = 80022

IF @strItemNo IS NOT NULL 
BEGIN 
	-- 'The status of {item} is Discontinued.'
	EXEC uspICRaiseError 80022, @strItemNo
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

-- Check for negative cost. 
SELECT @strItemNo = NULL, @intItemId = NULL
SELECT TOP 1 
		@strItemNo = CASE WHEN ISNULL(Item.strItemNo, '') = '' THEN '(Item id: ' + CAST(Item.intItemId AS NVARCHAR(10)) + ')' ELSE Item.strItemNo END 
		,@intItemId = Item.intItemId
FROM	#FoundErrors Errors INNER JOIN tblICItem Item
			ON Errors.intItemId = Item.intItemId
WHERE	intErrorCode = 80196

IF @intItemId IS NOT NULL 
BEGIN 
	-- '{Item} will have a negative cost. Negative cost is not allowed.'
	EXEC uspICRaiseError 80196, @strItemNo
	RETURN -1
END 

-- Check if system is trying to post stocks for bundle types
SELECT @strItemNo = NULL, @intItemId = NULL
SELECT TOP 1 
		@strItemNo = CASE WHEN ISNULL(Item.strItemNo, '') = '' THEN '(Item id: ' + CAST(Item.intItemId AS NVARCHAR(10)) + ')' ELSE Item.strItemNo END 
		,@intItemId = Item.intItemId
FROM	#FoundErrors Errors INNER JOIN tblICItem Item
			ON Errors.intItemId = Item.intItemId
WHERE	intErrorCode = 80202

IF @intItemId IS NOT NULL 
BEGIN 
	-- '{Item} is a bundle type and it is not allowed to receive nor reduce stocks.'
	EXEC uspICRaiseError 80202, @strItemNo
	RETURN -1
END 