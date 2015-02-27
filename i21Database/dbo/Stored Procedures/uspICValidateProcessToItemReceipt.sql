/*
	Used to validate the items before converting it to item receipt. When an error is found, it will execute a RAISERROR. 
	This stored procedure is internally used for validation and it will always be called. 
	
	If you wish to retrieve the errors prior to posting and show it to the user, I suggest you use fnGetProcessToItemReceiptErrors
	and return the result back to the user-interface. 

	These are the validations performed by this stored procedure
	1. Check if item id is valid
	2. Check if location is valid
*/

CREATE PROCEDURE [dbo].[uspICValidateProcessToItemReceipt]
	@Items ItemCostingTableType READONLY
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

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
FROM	@Items Item CROSS APPLY dbo.fnGetProcessToItemReceiptErrors(Item.intItemId, Item.intItemLocationId, Item.dblQty, Item.dblUOMQty) Errors

-- Check for invalid items in the temp table. 
-- If such error is found, raise the error to stop the costing and allow the caller code to do a rollback. 
IF EXISTS (SELECT TOP 1 1 FROM #FoundErrors WHERE intErrorCode = 50027)
BEGIN 
	RAISERROR(50027, 11, 1)
	GOTO _Exit
END 

---- Check for invalid location in the item-location setup. 
--IF EXISTS (SELECT TOP 1 1 FROM #FoundErrors WHERE intErrorCode = 50028)
--BEGIN 
--	RAISERROR(50028, 11, 1)
--	GOTO _Exit
--END 

_Exit: 
IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#FoundErrors')) 
	DROP TABLE #FoundErrors

GO