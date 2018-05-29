﻿CREATE PROCEDURE [dbo].[uspARValidatePaymentPosting]
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

DECLARE @PaymentIds AS [dbo].[Id]
INSERT INTO @PaymentIds SELECT @PaymentId


DECLARE @PaymentData AS [dbo].[ReceivePaymentPostingTable]
INSERT INTO @PaymentData
SELECT * FROM [dbo].[fnARGetPaymentDetailsForPosting](@PaymentIds, @PostDate, @BatchId, @BankAccountId, @Post, 0, @UserId)


DECLARE @InvalidData TABLE (
     [intTransactionId]         INT             NOT NULL
    ,[strTransactionId]         NVARCHAR(25)    COLLATE Latin1_General_CI_AS    NULL
    ,[strTransactionType]       NVARCHAR(50)    COLLATE Latin1_General_CI_AS    NULL
    ,[intTransactionDetailId]   INT             NULL
    ,[strBatchId]               NVARCHAR(40)    COLLATE Latin1_General_CI_AS    NULL
    ,[strError]                 NVARCHAR(MAX)   COLLATE Latin1_General_CI_AS    NULL
);

INSERT INTO @InvalidData
SELECT * FROM [dbo].[fnARGetInvalidPaymentsForPosting](@PaymentData)

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

DECLARE @GLEntries AS RecapTableType
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
