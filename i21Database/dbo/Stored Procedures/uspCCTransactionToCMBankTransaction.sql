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

DECLARE @ErrorSeverity INT,
		@ErrorNumber   INT,
		@ErrorState INT

BEGIN TRY

	DECLARE @BankTransaction BankTransactionTable
	DECLARE @BankTransactionDetail BankTransactionDetailTable
	DECLARE @strTransactionId NVARCHAR(40)
	DECLARE @dblSumAmount DECIMAL(18, 6)
	DECLARE @transCount INT = 0
	DECLARE @CCRItemToCMItem TABLE
	(
		intSiteHeaderId int, 
		strItem nvarchar(100)
	)

	INSERT INTO @CCRItemToCMItem VALUES (@intSiteHeaderId,'Dealer Sites Net')
	INSERT INTO @CCRItemToCMItem VALUES (@intSiteHeaderId,'Company Owned Gross')
	INSERT INTO @CCRItemToCMItem VALUES (@intSiteHeaderId,'Company Owned Fees')

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
		AND ccSiteHeader.strApType = 'Cash Deposited'

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
		intBankAccountId,
		[strDescription] = strItem, 
		[dblDebit] = SUM(ISNULL(dblDebit,0)),
		[dblCredit] = SUM(ISNULL(dblCredit,0))
	FROM (
	SELECT ccSiteHeader.intSiteHeaderId
	    ,ccSiteHeader.dtmDate
	    ,(CASE WHEN ccItem.strItem = 'Dealer Sites Net' AND ccSite.strSiteType = 'Dealer Site' THEN ccSite.intAccountId 
			WHEN ccItem.strItem = 'Company Owned Gross' AND ccSite.strSiteType = 'Company Owned' THEN ccSite.intCreditCardReceivableAccountId  
			WHEN ccItem.strItem = 'Company Owned Fees' AND ccSite.strSiteType = 'Company Owned' THEN ccSite.intFeeExpenseAccountId
			ELSE null END)  AS intBankAccountId
		,ccItem.strItem
		,(CASE WHEN ccItem.strItem = 'Company Owned Fees' AND ccSite.strSiteType = 'Company Owned' THEN ccSiteDetail.dblFees 
			ELSE null END) dblDebit
		,(CASE WHEN ccItem.strItem = 'Dealer Sites Net' AND ccSite.strSiteType = 'Dealer Site' THEN ccSiteDetail.dblNet 
			WHEN ccItem.strItem = 'Company Owned Gross' AND ccSite.strSiteType = 'Company Owned' THEN ccSiteDetail.dblGross 
			ELSE null END) dblCredit
	FROM tblCCSiteHeader ccSiteHeader
		LEFT JOIN tblCCSiteDetail ccSiteDetail ON ccSiteDetail.intSiteHeaderId = ccSiteHeader.intSiteHeaderId
		LEFT JOIN vyuCCSite ccSite ON ccSite.intSiteId = ccSiteDetail.intSiteId
		LEFT JOIN @CCRItemToCMItem ccItem ON ccItem.intSiteHeaderId = ccSiteDetail.intSiteHeaderId
	WHERE ccSiteHeader.intSiteHeaderId = @intSiteHeaderId AND ccSiteHeader.strApType = 'Cash Deposited') A
	WHERE (dblDebit IS NOT NULL OR dblCredit IS NOT NULL)
	GROUP BY dtmDate, intBankAccountId, strItem

	SELECT @transCount=COUNT(*) FROM @BankTransactionDetail
		
	IF(@transCount > 0)
		BEGIN

		DECLARE @dblSumDebit DECIMAL(18,6)
		DECLARE @dblSumCredit DECIMAL(18,6)

		SELECT @dblSumDebit = SUM(ISNULL(dblDebit,0)), @dblSumCredit =SUM(ISNULL(dblCredit,0)) FROM @BankTransactionDetail
		SET @dblSumAmount = @dblSumCredit - @dblSumDebit

		UPDATE @BankTransaction SET dblAmount = @dblSumAmount

		EXEC [dbo].[uspCMCreateBankTransactionEntries]
			 @BankTransactionEntries = @BankTransaction
			,@BankTransactionDetailEntries = @BankTransactionDetail
			,@intTransactionId = @createdBankTransactionId OUTPUT

			BEGIN TRY
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
				SET @ErrorSeverity = ERROR_SEVERITY()
				SET @ErrorNumber   = ERROR_NUMBER()
				SET @errorMessage  = ERROR_MESSAGE()
				SET @ErrorState    = ERROR_STATE()
				SET	@success = 0

				IF(@strTransactionId IS NOT NULL)
					DELETE tblAPBill WHERE intBillId = @strTransactionId

				RAISERROR (@errorMessage , @ErrorSeverity, @ErrorState, @ErrorNumber)

			END CATCH
		END
	ELSE
		BEGIN
			SET @success = 1
		END

END TRY
BEGIN CATCH
	SET @ErrorSeverity = ERROR_SEVERITY()
	SET @ErrorNumber   = ERROR_NUMBER()
	SET @errorMessage  = ERROR_MESSAGE()
	SET @ErrorState    = ERROR_STATE()
	SET	@success = 0
	RAISERROR (@errorMessage , @ErrorSeverity, @ErrorState, @ErrorNumber)
END CATCH