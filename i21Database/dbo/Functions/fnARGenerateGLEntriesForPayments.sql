CREATE FUNCTION [dbo].[fnARGenerateGLEntriesForPayments]
(
      @Payments	        [dbo].[ReceivePaymentPostingTable] Readonly
     ,@AROverpayment    [dbo].[Id] Readonly
     ,@ARPrepayment     [dbo].[Id] Readonly
)
RETURNS @returntable TABLE
(
     [dtmDate]                      DATETIME        NOT NULL
    ,[strBatchId]                   NVARCHAR(40)    COLLATE Latin1_General_CI_AS NULL
    ,[intAccountId]                 INT             NULL
    ,[dblDebit]                     NUMERIC(18,6)   NULL
    ,[dblCredit]                    NUMERIC(18,6)   NULL
    ,[dblDebitUnit]                 NUMERIC(18,6)   NULL
    ,[dblCreditUnit]                NUMERIC(18,6)   NULL
    ,[strDescription]               NVARCHAR(255)   COLLATE Latin1_General_CI_AS NULL
    ,[strCode]                      NVARCHAR(40)    COLLATE Latin1_General_CI_AS NULL
    ,[strReference]                 NVARCHAR(255)   COLLATE Latin1_General_CI_AS NULL
    ,[intCurrencyId]                INT             NULL
    ,[dblExchangeRate]              NUMERIC(38,20)  DEFAULT 1 NOT NULL
    ,[dtmDateEntered]               DATETIME        NOT NULL
    ,[dtmTransactionDate]           DATETIME        NULL
    ,[strJournalLineDescription]    NVARCHAR(250)   COLLATE Latin1_General_CI_AS NULL
    ,[intJournalLineNo]             INT             NULL
    ,[ysnIsUnposted]                BIT             NOT NULL
    ,[intUserId]                    INT             NULL
    ,[intEntityId]                  INT             NULL
    ,[strTransactionId]             NVARCHAR(40)    COLLATE Latin1_General_CI_AS NULL
    ,[intTransactionId]             INT             NULL
    ,[strTransactionType]           NVARCHAR(255)   COLLATE Latin1_General_CI_AS NOT NULL
    ,[strTransactionForm]           NVARCHAR(255)   COLLATE Latin1_General_CI_AS NOT NULL
    ,[strModuleName]                NVARCHAR(255)   COLLATE Latin1_General_CI_AS NOT NULL
    ,[intConcurrencyId]             INT             DEFAULT 1 NOT NULL
    ,[dblDebitForeign]              NUMERIC(18,9)   NULL
    ,[dblDebitReport]               NUMERIC(18,9)   NULL
    ,[dblCreditForeign]             NUMERIC(18,9)   NULL
    ,[dblCreditReport]              NUMERIC(18,9)   NULL
    ,[dblReportingRate]             NUMERIC(18,9)   NULL
    ,[dblForeignRate]               NUMERIC(18,9)   NULL
    ,[strRateType]                  NVARCHAR(50)    COLLATE Latin1_General_CI_AS
    ,[strDocument]                  NVARCHAR(255)   COLLATE Latin1_General_CI_AS NULL
    ,[strComments]                  NVARCHAR(255)   COLLATE Latin1_General_CI_AS NULL
    ,[strSourceDocumentId]          NVARCHAR(50)    COLLATE Latin1_General_CI_AS
    ,[intSourceLocationId]          INT             NULL
    ,[intSourceUOMId]		        INT             NULL
    ,[dblSourceUnitDebit]           NUMERIC(18,6)   NULL
    ,[dblSourceUnitCredit]          NUMERIC(18,6)    NULL
    ,[intCommodityId]               INT        NULL
    ,[intSourceEntityId]            INT        NULL
    ,[ysnRebuild]                   BIT        NULL

)
AS
BEGIN

DECLARE @ZeroDecimal    DECIMAL(18,6)
SET @ZeroDecimal = 0.000000

DECLARE @MODULE_NAME NVARCHAR(25) = 'Accounts Receivable'
DECLARE @SCREEN_NAME NVARCHAR(25) = 'Receive Payments'
DECLARE @CODE NVARCHAR(25) = 'AR'
DECLARE @POSTDESC NVARCHAR(10) = 'Posted '

INSERT @returntable
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

--DEBIT PAYMENT HEADER
SELECT
     [dtmDate]                      = P.[dtmDatePaid]
    ,[strBatchId]                   = P.[strBatchId]
    ,[intAccountId]                 = (CASE WHEN UPPER(RTRIM(LTRIM(P.[strPaymentMethod]))) = UPPER('Write Off') THEN P.[intWriteOffAccountId]
                                            WHEN UPPER(RTRIM(LTRIM(P.[strPaymentMethod]))) = UPPER('CF Invoice') THEN ISNULL(P.[intWriteOffAccountId], P.[intCFAccountId])
                                            ELSE P.[intAccountId]
                                      END)
	,[dblDebit]                     = P.[dblBaseAmountPaid] * (CASE WHEN ISNULL(P.[ysnInvoicePrepayment],0) = 1 THEN -1 ELSE 1 END)
    ,[dblCredit]                    = @ZeroDecimal
    ,[dblDebitUnit]                 = @ZeroDecimal
    ,[dblCreditUnit]                = @ZeroDecimal
    ,[strDescription]               = 'Payment from ' + P.strCustomerName
    ,[strCode]                      = @CODE
    ,[strReference]                 = P.[strCustomerNumber]
    ,[intCurrencyId]                = P.[intCurrencyId]
    ,[dblExchangeRate]              = ISNULL(P.[dblExchangeRate], 1)
    ,[dtmDateEntered]               = P.[dtmPostDate]
    ,[dtmTransactionDate]           = P.[dtmDatePaid]
    ,[strJournalLineDescription]    = @POSTDESC + @SCREEN_NAME 
    ,[intJournalLineNo]             = P.[intTransactionId]
    ,[ysnIsUnposted]                = 0
    ,[intUserId]                    = P.[intUserId]
    ,[intEntityId]                  = P.[intEntityId]
    ,[strTransactionId]             = P.[strTransactionId]
    ,[intTransactionId]             = P.[intTransactionId]
    ,[strTransactionType]           = @SCREEN_NAME
    ,[strTransactionForm]           = @SCREEN_NAME
    ,[strModuleName]                = @MODULE_NAME
    ,[intConcurrencyId]             = 1
	,[dblDebitForeign]              = P.[dblAmountPaid] * (CASE WHEN ISNULL(P.[ysnInvoicePrepayment],0) = 1 THEN -1 ELSE 1 END)
    ,[dblDebitReport]               = P.[dblBaseAmountPaid] * (CASE WHEN ISNULL(P.[ysnInvoicePrepayment],0) = 1 THEN -1 ELSE 1 END)
    ,[dblCreditForeign]             = @ZeroDecimal
    ,[dblCreditReport]              = @ZeroDecimal
    ,[dblReportingRate]             = P.[dblExchangeRate]
    ,[dblForeignRate]               = P.[dblExchangeRate]
    ,[strRateType]                  = P.[strRateType]
    ,[strDocument]                  = NULL
    ,[strComments]                  = NULL
    ,[strSourceDocumentId]          = NULL
    ,[intSourceLocationId]          = NULL
    ,[intSourceUOMId]               = NULL
    ,[dblSourceUnitDebit]           = NULL
    ,[dblSourceUnitCredit]          = NULL
    ,[intCommodityId]               = NULL
    ,[intSourceEntityId]            = NULL
    ,[ysnRebuild]                   = NULL
FROM @Payments P
WHERE P.[intTransactionDetailId] IS NULL

UNION ALL

--OVERPAYMENTS
SELECT
     [dtmDate]                      = P.[dtmDatePaid]
    ,[strBatchId]                   = P.[strBatchId]
    ,[intAccountId]                 = P.[intARAccountId]
    ,[dblDebit]                     = @ZeroDecimal
    ,[dblCredit]                    = P.[dblBaseUnappliedAmount]
    ,[dblDebitUnit]                 = @ZeroDecimal
    ,[dblCreditUnit]                = @ZeroDecimal
    ,[strDescription]               = 'Overpayment for ' + P.strTransactionId
    ,[strCode]                      = @CODE
    ,[strReference]                 = P.[strCustomerNumber]
    ,[intCurrencyId]                = P.[intCurrencyId]
    ,[dblExchangeRate]              = ISNULL(P.[dblExchangeRate], 1)
    ,[dtmDateEntered]               = P.[dtmPostDate]
    ,[dtmTransactionDate]           = P.[dtmDatePaid]
    ,[strJournalLineDescription]    = @POSTDESC + @SCREEN_NAME 
    ,[intJournalLineNo]             = P.[intTransactionId]
    ,[ysnIsUnposted]                = 0
    ,[intUserId]                    = P.[intUserId]
    ,[intEntityId]                  = P.[intEntityId]
    ,[strTransactionId]             = P.[strTransactionId]
    ,[intTransactionId]             = P.[intTransactionId]
    ,[strTransactionType]           = @SCREEN_NAME
    ,[strTransactionForm]           = @SCREEN_NAME
    ,[strModuleName]                = @MODULE_NAME
    ,[intConcurrencyId]             = 1
    ,[dblDebitForeign]              = @ZeroDecimal
    ,[dblDebitReport]               = @ZeroDecimal
    ,[dblCreditForeign]             = P.[dblUnappliedAmount]
    ,[dblCreditReport]              = P.[dblBaseUnappliedAmount]
    ,[dblReportingRate]             = P.[dblExchangeRate]
    ,[dblForeignRate]               = P.[dblExchangeRate]
    ,[strRateType]                  = P.[strRateType]
    ,[strDocument]                  = NULL
    ,[strComments]                  = NULL
    ,[strSourceDocumentId]          = NULL
    ,[intSourceLocationId]          = NULL
    ,[intSourceUOMId]               = NULL
    ,[dblSourceUnitDebit]           = NULL
    ,[dblSourceUnitCredit]          = NULL
    ,[intCommodityId]               = NULL
    ,[intSourceEntityId]            = NULL
    ,[ysnRebuild]                   = NULL
FROM @Payments P
INNER JOIN @AROverpayment OP ON P.[intTransactionId] = OP.[intId]
WHERE P.[intTransactionDetailId] IS NULL
 AND (P.[dblBaseUnappliedAmount] <> @ZeroDecimal OR P.[dblUnappliedAmount] <> @ZeroDecimal)

UNION ALL

--PREPAYMENTS
SELECT
     [dtmDate]                      = P.[dtmDatePaid]
    ,[strBatchId]                   = P.[strBatchId]
    ,[intAccountId]                 = P.[intSalesAdvAcct]
    ,[dblDebit]                     = @ZeroDecimal
    ,[dblCredit]                    = P.[dblBaseAmountPaid]
    ,[dblDebitUnit]                 = @ZeroDecimal
    ,[dblCreditUnit]                = @ZeroDecimal
    ,[strDescription]               = 'Prepayment for ' + P.strTransactionId
    ,[strCode]                      = @CODE
    ,[strReference]                 = P.[strCustomerNumber]
    ,[intCurrencyId]                = P.[intCurrencyId]
    ,[dblExchangeRate]              = ISNULL(P.[dblExchangeRate], 1)
    ,[dtmDateEntered]               = P.[dtmPostDate]
    ,[dtmTransactionDate]           = P.[dtmDatePaid]
    ,[strJournalLineDescription]    = @POSTDESC + @SCREEN_NAME 
    ,[intJournalLineNo]             = P.[intTransactionId]
    ,[ysnIsUnposted]                = 0
    ,[intUserId]                    = P.[intUserId]
    ,[intEntityId]                  = P.[intEntityId]
    ,[strTransactionId]             = P.[strTransactionId]
    ,[intTransactionId]             = P.[intTransactionId]
    ,[strTransactionType]           = @SCREEN_NAME
    ,[strTransactionForm]           = @SCREEN_NAME
    ,[strModuleName]                = @MODULE_NAME
    ,[intConcurrencyId]             = 1
    ,[dblDebitForeign]              = @ZeroDecimal
    ,[dblDebitReport]               = @ZeroDecimal
    ,[dblCreditForeign]             = P.[dblAmountPaid]
    ,[dblCreditReport]              = P.[dblBaseAmountPaid]
    ,[dblReportingRate]             = P.[dblExchangeRate]
    ,[dblForeignRate]               = P.[dblExchangeRate]
    ,[strRateType]                  = P.[strRateType]
    ,[strDocument]                  = NULL
    ,[strComments]                  = NULL
    ,[strSourceDocumentId]          = NULL
    ,[intSourceLocationId]          = NULL
    ,[intSourceUOMId]               = NULL
    ,[dblSourceUnitDebit]           = NULL
    ,[dblSourceUnitCredit]          = NULL
    ,[intCommodityId]               = NULL
    ,[intSourceEntityId]            = NULL
    ,[ysnRebuild]                   = NULL
FROM @Payments P
INNER JOIN @ARPrepayment OP ON P.[intTransactionId] = OP.[intId]
WHERE P.[intTransactionDetailId] IS NULL
 AND (P.[dblAmountPaid] <> @ZeroDecimal OR P.[dblBaseAmountPaid] <> @ZeroDecimal)

UNION ALL

--DEBIT DISCOUNT
SELECT
     [dtmDate]                      = P.[dtmDatePaid]
    ,[strBatchId]                   = P.[strBatchId]
    ,[intAccountId]                 = P.[intDiscountAccount]
    ,[dblDebit]                     = P.[dblBaseDiscount]
    ,[dblCredit]                    = @ZeroDecimal
    ,[dblDebitUnit]                 = @ZeroDecimal
    ,[dblCreditUnit]                = @ZeroDecimal
    ,[strDescription]               = 'Discount for ' + P.strTransactionNumber
    ,[strCode]                      = @CODE
    ,[strReference]                 = P.[strCustomerNumber]
    ,[intCurrencyId]                = P.[intCurrencyId]
    ,[dblExchangeRate]              = ISNULL(P.[dblCurrencyExchangeRate], 1)
    ,[dtmDateEntered]               = P.[dtmPostDate]
    ,[dtmTransactionDate]           = P.[dtmDatePaid]
    ,[strJournalLineDescription]    = @POSTDESC + @SCREEN_NAME 
    ,[intJournalLineNo]             = P.[intTransactionDetailId]
    ,[ysnIsUnposted]                = 0
    ,[intUserId]                    = P.[intUserId]
    ,[intEntityId]                  = P.[intEntityId]
    ,[strTransactionId]             = P.[strTransactionId]
    ,[intTransactionId]             = P.[intTransactionId]
    ,[strTransactionType]           = @SCREEN_NAME
    ,[strTransactionForm]           = @SCREEN_NAME
    ,[strModuleName]                = @MODULE_NAME
    ,[intConcurrencyId]             = 1
    ,[dblDebitForeign]              = P.[dblDiscount]
    ,[dblDebitReport]               = P.[dblBaseDiscount]
    ,[dblCreditForeign]             = @ZeroDecimal
    ,[dblCreditReport]              = @ZeroDecimal
    ,[dblReportingRate]             = P.[dblCurrencyExchangeRate]
    ,[dblForeignRate]               = P.[dblCurrencyExchangeRate]
    ,[strRateType]                  = P.[strRateType]
    ,[strDocument]                  = NULL
    ,[strComments]                  = NULL
    ,[strSourceDocumentId]          = NULL
    ,[intSourceLocationId]          = NULL
    ,[intSourceUOMId]               = NULL
    ,[dblSourceUnitDebit]           = NULL
    ,[dblSourceUnitCredit]          = NULL
    ,[intCommodityId]               = NULL
    ,[intSourceEntityId]            = NULL
    ,[ysnRebuild]                   = NULL
FROM @Payments P
WHERE P.[intTransactionDetailId] IS NOT NULL
  AND P.[strTransactionType] <> 'Claim'
  AND ((P.[dblDiscount] <> @ZeroDecimal AND P.[dblAmountDue] = @ZeroDecimal)
		OR
	  (P.[dblBaseDiscount] <> @ZeroDecimal AND P.[dblBaseAmountDue] = @ZeroDecimal))

UNION ALL

--DEBIT INTEREST
SELECT
     [dtmDate]                      = P.[dtmDatePaid]
    ,[strBatchId]                   = P.[strBatchId]
    ,[intAccountId]                 = P.[intARAccountId]
    ,[dblDebit]                     = P.[dblBaseInterest]
    ,[dblCredit]                    = @ZeroDecimal
    ,[dblDebitUnit]                 = @ZeroDecimal
    ,[dblCreditUnit]                = @ZeroDecimal
    ,[strDescription]               = 'Interest for ' + P.strTransactionNumber
    ,[strCode]                      = @CODE
    ,[strReference]                 = P.[strCustomerNumber]
    ,[intCurrencyId]                = P.[intCurrencyId]
    ,[dblExchangeRate]              = ISNULL(P.[dblCurrencyExchangeRate], 1)
    ,[dtmDateEntered]               = P.[dtmPostDate]
    ,[dtmTransactionDate]           = P.[dtmDatePaid]
    ,[strJournalLineDescription]    = @POSTDESC + @SCREEN_NAME 
    ,[intJournalLineNo]             = P.[intTransactionDetailId]
    ,[ysnIsUnposted]                = 0
    ,[intUserId]                    = P.[intUserId]
    ,[intEntityId]                  = P.[intEntityId]
    ,[strTransactionId]             = P.[strTransactionId]
    ,[intTransactionId]             = P.[intTransactionId]
    ,[strTransactionType]           = @SCREEN_NAME
    ,[strTransactionForm]           = @SCREEN_NAME
    ,[strModuleName]                = @MODULE_NAME
    ,[intConcurrencyId]             = 1
    ,[dblDebitForeign]              = P.[dblInterest]
    ,[dblDebitReport]               = P.[dblBaseInterest]
    ,[dblCreditForeign]             = @ZeroDecimal
    ,[dblCreditReport]              = @ZeroDecimal
    ,[dblReportingRate]             = P.[dblCurrencyExchangeRate]
    ,[dblForeignRate]               = P.[dblCurrencyExchangeRate]
    ,[strRateType]                  = P.[strRateType]
    ,[strDocument]                  = NULL
    ,[strComments]                  = NULL
    ,[strSourceDocumentId]          = NULL
    ,[intSourceLocationId]          = NULL
    ,[intSourceUOMId]               = NULL
    ,[dblSourceUnitDebit]           = NULL
    ,[dblSourceUnitCredit]          = NULL
    ,[intCommodityId]               = NULL
    ,[intSourceEntityId]            = NULL
    ,[ysnRebuild]                   = NULL
FROM @Payments P
WHERE P.[intTransactionDetailId] IS NOT NULL
  AND P.[strTransactionType] <> 'Claim'
  AND ((P.[dblInterest] <> @ZeroDecimal AND P.[dblPayment] = @ZeroDecimal AND P.[dblAmountDue] = @ZeroDecimal)
		OR
	  (P.[dblBaseInterest] <> @ZeroDecimal AND P.[dblBasePayment] = @ZeroDecimal AND P.[dblBaseAmountDue] = @ZeroDecimal))

UNION ALL

--CREDIT PAYMENT DETAILS
SELECT
     [dtmDate]                      = P.[dtmDatePaid]
    ,[strBatchId]                   = P.[strBatchId]
    ,[intAccountId]                 = P.[intTransactionAccountId]
    ,[dblDebit]                     = @ZeroDecimal
    ,[dblCredit]                    = (P.[dblBasePayment] - ISNULL(GL.[dblGainLossAmount], @ZeroDecimal)) * (CASE WHEN ISNULL(P.[ysnInvoicePrepayment],0) = 1 THEN -1 ELSE 1 END)
    ,[dblDebitUnit]                 = @ZeroDecimal
    ,[dblCreditUnit]                = @ZeroDecimal
    ,[strDescription]               = 'Payment for ' + P.strTransactionNumber
    ,[strCode]                      = @CODE
    ,[strReference]                 = P.[strCustomerNumber]
    ,[intCurrencyId]                = P.[intCurrencyId]
    ,[dblExchangeRate]              = ISNULL(P.[dblCurrencyExchangeRate], 1)
    ,[dtmDateEntered]               = P.[dtmPostDate]
    ,[dtmTransactionDate]           = P.[dtmDatePaid]
    ,[strJournalLineDescription]    = @POSTDESC + @SCREEN_NAME 
    ,[intJournalLineNo]             = P.[intTransactionDetailId]
    ,[ysnIsUnposted]                = 0
    ,[intUserId]                    = P.[intUserId]
    ,[intEntityId]                  = P.[intEntityId]
    ,[strTransactionId]             = P.[strTransactionId]
    ,[intTransactionId]             = P.[intTransactionId]
    ,[strTransactionType]           = @SCREEN_NAME
    ,[strTransactionForm]           = @SCREEN_NAME
    ,[strModuleName]                = @MODULE_NAME
    ,[intConcurrencyId]             = 1
    ,[dblDebitForeign]              = @ZeroDecimal
    ,[dblDebitReport]               = @ZeroDecimal
    ,[dblCreditForeign]             = P.[dblPayment] * (CASE WHEN ISNULL(P.[ysnInvoicePrepayment],0) = 1 THEN -1 ELSE 1 END)
    ,[dblCreditReport]              = (P.[dblBasePayment] - ISNULL(GL.[dblGainLossAmount], @ZeroDecimal)) * (CASE WHEN ISNULL(P.[ysnInvoicePrepayment],0) = 1 THEN -1 ELSE 1 END)
    ,[dblReportingRate]             = P.[dblCurrencyExchangeRate]
    ,[dblForeignRate]               = P.[dblCurrencyExchangeRate]
    ,[strRateType]                  = P.[strRateType]
    ,[strDocument]                  = NULL
    ,[strComments]                  = NULL
    ,[strSourceDocumentId]          = NULL
    ,[intSourceLocationId]          = NULL
    ,[intSourceUOMId]               = NULL
    ,[dblSourceUnitDebit]           = NULL
    ,[dblSourceUnitCredit]          = NULL
    ,[intCommodityId]               = NULL
    ,[intSourceEntityId]            = NULL
    ,[ysnRebuild]                   = NULL
FROM @Payments P
LEFT OUTER JOIN (
	SELECT [dblGainLossAmount]        = SUM((ISNULL((P.[dblBasePayment] - (((ISNULL(P.[dblBaseTransactionAmountDue], @ZeroDecimal) + ISNULL(P.[dblBaseInterest], @ZeroDecimal)) - ISNULL(P.[dblBaseDiscount], @ZeroDecimal) * [dbo].[fnARGetInvoiceAmountMultiplier](P.[strTransactionType])))), @ZeroDecimal)))
		 , [intTransactionDetailId]   = P.[intTransactionDetailId]
	FROM @Payments P
	WHERE P.[intTransactionDetailId] IS NOT NULL
		AND P.[strTransactionType] <> 'Claim'
		AND ((ISNULL(((((ISNULL(P.[dblBaseTransactionAmountDue], @ZeroDecimal) + ISNULL(P.[dblBaseInterest], @ZeroDecimal)) - ISNULL(P.[dblBaseDiscount], @ZeroDecimal) * [dbo].[fnARGetInvoiceAmountMultiplier](P.[strTransactionType]))) - P.[dblBasePayment]),0)))  <> @ZeroDecimal
				AND ((P.[dblTransactionAmountDue] + P.[dblInterest]) - P.[dblDiscount]) = ((P.[dblPayment] - P.[dblInterest]) + P.[dblDiscount])
	GROUP BY P.[intTransactionDetailId]
) GL ON P.[intTransactionDetailId] = GL.[intTransactionDetailId]
WHERE P.[intTransactionDetailId] IS NOT NULL
  AND P.[strTransactionType] <> 'Claim'
  AND (P.[dblPayment] <> @ZeroDecimal OR P.[dblBasePayment] <> @ZeroDecimal)

UNION ALL

--GAIN/LOSS
SELECT
     [dtmDate]                      = P.[dtmDatePaid]
    ,[strBatchId]                   = P.[strBatchId]
    ,[intAccountId]                 = P.[intGainLossAccount]
    ,[dblDebit]                     = CASE WHEN (ISNULL((( P.[dblBasePayment] - ((ISNULL(P.[dblBaseTransactionAmountDue], @ZeroDecimal) + ISNULL(P.[dblBaseInterest], @ZeroDecimal)) - ISNULL(P.[dblBaseDiscount], @ZeroDecimal) * [dbo].[fnARGetInvoiceAmountMultiplier](P.[strTransactionType])))),@ZeroDecimal)) > @ZeroDecimal THEN @ZeroDecimal ELSE ABS((ISNULL((P.[dblBasePayment] - (((ISNULL(P.[dblBaseTransactionAmountDue], @ZeroDecimal) + ISNULL(P.[dblBaseInterest], @ZeroDecimal)) - ISNULL(P.[dblBaseDiscount], @ZeroDecimal) * [dbo].[fnARGetInvoiceAmountMultiplier](P.[strTransactionType])))), @ZeroDecimal))) END
    ,[dblCredit]                    = CASE WHEN (ISNULL(( P.[dblBasePayment] - (((ISNULL(P.[dblBaseTransactionAmountDue], @ZeroDecimal) + ISNULL(P.[dblBaseInterest], @ZeroDecimal)) - ISNULL(P.[dblBaseDiscount], @ZeroDecimal) * [dbo].[fnARGetInvoiceAmountMultiplier](P.[strTransactionType])))),@ZeroDecimal)) > @ZeroDecimal THEN ABS((ISNULL((P.[dblBasePayment] - (((ISNULL(P.[dblBaseTransactionAmountDue], @ZeroDecimal) + ISNULL(P.[dblBaseInterest], @ZeroDecimal)) - ISNULL(P.[dblBaseDiscount], @ZeroDecimal) * [dbo].[fnARGetInvoiceAmountMultiplier](P.[strTransactionType])))),@ZeroDecimal))) ELSE @ZeroDecimal END
    ,[dblDebitUnit]                 = @ZeroDecimal
    ,[dblCreditUnit]                = @ZeroDecimal
    ,[strDescription]               = 'Payment for ' + P.strTransactionNumber
    ,[strCode]                      = @CODE
    ,[strReference]                 = P.[strCustomerNumber]
    ,[intCurrencyId]                = P.[intCurrencyId]
    ,[dblExchangeRate]              = ISNULL(P.[dblCurrencyExchangeRate], 1)
    ,[dtmDateEntered]               = P.[dtmPostDate]
    ,[dtmTransactionDate]           = P.[dtmDatePaid]
    ,[strJournalLineDescription]    = @POSTDESC + @SCREEN_NAME 
    ,[intJournalLineNo]             = P.[intTransactionDetailId]
    ,[ysnIsUnposted]                = 0
    ,[intUserId]                    = P.[intUserId]
    ,[intEntityId]                  = P.[intEntityId]
    ,[strTransactionId]             = P.[strTransactionId]
    ,[intTransactionId]             = P.[intTransactionId]
    ,[strTransactionType]           = @SCREEN_NAME
    ,[strTransactionForm]           = @SCREEN_NAME
    ,[strModuleName]                = @MODULE_NAME
    ,[intConcurrencyId]             = 1
    ,[dblDebitForeign]              = @ZeroDecimal
    ,[dblDebitReport]               = CASE WHEN (ISNULL((( P.[dblBasePayment] - ((ISNULL(P.[dblBaseTransactionAmountDue], @ZeroDecimal) + ISNULL(P.[dblBaseInterest], @ZeroDecimal)) - ISNULL(P.[dblBaseDiscount], @ZeroDecimal) * [dbo].[fnARGetInvoiceAmountMultiplier](P.[strTransactionType])))),@ZeroDecimal)) > @ZeroDecimal THEN @ZeroDecimal ELSE ABS((ISNULL((P.[dblBasePayment] - (((ISNULL(P.[dblBaseTransactionAmountDue], @ZeroDecimal) + ISNULL(P.[dblBaseInterest], @ZeroDecimal)) - ISNULL(P.[dblBaseDiscount], @ZeroDecimal) * [dbo].[fnARGetInvoiceAmountMultiplier](P.[strTransactionType])))), @ZeroDecimal))) END
    ,[dblCreditForeign]             = @ZeroDecimal
    ,[dblCreditReport]              = CASE WHEN (ISNULL(( P.[dblBasePayment] - (((ISNULL(P.[dblBaseTransactionAmountDue], @ZeroDecimal) + ISNULL(P.[dblBaseInterest], @ZeroDecimal)) - ISNULL(P.[dblBaseDiscount], @ZeroDecimal) * [dbo].[fnARGetInvoiceAmountMultiplier](P.[strTransactionType])))),@ZeroDecimal)) > @ZeroDecimal THEN ABS((ISNULL((P.[dblBasePayment] - (((ISNULL(P.[dblBaseTransactionAmountDue], @ZeroDecimal) + ISNULL(P.[dblBaseInterest], @ZeroDecimal)) - ISNULL(P.[dblBaseDiscount], @ZeroDecimal) * [dbo].[fnARGetInvoiceAmountMultiplier](P.[strTransactionType])))),@ZeroDecimal))) ELSE @ZeroDecimal END
    ,[dblReportingRate]             = P.[dblCurrencyExchangeRate]
    ,[dblForeignRate]               = P.[dblCurrencyExchangeRate]
    ,[strRateType]                  = P.[strRateType]
    ,[strDocument]                  = NULL
    ,[strComments]                  = NULL
    ,[strSourceDocumentId]          = NULL
    ,[intSourceLocationId]          = NULL
    ,[intSourceUOMId]               = NULL
    ,[dblSourceUnitDebit]           = NULL
    ,[dblSourceUnitCredit]          = NULL
    ,[intCommodityId]               = NULL
    ,[intSourceEntityId]            = NULL
    ,[ysnRebuild]                   = NULL
FROM @Payments P
WHERE P.[intTransactionDetailId] IS NOT NULL
  AND P.[strTransactionType] <> 'Claim'
  AND ((ISNULL(((((ISNULL(P.[dblBaseTransactionAmountDue], @ZeroDecimal) + ISNULL(P.[dblBaseInterest], @ZeroDecimal)) - ISNULL(P.[dblBaseDiscount], @ZeroDecimal) * [dbo].[fnARGetInvoiceAmountMultiplier](P.[strTransactionType]))) - P.[dblBasePayment]),0)))  <> @ZeroDecimal
			AND ((P.[dblTransactionAmountDue] + P.[dblInterest]) - P.[dblDiscount]) = ((P.[dblPayment] - P.[dblInterest]) + P.[dblDiscount])

UNION ALL

--CREDIT DISCOUNT
SELECT
     [dtmDate]                      = P.[dtmDatePaid]
    ,[strBatchId]                   = P.[strBatchId]
    ,[intAccountId]                 = P.[intARAccountId]
    ,[dblDebit]                     = @ZeroDecimal
    ,[dblCredit]                    = P.[dblBaseDiscount]
    ,[dblDebitUnit]                 = @ZeroDecimal
    ,[dblCreditUnit]                = @ZeroDecimal
    ,[strDescription]               = 'Discount for ' + P.strTransactionNumber
    ,[strCode]                      = @CODE
    ,[strReference]                 = P.[strCustomerNumber]
    ,[intCurrencyId]                = P.[intCurrencyId]
    ,[dblExchangeRate]              = ISNULL(P.[dblCurrencyExchangeRate], 1)
    ,[dtmDateEntered]               = P.[dtmPostDate]
    ,[dtmTransactionDate]           = P.[dtmDatePaid]
    ,[strJournalLineDescription]    = @POSTDESC + @SCREEN_NAME 
    ,[intJournalLineNo]             = P.[intTransactionDetailId]
    ,[ysnIsUnposted]                = 0
    ,[intUserId]                    = P.[intUserId]
    ,[intEntityId]                  = P.[intEntityId]
    ,[strTransactionId]             = P.[strTransactionId]
    ,[intTransactionId]             = P.[intTransactionId]
    ,[strTransactionType]           = @SCREEN_NAME
    ,[strTransactionForm]           = @SCREEN_NAME
    ,[strModuleName]                = @MODULE_NAME
    ,[intConcurrencyId]             = 1
    ,[dblDebitForeign]              = @ZeroDecimal
    ,[dblDebitReport]               = @ZeroDecimal
    ,[dblCreditForeign]             = P.[dblDiscount]
    ,[dblCreditReport]              = P.[dblBaseDiscount]
    ,[dblReportingRate]             = P.[dblCurrencyExchangeRate]
    ,[dblForeignRate]               = P.[dblCurrencyExchangeRate]
    ,[strRateType]                  = P.[strRateType]
    ,[strDocument]                  = NULL
    ,[strComments]                  = NULL
    ,[strSourceDocumentId]          = NULL
    ,[intSourceLocationId]          = NULL
    ,[intSourceUOMId]               = NULL
    ,[dblSourceUnitDebit]           = NULL
    ,[dblSourceUnitCredit]          = NULL
    ,[intCommodityId]               = NULL
    ,[intSourceEntityId]            = NULL
    ,[ysnRebuild]                   = NULL
FROM @Payments P
WHERE P.[intTransactionDetailId] IS NOT NULL
  AND P.[strTransactionType] <> 'Claim'
  AND ((P.[dblDiscount] <> @ZeroDecimal AND P.[dblAmountDue] = @ZeroDecimal)
		OR
	  (P.[dblBaseDiscount] <> @ZeroDecimal AND P.[dblBaseAmountDue] = @ZeroDecimal))

UNION ALL

--CREDIT INTEREST
SELECT
     [dtmDate]                      = P.[dtmDatePaid]
    ,[strBatchId]                   = P.[strBatchId]
    ,[intAccountId]                 = P.[intInterestAccount]
    ,[dblDebit]                     = @ZeroDecimal
    ,[dblCredit]                    = P.[dblBaseInterest]
    ,[dblDebitUnit]                 = @ZeroDecimal
    ,[dblCreditUnit]                = @ZeroDecimal
    ,[strDescription]               = 'Interest for ' + P.strTransactionNumber
    ,[strCode]                      = @CODE
    ,[strReference]                 = P.[strCustomerNumber]
    ,[intCurrencyId]                = P.[intCurrencyId]
    ,[dblExchangeRate]              = ISNULL(P.[dblCurrencyExchangeRate], 1)
    ,[dtmDateEntered]               = P.[dtmPostDate]
    ,[dtmTransactionDate]           = P.[dtmDatePaid]
    ,[strJournalLineDescription]    = @POSTDESC + @SCREEN_NAME 
    ,[intJournalLineNo]             = P.[intTransactionDetailId]
    ,[ysnIsUnposted]                = 0
    ,[intUserId]                    = P.[intUserId]
    ,[intEntityId]                  = P.[intEntityId]
    ,[strTransactionId]             = P.[strTransactionId]
    ,[intTransactionId]             = P.[intTransactionId]
    ,[strTransactionType]           = @SCREEN_NAME
    ,[strTransactionForm]           = @SCREEN_NAME
    ,[strModuleName]                = @MODULE_NAME
    ,[intConcurrencyId]             = 1
    ,[dblDebitForeign]              = @ZeroDecimal
    ,[dblDebitReport]               = @ZeroDecimal
    ,[dblCreditForeign]             = P.[dblInterest]
    ,[dblCreditReport]              = P.[dblBaseInterest]
    ,[dblReportingRate]             = P.[dblCurrencyExchangeRate]
    ,[dblForeignRate]               = P.[dblCurrencyExchangeRate]
    ,[strRateType]                  = P.[strRateType]
    ,[strDocument]                  = NULL
    ,[strComments]                  = NULL
    ,[strSourceDocumentId]          = NULL
    ,[intSourceLocationId]          = NULL
    ,[intSourceUOMId]               = NULL
    ,[dblSourceUnitDebit]           = NULL
    ,[dblSourceUnitCredit]          = NULL
    ,[intCommodityId]               = NULL
    ,[intSourceEntityId]            = NULL
    ,[ysnRebuild]                   = NULL
FROM @Payments P
WHERE P.[intTransactionDetailId] IS NOT NULL
  AND P.[strTransactionType] <> 'Claim'
  AND ((P.[dblInterest] <> @ZeroDecimal AND P.[dblPayment] = @ZeroDecimal AND P.[dblAmountDue] = @ZeroDecimal)
		OR
        (P.[dblBaseInterest] <> @ZeroDecimal AND P.[dblBasePayment] = @ZeroDecimal AND P.[dblBaseAmountDue] = @ZeroDecimal))


RETURN
END
