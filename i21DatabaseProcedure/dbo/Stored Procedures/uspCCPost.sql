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
DECLARE @intAPAccount INT
DECLARE @strCompanyLocation NVARCHAR(50)
DECLARE @strAPAccountErrorMessage NVARCHAR(255)

BEGIN TRY
	
	BEGIN TRANSACTION

	SELECT @intCompanyLocationId = SH.intCompanyLocationId
	FROM tblCCSiteHeader SH
	--LEFT JOIN tblCCVendorDefault VD ON VD.intVendorDefaultId = SH.intVendorDefaultId
	LEFT JOIN tblSMUserSecurityCompanyLocationRolePermission CL ON SH.intCompanyLocationId = CL.intCompanyLocationId
	WHERE SH.intSiteHeaderId = @intSiteHeaderId
		AND CL.intEntityId = @userId

	IF(@intCompanyLocationId IS NULL)
	BEGIN
		IF EXISTS(SELECT TOP 1 1 FROM tblSMUserSecurityCompanyLocationRolePermission WHERE intEntityUserSecurityId = @userId)
		BEGIN
			RAISERROR('Invalid Vendor Company Location Id found!',16,1)
		END
	END

	select @intAPAccount = isnull(intAPAccount,0), @strCompanyLocation = rtrim(ltrim(strLocationName)) from tblSMCompanyLocation where intCompanyLocationId = @intCompanyLocationId;
	IF(@intAPAccount = 0)
	BEGIN
		set @strAPAccountErrorMessage = 'Please setup AP Account for Vendor Company Location (' + @strCompanyLocation + ').';
		RAISERROR(@strAPAccountErrorMessage,16,1)
	END
	
	-- Validate Total Detail Gross, Fees and Net should equal to Header
	DECLARE @dblGross NUMERIC(18,6) = NULL
	DECLARE @dblFee NUMERIC(18,6) = NULL
	DECLARE @dblNet NUMERIC(18,6) = NULL
	
	SELECT @dblGross = A.dblGross - SUM(ISNULL(B.dblGross,0))
	, @dblFee = A.dblFees -  SUM(ISNULL(B.dblFees,0))
	, @dblNet = A.dblNet - SUM(ISNULL(B.dblNet,0))
	FROM tblCCSiteHeader A
	INNER JOIN tblCCSiteDetail B ON A.intSiteHeaderId = B.intSiteHeaderId
	WHERE A.intSiteHeaderId = @intSiteHeaderId
	GROUP BY  A.intSiteHeaderId,  A.dblGross, A.dblFees, A.dblNet

	IF(@dblGross != 0 OR @dblFee != 0 OR @dblNet != 0)
	BEGIN
		RAISERROR('Gross, Fees and Net should be equal to ZERO.',16,1)
	END

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