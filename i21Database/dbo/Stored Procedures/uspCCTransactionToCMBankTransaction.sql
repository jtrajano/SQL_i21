CREATE PROCEDURE [dbo].[uspCCTransactionToCMBankTransaction]
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

BEGIN TRY

	DECLARE @BankTransaction BankTransactionTable
	DECLARE @BankTransactionDetail BankTransactionDetailTable
	DECLARE @strTransactionId NVARCHAR(40)
	DECLARE @dblSumAmount DECIMAL(18, 6)
	
	EXEC uspSMGetStartingNumber 13, @strTransactionId OUT

	-- CM Header
	INSERT INTO @BankTransaction([intBankAccountId]
		,[strTransactionId]
		,[intCurrencyId]
		,[intBankTransactionTypeId] 
		,[dtmDate]
		,[strMemo]
		,[intCompanyLocationId])
	SELECT 
	 [intBankAccountId] = ccSiteHeader.intBankAccountId
	,[strTransactionId] = @strTransactionId
	,[intCurrencyId] = apVendor.intCurrencyId
	,[intBankTransactionTypeId]  = 5
	,[dtmDate] = ccSiteHeader.dtmDate
	,[strMemo] = ccSiteHeader.strCcdReference
	,[intCompanyLocationId] = ccVendorDefault.intCompanyLocationId
	FROM tblCCSiteHeader ccSiteHeader
	INNER JOIN tblCCVendorDefault ccVendorDefault ON ccVendorDefault.intVendorDefaultId = ccSiteHeader.intVendorDefaultId
	LEFT JOIN tblAPVendor apVendor ON apVendor.intEntityVendorId =  ccVendorDefault.intVendorId
	WHERE ccSiteHeader.intSiteHeaderId = @intSiteHeaderId 

	-- CM Details
	INSERT INTO @BankTransactionDetail(
		[intTransactionId]
		,[dtmDate]
		,[intGLAccountId] 
		,[strDescription]
		,[dblDebit]
		,[dblCredit])
	SELECT 
	[intTransactionId] = 0,
	[dtmDate] = dtmDate,
	[intGLAccountId] = intBankAccountId,
	[strDescription] = strSiteType, 
	[dblDebit] = SUM(dblGross),
	[dblCredit] = SUM(dblFees)
	FROM (
	SELECT ccSiteHeader.dtmDate, 
	ccVendorDefault.intBankAccountId,
	ccSite.strSiteType,
	ccSiteDetail.dblGross,
	ccSiteDetail.dblFees,
	ccSiteDetail.dblNet,
	(CASE WHEN ccSite.strSiteType LIKE 'Company Owned%' THEN ccSiteDetail.dblFees ELSE 0 END) dblDebit,
	(CASE WHEN ccSite.strSiteType LIKE 'Dealer Site%' THEN ccSiteDetail.dblNet ELSE 0 END) + 
	(CASE WHEN ccSite.strSiteType LIKE 'Company Owned%' THEN ccSiteDetail.dblGross ELSE 0 END) dblCredit
	FROM tblCCSiteHeader ccSiteHeader
	INNER  JOIN tblCCVendorDefault ccVendorDefault ON ccVendorDefault.intVendorDefaultId = ccSiteHeader.intVendorDefaultId
	LEFT JOIN tblCCSiteDetail ccSiteDetail ON ccSiteDetail.intSiteHeaderId = ccSiteHeader.intSiteHeaderId
	LEFT JOIN vyuCCSite ccSite ON ccSite.intSiteId = ccSiteDetail.intSiteId
	WHERE ccSiteHeader.intSiteHeaderId = @intSiteHeaderId) A
	GROUP BY dtmDate,intBankAccountId, strSiteType

	DECLARE @dblSumDebit DECIMAL(18,6)
	DECLARE @dblSumCredit DECIMAL(18,6)

	SELECT @dblSumDebit = SUM(dblDebit), @dblSumCredit =SUM(dblCredit) FROM @BankTransactionDetail
	SET @dblSumAmount = @dblSumCredit - @dblSumDebit

	UPDATE @BankTransaction SET dblAmount = @dblSumAmount

	EXEC [dbo].[uspCMCreateBankTransactionEntries]
		 @BankTransactionEntries = @BankTransaction
		,@BankTransactionDetailEntries = @BankTransactionDetail
		,@intTransactionId = @createdBankTransactionId OUTPUT

	EXEC [dbo].[uspCMPostBankTransaction]
		@ysnPost = 1
		,@ysnRecap = 0
		,@strTransactionId = @strTransactionId
		,@intUserId = @userId
		,@intEntityId = @userId
		,@isSuccessful = @success OUTPUT

	IF ISNULL(@success, 0) = 0
		SET @success = 0

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