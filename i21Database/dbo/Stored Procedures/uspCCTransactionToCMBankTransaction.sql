CREATE PROCEDURE [dbo].[uspCCTransactionToCMBankTransaction]
	@intSiteHeaderId	INT
	,@userId			INT	
	,@post				BIT
	,@recap				BIT
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

BEGIN

	DECLARE @BankTransaction BankTransactionTable
	DECLARE @BankTransactionDetail BankTransactionDetailTable
	DECLARE @strTransactionId NVARCHAR(40) = NULL
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
	INSERT INTO @CCRItemToCMItem VALUES (@intSiteHeaderId,'Dealer Sites Shared Fees')

	EXEC uspSMGetStartingNumber 13, @strTransactionId OUT

	-- CM Header
	INSERT INTO @BankTransaction([intBankAccountId]
		,[strTransactionId]
		,[intCurrencyId]
		,[intBankTransactionTypeId] 
		,[dtmDate]
		,[strMemo]
		,[intEntityId]
		,[intCompanyLocationId]
		,[ysnCCTransaction])
	SELECT 
		[intBankAccountId] = ccSiteHeader.intBankAccountId
		,[strTransactionId] = @strTransactionId
		,[intCurrencyId] = apVendor.intCurrencyId
		,[intBankTransactionTypeId]  = 5
		,[dtmDate] = ccSiteHeader.dtmDate
		,[strMemo] = ccSiteHeader.strCcdReference
		,[intEntityId] = @userId
		,[intCompanyLocationId] = ccSiteHeader.intCompanyLocationId
		,[ysnCCTransaction] = 1
	FROM tblCCSiteHeader ccSiteHeader
	INNER JOIN tblCCVendorDefault ccVendorDefault ON ccVendorDefault.intVendorDefaultId = ccSiteHeader.intVendorDefaultId
	LEFT JOIN tblAPVendor apVendor ON apVendor.[intEntityId] =  ccVendorDefault.intVendorId
	WHERE ccSiteHeader.intSiteHeaderId = @intSiteHeaderId 
		AND ccSiteHeader.strApType = 'Cash Deposited'

	-- CM Details
	INSERT INTO @BankTransactionDetail(
		[intTransactionId]
		,[dtmDate]
		,[intGLAccountId] 
		,[strDescription]
		,[dblDebit]
		,[dblCredit]
		,[intEntityId])
	SELECT 
		[intTransactionId] = 0,
		[dtmDate] = dtmDate,
		intBankAccountId,
		[strDescription] = strItem, 
		--[dblDebit] = SUM(ISNULL(dblDebit,0)),
		--[dblCredit] = SUM(ISNULL(dblCredit,0)),
		[dblDebit] = round(SUM(ISNULL(dblDebit,0)),2),
		[dblCredit] = round(SUM(ISNULL(dblCredit,0)),2),
		[intEntityId] = @userId
	FROM (
	SELECT ccSiteHeader.intSiteHeaderId
	    ,ccSiteHeader.dtmDate
	    ,(CASE WHEN ccItem.strItem = 'Dealer Sites Net' AND ccSite.strSiteType = 'Dealer Site' THEN ccSite.intAccountId 
			WHEN ccItem.strItem = 'Company Owned Gross' AND (ccSite.strSiteType = 'Company Owned' or ccSite.strSiteType = 'Company Owned Pass Thru') THEN ccSite.intCreditCardReceivableAccountId  
			WHEN ccItem.strItem = 'Company Owned Fees' AND (ccSite.strSiteType = 'Company Owned' or ccSite.strSiteType = 'Company Owned Pass Thru') THEN ccSite.intFeeExpenseAccountId
			WHEN ccItem.strItem = 'Dealer Sites Net' AND ccSite.strSiteType = 'Dealer Site Shared Fees' THEN ccSite.intAccountId 
			WHEN ccItem.strItem = 'Dealer Sites Shared Fees' AND ccSite.strSiteType = 'Dealer Site Shared Fees' THEN ccSite.intFeeExpenseAccountId
			ELSE null END)  AS intBankAccountId
		,ccItem.strItem
		,(CASE WHEN ccItem.strItem = 'Company Owned Fees' AND (ccSite.strSiteType = 'Company Owned' OR ccSite.strSiteType = 'Company Owned Pass Thru') THEN ccSiteDetail.dblFees 
			WHEN ccItem.strItem = 'Dealer Sites Shared Fees' AND ccSite.strSiteType = 'Dealer Site Shared Fees' THEN ccSiteDetail.dblFees - ROUND(ccSiteDetail.dblFees * (ccSite.dblSharedFeePercentage / 100), 2)
			--ROUND(ccSiteDetail.dblFees * (1 - (ccSite.dblSharedFeePercentage / 100)), 2)
			ELSE null END) dblDebit
		,(CASE WHEN ccItem.strItem = 'Dealer Sites Net' AND ccSite.strSiteType = 'Dealer Site' THEN ccSiteDetail.dblNet 
			WHEN ccItem.strItem = 'Company Owned Gross' AND (ccSite.strSiteType = 'Company Owned' or ccSite.strSiteType = 'Company Owned Pass Thru') THEN ccSiteDetail.dblGross
			WHEN ccItem.strItem = 'Dealer Sites Net' AND ccSite.strSiteType = 'Dealer Site Shared Fees' THEN ccSiteDetail.dblNet + (ccSiteDetail.dblFees - ROUND(ccSiteDetail.dblFees * (ccSite.dblSharedFeePercentage / 100), 2))
			--ccSiteDetail.dblNet + ROUND(ccSiteDetail.dblFees * (1 - (ccSite.dblSharedFeePercentage / 100)), 2)
			--WHEN ccItem.strItem = 'Dealer Sites Shared Fees' AND ccSite.strSiteType = 'Dealer Site Shared Fees' THEN ccSiteDetail.dblFees * (ccSite.dblSharedFeePercentage / 100)
			--WHEN ccItem.strItem = 'Dealer Sites Shared Fees' AND ccSite.strSiteType = 'Dealer Site Shared Fees' THEN ccSiteDetail.dblFees - (ccSiteDetail.dblFees * (ccSite.dblSharedFeePercentage / 100))
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
			IF(@post = 1)
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

					EXEC [dbo].[uspCMPostBankTransaction]
						@ysnPost = @post
						,@ysnRecap = @recap
						,@strTransactionId = @strTransactionId
						,@intUserId = @userId
						,@intEntityId = @userId
						,@isSuccessful = @success OUTPUT

					IF ISNULL(@success, 0) = 0
						SET @success = 0
				END
			ELSE IF (@post = 0)
				BEGIN
					SELECT @strTransactionId = cmBankTrans.strTransactionId 
						FROM tblCCSiteHeader ccSiteHeader 
						INNER JOIN tblCMBankTransaction cmBankTrans ON cmBankTrans.intTransactionId = ccSiteHeader.intCMBankTransactionId
						WHERE ccSiteHeader.intSiteHeaderId = @intSiteHeaderId
					IF (@strTransactionId IS NOT NULL)
					BEGIN
						EXEC [dbo].[uspCMPostBankTransaction]
							@ysnPost = @post
							,@ysnRecap = @recap
							,@strTransactionId = @strTransactionId
							,@intUserId = @userId
							,@intEntityId = @userId
							,@isSuccessful = @success OUTPUT

						--DELETE Bank Transaction
						DELETE FROM tblCMBankTransaction WHERE intTransactionId = 
						(SELECT intCMBankTransactionId 
							FROM tblCCSiteHeader 
						WHERE intSiteHeaderId = @intSiteHeaderId)

					END
					ELSE
						RAISERROR('Bank Transaction ID is null', 16, 1)
				END
		END
	ELSE
		BEGIN
			SET @success = 1
		END
END