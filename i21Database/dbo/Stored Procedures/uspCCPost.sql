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

	SELECT @intCompanyLocationId = SH.intCompanyLocationId FROM tblCCSiteHeader SH WHERE SH.intSiteHeaderId = @intSiteHeaderId

	--SELECT @intCompanyLocationId = SH.intCompanyLocationId
	--FROM tblCCSiteHeader SH
	----LEFT JOIN tblCCVendorDefault VD ON VD.intVendorDefaultId = SH.intVendorDefaultId
	--LEFT JOIN tblSMUserSecurityCompanyLocationRolePermission CL ON SH.intCompanyLocationId = CL.intCompanyLocationId
	--WHERE SH.intSiteHeaderId = @intSiteHeaderId
	--	AND CL.intEntityId = @userId

	-- CHECK THE POST STATUS
	DECLARE @ysnCurrentPostValue BIT = NULL

	SELECT @ysnCurrentPostValue = ysnPosted FROM tblCCSiteHeader WHERE intSiteHeaderId = @intSiteHeaderId
	
	IF(@ysnCurrentPostValue = @post) 
	BEGIN
		IF(@ysnCurrentPostValue = 1)
		BEGIN
			RAISERROR('Transaction is already posted.',16,1)
		END
		ELSE IF (@ysnCurrentPostValue = 0)
		BEGIN
			RAISERROR('Transaction is already unposted.',16,1)
		END
	END

	IF(@intCompanyLocationId IS NULL)
	BEGIN
		RAISERROR('Invalid Vendor Company Location!', 16, 1)
	END
	ELSE
	BEGIN
		IF EXISTS(SELECT TOP 1 1 FROM tblSMUserSecurityCompanyLocationRolePermission CL WHERE CL.intEntityId = @userId)
		BEGIN	
			IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMUserSecurityCompanyLocationRolePermission CL WHERE CL.intEntityId = @userId AND CL.intCompanyLocationId = @intCompanyLocationId)
			BEGIN
				RAISERROR('You dont have permission to post transaction using this location!', 16, 1)
			END
		END
	END

	SELECT @intAPAccount = intAPAccount, @strCompanyLocation = rtrim(ltrim(strLocationName)) from tblSMCompanyLocation where intCompanyLocationId = @intCompanyLocationId
	IF(@intAPAccount IS NULL)
	BEGIN
		SET @strAPAccountErrorMessage = 'Please setup AP Account for Vendor Company Location (' + @strCompanyLocation + ').';
		RAISERROR(@strAPAccountErrorMessage, 16, 1)
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

	SET @errorMessage = NULL

	DECLARE @errorMessagePerProcess NVARCHAR(4000) = NULL

	-- AP Transaction and Posting
	EXEC [dbo].[uspCCTransactionToAPBill] 
		@intSiteHeaderId = @intSiteHeaderId
		,@userId = @userId
		,@post	= @post
		,@recap = 0
		,@success = @success OUTPUT
		,@errorMessage = @errorMessagePerProcess OUTPUT
		--,@createdBillId = @billId OUTPUT

	IF(ISNULL(@errorMessage, '') = '')
	BEGIN
		SET @errorMessage = @errorMessagePerProcess
	END
	ELSE
	BEGIN
		SET @errorMessage = @errorMessage + CHAR(13) + @errorMessagePerProcess
	END

	IF(@success = 1)
	BEGIN
		SET @errorMessage = NULL
		-- AR Transaction and Posting
		EXEC [dbo].[uspCCTransactionToARInvoice] 
			@intSiteHeaderId = @intSiteHeaderId
			,@UserId = @userId
			,@Post	= @post
			,@Recap = 0
			,@CreatedIvoices = @InvoicesId OUTPUT
			,@success = @success OUTPUT
			,@ErrorMessage = @errorMessagePerProcess OUTPUT

		IF(ISNULL(@errorMessage, '') = '')
		BEGIN
			SET @errorMessage = @errorMessagePerProcess
		END
		ELSE
		BEGIN
			SET @errorMessage = @errorMessage + CHAR(13) + @errorMessagePerProcess
		END
	END

	IF(@success = 1)
	BEGIN
		SET @errorMessage = NULL
		-- CM Transaction and Posting
		EXEC [dbo].[uspCCTransactionToCMBankTransaction]
			@intSiteHeaderId = @intSiteHeaderId
			,@userId = @userId
			,@post	= @post
			,@recap = 0
			,@success = @success OUTPUT
			,@errorMessage = @errorMessagePerProcess OUTPUT
			,@createdBankTransactionId = @bankTransactionId OUTPUT

		IF(ISNULL(@errorMessage, '') = '')
		BEGIN
			SET @errorMessage = @errorMessagePerProcess
		END
		ELSE
		BEGIN
			SET @errorMessage = @errorMessage +  CHAR(13) + @errorMessagePerProcess
		END
	END

	-- SET Posted Flag
	IF(@success = 1)
	BEGIN
		IF(@post = 1)
		BEGIN
			UPDATE [dbo].[tblCCSiteHeader] SET ysnPosted = @post, intCMBankTransactionId = @bankTransactionId WHERE intSiteHeaderId = @intSiteHeaderId
		END
		ELSE IF(@post = 0)
		BEGIN
			UPDATE [dbo].[tblCCSiteHeader] SET ysnPosted = @post WHERE intSiteHeaderId = @intSiteHeaderId
		END
	END
	
	IF(@success = 0)
	BEGIN
		RAISERROR(@errorMessage,16,1)
	END

	IF(@@TRANCOUNT > 0)
	BEGIN
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
	IF(@@TRANCOUNT > 0)
	BEGIN
		ROLLBACK TRANSACTION
	END
	RAISERROR (@errorMessage , @ErrorSeverity, @ErrorState, @ErrorNumber)
END CATCH