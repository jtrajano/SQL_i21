/*
	Used to validate the items when doing a post. When an error is found, it will execute a RAISERROR. 
	This stored procedure is internally used for validation and it will always be called. 
	
	If you wish to retrieve the errors prior to posting and show it to the user, I suggest you use fnGetItemCostingOnPostErrors
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

CREATE PROCEDURE [dbo].[uspICValidateCostingOnPost]
	@ItemsToValidate ItemCostingTableType READONLY
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @strItemNo AS NVARCHAR(50)
		,@intItemId AS INT 
		,@strLocationName AS NVARCHAR(2000)
		,@strTransactionId AS NVARCHAR(50) 
		,@strCurrencyId NVARCHAR(50)
		,@strFunctionalCurrencyId NVARCHAR(50)

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
	,strTransactionId NVARCHAR(50)
	,intCurrencyId INT 
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
		,Item.strTransactionId
		,Item.intCurrencyId
FROM	@ItemsToValidate Item 
		CROSS APPLY dbo.fnGetItemCostingOnPostErrors(
			Item.intItemId
			, Item.intItemLocationId
			, Item.intItemUOMId
			, Item.intSubLocationId
			, Item.intStorageLocationId
			, Item.dblQty
			, Item.intLotId
			, Item.strActualCostId
			, Item.intTransactionTypeId
			, Item.strTransactionId
			, Item.intCurrencyId
			, Item.dblForexRate
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
SELECT @strItemNo = NULL, @intItemId = NULL 
SELECT TOP 1 
		@strItemNo = CASE WHEN ISNULL(Item.strItemNo, '') = '' THEN '(Item id: ' + CAST(Item.intItemId AS NVARCHAR(10)) + ')' ELSE Item.strItemNo END 
		,@intItemId = Item.intItemId
FROM	#FoundErrors Errors INNER JOIN tblICItem Item
			ON Errors.intItemId = Item.intItemId
WHERE	intErrorCode = 80002

IF @intItemId IS NOT NULL 
BEGIN 
	SELECT TOP 1 
			@strItemNo = CASE WHEN ISNULL(Item.strItemNo, '') = '' THEN '(Item id: ' + CAST(Item.intItemId AS NVARCHAR(10)) + ')' ELSE Item.strItemNo END 
			,@intItemId = Item.intItemId
	FROM	#FoundErrors Errors INNER JOIN tblICItem Item
				ON Errors.intItemId = Item.intItemId
	WHERE	intErrorCode = 80002

	-- 'Item Location is invalid or missing for {Item}.'
	EXEC uspICRaiseError 80002, @strItemNo;
	RETURN -1
END 

-- Check for invalid item UOM 
IF EXISTS (SELECT TOP 1 1 FROM #FoundErrors WHERE intErrorCode = 80048)
BEGIN 
	EXEC uspICRaiseError 80048; 
	RETURN -1
END 

-- Check for negative stock qty 
-- 'Negative stock quantity is not allowed for {Item Name} on {Location Name}, {Sub Location Name}, and {Storage Location Name}.'	
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

-- Check for Missing Costing Method
SELECT @strItemNo = NULL, @intItemId = NULL
SELECT TOP 1 
		@strItemNo = CASE WHEN ISNULL(Item.strItemNo, '') = '' THEN '(Item id: ' + CAST(Item.intItemId AS NVARCHAR(10)) + ')' ELSE Item.strItemNo END 
		,@intItemId = Item.intItemId
FROM	#FoundErrors Errors INNER JOIN tblICItem Item
			ON Errors.intItemId = Item.intItemId
WHERE	intErrorCode = 80023

IF @intItemId IS NOT NULL 
BEGIN 
	-- 'Missing costing method setup for item {Item}.'
	EXEC uspICRaiseError 80023, @strItemNo
	RETURN -1
END 

-- Check for "Discontinued" status
SELECT @strItemNo = NULL, @intItemId = NULL
SELECT TOP 1 
		@strItemNo = CASE WHEN ISNULL(Item.strItemNo, '') = '' THEN '(Item id: ' + CAST(Item.intItemId AS NVARCHAR(10)) + ')' ELSE Item.strItemNo END 
		,@intItemId = Item.intItemId
FROM	#FoundErrors Errors INNER JOIN tblICItem Item
			ON Errors.intItemId = Item.intItemId
WHERE	intErrorCode = 80022

IF @intItemId IS NOT NULL 
BEGIN 
	-- 'The status of {item} is Discontinued.'
	EXEC uspICRaiseError 80022, @strItemNo
	RETURN -1
END 

-- Check for the missing Stock Unit UOM 
SELECT @strItemNo = NULL, @intItemId = NULL
SELECT TOP 1 
		@strItemNo = CASE WHEN ISNULL(Item.strItemNo, '') = '' THEN '(Item id: ' + CAST(Item.intItemId AS NVARCHAR(10)) + ')' ELSE Item.strItemNo END 
		,@intItemId = Item.intItemId
FROM	#FoundErrors Errors INNER JOIN tblICItem Item
			ON Errors.intItemId = Item.intItemId
WHERE	intErrorCode = 80049

IF @intItemId IS NOT NULL 
BEGIN 
	-- 'Item {Item Name} is missing a Stock Unit. Please check the Unit of Measure setup.'
	EXEC uspICRaiseError 80049, @strItemNo;
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

IF @intItemId IS NOT NULL 
BEGIN 
	-- 'Inventory Count is ongoing for Item {Item Name} and is locked under Location {Location Name}.'
	EXEC uspICRaiseError 80066, @strItemNo, @strLocationName;
	RETURN -1
END 

/*
	Check if the item is using Average Costing and the transaction is Actual Costing 
*/
SELECT @strItemNo = NULL
		, @intItemId = NULL 
		, @strTransactionId = NULL 

SELECT @strItemNo = NULL, @intItemId = NULL
SELECT	TOP 1 
		@strItemNo = CASE WHEN ISNULL(Item.strItemNo, '') = '' THEN '(Item id: ' + CAST(Item.intItemId AS NVARCHAR(10)) + ')' ELSE Item.strItemNo END
		,@intItemId = Errors.intItemId
		,@strTransactionId = Errors.strTransactionId
FROM	#FoundErrors Errors INNER JOIN tblICItem Item ON Errors.intItemId = Item.intItemId
WHERE	intErrorCode = 80094

IF @intItemId IS NOT NULL 
BEGIN 
	-- '{Item No} is set to use AVG Costing and it will be received in {Receipt Id} as Actual costing. Average cost computation will be messed up. Try receiving the stocks using Inventory Receipt instead of Transport Load.'
	EXEC uspICRaiseError 80094, @strItemNo, @strTransactionId;
	RETURN -1
END 

/*
	Check if the transaction is using a foreign currency and it has a missing forex rate. 
*/
SELECT @strItemNo = NULL
		, @intItemId = NULL 
		, @strTransactionId = NULL 

SELECT	TOP 1 
		@strItemNo = CASE WHEN ISNULL(Item.strItemNo, '') = '' THEN '(Item id: ' + CAST(Item.intItemId AS NVARCHAR(10)) + ')' ELSE Item.strItemNo END
		,@intItemId = Errors.intItemId
		,@strTransactionId = Errors.strTransactionId
		,@strCurrencyId = c.strCurrency
		,@strFunctionalCurrencyId = fc.strCurrency
FROM	#FoundErrors Errors INNER JOIN tblICItem Item ON Errors.intItemId = Item.intItemId
		LEFT JOIN tblSMCurrency c
			ON c.intCurrencyID = Errors.intCurrencyId
		LEFT JOIN tblSMCurrency fc
			ON fc.intCurrencyID = dbo.fnSMGetDefaultCurrency('FUNCTIONAL') 
WHERE	intErrorCode = 80162

IF @intItemId IS NOT NULL 
BEGIN 
	-- '{Transaction Id} is using a foreign currency. Please check if {Item No} has a forex rate. You may also need to review the Currency Exchange Rates and check if there is a valid forex rate from {Trans Currency} to {Functional Currency}.'
	EXEC uspICRaiseError 80162, @strTransactionId, @strItemNo, @strCurrencyId, @strFunctionalCurrencyId
	RETURN -1
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