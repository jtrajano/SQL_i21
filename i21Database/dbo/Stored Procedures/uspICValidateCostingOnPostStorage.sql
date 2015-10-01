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
		,@strLocationName AS NVARCHAR(50)
		,@intItemLocationId AS INT 

CREATE TABLE #FoundErrors (
	intItemId INT
	,intItemLocationId INT
	,strText NVARCHAR(MAX)
	,intErrorCode INT
)

-- Cross-check each items against the function that does the validation. 
-- Store the result in a temporary table. 
INSERT INTO #FoundErrors
SELECT	Errors.intItemId
		,Errors.intItemLocationId
		,Errors.strText
		,Errors.intErrorCode
FROM	@ItemsToValidate Item CROSS APPLY dbo.fnGetItemCostingOnPostStorageErrors(Item.intItemId, Item.intItemLocationId, Item.intItemUOMId, Item.intSubLocationId, Item.intStorageLocationId, Item.dblQty, Item.intLotId) Errors

-- Check for invalid items in the temp table. 
-- If such error is found, raise the error to stop the costing and allow the caller code to do a rollback. 
IF EXISTS (SELECT TOP 1 1 FROM #FoundErrors WHERE intErrorCode = 80001)
BEGIN 
	RAISERROR(80001, 11, 1)
	GOTO _Exit
END 

-- Check for invalid location in the item-location setup. 
IF EXISTS (SELECT TOP 1 1 FROM #FoundErrors WHERE intErrorCode = 80002)
BEGIN 
	SELECT TOP 1 
			@strItemNo = CASE WHEN ISNULL(Item.strItemNo, '') = '' THEN '(Item id: ' + CAST(Item.intItemId AS NVARCHAR(10)) + ')' ELSE Item.strItemNo END 
			,@intItemId = Item.intItemId
	FROM	#FoundErrors Errors INNER JOIN tblICItem Item
				ON Errors.intItemId = Item.intItemId
	WHERE	intErrorCode = 80002

	-- 'Item Location is invalid or missing for {Item}.'
	RAISERROR(80002, 11, 1, @strItemNo)
	GOTO _Exit
END 

-- Check for negative stock qty 
IF EXISTS (SELECT TOP 1 1 FROM #FoundErrors WHERE intErrorCode = 80003)
BEGIN 
	SELECT	TOP 1 
			@strItemNo = Item.strItemNo
			,@intItemId = Item.intItemId
	FROM	#FoundErrors Errors INNER JOIN tblICItem Item
				ON Errors.intItemId = Item.intItemId
	WHERE	intErrorCode = 80003

	SELECT	TOP 1 
			@strLocationName = CompanyLocation.strLocationName
			,@intItemLocationId = ItemLocation.intItemLocationId
	FROM	#FoundErrors Errors INNER JOIN dbo.tblICItemLocation ItemLocation
				ON Errors.intItemLocationId = ItemLocation.intItemLocationId
			INNER JOIN dbo.tblSMCompanyLocation CompanyLocation
				ON ItemLocation.intLocationId = CompanyLocation.intCompanyLocationId
	WHERE	Errors.intErrorCode = 80003
			AND Errors.intItemId = @intItemId

	SELECT	@strItemNo = ISNULL(@strItemNo, '(Item id: ' + ISNULL(CAST(@intItemId AS NVARCHAR(10)), 'Blank') + ')')
			,@strLocationName = ISNULL(@strLocationName, '(Item Location id: ' + ISNULL(CAST(@intItemLocationId AS NVARCHAR(10)), 'Blank') + ')')
			
	RAISERROR(80003, 11, 1, @strItemNo, @strLocationName)
	GOTO _Exit
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
	RAISERROR(80023, 11, 1, @strItemNo)
	GOTO _Exit
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
	RAISERROR(80022, 11, 1, @strItemNo)
	GOTO _Exit
END 

_Exit: 
IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#FoundErrors')) 
	DROP TABLE #FoundErrors

GO