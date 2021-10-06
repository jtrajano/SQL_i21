CREATE PROCEDURE [dbo].[uspICRebuildInventoryValuationWrapper]
	@dtmStartDate AS DATETIME 
	,@strCategoryCode AS NVARCHAR(50) = NULL 
	,@strItemNo AS NVARCHAR(50) = NULL 
	,@isPeriodic AS BIT = 1
	,@ysnRegenerateBillGLEntries AS BIT = 0
	,@intEntityUserId AS INT = NULL
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS ON

BEGIN TRY 
	BEGIN TRANSACTION 
	
	DECLARE @intReturnValue AS INT
	EXEC @intReturnValue = uspICRebuildInventoryValuation
		@dtmStartDate
		,@strCategoryCode
		,@strItemNo
		,@isPeriodic
		,@ysnRegenerateBillGLEntries
		,@intEntityUserId

	COMMIT TRANSACTION 
END TRY
BEGIN CATCH
	DECLARE @ErrorSeverity INT,
			@ErrorNumber   INT,
			@ErrorMessage nvarchar(4000),
			@ErrorState INT,
			@ErrorLine  INT,
			@ErrorProc nvarchar(200);

	-- Grab error information from SQL functions
	SET @ErrorSeverity = ERROR_SEVERITY()
	SET @ErrorNumber   = ERROR_NUMBER()
	SET @ErrorMessage  = ERROR_MESSAGE()
	SET @ErrorState    = ERROR_STATE()
	SET @ErrorLine     = ERROR_LINE()
	SET @ErrorProc     = ERROR_PROCEDURE()

	SET @ErrorMessage  = @ErrorMessage 
		--'Error force rebuilding the stocks.' + CHAR(13) + 
		--'Error: ' + CAST(@ErrorNumber AS VARCHAR(10)) 
		--+ ' in: ' + @ErrorProc 
		--+ ' line: ' + CAST(@ErrorLine AS VARCHAR(10)) 
		--+ ' text: ' + @ErrorMessage
	
	-- Rollback the stock rebuild. 
	IF (XACT_STATE()) = -1
	BEGIN
		ROLLBACK TRANSACTION
	END
	ELSE IF (XACT_STATE()) = 1 AND @@TRANCOUNT = 0
	BEGIN
		ROLLBACK TRANSACTION
	END
	ELSE IF (XACT_STATE()) = 1 AND @@TRANCOUNT > 0
	BEGIN
		ROLLBACK TRANSACTION  
	END

	RAISERROR (@ErrorMessage , @ErrorSeverity, @ErrorState, @ErrorNumber)
END CATCH 