--/*
--	This is the main stored procedure used for handling the inventory costing. 
--*/

--CREATE PROCEDURE [dbo].[uspICProcessCosting]
--	@ItemsToPostOrUnpost AS ItemCostingTableType READONLY 
--	,@strBatchId AS NVARCHAR(20)
--	,@ysnPost AS BIT
--	,@strAccountToCounterInventory AS NVARCHAR(255) = 'Cost of Goods'
--	,@intUserId AS INT 
--AS

--SET QUOTED_IDENTIFIER OFF
--SET ANSI_NULLS ON
--SET NOCOUNT ON
--SET XACT_ABORT ON
--SET ANSI_WARNINGS OFF

--DECLARE @ErrorMessage NVARCHAR(4000);
--DECLARE @ErrorSeverity INT;
--DECLARE @ErrorState INT;

--/* Check if we are doing a post */
--IF @ysnPost = 1 
--BEGIN 
--	BEGIN TRY
--		-- Do the Validation
--		EXEC [dbo].[uspICValidateCostingOnPost] 
--			@ItemsToValidate = @ItemsToPostOrUnpost

--		-- Post the items to the costing tables and generate the financials (g/l entries)
--		EXEC [dbo].[uspICPostCosting] 
--			@ItemsToPostOrUnpost
--			,@strBatchId
--			,@strAccountToCounterInventory
--			,@intUserId
--	END TRY
--	BEGIN CATCH
--		SELECT 
--			@ErrorMessage = ERROR_MESSAGE(),
--			@ErrorSeverity = ERROR_SEVERITY(),
--			@ErrorState = ERROR_STATE();

--		-- Use RAISERROR inside the CATCH block to return error
--		-- information about the original error that caused
--		-- execution to jump to the CATCH block.
--		RAISERROR (
--			@ErrorMessage, -- Message text.
--			@ErrorSeverity, -- Severity.
--			@ErrorState -- State.
--		);
--	END CATCH
--END

--/* Check if we are doing an unpost*/
--ELSE IF @ysnPost = 0
--BEGIN 
--	BEGIN TRY
--		-- Validate if the items can be reversed. 
--		EXEC [dbo].[uspICValidateCostingOnUnpost] 
--			@ItemsToValidate = @ItemsToPostOrUnpost

--		-- Reverse the stocks and generate the financials (g/l entries)
--		EXEC dbo.uspICUnpostCosting
--			@intTransactionId = NULL 
--			,@strTransactionId = NULL 
--			,@intUserId = NULL 
--	END TRY
--	BEGIN CATCH
--		SELECT 
--			@ErrorMessage = ERROR_MESSAGE(),
--			@ErrorSeverity = ERROR_SEVERITY(),
--			@ErrorState = ERROR_STATE();

--		-- Use RAISERROR inside the CATCH block to return error
--		-- information about the original error that caused
--		-- execution to jump to the CATCH block.
--		RAISERROR (
--			@ErrorMessage, -- Message text.
--			@ErrorSeverity, -- Severity.
--			@ErrorState -- State.
--		);
--	END CATCH
--END 