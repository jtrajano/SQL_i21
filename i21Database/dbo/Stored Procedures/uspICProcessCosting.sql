/*
	This is the main stored procedure used for handling the inventory costing. 
*/

CREATE PROCEDURE [dbo].[uspICProcessCosting]
	@ItemsToProcess AS ItemCostingTableType READONLY 
	,@strBatchId AS NVARCHAR(20)
	,@ysnPost AS BIT
	,@intTransactionId INT
	,@intTransactionTypeId INT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @ErrorMessage NVARCHAR(4000);
DECLARE @ErrorSeverity INT;
DECLARE @ErrorState INT;

/* Check if we are doing a post */
IF @ysnPost = 1 
BEGIN 
	BEGIN TRY
		-- Do the Validation
		EXEC [dbo].[uspICValidateCostingOnPost] @ItemsToValidate = @ItemsToProcess

		-- Post the items to the costing tables and generate financials (g/l entries)
		EXEC [dbo].[uspICPostCosting] @ItemsToProcess, @strBatchId

	END TRY
	BEGIN CATCH
		SELECT 
			@ErrorMessage = ERROR_MESSAGE(),
			@ErrorSeverity = ERROR_SEVERITY(),
			@ErrorState = ERROR_STATE();

		-- Use RAISERROR inside the CATCH block to return error
		-- information about the original error that caused
		-- execution to jump to the CATCH block.
		RAISERROR (@ErrorMessage, -- Message text.
			   @ErrorSeverity, -- Severity.
			   @ErrorState -- State.
		);
	END CATCH 

END

/* Check if we are doing an unpost*/
ELSE IF @ysnPost = 0
BEGIN 
	BEGIN TRY
		-- Get the items to unpost
		DECLARE @ItemsToUnpost AS ItemCostingTableType 

		INSERT INTO @ItemsToUnpost
		SELECT * FROM dbo.fnGetItemsToUnpost(@intTransactionId, @intTransactionTypeId); 

		-- Validate if the items can be reversed. 
		EXEC [dbo].[uspICValidateCostingOnUnpost] @ItemsToValidate = @ItemsToUnpost

		-- Reverse the stocks and generate the financials (g/l entries)
		EXEC [dbo].[uspICUnpostCosting] @strBatchId, @intTransactionId, @intTransactionTypeId

	END TRY
	BEGIN CATCH
		SELECT 
			@ErrorMessage = ERROR_MESSAGE(),
			@ErrorSeverity = ERROR_SEVERITY(),
			@ErrorState = ERROR_STATE();

		-- Use RAISERROR inside the CATCH block to return error
		-- information about the original error that caused
		-- execution to jump to the CATCH block.
		RAISERROR (@ErrorMessage, -- Message text.
			   @ErrorSeverity, -- Severity.
			   @ErrorState -- State.
		);
	END CATCH 

END 

