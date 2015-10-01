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
FROM	@ItemsToValidate Item CROSS APPLY dbo.fnGetItemCostingOnUnpostStorageErrors(Item.intItemId, Item.intItemLocationId, Item.intItemUOMId, Item.intSubLocationId, Item.intStorageLocationId, Item.dblQty, Item.intLotId) Errors
WHERE	ISNULL(@ysnRecap, 0) = 0

-- If such error is found, raise the error to stop the costing and allow the caller code to do a rollback. 
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

_Exit: 
IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#FoundErrors')) 
	DROP TABLE #FoundErrors

GO