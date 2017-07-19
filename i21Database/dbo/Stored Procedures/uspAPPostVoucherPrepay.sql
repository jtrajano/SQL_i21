CREATE PROCEDURE [dbo].[uspAPPostVoucherPrepay]
	@param				NVARCHAR(MAX),
	@post				BIT,
	@recap				BIT,
	@userId				INT,
	@batchId			NVARCHAR(20) = NULL,
	@success			BIT = 0 OUTPUT,
	@invalidCount		INT = 0 OUTPUT,
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
DECLARE @totalInvalid INT = 0;
DECLARE @totalRecords INT;
DECLARE @validVoucherPrepay Id;

CREATE TABLE #tmpInvalidVoucherPrepayData (
	[strError] [NVARCHAR](200),
	[strTransactionType] [NVARCHAR](50),
	[strTransactionId] [NVARCHAR](50),
	[intTransactionId] INT,
	[intErrorKey]	INT
);

INSERT INTO @voucherPrepayIdData SELECT [intID] FROM [dbo].fnGetRowsFromDelimitedValues(@param)

--GENERATE BATCH ID SO WE HAVE KEY WHEN WE GET THE RESULT
IF @batchId IS NULL EXEC uspSMGetStartingNumber 3, @batchId OUT

SET @batchIdUsed = @batchId;

INSERT INTO #tmpInvalidVoucherPrepayData
SELECT * FROM dbo.fnAPValidateVoucherPrepay(@voucherPrepayIdData, @post)

SELECT @totalInvalid = COUNT(*) FROM #tmpInvalidVoucherPrepayData

IF(@totalInvalid > 0)
BEGIN
	--Insert Invalid Post transaction result
	INSERT INTO tblAPPostResult(strMessage, strTransactionType, strTransactionId, strBatchNumber, intTransactionId)
	SELECT strError, strTransactionType, strTransactionId, @batchId, intTransactionId FROM #tmpInvalidVoucherPrepayData

	SET @invalidCount = @totalInvalid
END

--LISTS ALL VALID RECORDS
INSERT INTO @validVoucherPrepay
SELECT intId FROM @voucherPrepayIdData A
WHERE NOT EXISTS (
	SELECT 1 FROM #tmpInvalidVoucherPrepayData B 
	WHERE B.intTransactionId = A.intId
)

SELECT @totalRecords = COUNT(*) FROM @validVoucherPrepay

IF @totalRecords = 0 
BEGIN
	SET @success = 0;
	RETURN; --EXIT, NO VOUCHER PREPAY TO POST
END

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
	FROM dbo.[fnAPCreateVoucherPrepayGLEntries](@validVoucherPrepay, @userId, @batchId)
END
ELSE
BEGIN
	INSERT INTO @GLEntries
	SELECT * FROM dbo.fnAPReverseGLEntries(@validVoucherPrepay, 'Bill', DEFAULT, @userId, @batchId)
END

BEGIN TRY
--THIS IS FOR THE UNHANDLED EXCEPTION
SET @transCount = @@TRANCOUNT;
IF @transCount = 0 BEGIN TRANSACTION

IF @recap = 0
BEGIN
	EXEC uspGLBatchPostEntries @GLEntries, @batchId, @userId, @post
	DELETE ids
	FROM @validVoucherPrepay ids
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
	INNER JOIN @validVoucherPrepay prepayIds ON prepay.intBillId = prepayIds.intId
END
ELSE
BEGIN
	DELETE FROM tblGLDetailRecap WHERE intTransactionId IN (SELECT intId FROM @validVoucherPrepay);

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

