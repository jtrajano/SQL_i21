CREATE PROCEDURE [dbo].[uspCCPost]
	@intSiteHeaderId	INT
	,@userId			INT	
	,@post				BIT
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
DECLARE @intCompanyLocationId INT

BEGIN TRY
	
	BEGIN TRANSACTION

	SELECT @intCompanyLocationId = VD.intCompanyLocationId FROM tblCCSiteHeader SH 
	JOIN tblCCVendorDefault VD ON VD.intVendorDefaultId = SH.intVendorDefaultId
	JOIN tblSMUserSecurityCompanyLocationRolePermission CL ON VD.intCompanyLocationId = CL.intCompanyLocationId
	WHERE SH.intSiteHeaderId = @intSiteHeaderId AND CL.intEntityId = @userId

	IF(@intCompanyLocationId IS NULL)
	BEGIN
		RAISERROR('Invalid Vendor Company Location!',16,1);
	END
	ELSE
	BEGIN
		-- AP Transaction and Posting
		EXEC [dbo].[uspCCTransactionToAPBill] 
			@intSiteHeaderId = @intSiteHeaderId
			,@userId = @userId
			,@post	= @post
			,@recap = 0
			,@success = @success OUTPUT
			,@errorMessage = @errorMessage OUTPUT
			,@createdBillId = @billId OUTPUT

		-- AR Transaction and Posting
		EXEC [dbo].[uspCCTransactionToARInvoice] 
			@intSiteHeaderId = @intSiteHeaderId
			,@UserId = @userId
			,@Post	= @post
			,@Recap = 0
			,@CreatedIvoices = @InvoicesId OUTPUT
			,@success = @success OUTPUT
			,@ErrorMessage = @errorMessage OUTPUT

		-- CM Transaction and Posting
		EXEC [dbo].[uspCCTransactionToCMBankTransaction]
			@intSiteHeaderId = @intSiteHeaderId
			,@userId = @userId
			,@post	= @post
			,@recap = 0
			,@success = @success OUTPUT
			,@errorMessage = @errorMessage OUTPUT
			,@createdBankTransactionId = @bankTransactionId OUTPUT

		-- SET Posted Flag
		IF(@post = 1)
		BEGIN
			UPDATE [dbo].[tblCCSiteHeader] SET ysnPosted = @post, intCMBankTransactionId = @bankTransactionId WHERE intSiteHeaderId = @intSiteHeaderId
		END
		ELSE IF(@post = 0)
		BEGIN
			UPDATE [dbo].[tblCCSiteHeader] SET ysnPosted = @post WHERE intSiteHeaderId = @intSiteHeaderId
		END

		COMMIT TRANSACTION

	END

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
	ROLLBACK TRANSACTION
	RAISERROR (@errorMessage , @ErrorSeverity, @ErrorState, @ErrorNumber)
END CATCH

