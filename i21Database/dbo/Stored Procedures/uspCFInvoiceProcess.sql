CREATE PROCEDURE [dbo].[uspCFInvoiceProcess](
	 @xmlParam					NVARCHAR(MAX)  
	,@entityId					INT			   = NULL
	,@ErrorMessage				NVARCHAR(250)  = NULL OUTPUT
	,@CreatedIvoices			NVARCHAR(MAX)  = NULL OUTPUT
	,@UpdatedIvoices			NVARCHAR(MAX)  = NULL OUTPUT
	,@ysnDevMode				BIT = 0
)
AS
BEGIN

BEGIN TRANSACTION CFMainInvoiceProcess

BEGIN TRY

	DECLARE	@return_value int

	----------RESET INVOICE RESULTS-----------
	DELETE FROM tblCFInvoiceProcessResult
	------------------------------------------

	EXEC	@return_value = [dbo].[uspCFCreateInvoicePayment]
			@xmlParam = @xmlParam,
			@entityId = @entityId,
			@ErrorMessage = @ErrorMessage OUTPUT,
			@CreatedIvoices = @CreatedIvoices OUTPUT,
			@UpdatedIvoices = @UpdatedIvoices OUTPUT,
			@ysnDevMode = @ysnDevMode

	SELECT	@ErrorMessage as N'@ErrorMessage',
			@CreatedIvoices as N'@CreatedIvoices',
			@UpdatedIvoices as N'@UpdatedIvoices'

	EXEC	@return_value = [dbo].[uspCFCreateDebitMemo]
			@xmlParam = @xmlParam,
			@entityId = @entityId,
			@ErrorMessage = @ErrorMessage OUTPUT,
			@CreatedIvoices = @CreatedIvoices OUTPUT,
			@UpdatedIvoices = @UpdatedIvoices OUTPUT,
			@ysnDevMode = @ysnDevMode

	SELECT	@ErrorMessage as N'@ErrorMessage',
			@CreatedIvoices as N'@CreatedIvoices',
			@UpdatedIvoices as N'@UpdatedIvoices'

	COMMIT TRANSACTION CFMainInvoiceProcess

END TRY
BEGIN CATCH
	
	ROLLBACK TRANSACTION CFMainInvoiceProcess

	SELECT ERROR_MESSAGE()

END CATCH



END











INSERT INTO tblCFLog (strProcessid,strProcess,strCallStack,intSortId) SELECT 'TEST','TEST','TEST',1

DELETE FROM tblCFLog