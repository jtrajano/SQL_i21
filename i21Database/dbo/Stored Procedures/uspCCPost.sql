CREATE PROCEDURE [dbo].[uspCCPost]
	@intSiteHeaderId	INT
	,@userId			INT	
	,@post				BIT	= NULL
	,@recap				BIT	= NULL
	,@success			BIT = NULL OUTPUT
	,@errorMessage NVARCHAR(MAX) = NULL OUTPUT
	,@createdBankTransactionId INT = NULL OUTPUT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @billId INT
DECLARE @InvoicesId NVARCHAR(MAX)
DECLARE @bankTransactionId INT

BEGIN TRY

	-- AP Transaction and Posting
	EXEC [dbo].[uspCCTransactionToAPBill] 
		@intSiteHeaderId = @intSiteHeaderId
		,@userId = @userId
		,@post	= @recap
		,@success = @success OUTPUT
		,@errorMessage = @errorMessage OUTPUT
		,@createdBillId = @billId OUTPUT

	-- AR Transaction and Posting
	EXEC [dbo].[uspCCTransactionToARInvoice] 
		@intSiteHeaderId = @intSiteHeaderId
		,@UserId = @userId
		,@Post	= @post
		,@Recap = @recap
		,@CreatedIvoices = @InvoicesId OUTPUT
		,@success = @success OUTPUT
		,@ErrorMessage = @errorMessage OUTPUT

	-- CM Transaction and Posting
	EXEC [dbo].[uspCCTransactionToCMBankTransaction]
		@intSiteHeaderId = @intSiteHeaderId
		,@userId = @userId
		,@post	= @recap
		,@success = @success OUTPUT
		,@errorMessage = @errorMessage OUTPUT
		,@createdBankTransactionId = @bankTransactionId OUTPUT

	-- SET Posted Flag
	UPDATE [dbo].[tblCCSiteHeader] SET ysnPosted = 1 WHERE intSiteHeaderId = @intSiteHeaderId

END TRY
BEGIN CATCH
	DECLARE @ErrorSeverity INT,
			@ErrorNumber   INT,
			@ErrorState INT,
			@ErrorProc nvarchar(200);
	SET @ErrorSeverity = ERROR_SEVERITY()
	SET @ErrorNumber   = ERROR_NUMBER()
	SET @errorMessage  = ERROR_MESSAGE()
	SET @ErrorState    = ERROR_STATE()
	SET	@success = 0
	RAISERROR (@errorMessage , @ErrorSeverity, @ErrorState, @ErrorNumber)
END CATCH

