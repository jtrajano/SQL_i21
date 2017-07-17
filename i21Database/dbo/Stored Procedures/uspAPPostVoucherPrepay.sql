CREATE PROCEDURE [dbo].[uspAPPostVoucherPrepay]
	@param				NVARCHAR(MAX),
	@post				BIT,
	@recap				BIT,
	@userId				INT,
	@batchId			NVARCHAR(20) = NULL,
	@success			BIT OUTPUT,
	@batchIdUsed		NVARCHAR(50) OUTPUT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @user INT = @userId;
DECLARE @GLEntries AS RecapTableType;
DECLARE @voucherPrepayIdData AS Id;
DECLARE @transCount INT;

INSERT INTO @voucherPrepayIdData SELECT [intID] FROM [dbo].fnGetRowsFromDelimitedValues(@param)

IF @batchId IS NULL EXEC uspSMGetStartingNumber 3, @batchId OUT

SET @batchIdUsed = @batchId;

IF @post = 1
BEGIN
	INSERT INTO @GLEntries (
		dtmDate ,
	    strBatchId ,
	    intAccountId ,
	    dblDebit ,
	    dblCredit ,
	    dblDebitUnit ,
	    dblCreditUnit ,
	    strDescription ,
	    strCode ,
	    strReference ,
	    intCurrencyId ,
	    dblExchangeRate ,
	    dtmDateEntered ,
	    dtmTransactionDate ,
	    strJournalLineDescription ,
	    intJournalLineNo ,
	    ysnIsUnposted ,
	    intUserId ,
	    intEntityId ,
	    strTransactionId ,
	    intTransactionId ,
	    strTransactionType ,
	    strTransactionForm ,
	    strModuleName ,
	    dblDebitForeign ,
	    dblDebitReport ,
	    dblCreditForeign ,
	    dblCreditReport ,
	    dblReportingRate ,
	    dblForeignRate ,
	    strRateType 
	)
	SELECT     
		dtmDate ,
	    strBatchId ,
	    intAccountId ,
	    dblDebit ,
	    dblCredit ,
	    dblDebitUnit ,
	    dblCreditUnit ,
	    strDescription ,
	    strCode ,
	    strReference ,
	    intCurrencyId ,
	    dblExchangeRate ,
	    dtmDateEntered ,
	    dtmTransactionDate ,
	    strJournalLineDescription ,
	    intJournalLineNo ,
	    ysnIsUnposted ,
	    intUserId ,
	    intEntityId ,
	    strTransactionId ,
	    intTransactionId ,
	    strTransactionType ,
	    strTransactionForm ,
	    strModuleName ,
	    dblDebitForeign ,
	    dblDebitReport ,
	    dblCreditForeign ,
	    dblCreditReport ,
	    dblReportingRate ,
	    dblForeignRate ,
	    strRateType 	 
	FROM dbo.[fnAPCreateVoucherPrepayGLEntries](@voucherPrepayIdData, @userId, @batchId)
END
ELSE
BEGIN
	INSERT INTO @GLEntries
	SELECT * FROM dbo.fnAPReverseGLEntries(@voucherPrepayIdData, 'Bill', DEFAULT, @userId, @batchId)
END

BEGIN TRY
--THIS IS FOR THE UNHANDLED EXCEPTION
SET @transCount = @@TRANCOUNT;
IF @transCount = 0 BEGIN TRANSACTION

IF @recap = 0
BEGIN
	EXEC uspGLBatchPostEntries @GLEntries, @batchId, @userId, @post
	DELETE ids
	FROM @voucherPrepayIdData ids
	INNER JOIN tblGLPostResult postResult ON ids.intId = postResult.intTransactionId
	WHERE postResult.strDescription NOT LIKE '%success%' AND postResult.strBatchId = @batchId

	INSERT INTO tblAPPostResult(strMessage, strTransactionType, strTransactionId, intTransactionId)
	SELECT 
		A.strDescription
		,A.strTransactionType
		,A.strTransactionId
		,A.intTransactionId
	FROM tblGLPostResult A
	WHERE A.strBatchId = @batchId

	UPDATE prepay
		SET prepay.ysnPosted = @post
	FROM tblAPBill prepay
	INNER JOIN @voucherPrepayIdData prepayIds ON prepay.intBillId = prepayIds.intId
END
ELSE
BEGIN
	DELETE FROM tblGLDetailRecap WHERE intTransactionId IN (SELECT intId FROM @voucherPrepayIdData);

	INSERT INTO tblGLPostRecap(
		[strTransactionId]
		,[intTransactionId]
		,[intAccountId]
		,[strDescription]
		,[strJournalLineDescription]
		,[strReference]	
		,[intCurrencyId]
		,[dtmTransactionDate]
		,[dblDebit]
		,[dblCredit]
		,[dblDebitUnit]
		,[dblCreditUnit]
		,[dtmDate]
		,[ysnIsUnposted]
		,[intConcurrencyId]	
		,[dblExchangeRate]
		,[intUserId]
		,[dtmDateEntered]
		,[strBatchId]
		,[strCode]
		,[strModuleName]
		,[strTransactionForm]
		,[strTransactionType]
		,[strAccountId]
		,[strAccountGroup]
		,[dblDebitForeign]
		,[dblCreditForeign]
		,[strRateType]
			
	)
	SELECT
		[strTransactionId]
		,A.[intTransactionId]
		,A.[intAccountId]
		,A.[strDescription]
		,A.[strJournalLineDescription]
		,A.[strReference]	
		,A.[intCurrencyId]
		,A.[dtmTransactionDate]
		,Debit.Value
		,Credit.Value
		,A.[dblDebitUnit]
		,A.[dblCreditUnit]
		,A.[dtmDate]
		,A.[ysnIsUnposted]
		,A.[intConcurrencyId]	
		,A.[dblForeignRate]
		,A.[intUserId]
		,A.[dtmDateEntered]
		,A.[strBatchId]
		,A.[strCode]
		,A.[strModuleName]
		,A.[strTransactionForm]
		,A.[strTransactionType]
		,B.strAccountId
		,C.strAccountGroup
		,DebitForeign.Value
		,CreditForeign.Value
		,A.[strRateType]           
	FROM @GLEntries A
	INNER JOIN dbo.tblGLAccount B 
		ON A.intAccountId = B.intAccountId
	INNER JOIN dbo.tblGLAccountGroup C
		ON B.intAccountGroupId = C.intAccountGroupId
	CROSS APPLY dbo.fnGetDebit(ISNULL(A.dblDebit, 0) - ISNULL(A.dblCredit, 0)) Debit
	CROSS APPLY dbo.fnGetCredit(ISNULL(A.dblDebit, 0) - ISNULL(A.dblCredit, 0))  Credit
	CROSS APPLY dbo.fnGetDebit(ISNULL(A.dblDebitForeign, 0) - ISNULL(A.dblCreditForeign, 0)) DebitForeign
	CROSS APPLY dbo.fnGetCredit(ISNULL(A.dblDebitForeign, 0) - ISNULL(A.dblCreditForeign, 0))  CreditForeign;
END

IF @transCount = 0 COMMIT TRANSACTION --COMMIT IF WE INITIATE THE TRANSACTION
SET @success = 1;
END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION
	DECLARE @ErrorMessage NVARCHAR(4000);
	SET @ErrorMessage  = ERROR_MESSAGE()
	RAISERROR(@ErrorMessage, 16, 1);
END CATCH

