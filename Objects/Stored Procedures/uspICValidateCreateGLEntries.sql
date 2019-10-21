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

CREATE PROCEDURE [dbo].[uspICValidateCreateGLEntries]
	@strBatchId AS NVARCHAR(50) 
	,@AccountCategory_ContraInventory AS NVARCHAR(255) = 'Cost of Goods'
	,@strTransactionId AS NVARCHAR(50) = NULL 
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @intErrorCode AS INT 
		,@strErrorText AS NVARCHAR(MAX) 

SELECT TOP 1 
		@intErrorCode = intErrorCode
		,@strErrorText = strText
FROM	dbo.fnICGetCreateGLEntriesErrors (
			@strBatchId
			,@AccountCategory_ContraInventory
			,@strTransactionId
		)

IF @intErrorCode IS NOT NULL 
BEGIN 
	EXEC uspICRaiseError @strErrorText
	RETURN -1; 
END 
