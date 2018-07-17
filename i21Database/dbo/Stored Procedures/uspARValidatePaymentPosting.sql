CREATE PROCEDURE [dbo].[uspARValidatePaymentPosting]
     @PaymentId     AS INT
    ,@Post          AS BIT
    ,@UserId        AS INT
    ,@BankAccountId AS INT = NULL
    ,@BatchId       AS NVARCHAR(40) = NULL
    ,@PostDate      AS DATETIME = NULL
    ,@Error         AS NVARCHAR(500) = NULL OUTPUT		
AS	


SET @Error = ''
IF @PostDate IS NULL
    SET @PostDate = GETDATE()
IF @BatchId IS NULL
    SET @BatchId = 'TestBatchId'

SET @Post = (SELECT TOP 1 CASE WHEN ysnPosted = 0 THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END FROM tblARPayment WHERE intPaymentId = @PaymentId)
SET @Post = ISNULL(@Post, 1)

DECLARE @UserEntityID INT = ISNULL((SELECT [intEntityId] FROM tblSMUserSecurity WHERE [intEntityId] = @UserId),@UserId)
DECLARE @PaymentIds AS [dbo].[Id]
INSERT INTO @PaymentIds SELECT @PaymentId

DECLARE @PaymentData AS [dbo].[ReceivePaymentPostingTable]
INSERT INTO @PaymentData
SELECT * FROM [dbo].[fnARGetPaymentDetailsForPosting](@PaymentIds, @PostDate, @BatchId, @BankAccountId, @Post, 0, @UserId, NULL)


DECLARE @InvalidData TABLE (
     [intTransactionId]         INT             NOT NULL
    ,[strTransactionId]         NVARCHAR(25)    COLLATE Latin1_General_CI_AS    NULL
    ,[strTransactionType]       NVARCHAR(50)    COLLATE Latin1_General_CI_AS    NULL
    ,[intTransactionDetailId]   INT             NULL
    ,[strBatchId]               NVARCHAR(40)    COLLATE Latin1_General_CI_AS    NULL
    ,[strError]                 NVARCHAR(MAX)   COLLATE Latin1_General_CI_AS    NULL
);

INSERT INTO @InvalidData
SELECT * FROM [dbo].[fnARGetInvalidPaymentsForPosting](@PaymentData, @Post, 1)

DECLARE @ErrorMessage AS NVARCHAR(500)
SELECT TOP 1
    @ErrorMessage = [strError]
FROM
    @InvalidData
WHERE
    [strError] NOT IN ('There was no payment to receive.' )

IF LTRIM(RTRIM(ISNULL(@ErrorMessage, ''))) <> ''
BEGIN
    SET @Error = @ErrorMessage
	RETURN 1
END

DECLARE @Overpayment AS [dbo].[Id]
DECLARE @Prepayment  AS [dbo].[Id]
DECLARE @GLEntries AS RecapTableType

IF @Post = 1
    BEGIN
        --+overpayment
        INSERT INTO
            @Overpayment
        SELECT
            A.intPaymentId
        FROM
            tblARPayment A 
        INNER JOIN
            @PaymentData P
                ON A.intPaymentId = P.[intTransactionId]				
        WHERE
                (A.dblAmountPaid) > (SELECT SUM(dblPayment) FROM tblARPaymentDetail WHERE intPaymentId = A.intPaymentId)
            AND EXISTS(SELECT NULL FROM tblARPaymentDetail WHERE intPaymentId = A.intPaymentId AND dblPayment <> 0)	
					
        --+prepayment
        INSERT INTO
            @Prepayment
        SELECT
            A.intPaymentId
        FROM
            tblARPayment A 
        INNER JOIN
            @PaymentData P
		        ON A.intPaymentId = P.[intTransactionId]				
        WHERE
            (A.dblAmountPaid) <> 0
            AND ISNULL((SELECT SUM(dblPayment) FROM tblARPaymentDetail WHERE intPaymentId = A.intPaymentId), 0) = 0	
            AND NOT EXISTS(SELECT NULL FROM tblARPaymentDetail WHERE intPaymentId = A.intPaymentId AND dblPayment <> 0)											
    END
ELSE	
    BEGIN
        ---overpayment
        INSERT INTO
            @Overpayment
        SELECT
            A.intPaymentId
        FROM
            tblARPayment A 
        INNER JOIN
            @PaymentData P
                ON A.intPaymentId = P.[intTransactionId]
        INNER JOIN
            tblARInvoice I
                ON A.strRecordNumber = I.strComments OR A.intPaymentId = I.intPaymentId 				
        WHERE
                I.strTransactionType = 'Overpayment'
					
        ---prepayment
        INSERT INTO
            @Prepayment
        SELECT
            A.intPaymentId
        FROM
            tblARPayment A 
        INNER JOIN
            @PaymentData P
                ON A.intPaymentId = P.[intTransactionId]
        INNER JOIN
            tblARInvoice I
                ON A.strRecordNumber = I.strComments OR A.intPaymentId = I.intPaymentId 				
        WHERE
                I.strTransactionType = 'Customer Prepayment'
    END

IF @Post = 1
	BEGIN
		INSERT INTO @GLEntries
			([dtmDate]
			,[strBatchId]
			,[intAccountId]
			,[dblDebit]
			,[dblCredit]
			,[dblDebitUnit]
			,[dblCreditUnit]
			,[strDescription]
			,[strCode]
			,[strReference]
			,[intCurrencyId]
			,[dblExchangeRate]
			,[dtmDateEntered]
			,[dtmTransactionDate]
			,[strJournalLineDescription]
			,[intJournalLineNo]
			,[ysnIsUnposted]
			,[intUserId]
			,[intEntityId]
			,[strTransactionId]
			,[intTransactionId]
			,[strTransactionType]
			,[strTransactionForm]
			,[strModuleName]
			,[intConcurrencyId]
			,[dblDebitForeign]
			,[dblDebitReport]
			,[dblCreditForeign]
			,[dblCreditReport]
			,[dblReportingRate]
			,[dblForeignRate]
			,[strRateType]
			,[strDocument]
			,[strComments]
			,[strSourceDocumentId]
			,[intSourceLocationId]
			,[intSourceUOMId]
			,[dblSourceUnitDebit]
			,[dblSourceUnitCredit]
			,[intCommodityId]
			,[intSourceEntityId]
			,[ysnRebuild])
		SELECT
			 [dtmDate]
			,[strBatchId]
			,[intAccountId]
			,[dblDebit]
			,[dblCredit]
			,[dblDebitUnit]
			,[dblCreditUnit]
			,[strDescription]
			,[strCode]
			,[strReference]
			,[intCurrencyId]
			,[dblExchangeRate]
			,[dtmDateEntered]
			,[dtmTransactionDate]
			,[strJournalLineDescription]
			,[intJournalLineNo]
			,[ysnIsUnposted]
			,[intUserId]
			,[intEntityId]
			,[strTransactionId]
			,[intTransactionId]
			,[strTransactionType]
			,[strTransactionForm]
			,[strModuleName]
			,[intConcurrencyId]
			,[dblDebitForeign]
			,[dblDebitReport]
			,[dblCreditForeign]
			,[dblCreditReport]
			,[dblReportingRate]
			,[dblForeignRate]
			,[strRateType]
			,[strDocument]
			,[strComments]
			,[strSourceDocumentId]
			,[intSourceLocationId]
			,[intSourceUOMId]
			,[dblSourceUnitDebit]
			,[dblSourceUnitCredit]
			,[intCommodityId]
			,[intSourceEntityId]
			,[ysnRebuild]
		FROM [dbo].[fnARGenerateGLEntriesForPayments] (@PaymentData, @Overpayment, @Prepayment)

		DELETE FROM @PaymentIds
        INSERT INTO @PaymentIds
        SELECT DISTINCT [intTransactionId] FROM @PaymentData WHERE [intTransactionDetailId] IS NOT NULL AND [strTransactionType] = 'Claim'

		INSERT INTO @GLEntries
			([dtmDate]
			,[strBatchId]
			,[intAccountId]
			,[dblDebit]
			,[dblCredit]
			,[dblDebitUnit]
			,[dblCreditUnit]
			,[strDescription]
			,[strCode]
			,[strReference]
			,[intCurrencyId]
			,[dblExchangeRate]
			,[dtmDateEntered]
			,[dtmTransactionDate]
			,[strJournalLineDescription]
			,[intJournalLineNo]
			,[ysnIsUnposted]
			,[intUserId]
			,[intEntityId]
			,[strTransactionId]
			,[intTransactionId]
			,[strTransactionType]
			,[strTransactionForm]
			,[strModuleName]
			,[intConcurrencyId]
			,[dblDebitForeign]
			,[dblDebitReport]
			,[dblCreditForeign]
			,[dblCreditReport]
			,[dblReportingRate]
			,[dblForeignRate]
			,[strRateType]
			,[strDocument]
			,[strComments]
			,[strSourceDocumentId]
			,[intSourceLocationId]
			,[intSourceUOMId]
			,[dblSourceUnitDebit]
			,[dblSourceUnitCredit]
			,[intCommodityId]
			,[intSourceEntityId]
			,[ysnRebuild])
		SELECT
		     [dtmDate]
			,[strBatchId]
			,[intAccountId]
			,[dblDebit]
			,[dblCredit]
			,[dblDebitUnit]
			,[dblCreditUnit]
			,[strDescription]
			,[strCode]
			,[strReference]
			,[intCurrencyId]
			,[dblExchangeRate]
			,[dtmDateEntered]
			,[dtmTransactionDate]
			,[strJournalLineDescription]
			,[intJournalLineNo]
			,[ysnIsUnposted]
			,[intUserId]
			,[intEntityId]
			,[strTransactionId]
			,[intTransactionId]
			,[strTransactionType]
			,[strTransactionForm]
			,[strModuleName]
			,[intConcurrencyId]
			,[dblDebitForeign]
			,[dblDebitReport]
			,[dblCreditForeign]
			,[dblCreditReport]
			,[dblReportingRate]
			,[dblForeignRate]
			,[strRateType]
			,NULL
			,NULL
			,NULL
			,NULL
			,NULL
			,NULL
			,NULL
			,NULL
			,NULL
			,NULL
		FROM [dbo].[fnAPCreateClaimARGLEntries] (@PaymentIds, @UserId, @BatchId)

	END
ELSE
	BEGIN
		INSERT INTO @GLEntries(
			 [dtmDate]
			,[strBatchId]
			,[intAccountId]
			,[dblDebit]
			,[dblCredit]
			,[dblDebitUnit]
			,[dblCreditUnit]
			,[strDescription]
			,[strCode]
			,[strReference]
			,[intCurrencyId]
			,[dblExchangeRate]
			,[dtmDateEntered]
			,[dtmTransactionDate]
			,[strJournalLineDescription]
			,[intJournalLineNo]
			,[ysnIsUnposted]
			,[intUserId]
			,[intEntityId]
			,[strTransactionId]
			,[intTransactionId]
			,[strTransactionType]
			,[strTransactionForm]
			,[strModuleName]
			,[intConcurrencyId]
			,[dblDebitForeign]
			,[dblDebitReport]
			,[dblCreditForeign]
			,[dblCreditReport]
			,[dblReportingRate]
			,[dblForeignRate]
			,[strRateType]
		)
		SELECT	
			 GL.dtmDate
			,@BatchId
			,GL.intAccountId
			,dblDebit						= GL.dblCredit
			,dblCredit						= GL.dblDebit
			,dblDebitUnit					= GL.dblCreditUnit
			,dblCreditUnit					= GL.dblDebitUnit				
			,GL.strDescription
			,GL.strCode
			,GL.strReference
			,GL.intCurrencyId
			,GL.dblExchangeRate
			,dtmDateEntered					= @PostDate
			,GL.dtmTransactionDate
			,strJournalLineDescription		= REPLACE(GL.strJournalLineDescription, 'Posted', 'Unposted ')
			,GL.intJournalLineNo 
			,ysnIsUnposted					= 1
			,intUserId						= @UserId
			,intEntityId					= @UserEntityID
			,GL.strTransactionId
			,GL.intTransactionId
			,GL.strTransactionType
			,GL.strTransactionForm
			,GL.strModuleName
			,GL.intConcurrencyId
			,[dblDebitForeign]				= GL.dblCreditForeign
			,[dblDebitReport]				= GL.dblCreditReport
			,[dblCreditForeign]				= GL.dblDebitForeign
			,[dblCreditReport]				= GL.dblDebitReport
			,[dblReportingRate]				= GL.dblReportingRate 
			,[dblForeignRate]				= GL.dblForeignRate 
			,[strRateType]					= ''
		FROM tblGLDetail GL
		INNER JOIN (
			SELECT intTransactionId
				 , strTransactionId
			FROM @PaymentData P
			GROUP BY intTransactionId, strTransactionId
		) P ON GL.intTransactionId = P.[intTransactionId]  
			AND GL.strTransactionId = P.strTransactionId
		WHERE GL.ysnIsUnposted = 0
		ORDER BY GL.intGLDetailId
	END

DECLARE @InvalidGLEntries AS TABLE
    (strTransactionId   NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
    ,strText            NVARCHAR(150) COLLATE Latin1_General_CI_AS NULL
    ,intErrorCode       INT
    ,strModuleName      NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL)

INSERT INTO @InvalidGLEntries
	([strTransactionId]
    ,[strText]
    ,[intErrorCode]
    ,[strModuleName])
SELECT DISTINCT
    [strTransactionId]
    ,[strText]
    ,[intErrorCode]
    ,[strModuleName]
FROM
    [dbo].[fnGetGLEntriesErrors](@GLEntries)

SELECT TOP 1 @ErrorMessage = strText FROM @InvalidGLEntries

IF LTRIM(RTRIM(ISNULL(@ErrorMessage, ''))) <> ''
BEGIN
    SET @Error = @ErrorMessage
	RETURN 1
END

SET @Error = ''

RETURN 0
