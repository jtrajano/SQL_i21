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
		,@strLocationName AS NVARCHAR(MAX)
		,@strTransactionId AS NVARCHAR(50) 

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
FROM	@ItemsToValidate Item CROSS APPLY dbo.fnGetItemCostingOnPostErrors(Item.intItemId, Item.intItemLocationId, Item.intItemUOMId, Item.intSubLocationId, Item.intStorageLocationId, Item.dblQty, Item.intLotId) Errors

-- Check for invalid items in the temp table. 
-- If such error is found, raise the error to stop the costing and allow the caller code to do a rollback. 
IF EXISTS (SELECT TOP 1 1 FROM #FoundErrors WHERE intErrorCode = 80001)
BEGIN 
	RAISERROR(80001, 11, 1)
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
	RAISERROR(80002, 11, 1, @strItemNo)
	RETURN -1
END 

-- Check for invalid item UOM 
IF EXISTS (SELECT TOP 1 1 FROM #FoundErrors WHERE intErrorCode = 80048)
BEGIN 
	RAISERROR(80048, 11, 1)
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

	RAISERROR(80003, 11, 1, @strItemNo, @strLocationName)
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
	RAISERROR(80023, 11, 1, @strItemNo)
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
	RAISERROR(80022, 11, 1, @strItemNo)
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
	RAISERROR(80049, 11, 1, @strItemNo)
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
	RAISERROR(80066, 11, 1, @strItemNo, @strLocationName)
	RETURN -1
END 

/*
	Check if the item is using Average Costing and the transaction is Actual Costing 

	Exception: 
		Allow it to happen Inventory Transfer. It will reduce the stock first using AVG and transfer it to the new location for ACTUAL COSTING. It will be reduce by the Sale Invoice 
		using Actual Costing. It will not mess up the inventory valuation because the actual cost is the same average cost. 
	
		To illustrate: 

		strTransactionId                         dblQty                                  dblCost                                 intCostingMethod strName             
		---------------------------------------- --------------------------------------- --------------------------------------- ---------------- --------------------
		INVTRN-3101                              -9829.00000000000000000000              1.01616662017389385428                  1                Inventory Transfer  
		INVTRN-3101                              9829.00000000000000000000               1.01616662017389385428                  5                Inventory Transfer  
		SI-34906                                 -9829.00000000000000000000              1.01616662017389385428                  5                Invoice

		The Average Cost of the item will remain as 1.01616662017389385428. 
*/
SELECT @strItemNo = NULL
		, @intItemId = NULL 
		, @strTransactionId = NULL 

SELECT TOP 1 
		@strTransactionId = strTransactionId
		,@strItemNo = i.strItemNo
		,@intItemId = iv.intItemId
FROM	@ItemsToValidate iv 
		INNER JOIN tblICItem i ON iv.intItemId = i.intItemId
		CROSS APPLY dbo.fnGetCostingMethodAsTable(iv.intItemId, iv.intItemLocationId) icm
		INNER JOIN tblICCostingMethod cm ON cm.intCostingMethodId = icm.CostingMethod
		INNER JOIN tblICInventoryTransactionType ty ON iv.intTransactionTypeId = ty.intTransactionTypeId
WHERE	strActualCostId IS NOT NULL 
		AND cm.strCostingMethod = 'AVERAGE COST'
		AND iv.dblQty > 0 
		AND ty.strName NOT IN ('Inventory Transfer') 

IF @intItemId IS NOT NULL 
BEGIN 
	-- 'Costing method mismatch. {Item No} is set to use Ave Costing. {Trans Id} is going to use Actual costing. It can''t be used together. You can fix it by changing the costing method to FIFO or LIFO.'
	-- '{Item No} is set to use AVG Costing and it will be received in {Receipt Id} as Actual costing. Average cost computation will be messed up. Try receiving the stocks using Inventory Receipt instead of Transport Load.'
	RAISERROR(80094, 11, 1, @strItemNo, @strTransactionId)
	RETURN -1
END 

/*
	Check if the transaction is using a foreign currency and it has a missing forex rate. 
*/
SELECT @strItemNo = NULL
		, @intItemId = NULL 
		, @strTransactionId = NULL 

SELECT TOP 1 
		@strTransactionId = strTransactionId
		,@strItemNo = i.strItemNo
		,@intItemId = iv.intItemId
FROM	@ItemsToValidate iv  
		INNER JOIN tblICItem i 
			ON iv.intItemId = i.intItemId
WHERE	ISNULL(iv.dblForexRate, 0) = 0 
		AND iv.intCurrencyId IS NOT NULL 
		AND iv.intCurrencyId <> dbo.fnSMGetDefaultCurrency('FUNCTIONAL') 

IF @intItemId IS NOT NULL 
BEGIN 
	-- '{Transaction Id} is using a foreign currency. Please check if {Item No} has a forex rate.'
	RAISERROR(80162, 11, 1, @strTransactionId, @strItemNo)
	RETURN -1
END 