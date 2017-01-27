CREATE PROCEDURE [dbo].[uspCFInvoiceProcess](
	 @xmlParam					NVARCHAR(MAX)  
	,@entityId					INT			   = NULL
	,@ErrorMessage				NVARCHAR(250)  = NULL	OUTPUT
	,@CreatedIvoices			NVARCHAR(MAX)  = NULL	OUTPUT
	,@UpdatedIvoices			NVARCHAR(MAX)  = NULL	OUTPUT
	,@SuccessfulPostCount		INT			   = 0		OUTPUT
	,@InvalidPostCount			INT			   = 0		OUTPUT
	,@ysnDevMode				BIT = 0
)
AS
BEGIN

	----------RESET INVOICE RESULTS-----------
	DELETE FROM tblCFInvoiceProcessResult
	DELETE FROM tblCFLog
	------------------------------------------

	INSERT INTO tblCFLog(
		 strProcess,strProcessid,strCallStack,strMessage,intSortId)
	SELECT 'Main process started','','Process Invoice','Begin transaction',0

BEGIN TRY

	DECLARE	@return_value int

	IF (@@TRANCOUNT = 0) BEGIN TRANSACTION

	EXEC	@return_value = [dbo].[uspCFCreateInvoicePayment]
			@xmlParam				= @xmlParam
			,@entityId				= @entityId
			,@ErrorMessage			= @ErrorMessage			OUTPUT
			,@CreatedIvoices		= @CreatedIvoices		OUTPUT
			,@UpdatedIvoices		= @UpdatedIvoices		OUTPUT
			,@SuccessfulPostCount	= @SuccessfulPostCount	OUTPUT
			,@InvalidPostCount		= @InvalidPostCount		OUTPUT
			,@ysnDevMode			= @ysnDevMode

	SELECT	'Payment'				AS 'Process'
			,@ErrorMessage			AS 'ErrorMessage'
			,@CreatedIvoices		AS 'CreatedIvoices'
			,@UpdatedIvoices		AS 'UpdatedIvoices'
			,@SuccessfulPostCount	AS 'SuccessfulPostCount'
			,@InvalidPostCount		AS 'InvalidPostCount'

	EXEC	@return_value = [dbo].[uspCFCreateDebitMemo]
			@xmlParam = @xmlParam,
			@entityId = @entityId,
			@ErrorMessage = @ErrorMessage OUTPUT,
			@CreatedIvoices = @CreatedIvoices OUTPUT,
			@UpdatedIvoices = @UpdatedIvoices OUTPUT,
			@ysnDevMode = @ysnDevMode

	SELECT	'Debit Memo'			AS 'Process'
			,@ErrorMessage			AS 'ErrorMessage'
			,@CreatedIvoices		AS 'CreatedIvoices'
			,@UpdatedIvoices		AS 'UpdatedIvoices'

	IF (@@TRANCOUNT > 0) COMMIT TRANSACTION 

END TRY
BEGIN CATCH
	
	IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION 

	DECLARE @CatchErrorMessage NVARCHAR(MAX);  
	DECLARE @CatchErrorSeverity INT;  
	DECLARE @CatchErrorState INT;  
  
	SELECT   
		@CatchErrorMessage = ERROR_MESSAGE(),  
		@CatchErrorSeverity = ERROR_SEVERITY(),  
		@CatchErrorState = ERROR_STATE();  

	INSERT INTO tblCFLog(
		 strProcess,strProcessid,strCallStack,strMessage,intSortId)
	SELECT 'Main','','Catch',@CatchErrorMessage,0

	INSERT INTO tblCFLog(
		 strProcess,strProcessid,strCallStack,strMessage,intSortId)
	SELECT 'Main process exited with error','','Process Invoice','Rollback transaction',0



	DECLARE @index INT = 0

	SELECT @index = CHARINDEX('>',@CatchErrorMessage)
	SELECT @ErrorMessage = SUBSTRING(@CatchErrorMessage,@index + 1, 1000);  

END CATCH



END
