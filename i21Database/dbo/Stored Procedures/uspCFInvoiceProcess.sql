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

DECLARE	@return_value int

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



END