CREATE PROCEDURE [dbo].[uspARGenerateGLEntriesForInvoices]

AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET ANSI_WARNINGS OFF

DECLARE @ZeroDecimal DECIMAL(18,6)
SET @ZeroDecimal = 0.000000
DECLARE @OneDecimal DECIMAL(18,6)
SET @OneDecimal = 1.000000
DECLARE @OneHundredDecimal DECIMAL(18,6)
SET @OneHundredDecimal = 100.000000

DECLARE @PostDate AS DATETIME
SET @PostDate = GETDATE()

DECLARE @MODULE_NAME NVARCHAR(25) = 'Accounts Receivable'
DECLARE @SCREEN_NAME NVARCHAR(25) = 'Invoice'
DECLARE @CODE NVARCHAR(25) = 'AR'
DECLARE @POSTDESC NVARCHAR(10) = 'Posted '

--REVERSE PROVISIONAL INVOICE
INSERT INTO ##ARInvoiceGLEntries (
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
    ,[strDocument]
    ,[strComments]
    ,[strSourceDocumentId]
    ,[intSourceLocationId]
    ,[intSourceUOMId]
    ,[dblSourceUnitDebit]
    ,[dblSourceUnitCredit]
    ,[intCommodityId]
    ,[intSourceEntityId])
SELECT 
     [dtmDate]						= CAST(ISNULL(P.[dtmPostDate], P.[dtmDate]) AS DATE)
    ,[strBatchId]					= P.[strBatchId]
    ,[intAccountId]					= GL.[intAccountId]
    ,[dblDebit]						= GL.[dblCredit]
    ,[dblCredit]					= GL.[dblDebit]
    ,[dblDebitUnit]					= GL.[dblCreditUnit]
    ,[dblCreditUnit]				= GL.[dblDebitUnit]
    ,[strDescription]				= 'Reverse Provisional Invoice' + ISNULL((' - ' + GL.strDescription), '')
    ,[strCode]						= @CODE
    ,[strReference]					= GL.[strReference]
    ,[intCurrencyId]				= GL.[intCurrencyId]
    ,[dblExchangeRate]				= GL.[dblExchangeRate]
    ,[dtmDateEntered]				= P.[dtmDatePosted]
    ,[dtmTransactionDate]			= P.[dtmDate]
    ,[strJournalLineDescription]	= GL.[strJournalLineDescription]
    ,[intJournalLineNo]				= P.[intOriginalInvoiceId]
    ,[ysnIsUnposted]				= 0
    ,[intUserId]					= P.[intUserId]
    ,[intEntityId]					= P.[intUserId]
    ,[strTransactionId]				= P.[strInvoiceNumber]
    ,[intTransactionId]				= P.[intInvoiceId]
    ,[strTransactionType]			= P.[strTransactionType]
    ,[strTransactionForm]			= @SCREEN_NAME
    ,[strModuleName]				= @MODULE_NAME
    ,[intConcurrencyId]				= 1
    ,[dblDebitForeign]				= GL.[dblCreditForeign]
    ,[dblDebitReport]				= GL.[dblCreditReport]
    ,[dblCreditForeign]				= GL.[dblDebitForeign]
    ,[dblCreditReport]				= GL.[dblDebitReport]
    ,[dblReportingRate]				= GL.[dblReportingRate]
    ,[dblForeignRate]				= GL.[dblForeignRate]
    ,[strDocument]					= GL.[strDocument]
    ,[strComments]					= GL.[strComments]
    ,[strSourceDocumentId]			= GL.[strSourceDocumentId]
    ,[intSourceLocationId]			= GL.[intSourceLocationId]
    ,[intSourceUOMId]				= GL.[intSourceUOMId]
    ,[dblSourceUnitDebit]			= GL.[dblSourceUnitCredit]
    ,[dblSourceUnitCredit]			= GL.[dblSourceUnitDebit]
    ,[intCommodityId]				= GL.[intCommodityId]
    ,[intSourceEntityId]			= GL.[intSourceEntityId]
FROM (
    SELECT [intOriginalInvoiceId]
        ,[strBatchId]
        ,[intInvoiceId]
        ,[dtmPostDate]
        ,[dtmDate]
        ,[dtmDatePosted]
        ,[strInvoiceNumber]
        ,[strTransactionType]
        ,[strInvoiceOriginId]
        ,[intUserId]
    FROM ##ARPostInvoiceHeader
    WHERE [intOriginalInvoiceId] IS NOT NULL
      AND [ysnFromProvisional] = 1
      AND [ysnProvisionalWithGL] = 1 
      AND [ysnPost] = 1
      AND (
            ([strTransactionType] <> 'Credit Memo'	AND [dblBaseInvoiceTotal] = 0.000000 AND [dblInvoiceTotal] = 0.000000)
            OR
            ([strTransactionType] IN ('Credit Memo', 'Invoice') AND [dblBaseInvoiceTotal] <> 0.000000 AND [dblProvisionalAmount] <> 0.000000)
            )
) P
INNER JOIN (
    SELECT [intAccountId]
        ,[intGLDetailId]
        ,[intTransactionId]
        ,[strTransactionId]
        ,[dblCredit]
        ,[dblDebit]
        ,[dblCreditUnit]
        ,[dblDebitUnit]
        ,[strReference]
        ,[strDescription]
        ,[strJournalLineDescription]
        ,[intCurrencyId]
        ,[dblExchangeRate]
        ,[dblCreditForeign]
        ,[dblCreditReport]
        ,[dblDebitForeign]
        ,[dblDebitReport]
        ,[dblReportingRate]
        ,[dblForeignRate]
        ,[strDocument]
        ,[strComments]
        ,[strSourceDocumentId]
        ,[intSourceLocationId]
        ,[intSourceUOMId]
        ,[dblSourceUnitDebit]
        ,[dblSourceUnitCredit]
        ,[intCommodityId]
        ,[intSourceEntityId]
    FROM tblGLDetail WITH (NOLOCK)
    WHERE [ysnIsUnposted] = 0
      AND [strModuleName] = @MODULE_NAME
) GL ON P.[intOriginalInvoiceId] = GL.[intTransactionId]
    AND P.[strInvoiceOriginId] = GL.[strTransactionId]
ORDER BY GL.intGLDetailId	

--NORMAL INVOICES
INSERT ##ARInvoiceGLEntries
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
     [dtmDate]                      = CAST(ISNULL(I.[dtmPostDate], I.[dtmDate]) AS DATE)
    ,[strBatchId]                   = I.[strBatchId]
    ,[intAccountId]                 = I.[intAccountId]
    ,[dblDebit]                     = CASE WHEN I.[strTransactionType] NOT IN ('Credit Memo', 'Overpayment', 'Credit', 'Customer Prepayment', 'Cash Refund') THEN I.[dblBaseInvoiceTotal] ELSE @ZeroDecimal END
    ,[dblCredit]                    = CASE WHEN I.[strTransactionType] IN ('Credit Memo', 'Overpayment', 'Credit', 'Customer Prepayment', 'Cash Refund') THEN I.[dblBaseInvoiceTotal] ELSE @ZeroDecimal END
    ,[dblDebitUnit]                 = CASE WHEN I.[strTransactionType] NOT IN ('Credit Memo', 'Overpayment', 'Credit', 'Customer Prepayment', 'Cash Refund') THEN ARID.[dblUnitQtyShipped] ELSE @ZeroDecimal END
    ,[dblCreditUnit]                = CASE WHEN I.[strTransactionType] IN ('Credit Memo', 'Overpayment', 'Credit', 'Customer Prepayment', 'Cash Refund') THEN ARID.[dblUnitQtyShipped] ELSE @ZeroDecimal END
    ,[strDescription]               = I.[strDescription]
    ,[strCode]                      = @CODE
    ,[strReference]                 = I.[strCustomerNumber]
    ,[intCurrencyId]                = I.[intCurrencyId]
    ,[dblExchangeRate]              = I.[dblAverageExchangeRate]
    ,[dtmDateEntered]               = @PostDate
    ,[dtmTransactionDate]           = I.[dtmDate]
    ,[strJournalLineDescription]    = @POSTDESC + I.[strTransactionType]
    ,[intJournalLineNo]             = I.[intInvoiceId]
    ,[ysnIsUnposted]                = 0
    ,[intUserId]                    = I.[intUserId]
    ,[intEntityId]                  = I.[intEntityId]
    ,[strTransactionId]             = I.[strInvoiceNumber]
    ,[intTransactionId]             = I.[intInvoiceId]
    ,[strTransactionType]           = I.[strTransactionType]
    ,[strTransactionForm]           = @SCREEN_NAME
    ,[strModuleName]                = @MODULE_NAME
    ,[intConcurrencyId]             = 1
    ,[dblDebitForeign]              = CASE WHEN I.[strTransactionType] NOT IN ('Credit Memo', 'Overpayment', 'Credit', 'Customer Prepayment', 'Cash Refund') THEN I.[dblInvoiceTotal] ELSE @ZeroDecimal END
    ,[dblDebitReport]               = CASE WHEN I.[strTransactionType] NOT IN ('Credit Memo', 'Overpayment', 'Credit', 'Customer Prepayment', 'Cash Refund') THEN I.[dblInvoiceTotal] ELSE @ZeroDecimal END
    ,[dblCreditForeign]             = CASE WHEN I.[strTransactionType] IN ('Credit Memo', 'Overpayment', 'Credit', 'Customer Prepayment', 'Cash Refund') THEN I.[dblInvoiceTotal] ELSE @ZeroDecimal END
    ,[dblCreditReport]              = CASE WHEN I.[strTransactionType] IN ('Credit Memo', 'Overpayment', 'Credit', 'Customer Prepayment', 'Cash Refund') THEN I.[dblInvoiceTotal] ELSE @ZeroDecimal END
    ,[dblReportingRate]             = I.[dblAverageExchangeRate]
    ,[dblForeignRate]               = I.[dblAverageExchangeRate]
    ,[strRateType]                  = NULL
    ,[strDocument]                  = NULL
    ,[strComments]                  = NULL
    ,[strSourceDocumentId]          = NULL
    ,[intSourceLocationId]          = NULL
    ,[intSourceUOMId]               = NULL
    ,[dblSourceUnitDebit]           = NULL
    ,[dblSourceUnitCredit]          = NULL
    ,[intCommodityId]               = NULL
    ,[intSourceEntityId]            = I.[intEntityCustomerId]
    ,[ysnRebuild]                   = NULL
FROM
    ##ARPostInvoiceHeader I
LEFT OUTER JOIN
    (
    SELECT
         [dblUnitQtyShipped]		= SUM([dblUnitQtyShipped])		
        ,[intInvoiceId]				= [intInvoiceId]
    FROM
        ##ARPostInvoiceDetail
    GROUP BY
        [intInvoiceId]
    ) ARID
        ON I.[intInvoiceId] = ARID.[intInvoiceId]
WHERE
    I.[intPeriodsToAccrue] <= 1
    AND I.[ysnFromProvisional] = 0
    AND
        (
        I.[dblInvoiceTotal] <> @ZeroDecimal
        OR
        EXISTS(SELECT NULL FROM ##ARPostInvoiceDetail ARID WHERE ARID.[intItemId] IS NOT NULL AND ARID.[strItemType] <> 'Comment' AND ARID.intInvoiceId  = I.[intInvoiceId])
        )

--PROVISIONAL INVOICES
INSERT ##ARInvoiceGLEntries
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
     [dtmDate]                      = CAST(ISNULL(I.[dtmPostDate], I.[dtmDate]) AS DATE)
    ,[strBatchId]                   = I.[strBatchId]
    ,[intAccountId]                 = I.[intAccountId]
    ,[dblDebit]                     = CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN I.[dblBaseInvoiceTotal] ELSE @ZeroDecimal END
    ,[dblCredit]                    = CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN @ZeroDecimal ELSE I.[dblBaseInvoiceTotal] END
    ,[dblDebitUnit]                 = ARID.[dblUnitQtyShipped]
    ,[dblCreditUnit]                = @ZeroDecimal
    ,[strDescription]               = I.[strDescription]
    ,[strCode]                      = @CODE
    ,[strReference]                 = I.[strCustomerNumber]
    ,[intCurrencyId]                = I.[intCurrencyId]
    ,[dblExchangeRate]              = I.[dblAverageExchangeRate]
    ,[dtmDateEntered]               = I.[dtmDatePosted]
    ,[dtmTransactionDate]           = I.[dtmDate]
    ,[strJournalLineDescription]    = 'Provisional Amount'
    ,[intJournalLineNo]             = I.[intInvoiceId]
    ,[ysnIsUnposted]                = 0
    ,[intUserId]                    = I.[intUserId]
    ,[intEntityId]                  = I.[intEntityId]
    ,[strTransactionId]             = I.[strInvoiceNumber]
    ,[intTransactionId]             = I.[intInvoiceId]
    ,[strTransactionType]           = I.[strTransactionType]
    ,[strTransactionForm]           = @SCREEN_NAME
    ,[strModuleName]                = @MODULE_NAME
    ,[intConcurrencyId]             = 1
    ,[dblDebitForeign]              = CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN I.[dblInvoiceTotal] ELSE @ZeroDecimal END
    ,[dblDebitReport]               = CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN I.[dblInvoiceTotal] ELSE @ZeroDecimal END
    ,[dblCreditForeign]             = CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN @ZeroDecimal ELSE I.[dblInvoiceTotal] END
    ,[dblCreditReport]              = CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN @ZeroDecimal ELSE I.[dblInvoiceTotal] END
    ,[dblReportingRate]             = I.[dblAverageExchangeRate]
    ,[dblForeignRate]               = I.[dblAverageExchangeRate]
    ,[strRateType]                  = NULL
    ,[strDocument]                  = NULL
    ,[strComments]                  = NULL
    ,[strSourceDocumentId]          = NULL
    ,[intSourceLocationId]          = NULL
    ,[intSourceUOMId]               = NULL
    ,[dblSourceUnitDebit]           = NULL
    ,[dblSourceUnitCredit]          = NULL
    ,[intCommodityId]               = NULL
    ,[intSourceEntityId]            = I.[intEntityCustomerId]
    ,[ysnRebuild]                   = NULL
FROM
    ##ARPostInvoiceHeader I
LEFT OUTER JOIN
    (
    SELECT
         [dblUnitQtyShipped]		= SUM([dblUnitQtyShipped])
        ,[intInvoiceId]				= [intInvoiceId]
    FROM
        ##ARPostInvoiceDetail
    GROUP BY
        [intInvoiceId]
    ) ARID
        ON I.[intInvoiceId] = ARID.[intInvoiceId]
WHERE
    I.[intPeriodsToAccrue] <= 1
    AND I.[ysnFromProvisional] = 1
	AND I.[dblInvoiceTotal] <> @ZeroDecimal

--APPLIED CREDIT/PREPAIDS
INSERT ##ARInvoiceGLEntries
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
    [dtmDate]                      = CAST(ISNULL(I.[dtmPostDate], I.[dtmDate]) AS DATE)
   ,[strBatchId]                   = I.[strBatchId]
   ,[intAccountId]                 = ARPAC.[intAccountId]
   ,[dblDebit]                     = CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN ARPAC.[dblBaseAppliedInvoiceDetailAmount] ELSE @ZeroDecimal END
   ,[dblCredit]                    = CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN @ZeroDecimal ELSE ARPAC.[dblBaseAppliedInvoiceDetailAmount] END
   ,[dblDebitUnit]                 = @ZeroDecimal
   ,[dblCreditUnit]                = @ZeroDecimal
   ,[strDescription]               = I.[strDescription]
   ,[strCode]                      = @CODE
   ,[strReference]                 = I.[strCustomerNumber]
   ,[intCurrencyId]                = I.[intCurrencyId]
   ,[dblExchangeRate]              = I.[dblAverageExchangeRate]
   ,[dtmDateEntered]               = I.[dtmDatePosted]
   ,[dtmTransactionDate]           = I.[dtmDate]
   ,[strJournalLineDescription]    = 'Applied Prepaid - ' + ARPAC.[strInvoiceNumber]
   ,[intJournalLineNo]             = ARPAC.[intPrepaidAndCreditId]
   ,[ysnIsUnposted]                = 0
   ,[intUserId]                    = I.[intUserId]
   ,[intEntityId]                  = I.[intEntityId]
   ,[strTransactionId]             = I.[strInvoiceNumber]
   ,[intTransactionId]             = I.[intInvoiceId]
   ,[strTransactionType]           = I.[strTransactionType]
   ,[strTransactionForm]           = @SCREEN_NAME
   ,[strModuleName]                = @MODULE_NAME
   ,[intConcurrencyId]             = 1
   ,[dblDebitForeign]              = CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN ARPAC.[dblAppliedInvoiceDetailAmount] ELSE @ZeroDecimal END
   ,[dblDebitReport]               = CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN ARPAC.[dblAppliedInvoiceDetailAmount] ELSE @ZeroDecimal END
   ,[dblCreditForeign]             = CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN @ZeroDecimal ELSE ARPAC.[dblAppliedInvoiceDetailAmount] END
   ,[dblCreditReport]              = CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN @ZeroDecimal ELSE ARPAC.[dblAppliedInvoiceDetailAmount] END
   ,[dblReportingRate]             = I.[dblAverageExchangeRate]
   ,[dblForeignRate]               = I.[dblAverageExchangeRate]
   ,[strRateType]                  = NULL
   ,[strDocument]                  = NULL
   ,[strComments]                  = NULL
   ,[strSourceDocumentId]          = NULL
   ,[intSourceLocationId]          = NULL
   ,[intSourceUOMId]               = NULL
   ,[dblSourceUnitDebit]           = NULL
   ,[dblSourceUnitCredit]          = NULL
   ,[intCommodityId]               = NULL
   ,[intSourceEntityId]            = I.[intEntityCustomerId]
   ,[ysnRebuild]                   = NULL
FROM
   (
   SELECT
        I.[strInvoiceNumber]
       ,PPC.[intInvoiceId]
       ,I.[intAccountId]
       ,[intPrepaidAndCreditId]
       ,[intPrepaymentId]
       ,[ysnApplied]
       ,[dblAppliedInvoiceDetailAmount]
       ,[dblBaseAppliedInvoiceDetailAmount]
   FROM
       tblARPrepaidAndCredit PPC WITH (NOLOCK)
   INNER JOIN
       tblARInvoice I
           ON I.intInvoiceId = PPC.intPrepaymentId
   ) ARPAC
INNER JOIN
   ##ARPostInvoiceHeader I
       ON ARPAC.[intInvoiceId] = I.[intInvoiceId]
       AND ISNULL(ARPAC.[ysnApplied],0) = 1 
       AND ARPAC.[dblAppliedInvoiceDetailAmount] <> @ZeroDecimal
       AND I.strTransactionType = 'Cash Refund'
WHERE
   I.[intPeriodsToAccrue] <= 1

--CASH TRANSACTION TYPE
INSERT ##ARInvoiceGLEntries
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
     [dtmDate]                      = CAST(ISNULL(I.[dtmPostDate], I.[dtmDate]) AS DATE)
    ,[strBatchId]                   = I.[strBatchId]
    ,[intAccountId]                 = I.[intUndepositedFundsId]
    ,[dblDebit]                     = CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN I.[dblBasePayment] ELSE @ZeroDecimal END
    ,[dblCredit]                    = CASE WHEN I.[ysnIsInvoicePositive] = 0 THEN I.[dblBasePayment] ELSE @ZeroDecimal END
    ,[dblDebitUnit]                 = @ZeroDecimal
    ,[dblCreditUnit]                = @ZeroDecimal
    ,[strDescription]               = I.[strDescription]
    ,[strCode]                      = @CODE
    ,[strReference]                 = I.[strCustomerNumber]
    ,[intCurrencyId]                = I.[intCurrencyId]
    ,[dblExchangeRate]              = I.[dblAverageExchangeRate]
    ,[dtmDateEntered]               = I.[dtmDatePosted]
    ,[dtmTransactionDate]           = I.[dtmDate]
    ,[strJournalLineDescription]    = @POSTDESC + I.[strTransactionType]
    ,[intJournalLineNo]             = I.[intInvoiceId]
    ,[ysnIsUnposted]                = 0
    ,[intUserId]                    = I.[intUserId]
    ,[intEntityId]                  = I.[intEntityId]
    ,[strTransactionId]             = I.[strInvoiceNumber]
    ,[intTransactionId]             = I.[intInvoiceId]
    ,[strTransactionType]           = I.[strTransactionType]
    ,[strTransactionForm]           = @SCREEN_NAME
    ,[strModuleName]                = @MODULE_NAME
    ,[intConcurrencyId]             = 1
    ,[dblDebitForeign]              = CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN I.[dblPayment] ELSE @ZeroDecimal END
    ,[dblDebitReport]               = CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN I.[dblPayment] ELSE @ZeroDecimal END
    ,[dblCreditForeign]             = CASE WHEN I.[ysnIsInvoicePositive] = 0 THEN I.[dblPayment] ELSE @ZeroDecimal END
    ,[dblCreditReport]              = CASE WHEN I.[ysnIsInvoicePositive] = 0 THEN I.[dblPayment] ELSE @ZeroDecimal END
    ,[dblReportingRate]             = I.[dblAverageExchangeRate]
    ,[dblForeignRate]               = I.[dblAverageExchangeRate]
    ,[strRateType]                  = NULL
    ,[strDocument]                  = NULL
    ,[strComments]                  = NULL
    ,[strSourceDocumentId]          = NULL
    ,[intSourceLocationId]          = NULL
    ,[intSourceUOMId]               = NULL
    ,[dblSourceUnitDebit]           = NULL
    ,[dblSourceUnitCredit]          = NULL
    ,[intCommodityId]               = NULL
    ,[intSourceEntityId]            = I.[intEntityCustomerId]
    ,[ysnRebuild]                   = NULL
FROM
    ##ARPostInvoiceHeader I
WHERE
    I.[intPeriodsToAccrue] <= 1
    AND I.[dblPayment] <> @ZeroDecimal

--SALES ACCOUNT 
INSERT ##ARInvoiceGLEntries
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
     [dtmDate]                      = CAST(ISNULL(I.[dtmPostDate], I.[dtmDate]) AS DATE)
    ,[strBatchId]                   = I.[strBatchId]
    ,[intAccountId]                 = I.[intItemAccountId]
    ,[dblDebit]                     = CASE WHEN I.strTransactionType IN ('Invoice', 'Cash') OR (I.strTransactionType = 'Debit Memo' AND I.strType IN ('CF Tran', 'CF Invoice', 'Card Fueling Transaction')) THEN @ZeroDecimal ELSE I.[dblBaseLineItemGLAmount] END
    ,[dblCredit]                    = CASE WHEN I.strTransactionType IN ('Invoice', 'Cash') OR (I.strTransactionType = 'Debit Memo' AND I.strType IN ('CF Tran', 'CF Invoice', 'Card Fueling Transaction')) THEN I.[dblBaseLineItemGLAmount] ELSE @ZeroDecimal END
    ,[dblDebitUnit]                 = CASE WHEN I.strTransactionType IN ('Invoice', 'Cash') OR (I.strTransactionType = 'Debit Memo' AND I.strType IN ('CF Tran', 'CF Invoice', 'Card Fueling Transaction')) THEN @ZeroDecimal ELSE I.[dblUnitQtyShipped] END
    ,[dblCreditUnit]                = CASE WHEN I.strTransactionType IN ('Invoice', 'Cash') OR (I.strTransactionType = 'Debit Memo' AND I.strType IN ('CF Tran', 'CF Invoice', 'Card Fueling Transaction')) THEN I.[dblUnitQtyShipped] ELSE @ZeroDecimal END
    ,[strDescription]               = I.[strDescription]
    ,[strCode]                      = @CODE
    ,[strReference]                 = I.[strCustomerNumber]
    ,[intCurrencyId]                = I.[intCurrencyId]
    ,[dblExchangeRate]              = I.[dblCurrencyExchangeRate]
    ,[dtmDateEntered]               = I.[dtmDatePosted]
    ,[dtmTransactionDate]           = I.[dtmDate]
    ,[strJournalLineDescription]    = I.[strItemDescription]
    ,[intJournalLineNo]             = I.[intInvoiceDetailId]
    ,[ysnIsUnposted]                = 0
    ,[intUserId]                    = I.[intUserId]
    ,[intEntityId]                  = I.[intEntityId]
    ,[strTransactionId]             = I.[strInvoiceNumber]
    ,[intTransactionId]             = I.[intInvoiceId]
    ,[strTransactionType]           = I.[strTransactionType]
    ,[strTransactionForm]           = @SCREEN_NAME
    ,[strModuleName]                = @MODULE_NAME
    ,[intConcurrencyId]             = 1
    ,[dblDebitForeign]              = CASE WHEN I.strTransactionType IN ('Invoice', 'Cash') OR (I.strTransactionType = 'Debit Memo' AND I.strType IN ('CF Tran', 'CF Invoice', 'Card Fueling Transaction')) THEN @ZeroDecimal ELSE I.[dblLineItemGLAmount] END
    ,[dblDebitReport]               = CASE WHEN I.strTransactionType IN ('Invoice', 'Cash') OR (I.strTransactionType = 'Debit Memo' AND I.strType IN ('CF Tran', 'CF Invoice', 'Card Fueling Transaction')) THEN @ZeroDecimal ELSE I.[dblLineItemGLAmount] END
    ,[dblCreditForeign]             = CASE WHEN I.strTransactionType IN ('Invoice', 'Cash') OR (I.strTransactionType = 'Debit Memo' AND I.strType IN ('CF Tran', 'CF Invoice', 'Card Fueling Transaction')) THEN I.[dblLineItemGLAmount] ELSE @ZeroDecimal END
    ,[dblCreditReport]              = CASE WHEN I.strTransactionType IN ('Invoice', 'Cash') OR (I.strTransactionType = 'Debit Memo' AND I.strType IN ('CF Tran', 'CF Invoice', 'Card Fueling Transaction')) THEN I.[dblLineItemGLAmount] ELSE @ZeroDecimal END
    ,[dblReportingRate]             = I.[dblCurrencyExchangeRate]
    ,[dblForeignRate]               = I.[dblCurrencyExchangeRate]
    ,[strRateType]                  = I.[strCurrencyExchangeRateType]
    ,[strDocument]                  = NULL
    ,[strComments]                  = NULL
    ,[strSourceDocumentId]          = NULL
    ,[intSourceLocationId]          = NULL
    ,[intSourceUOMId]               = NULL
    ,[dblSourceUnitDebit]           = NULL
    ,[dblSourceUnitCredit]          = NULL
    ,[intCommodityId]               = NULL
    ,[intSourceEntityId]            = I.[intEntityCustomerId]
    ,[ysnRebuild]                   = NULL
FROM ##ARPostInvoiceDetail I
WHERE I.[intPeriodsToAccrue] <= 1
    AND (
        (	I.[intItemId] IS NULL 
			AND
			(I.[strTransactionType] <> 'Debit Memo' OR (I.strTransactionType = 'Debit Memo' AND I.ysnFromProvisional = 0))
		)
        OR
        (
            I.[intItemId] IS NOT NULL
            AND
            (I.[strTransactionType] <> 'Debit Memo' OR (I.strTransactionType = 'Debit Memo' AND I.ysnFromProvisional = 0) OR (I.strTransactionType = 'Credit Memo' AND I.ysnFromProvisional = 1))
			AND 
			I.[strItemType] IN ('Non-Inventory','Service','Other Charge')
        )		
    )
    AND (I.[dblTotal] <> @ZeroDecimal OR I.[dblQtyShipped] <> @ZeroDecimal)
    AND I.[strTransactionType] NOT IN ('Debit Memo', 'Cash Refund')

--SOFTWARE LICENSE DEBIT
INSERT ##ARInvoiceGLEntries
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
     [dtmDate]                      = CAST(ISNULL(I.[dtmPostDate], I.[dtmDate]) AS DATE)
    ,[strBatchId]                   = I.[strBatchId]
    ,[intAccountId]                 = I.[intLicenseAccountId]
    ,[dblDebit]                     = CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN @ZeroDecimal ELSE I.[dblBaseLicenseGLAmount] END
    ,[dblCredit]                    = CASE WHEN I.[ysnIsInvoicePositive] = 0 THEN @ZeroDecimal ELSE I.[dblBaseLicenseGLAmount] END
    ,[dblDebitUnit]                 = CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN @ZeroDecimal ELSE I.[dblUnitQtyShipped] END
    ,[dblCreditUnit]                = CASE WHEN I.[ysnIsInvoicePositive] = 0 THEN @ZeroDecimal ELSE I.[dblUnitQtyShipped] END
    ,[strDescription]               = I.[strDescription]
    ,[strCode]                      = @CODE
    ,[strReference]                 = I.[strCustomerNumber]
    ,[intCurrencyId]                = I.[intCurrencyId]
    ,[dblExchangeRate]              = I.[dblCurrencyExchangeRate]
    ,[dtmDateEntered]               = I.[dtmDatePosted]
    ,[dtmTransactionDate]           = I.[dtmDate]
    ,[strJournalLineDescription]    = I.[strItemDescription]
    ,[intJournalLineNo]             = I.[intInvoiceDetailId]
    ,[ysnIsUnposted]                = 0
    ,[intUserId]                    = I.[intUserId]
    ,[intEntityId]                  = I.[intEntityId]
    ,[strTransactionId]             = I.[strInvoiceNumber]
    ,[intTransactionId]             = I.[intInvoiceId]
    ,[strTransactionType]           = I.[strTransactionType]
    ,[strTransactionForm]           = @SCREEN_NAME
    ,[strModuleName]                = @MODULE_NAME
    ,[intConcurrencyId]             = 1
    ,[dblDebitForeign]              = CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN @ZeroDecimal ELSE I.[dblLicenseGLAmount] END
    ,[dblDebitReport]               = CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN @ZeroDecimal ELSE I.[dblLicenseGLAmount] END
    ,[dblCreditForeign]             = CASE WHEN I.[ysnIsInvoicePositive] = 0 THEN @ZeroDecimal ELSE I.[dblLicenseGLAmount] END
    ,[dblCreditReport]              = CASE WHEN I.[ysnIsInvoicePositive] = 0 THEN @ZeroDecimal ELSE I.[dblLicenseGLAmount] END
    ,[dblReportingRate]             = I.[dblCurrencyExchangeRate]
    ,[dblForeignRate]               = I.[dblCurrencyExchangeRate]
    ,[strRateType]                  = I.[strCurrencyExchangeRateType]
    ,[strDocument]                  = NULL
    ,[strComments]                  = NULL
    ,[strSourceDocumentId]          = NULL
    ,[intSourceLocationId]          = NULL
    ,[intSourceUOMId]               = NULL
    ,[dblSourceUnitDebit]           = NULL
    ,[dblSourceUnitCredit]          = NULL
    ,[intCommodityId]               = NULL
    ,[intSourceEntityId]            = I.[intEntityCustomerId]
    ,[ysnRebuild]                   = NULL
FROM
    ##ARPostInvoiceDetail I
WHERE
    I.[dblLicenseAmount] <> @ZeroDecimal
    AND I.[strMaintenanceType] IN ('License/Maintenance', 'License Only')
    AND I.[strItemType] = 'Software'
    AND I.[strTransactionType] NOT IN ('Cash Refund', 'Debit Memo')
    AND (
        I.[intPeriodsToAccrue] <= 1
        OR
        (
            I.[intPeriodsToAccrue] > 1
            AND
            I.[ysnAccrueLicense] = 0
        )		
        )

--SOFTWARE LICENSE CREDIT
INSERT ##ARInvoiceGLEntries
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
     [dtmDate]                      = CAST(ISNULL(I.[dtmPostDate], I.[dtmDate]) AS DATE)
    ,[strBatchId]                   = I.[strBatchId]
    ,[intAccountId]                 = I.[intDeferredRevenueAccountId]
    ,[dblDebit]                     = CASE WHEN I.[ysnIsInvoicePositive] = 0 THEN @ZeroDecimal ELSE I.[dblBaseLicenseGLAmount] END
    ,[dblCredit]                    = CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN @ZeroDecimal ELSE I.[dblBaseLicenseGLAmount] END
    ,[dblDebitUnit]                 = CASE WHEN I.[ysnIsInvoicePositive] = 0 THEN @ZeroDecimal ELSE I.[dblUnitQtyShipped] END
    ,[dblCreditUnit]                = CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN @ZeroDecimal ELSE I.[dblUnitQtyShipped] END
    ,[strDescription]               = I.[strDescription]
    ,[strCode]                      = @CODE
    ,[strReference]                 = I.[strCustomerNumber]
    ,[intCurrencyId]                = I.[intCurrencyId]
    ,[dblExchangeRate]              = I.[dblCurrencyExchangeRate]
    ,[dtmDateEntered]               = I.[dtmDatePosted]
    ,[dtmTransactionDate]           = I.[dtmDate]
    ,[strJournalLineDescription]    = I.[strItemDescription]
    ,[intJournalLineNo]             = I.[intInvoiceDetailId]
    ,[ysnIsUnposted]                = 0
    ,[intUserId]                    = I.[intUserId]
    ,[intEntityId]                  = I.[intEntityId]
    ,[strTransactionId]             = I.[strInvoiceNumber]
    ,[intTransactionId]             = I.[intInvoiceId]
    ,[strTransactionType]           = I.[strTransactionType]
    ,[strTransactionForm]           = @SCREEN_NAME
    ,[strModuleName]                = @MODULE_NAME
    ,[intConcurrencyId]             = 1
    ,[dblDebitForeign]              = CASE WHEN I.[ysnIsInvoicePositive] = 0 THEN @ZeroDecimal ELSE I.[dblLicenseGLAmount] END
    ,[dblDebitReport]               = CASE WHEN I.[ysnIsInvoicePositive] = 0 THEN @ZeroDecimal ELSE I.[dblLicenseGLAmount] END
    ,[dblCreditForeign]             = CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN @ZeroDecimal ELSE I.[dblLicenseGLAmount] END
    ,[dblCreditReport]              = CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN @ZeroDecimal ELSE I.[dblLicenseGLAmount] END
    ,[dblReportingRate]             = I.[dblCurrencyExchangeRate]
    ,[dblForeignRate]               = I.[dblCurrencyExchangeRate]
    ,[strRateType]                  = I.[strCurrencyExchangeRateType]
    ,[strDocument]                  = NULL
    ,[strComments]                  = NULL
    ,[strSourceDocumentId]          = NULL
    ,[intSourceLocationId]          = NULL
    ,[intSourceUOMId]               = NULL
    ,[dblSourceUnitDebit]           = NULL
    ,[dblSourceUnitCredit]          = NULL
    ,[intCommodityId]               = NULL
    ,[intSourceEntityId]            = I.[intEntityCustomerId]
    ,[ysnRebuild]                   = NULL
FROM
    ##ARPostInvoiceDetail I
WHERE
    I.[intPeriodsToAccrue] > 1
    AND I.[dblLicenseAmount] <> @ZeroDecimal
    AND I.[strMaintenanceType] IN ('License/Maintenance', 'License Only')
    AND I.[strItemType] = 'Software'
    AND I.[strTransactionType] NOT IN ('Cash Refund', 'Debit Memo')
    AND I.[ysnAccrueLicense] = 0

--SOFTWARE MAINTENANCE/SAAS DEBIT
INSERT ##ARInvoiceGLEntries
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
     [dtmDate]                      = CAST(ISNULL(I.[dtmPostDate], I.[dtmDate]) AS DATE)
    ,[strBatchId]                   = I.[strBatchId]
    ,[intAccountId]                 = I.[intMaintenanceAccountId]
    ,[dblDebit]                     = CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN @ZeroDecimal ELSE I.[dblBaseMaintenanceGLAmount] END
    ,[dblCredit]                    = CASE WHEN I.[ysnIsInvoicePositive] = 0 THEN @ZeroDecimal ELSE I.[dblBaseMaintenanceGLAmount] END
    ,[dblDebitUnit]                 = CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN @ZeroDecimal ELSE I.[dblUnitQtyShipped] END
    ,[dblCreditUnit]                = CASE WHEN I.[ysnIsInvoicePositive] = 0 THEN @ZeroDecimal ELSE I.[dblUnitQtyShipped] END
    ,[strDescription]               = I.[strDescription]
    ,[strCode]                      = @CODE
    ,[strReference]                 = I.[strCustomerNumber]
    ,[intCurrencyId]                = I.[intCurrencyId]
    ,[dblExchangeRate]              = I.[dblCurrencyExchangeRate]
    ,[dtmDateEntered]               = I.[dtmDatePosted]
    ,[dtmTransactionDate]           = I.[dtmDate]
    ,[strJournalLineDescription]    = I.[strItemDescription]
    ,[intJournalLineNo]             = I.[intInvoiceDetailId]
    ,[ysnIsUnposted]                = 0
    ,[intUserId]                    = I.[intUserId]
    ,[intEntityId]                  = I.[intEntityId]
    ,[strTransactionId]             = I.[strInvoiceNumber]
    ,[intTransactionId]             = I.[intInvoiceId]
    ,[strTransactionType]           = I.[strTransactionType]
    ,[strTransactionForm]           = @SCREEN_NAME
    ,[strModuleName]                = @MODULE_NAME
    ,[intConcurrencyId]             = 1
    ,[dblDebitForeign]              = CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN @ZeroDecimal ELSE I.[dblMaintenanceGLAmount] END
    ,[dblDebitReport]               = CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN @ZeroDecimal ELSE I.[dblMaintenanceGLAmount] END
    ,[dblCreditForeign]             = CASE WHEN I.[ysnIsInvoicePositive] = 0 THEN @ZeroDecimal ELSE I.[dblMaintenanceGLAmount] END
    ,[dblCreditReport]              = CASE WHEN I.[ysnIsInvoicePositive] = 0 THEN @ZeroDecimal ELSE I.[dblMaintenanceGLAmount] END
    ,[dblReportingRate]             = I.[dblCurrencyExchangeRate]
    ,[dblForeignRate]               = I.[dblCurrencyExchangeRate]
    ,[strRateType]                  = I.[strCurrencyExchangeRateType]
    ,[strDocument]                  = NULL
    ,[strComments]                  = NULL
    ,[strSourceDocumentId]          = NULL
    ,[intSourceLocationId]          = NULL
    ,[intSourceUOMId]               = NULL
    ,[dblSourceUnitDebit]           = NULL
    ,[dblSourceUnitCredit]          = NULL
    ,[intCommodityId]               = NULL
    ,[intSourceEntityId]            = I.[intEntityCustomerId]
    ,[ysnRebuild]                   = NULL
FROM
    ##ARPostInvoiceDetail I
WHERE
    I.[intPeriodsToAccrue] <= 1
    AND I.[dblMaintenanceAmount] <> @ZeroDecimal
    AND I.[strMaintenanceType] IN ('License/Maintenance', 'Maintenance Only', 'SaaS')
    AND I.[strItemType] = 'Software'
    AND I.[strTransactionType] NOT IN ('Cash Refund', 'Debit Memo')

--SOFTWARE MAINTENANCE/SAAS CREDIT
INSERT ##ARInvoiceGLEntries
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
     [dtmDate]                      = CAST(ISNULL(I.[dtmPostDate], I.[dtmDate]) AS DATE)
    ,[strBatchId]                   = I.[strBatchId]
    ,[intAccountId]                 = I.[intSalesAccountId]
    ,[dblDebit]                     = CASE WHEN I.[strTransactionType] IN ('Invoice', 'Cash') THEN @ZeroDecimal ELSE I.[dblBaseLineItemGLAmount] END
    ,[dblCredit]                    = CASE WHEN I.[strTransactionType] IN ('Invoice', 'Cash') THEN I.[dblBaseLineItemGLAmount] ELSE @ZeroDecimal END
    ,[dblDebitUnit]                 = CASE WHEN I.[strTransactionType] IN ('Invoice', 'Cash') THEN @ZeroDecimal ELSE I.[dblUnitQtyShipped] END
    ,[dblCreditUnit]                = CASE WHEN I.[strTransactionType] IN ('Invoice', 'Cash') THEN I.[dblUnitQtyShipped] ELSE @ZeroDecimal END
    ,[strDescription]               = I.[strDescription]
    ,[strCode]                      = @CODE
    ,[strReference]                 = I.[strCustomerNumber]
    ,[intCurrencyId]                = I.[intCurrencyId]
    ,[dblExchangeRate]              = I.[dblCurrencyExchangeRate]
    ,[dtmDateEntered]               = I.[dtmDatePosted]
    ,[dtmTransactionDate]           = I.[dtmDate]
    ,[strJournalLineDescription]    = I.[strItemDescription]
    ,[intJournalLineNo]             = I.[intInvoiceDetailId]
    ,[ysnIsUnposted]                = 0
    ,[intUserId]                    = I.[intUserId]
    ,[intEntityId]                  = I.[intEntityId]
    ,[strTransactionId]             = I.[strInvoiceNumber]
    ,[intTransactionId]             = I.[intInvoiceId]
    ,[strTransactionType]           = I.[strTransactionType]
    ,[strTransactionForm]           = @SCREEN_NAME
    ,[strModuleName]                = @MODULE_NAME
    ,[intConcurrencyId]             = 1
    ,[dblDebitForeign]              = CASE WHEN I.[strTransactionType] IN ('Invoice', 'Cash') THEN @ZeroDecimal ELSE I.[dblLineItemGLAmount] END
    ,[dblDebitReport]               = CASE WHEN I.[strTransactionType] IN ('Invoice', 'Cash') THEN @ZeroDecimal ELSE I.[dblLineItemGLAmount] END
    ,[dblCreditForeign]             = CASE WHEN I.[strTransactionType] IN ('Invoice', 'Cash') THEN I.[dblLineItemGLAmount] ELSE @ZeroDecimal END
    ,[dblCreditReport]              = CASE WHEN I.[strTransactionType] IN ('Invoice', 'Cash') THEN I.[dblLineItemGLAmount] ELSE @ZeroDecimal END
    ,[dblReportingRate]             = I.[dblCurrencyExchangeRate]
    ,[dblForeignRate]               = I.[dblCurrencyExchangeRate]
    ,[strRateType]                  = I.[strCurrencyExchangeRateType]
    ,[strDocument]                  = NULL
    ,[strComments]                  = NULL
    ,[strSourceDocumentId]          = NULL
    ,[intSourceLocationId]          = NULL
    ,[intSourceUOMId]               = NULL
    ,[dblSourceUnitDebit]           = NULL
    ,[dblSourceUnitCredit]          = NULL
    ,[intCommodityId]               = NULL
    ,[intSourceEntityId]            = I.[intEntityCustomerId]
    ,[ysnRebuild]                   = NULL
FROM
    ##ARPostInvoiceDetail I
WHERE
    I.[intPeriodsToAccrue] <= 1
	AND I.[ysnFromProvisional] = 0
    AND I.[intItemId] IS NOT NULL
    AND I.[strItemType] NOT IN ('Non-Inventory','Service','Other Charge','Software','Comment')
    AND I.[strTransactionType] NOT IN ('Cash Refund', 'Debit Memo')
    AND (
        I.[dblQtyShipped] <> @ZeroDecimal
        OR
	    (I.[dblQtyShipped] = @ZeroDecimal AND I.[dblInvoiceTotal] = @ZeroDecimal)
        )

--FINAL INVOICE CREDIT
INSERT ##ARInvoiceGLEntries
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
     [dtmDate]                      = CAST(ISNULL(I.[dtmPostDate], I.[dtmDate]) AS DATE)
    ,[strBatchId]                   = I.[strBatchId]
    ,[intAccountId]                 = I.[intSalesAccountId]
    ,[dblDebit]                     = CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN @ZeroDecimal ELSE I.[dblBaseLineItemGLAmount] END
    ,[dblCredit]                    = CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN I.[dblBaseLineItemGLAmount] ELSE @ZeroDecimal END
    ,[dblDebitUnit]                 = @ZeroDecimal
    ,[dblCreditUnit]                = I.[dblUnitQtyShipped]
    ,[strDescription]               = I.[strDescription]
    ,[strCode]                      = @CODE
    ,[strReference]                 = I.[strCustomerNumber]
    ,[intCurrencyId]                = I.[intCurrencyId]
    ,[dblExchangeRate]              = I.[dblCurrencyExchangeRate]
    ,[dtmDateEntered]               = I.[dtmDatePosted]
    ,[dtmTransactionDate]           = I.[dtmDate]
    ,[strJournalLineDescription]    = I.[strItemDescription]
    ,[intJournalLineNo]             = I.[intInvoiceDetailId]
    ,[ysnIsUnposted]                = 0
    ,[intUserId]                    = I.[intUserId]
    ,[intEntityId]                  = I.[intEntityId]
    ,[strTransactionId]             = I.[strInvoiceNumber]
    ,[intTransactionId]             = I.[intInvoiceId]
    ,[strTransactionType]           = I.[strTransactionType]
    ,[strTransactionForm]           = @SCREEN_NAME
    ,[strModuleName]                = @MODULE_NAME
    ,[intConcurrencyId]             = 1
    ,[dblDebitForeign]              = CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN @ZeroDecimal ELSE I.[dblLineItemGLAmount] END
    ,[dblDebitReport]               = CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN @ZeroDecimal ELSE I.[dblLineItemGLAmount] END
    ,[dblCreditForeign]             = CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN I.[dblLineItemGLAmount] ELSE @ZeroDecimal END
    ,[dblCreditReport]              = CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN I.[dblLineItemGLAmount] ELSE @ZeroDecimal END
    ,[dblReportingRate]             = I.[dblCurrencyExchangeRate]
    ,[dblForeignRate]               = I.[dblCurrencyExchangeRate]
    ,[strRateType]                  = I.[strCurrencyExchangeRateType]
    ,[strDocument]                  = NULL
    ,[strComments]                  = NULL
    ,[strSourceDocumentId]          = NULL
    ,[intSourceLocationId]          = NULL
    ,[intSourceUOMId]               = NULL
    ,[dblSourceUnitDebit]           = NULL
    ,[dblSourceUnitCredit]          = NULL
    ,[intCommodityId]               = NULL
    ,[intSourceEntityId]            = I.[intEntityCustomerId]
    ,[ysnRebuild]                   = NULL
FROM
    ##ARPostInvoiceDetail I
WHERE
    I.[intPeriodsToAccrue] <= 1
	AND I.[ysnFromProvisional] = 1
	AND I.[dblBaseLineItemGLAmount] <> @ZeroDecimal
	--AND I.[dblProvisionalAmount] <> @ZeroDecimal
    AND I.[intItemId] IS NOT NULL
    AND I.[strItemType] NOT IN ('Non-Inventory','Service','Other Charge','Software','Comment')
    AND I.[strTransactionType] NOT IN ('Cash Refund', 'Debit Memo')

--FINAL INVOICES (DROP SHIP/ COGS)
INSERT ##ARInvoiceGLEntries
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
     [dtmDate]                      = CAST(ISNULL(I.[dtmPostDate], I.[dtmDate]) AS DATE)
    ,[strBatchId]                   = I.[strBatchId]
    ,[intAccountId]                 = ARID.[intAccountId]
    ,[dblDebit]                     = @ZeroDecimal
    ,[dblCredit]                    = ARID.[dblTotal]
    ,[dblDebitUnit]                 = @ZeroDecimal
    ,[dblCreditUnit]                = ARID.[dblUnitQtyShipped]
    ,[strDescription]               = I.[strDescription]
    ,[strCode]                      = @CODE
    ,[strReference]                 = I.[strCustomerNumber]
    ,[intCurrencyId]                = I.[intCurrencyId]
    ,[dblExchangeRate]              = I.[dblAverageExchangeRate]
    ,[dtmDateEntered]               = I.[dtmDatePosted]
    ,[dtmTransactionDate]           = I.[dtmDate]
    ,[strJournalLineDescription]    = 'Provisional Amount'
    ,[intJournalLineNo]             = I.[intInvoiceId]
    ,[ysnIsUnposted]                = 0
    ,[intUserId]                    = I.[intUserId]
    ,[intEntityId]                  = I.[intEntityId]
    ,[strTransactionId]             = I.[strInvoiceNumber]
    ,[intTransactionId]             = I.[intInvoiceId]
    ,[strTransactionType]           = I.[strTransactionType]
    ,[strTransactionForm]           = @SCREEN_NAME
    ,[strModuleName]                = @MODULE_NAME
    ,[intConcurrencyId]             = 1
    ,[dblDebitForeign]              = @ZeroDecimal
    ,[dblDebitReport]               = @ZeroDecimal
    ,[dblCreditForeign]             = ARID.[dblTotal]
    ,[dblCreditReport]              = ARID.[dblTotal]
    ,[dblReportingRate]             = I.[dblAverageExchangeRate]
    ,[dblForeignRate]               = I.[dblAverageExchangeRate]
    ,[strRateType]                  = NULL
    ,[strDocument]                  = NULL
    ,[strComments]                  = NULL
    ,[strSourceDocumentId]          = NULL
    ,[intSourceLocationId]          = NULL
    ,[intSourceUOMId]               = NULL
    ,[dblSourceUnitDebit]           = NULL
    ,[dblSourceUnitCredit]          = NULL
    ,[intCommodityId]               = NULL
    ,[intSourceEntityId]            = I.[intEntityCustomerId]
    ,[ysnRebuild]                   = NULL
FROM
    ##ARPostInvoiceHeader I
LEFT OUTER JOIN
    (
    SELECT
         [dblUnitQtyShipped]	= SUM(ISNULL(dbo.fnARCalculateQtyBetweenUOM(IDP.[intItemWeightUOMId], IDP.[intOrderUOMId], ID.[dblShipmentNetWt] - IDP.[dblShipmentNetWt], ICI.[intItemId], ICI.[strType]), @ZeroDecimal)) -- SUM(ISNULL([dblUnitQtyShipped], @ZeroDecimal) - ISNULL(dbo.fnARCalculateQtyBetweenUOM(IDP.[intItemUOMId], ICSUOM.[intItemUOMId], IDP.[dblQtyShipped], ICI.[intItemId], ICI.[strType]), @ZeroDecimal))
		,[dblTotal]				= SUM(ID.[dblTotal] - IDP.[dblTotal])
        ,[intInvoiceId]			= ID.[intInvoiceId]
		,[intSourceType]		= LG.[intSourceType]
		,[intAccountId]			= dbo.fnGetItemGLAccount(IDP.[intItemId], ICIL.[intItemLocationId], 'Cost of Goods')
    FROM
        ##ARPostInvoiceDetail ID
	INNER JOIN tblARInvoiceDetail IDP
	ON ID.intOriginalInvoiceDetailId = IDP.intInvoiceDetailId
	INNER JOIN tblARInvoice ARI
	ON ARI.intInvoiceId = IDP.intInvoiceId
	AND ID.[dblTotal] > IDP.[dblTotal]
	INNER JOIN (
		SELECT [intItemId], [strItemNo], [strType], [strManufactureType], [strDescription], [ysnAutoBlend], [intCategoryId] FROM tblICItem WITH(NOLOCK)
	) ICI ON IDP.[intItemId] = ICI.[intItemId]
	INNER JOIN (
        SELECT [intItemId], [intLocationId], [intItemLocationId], [intAllowNegativeInventory], [intSubLocationId] FROM tblICItemLocation WITH(NOLOCK)
	) ICIL ON ICI.[intItemId] = ICIL.[intItemId]
		  AND ARI.[intCompanyLocationId] = ICIL.[intLocationId]
	OUTER APPLY (
		SELECT TOP 1 [intItemId]
				   , [intItemUOMId] 
		FROM tblICItemUOM IUOM WITH(NOLOCK) 
		WHERE [ysnStockUnit] = 1
		  AND ICI.[intItemId] = IUOM.[intItemId]
	) ICSUOM 
	OUTER APPLY (
		SELECT TOP 1 L.intSourceType
		FROM tblLGLoadDetail LD WITH(NOLOCK) 
		INNER JOIN tblLGLoad L
		ON LD.intLoadId = L.intLoadId
		WHERE LD.intLoadDetailId = IDP.intLoadDetailId
	) LG
    GROUP BY
        ID.[intInvoiceId], LG.[intSourceType], IDP.[intItemId], ICIL.[intItemLocationId]
    ) ARID
        ON I.[intInvoiceId] = ARID.[intInvoiceId]
WHERE
    I.[intPeriodsToAccrue] <= 1
    AND I.[ysnFromProvisional] = 1
	AND I.[dblInvoiceTotal] <> @ZeroDecimal
	AND ARID.[dblTotal] > 0
	AND ARID.[intSourceType] = 4

--FINAL INVOICES (DROP SHIP / COGS)
INSERT ##ARInvoiceGLEntries
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
     [dtmDate]                      = CAST(ISNULL(I.[dtmPostDate], I.[dtmDate]) AS DATE)
    ,[strBatchId]                   = I.[strBatchId]
    ,[intAccountId]                 = ARID.[intAccountId]
    ,[dblDebit]                     = ARID.[dblTotal]
    ,[dblCredit]                    = @ZeroDecimal
    ,[dblDebitUnit]                 = ARID.[dblUnitQtyShipped]
    ,[dblCreditUnit]                = @ZeroDecimal
    ,[strDescription]               = I.[strDescription]
    ,[strCode]                      = @CODE
    ,[strReference]                 = I.[strCustomerNumber]
    ,[intCurrencyId]                = I.[intCurrencyId]
    ,[dblExchangeRate]              = I.[dblAverageExchangeRate]
    ,[dtmDateEntered]               = I.[dtmDatePosted]
    ,[dtmTransactionDate]           = I.[dtmDate]
    ,[strJournalLineDescription]    = 'Provisional Amount'
    ,[intJournalLineNo]             = I.[intInvoiceId]
    ,[ysnIsUnposted]                = 0
    ,[intUserId]                    = I.[intUserId]
    ,[intEntityId]                  = I.[intEntityId]
    ,[strTransactionId]             = I.[strInvoiceNumber]
    ,[intTransactionId]             = I.[intInvoiceId]
    ,[strTransactionType]           = I.[strTransactionType]
    ,[strTransactionForm]           = @SCREEN_NAME
    ,[strModuleName]                = @MODULE_NAME
    ,[intConcurrencyId]             = 1
    ,[dblDebitForeign]              = ARID.[dblTotal]
    ,[dblDebitReport]               = ARID.[dblTotal]
    ,[dblCreditForeign]             = @ZeroDecimal
    ,[dblCreditReport]              = @ZeroDecimal
    ,[dblReportingRate]             = I.[dblAverageExchangeRate]
    ,[dblForeignRate]               = I.[dblAverageExchangeRate]
    ,[strRateType]                  = NULL
    ,[strDocument]                  = NULL
    ,[strComments]                  = NULL
    ,[strSourceDocumentId]          = NULL
    ,[intSourceLocationId]          = NULL
    ,[intSourceUOMId]               = NULL
    ,[dblSourceUnitDebit]           = NULL
    ,[dblSourceUnitCredit]          = NULL
    ,[intCommodityId]               = NULL
    ,[intSourceEntityId]            = I.[intEntityCustomerId]
    ,[ysnRebuild]                   = NULL
FROM
    ##ARPostInvoiceHeader I
LEFT OUTER JOIN
    (
    SELECT
         [dblUnitQtyShipped]	= SUM(ISNULL(dbo.fnARCalculateQtyBetweenUOM(IDP.[intItemWeightUOMId], IDP.[intOrderUOMId], ID.[dblShipmentNetWt] - IDP.[dblShipmentNetWt], ICI.[intItemId], ICI.[strType]), @ZeroDecimal))
		,[dblTotal]				= SUM(ID.[dblTotal] - IDP.[dblTotal])
        ,[intInvoiceId]			= ID.[intInvoiceId]
		,[intSourceType]		= LG.[intSourceType]
		,[intAccountId]			= dbo.fnGetItemGLAccount(IDP.[intItemId], ICIL.[intItemLocationId], 'Cost of Goods')
    FROM
        ##ARPostInvoiceDetail ID
	INNER JOIN tblARInvoiceDetail IDP
	ON ID.intOriginalInvoiceDetailId = IDP.intInvoiceDetailId
	INNER JOIN tblARInvoice ARI
	ON ARI.intInvoiceId = IDP.intInvoiceId
	AND ID.[dblTotal] > IDP.[dblTotal]
	INNER JOIN (
		SELECT [intItemId], [strItemNo], [strType], [strManufactureType], [strDescription], [ysnAutoBlend], [intCategoryId] FROM tblICItem WITH(NOLOCK)
	) ICI ON IDP.[intItemId] = ICI.[intItemId]
	INNER JOIN (
        SELECT [intItemId], [intLocationId], [intItemLocationId], [intAllowNegativeInventory], [intSubLocationId] FROM tblICItemLocation WITH(NOLOCK)
	) ICIL ON ICI.[intItemId] = ICIL.[intItemId]
		  AND ARI.[intCompanyLocationId] = ICIL.[intLocationId]
	OUTER APPLY (
		SELECT TOP 1 [intItemId]
				   , [intItemUOMId] 
		FROM tblICItemUOM IUOM WITH(NOLOCK) 
		WHERE [ysnStockUnit] = 1
		  AND ICI.[intItemId] = IUOM.[intItemId]
	) ICSUOM 
	OUTER APPLY (
		SELECT TOP 1 L.intSourceType
		FROM tblLGLoadDetail LD WITH(NOLOCK) 
		INNER JOIN tblLGLoad L
		ON LD.intLoadId = L.intLoadId
		WHERE LD.intLoadDetailId = IDP.intLoadDetailId
	) LG
    GROUP BY
        ID.[intInvoiceId], LG.[intSourceType], IDP.[intItemId], ICIL.[intItemLocationId]
    ) ARID
        ON I.[intInvoiceId] = ARID.[intInvoiceId]
WHERE
    I.[intPeriodsToAccrue] <= 1
    AND I.[ysnFromProvisional] = 1
	AND I.[dblInvoiceTotal] <> @ZeroDecimal
	AND ARID.[dblTotal] > 0
	AND ARID.[intSourceType] = 4

--CarQuest Import (Inventory)
INSERT ##ARInvoiceGLEntries
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
     [dtmDate]                      = CAST(ISNULL(I.[dtmPostDate], I.[dtmDate]) AS DATE)
    ,[strBatchId]                   = I.[strBatchId]
    ,[intAccountId]                 = dbo.fnGetItemGLAccount(ARID.[intItemId], ICIL.[intItemLocationId], 'Inventory')
    ,[dblDebit]                     = @ZeroDecimal
    ,[dblCredit]                    = IM.[dblCOGSAmount]
    ,[dblDebitUnit]                 = @ZeroDecimal
    ,[dblCreditUnit]                = 1
    ,[strDescription]               = 'Inventory -' + ARID.[strDescription]
    ,[strCode]                      = @CODE
    ,[strReference]                 = I.[strCustomerNumber]
    ,[intCurrencyId]                = I.[intCurrencyId]
    ,[dblExchangeRate]              = I.[dblAverageExchangeRate]
    ,[dtmDateEntered]               = I.[dtmDatePosted]
    ,[dtmTransactionDate]           = I.[dtmDate]
    ,[strJournalLineDescription]    = 'CarQuest Import'
    ,[intJournalLineNo]             = I.[intInvoiceId]
    ,[ysnIsUnposted]                = 0
    ,[intUserId]                    = I.[intUserId]
    ,[intEntityId]                  = I.[intEntityId]
    ,[strTransactionId]             = I.[strInvoiceNumber]
    ,[intTransactionId]             = I.[intInvoiceId]
    ,[strTransactionType]           = I.[strTransactionType]
    ,[strTransactionForm]           = @SCREEN_NAME
    ,[strModuleName]                = @MODULE_NAME
    ,[intConcurrencyId]             = 1
    ,[dblDebitForeign]              = @ZeroDecimal
    ,[dblDebitReport]               = @ZeroDecimal
    ,[dblCreditForeign]             = @ZeroDecimal
    ,[dblCreditReport]              = @ZeroDecimal
    ,[dblReportingRate]             = I.[dblAverageExchangeRate]
    ,[dblForeignRate]               = I.[dblAverageExchangeRate]
    ,[strRateType]                  = NULL
    ,[strDocument]                  = NULL
    ,[strComments]                  = NULL
    ,[strSourceDocumentId]          = NULL
    ,[intSourceLocationId]          = NULL
    ,[intSourceUOMId]               = NULL
    ,[dblSourceUnitDebit]           = NULL
    ,[dblSourceUnitCredit]          = NULL
    ,[intCommodityId]               = NULL
    ,[intSourceEntityId]            = I.[intEntityCustomerId]
    ,[ysnRebuild]                   = NULL
FROM
    ##ARPostInvoiceHeader I
INNER JOIN 
     ##ARPostInvoiceDetail ARID
ON I.[intInvoiceId] = ARID.[intInvoiceId]
INNER JOIN (
	SELECT [intItemId], [strType], [strDescription] FROM tblICItem WITH(NOLOCK)
) ICI 
ON ARID.[intItemId] = ICI.[intItemId]
INNER JOIN (
    SELECT [intItemId], [intLocationId], [intItemLocationId] FROM tblICItemLocation WITH(NOLOCK)
) ICIL 
ON ICI.[intItemId] = ICIL.[intItemId]
AND I.[intCompanyLocationId] = ICIL.[intLocationId]
OUTER APPLY (
	SELECT TOP 1 dblCOGSAmount
	FROM tblARImportLogDetail WITH(NOLOCK) 
	WHERE strTransactionNumber = I.strInvoiceNumber
    ORDER BY intImportLogDetailId DESC
) IM
WHERE
    I.[strImportFormat] = 'CarQuest'

--CarQuest Import (COGS)
INSERT ##ARInvoiceGLEntries
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
     [dtmDate]                      = CAST(ISNULL(I.[dtmPostDate], I.[dtmDate]) AS DATE)
    ,[strBatchId]                   = I.[strBatchId]
    ,[intAccountId]                 = dbo.fnGetItemGLAccount(ARID.[intItemId], ICIL.[intItemLocationId], 'Cost of Goods')
    ,[dblDebit]                     = IM.[dblCOGSAmount]
    ,[dblCredit]                    = @ZeroDecimal
    ,[dblDebitUnit]                 = 1
    ,[dblCreditUnit]                = @ZeroDecimal
    ,[strDescription]               = 'COGS -' + ARID.[strDescription]
    ,[strCode]                      = @CODE
    ,[strReference]                 = I.[strCustomerNumber]
    ,[intCurrencyId]                = I.[intCurrencyId]
    ,[dblExchangeRate]              = I.[dblAverageExchangeRate]
    ,[dtmDateEntered]               = I.[dtmDatePosted]
    ,[dtmTransactionDate]           = I.[dtmDate]
    ,[strJournalLineDescription]    = 'CarQuest Import'
    ,[intJournalLineNo]             = I.[intInvoiceId]
    ,[ysnIsUnposted]                = 0
    ,[intUserId]                    = I.[intUserId]
    ,[intEntityId]                  = I.[intEntityId]
    ,[strTransactionId]             = I.[strInvoiceNumber]
    ,[intTransactionId]             = I.[intInvoiceId]
    ,[strTransactionType]           = I.[strTransactionType]
    ,[strTransactionForm]           = @SCREEN_NAME
    ,[strModuleName]                = @MODULE_NAME
    ,[intConcurrencyId]             = 1
    ,[dblDebitForeign]              = @ZeroDecimal
    ,[dblDebitReport]               = @ZeroDecimal
    ,[dblCreditForeign]             = @ZeroDecimal
    ,[dblCreditReport]              = @ZeroDecimal
    ,[dblReportingRate]             = I.[dblAverageExchangeRate]
    ,[dblForeignRate]               = I.[dblAverageExchangeRate]
    ,[strRateType]                  = NULL
    ,[strDocument]                  = NULL
    ,[strComments]                  = NULL
    ,[strSourceDocumentId]          = NULL
    ,[intSourceLocationId]          = NULL
    ,[intSourceUOMId]               = NULL
    ,[dblSourceUnitDebit]           = NULL
    ,[dblSourceUnitCredit]          = NULL
    ,[intCommodityId]               = NULL
    ,[intSourceEntityId]            = I.[intEntityCustomerId]
    ,[ysnRebuild]                   = NULL
FROM
    ##ARPostInvoiceHeader I
INNER JOIN 
     ##ARPostInvoiceDetail ARID
ON I.[intInvoiceId] = ARID.[intInvoiceId]
INNER JOIN (
	SELECT [intItemId], [strType], [strDescription] FROM tblICItem WITH(NOLOCK)
) ICI 
ON ARID.[intItemId] = ICI.[intItemId]
INNER JOIN (
    SELECT [intItemId], [intLocationId], [intItemLocationId] FROM tblICItemLocation WITH(NOLOCK)
) ICIL 
ON ICI.[intItemId] = ICIL.[intItemId]
AND I.[intCompanyLocationId] = ICIL.[intLocationId]
OUTER APPLY (
	SELECT TOP 1 dblCOGSAmount
	FROM tblARImportLogDetail WITH(NOLOCK) 
	WHERE strTransactionNumber = I.strInvoiceNumber
    ORDER BY intImportLogDetailId DESC
) IM
WHERE
    I.[strImportFormat] = 'CarQuest'

--DEBIT MEMO DEBIT
INSERT ##ARInvoiceGLEntries
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
     [dtmDate]                      = CAST(ISNULL(I.[dtmPostDate], I.[dtmDate]) AS DATE)
    ,[strBatchId]                   = I.[strBatchId]
    ,[intAccountId]                 = I.[intSalesAccountId]
    ,[dblDebit]                     = CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN @ZeroDecimal ELSE I.[dblBaseLineItemGLAmount] END
    ,[dblCredit]                    = CASE WHEN I.[ysnIsInvoicePositive] = 0 THEN @ZeroDecimal ELSE I.[dblBaseLineItemGLAmount] END
    ,[dblDebitUnit]                 = CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN @ZeroDecimal ELSE I.[dblUnitQtyShipped] END
    ,[dblCreditUnit]                = CASE WHEN I.[ysnIsInvoicePositive] = 0 THEN @ZeroDecimal ELSE I.[dblUnitQtyShipped] END
    ,[strDescription]               = I.[strDescription]
    ,[strCode]                      = @CODE
    ,[strReference]                 = I.[strCustomerNumber]
    ,[intCurrencyId]                = I.[intCurrencyId]
    ,[dblExchangeRate]              = I.[dblCurrencyExchangeRate]
    ,[dtmDateEntered]               = I.[dtmDatePosted]
    ,[dtmTransactionDate]           = I.[dtmDate]
    ,[strJournalLineDescription]    = I.[strItemDescription]
    ,[intJournalLineNo]             = I.[intInvoiceDetailId]
    ,[ysnIsUnposted]                = 0
    ,[intUserId]                    = I.[intUserId]
    ,[intEntityId]                  = I.[intEntityId]
    ,[strTransactionId]             = I.[strInvoiceNumber]
    ,[intTransactionId]             = I.[intInvoiceId]
    ,[strTransactionType]           = I.[strTransactionType]
    ,[strTransactionForm]           = @SCREEN_NAME
    ,[strModuleName]                = @MODULE_NAME
    ,[intConcurrencyId]             = 1
    ,[dblDebitForeign]              = CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN @ZeroDecimal ELSE I.[dblLineItemGLAmount] END
    ,[dblDebitReport]               = CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN @ZeroDecimal ELSE I.[dblLineItemGLAmount] END
    ,[dblCreditForeign]             = CASE WHEN I.[ysnIsInvoicePositive] = 0 THEN @ZeroDecimal ELSE I.[dblLineItemGLAmount] END
    ,[dblCreditReport]              = CASE WHEN I.[ysnIsInvoicePositive] = 0 THEN @ZeroDecimal ELSE I.[dblLineItemGLAmount] END
    ,[dblReportingRate]             = I.[dblCurrencyExchangeRate]
    ,[dblForeignRate]               = I.[dblCurrencyExchangeRate]
    ,[strRateType]                  = I.[strCurrencyExchangeRateType]
    ,[strDocument]                  = NULL
    ,[strComments]                  = NULL
    ,[strSourceDocumentId]          = NULL
    ,[intSourceLocationId]          = NULL
    ,[intSourceUOMId]               = NULL
    ,[dblSourceUnitDebit]           = NULL
    ,[dblSourceUnitCredit]          = NULL
    ,[intCommodityId]               = NULL
    ,[intSourceEntityId]            = I.[intEntityCustomerId]
    ,[ysnRebuild]                   = NULL
FROM
    ##ARPostInvoiceDetail I
WHERE
    I.[intPeriodsToAccrue] <= 1
    AND I.[dblQtyShipped] <> @ZeroDecimal
    -- AND I.[strType] NOT IN ('CF Tran', 'CF Invoice', 'Card Fueling Transaction')
    AND I.[strTransactionType] = 'Debit Memo'
    AND I.[strItemType] <> 'Comment'

--dblShipping <> 0
INSERT ##ARInvoiceGLEntries
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
     [dtmDate]                      = CAST(ISNULL(I.[dtmPostDate], I.[dtmDate]) AS DATE)
    ,[strBatchId]                   = I.[strBatchId]
    ,[intAccountId]                 = I.[intFreightIncome]
    ,[dblDebit]                     = CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN @ZeroDecimal ELSE I.[dblBaseShipping] END
    ,[dblCredit]                    = CASE WHEN I.[ysnIsInvoicePositive] = 0 THEN @ZeroDecimal ELSE I.[dblBaseShipping] END
    ,[dblDebitUnit]                 = @ZeroDecimal
    ,[dblCreditUnit]                = @ZeroDecimal
    ,[strDescription]               = I.[strDescription]
    ,[strCode]                      = @CODE
    ,[strReference]                 = I.[strCustomerNumber]
    ,[intCurrencyId]                = I.[intCurrencyId]
    ,[dblExchangeRate]              = I.[dblAverageExchangeRate]
    ,[dtmDateEntered]               = I.[dtmDatePosted]
    ,[dtmTransactionDate]           = I.[dtmDate]
    ,[strJournalLineDescription]    = @POSTDESC + I.[strTransactionType]
    ,[intJournalLineNo]             = I.[intInvoiceId]
    ,[ysnIsUnposted]                = 0
    ,[intUserId]                    = I.[intUserId]
    ,[intEntityId]                  = I.[intEntityId]
    ,[strTransactionId]             = I.[strInvoiceNumber]
    ,[intTransactionId]             = I.[intInvoiceId]
    ,[strTransactionType]           = I.[strTransactionType]
    ,[strTransactionForm]           = @SCREEN_NAME
    ,[strModuleName]                = @MODULE_NAME
    ,[intConcurrencyId]             = 1
    ,[dblDebitForeign]              = CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN @ZeroDecimal ELSE I.[dblShipping] END
    ,[dblDebitReport]               = CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN @ZeroDecimal ELSE I.[dblShipping] END
    ,[dblCreditForeign]             = CASE WHEN I.[ysnIsInvoicePositive] = 0 THEN @ZeroDecimal ELSE I.[dblShipping] END
    ,[dblCreditReport]              = CASE WHEN I.[ysnIsInvoicePositive] = 0 THEN @ZeroDecimal ELSE I.[dblShipping] END
    ,[dblReportingRate]             = I.[dblAverageExchangeRate]
    ,[dblForeignRate]               = I.[dblAverageExchangeRate]
    ,[strRateType]                  = NULL
    ,[strDocument]                  = NULL
    ,[strComments]                  = NULL
    ,[strSourceDocumentId]          = NULL
    ,[intSourceLocationId]          = NULL
    ,[intSourceUOMId]               = NULL
    ,[dblSourceUnitDebit]           = NULL
    ,[dblSourceUnitCredit]          = NULL
    ,[intCommodityId]               = NULL
    ,[intSourceEntityId]            = I.[intEntityCustomerId]
    ,[ysnRebuild]                   = NULL
FROM
    ##ARPostInvoiceHeader I
WHERE
    I.[dblShipping] <> @ZeroDecimal

--TAX DETAIL DEBIT
INSERT ##ARInvoiceGLEntries
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
     [dtmDate]                      = CAST(ISNULL(I.[dtmPostDate], I.[dtmDate]) AS DATE)
    ,[strBatchId]                   = I.[strBatchId]
    ,[intAccountId]                 = CASE WHEN ARIDT.[ysnAddToCost] = 0 THEN ARIDT.[intSalesTaxAccountId] 
										   WHEN [intSalesTaxExemptionAccountId] > 0 AND [ysnAddToCost] = 1 AND [ysnTaxExempt] = 1 THEN ARIDT.[intSalesTaxExemptionAccountId]
										   ELSE I.intItemAccountId 
									  END
    ,[dblDebit]                     = CASE WHEN I.[ysnIsInvoicePositive] = 1 
                                           THEN (CASE WHEN ARIDT.[dblBaseAdjustedTax] < @ZeroDecimal 
													  THEN ABS(ARIDT.[dblBaseAdjustedTax]) 
													  ELSE (CASE WHEN ARIDT.[dblAdjustedTax] = @ZeroDecimal AND [intSalesTaxExemptionAccountId] > 0 AND [ysnAddToCost] = 1 AND [ysnTaxExempt] = 1 
																 THEN ROUND(I.dblQtyShipped * ARIDT.dblRate, dbo.fnARGetDefaultDecimal())
																 ELSE @ZeroDecimal 
															END) 
												 END)
                                           ELSE (CASE WHEN ARIDT.[dblBaseAdjustedTax] < @ZeroDecimal THEN @ZeroDecimal ELSE ARIDT.[dblBaseAdjustedTax] END)
                                      END
    ,[dblCredit]                    = CASE WHEN I.[ysnIsInvoicePositive] = 0 
                                           THEN (CASE WHEN ARIDT.[dblBaseAdjustedTax] < @ZeroDecimal THEN ABS(ARIDT.[dblBaseAdjustedTax]) ELSE @ZeroDecimal END )
                                           ELSE (CASE WHEN ARIDT.[dblBaseAdjustedTax] < @ZeroDecimal THEN @ZeroDecimal ELSE ARIDT.[dblBaseAdjustedTax] END)
                                      END
    ,[dblDebitUnit]                 = @ZeroDecimal
    ,[dblCreditUnit]                = @ZeroDecimal
    ,[strDescription]               = I.[strDescription]
    ,[strCode]                      = @CODE
    ,[strReference]                 = I.[strCustomerNumber]
    ,[intCurrencyId]                = I.[intCurrencyId]
    ,[dblExchangeRate]              = I.[dblCurrencyExchangeRate]
    ,[dtmDateEntered]               = I.[dtmDatePosted]
    ,[dtmTransactionDate]           = I.[dtmDate]
    ,[strJournalLineDescription]    = @POSTDESC + I.[strTransactionType]
    ,[intJournalLineNo]             = ARIDT.[intInvoiceDetailTaxId]
    ,[ysnIsUnposted]                = 0
    ,[intUserId]                    = I.[intUserId]
    ,[intEntityId]                  = I.[intEntityId]
    ,[strTransactionId]             = I.[strInvoiceNumber]
    ,[intTransactionId]             = I.[intInvoiceId]
    ,[strTransactionType]           = I.[strTransactionType]
    ,[strTransactionForm]           = @SCREEN_NAME
    ,[strModuleName]                = @MODULE_NAME
    ,[intConcurrencyId]             = 1
    ,[dblDebitForeign]              = CASE WHEN I.[ysnIsInvoicePositive] = 1 
                                           THEN (CASE WHEN ARIDT.[dblAdjustedTax] < @ZeroDecimal 
													  THEN ABS(ARIDT.[dblAdjustedTax]) 
													  ELSE (CASE WHEN ARIDT.[dblAdjustedTax] = @ZeroDecimal AND [intSalesTaxExemptionAccountId] > 0 AND [ysnAddToCost] = 1 AND [ysnTaxExempt] = 1 
																 THEN ROUND(I.dblQtyShipped * ARIDT.dblRate, dbo.fnARGetDefaultDecimal())
																 ELSE @ZeroDecimal 
															END)  
												 END )
                                           ELSE (CASE WHEN ARIDT.[dblAdjustedTax] < @ZeroDecimal THEN @ZeroDecimal ELSE ARIDT.[dblAdjustedTax] END)
                                      END
    ,[dblDebitReport]               = CASE WHEN I.[ysnIsInvoicePositive] = 1 
                                           THEN (CASE WHEN ARIDT.[dblAdjustedTax] < @ZeroDecimal 
													  THEN ABS(ARIDT.[dblAdjustedTax]) 
													  ELSE (CASE WHEN ARIDT.[dblAdjustedTax] = @ZeroDecimal AND [intSalesTaxExemptionAccountId] > 0 AND [ysnAddToCost] = 1 AND [ysnTaxExempt] = 1 
																 THEN ROUND(I.dblQtyShipped * ARIDT.dblRate, dbo.fnARGetDefaultDecimal())
																 ELSE @ZeroDecimal 
															END)  
												 END )
                                           ELSE (CASE WHEN ARIDT.[dblAdjustedTax] < @ZeroDecimal THEN @ZeroDecimal ELSE ARIDT.[dblAdjustedTax] END)
                                      END
    ,[dblCreditForeign]             = CASE WHEN I.[ysnIsInvoicePositive] = 0 
                                           THEN (CASE WHEN ARIDT.[dblAdjustedTax] < @ZeroDecimal THEN ABS(ARIDT.[dblAdjustedTax]) ELSE @ZeroDecimal END )
                                           ELSE (CASE WHEN ARIDT.[dblAdjustedTax] < @ZeroDecimal THEN @ZeroDecimal ELSE ARIDT.[dblAdjustedTax] END)
                                      END
    ,[dblCreditReport]              = CASE WHEN I.[ysnIsInvoicePositive] = 0 
                                           THEN (CASE WHEN ARIDT.[dblAdjustedTax] < @ZeroDecimal THEN ABS(ARIDT.[dblAdjustedTax]) ELSE @ZeroDecimal END )
                                           ELSE (CASE WHEN ARIDT.[dblAdjustedTax] < @ZeroDecimal THEN @ZeroDecimal ELSE ARIDT.[dblAdjustedTax] END)
                                      END
    ,[dblReportingRate]             = I.[dblCurrencyExchangeRate]
    ,[dblForeignRate]               = I.[dblCurrencyExchangeRate]
    ,[strRateType]                  = I.[strCurrencyExchangeRateType]
    ,[strDocument]                  = NULL
    ,[strComments]                  = NULL
    ,[strSourceDocumentId]          = NULL
    ,[intSourceLocationId]          = NULL
    ,[intSourceUOMId]               = NULL
    ,[dblSourceUnitDebit]           = NULL
    ,[dblSourceUnitCredit]          = NULL
    ,[intCommodityId]               = NULL
    ,[intSourceEntityId]            = I.[intEntityCustomerId]
    ,[ysnRebuild]                   = NULL
FROM (
    SELECT IDT.[intTaxCodeId]
		 , IDT.[intInvoiceDetailId]
		 , IDT.[intInvoiceDetailTaxId]
		 , IDT.[intSalesTaxAccountId]
		 , [intSalesTaxExemptionAccountId]  = ISNULL(IDT.[intSalesTaxExemptionAccountId], TC.[intSalesTaxExemptionAccountId])
		 , IDT.[dblAdjustedTax]
		 , IDT.[dblBaseAdjustedTax]
		 , [ysnAddToCost]  = ISNULL(TC.[ysnAddToCost], 0)
		 , [ysnTaxExempt]  = ISNULL(IDT.[ysnTaxExempt], 0)
         , [ysnInvalidSetup]  = ISNULL(IDT.[ysnInvalidSetup], 0)
		 , IDT.[dblRate]
    FROM tblARInvoiceDetailTax IDT WITH (NOLOCK)
	INNER JOIN tblSMTaxCode TC ON IDT.intTaxCodeId = TC.intTaxCodeId
) ARIDT
INNER JOIN ##ARPostInvoiceDetail I ON ARIDT.[intInvoiceDetailId] = I.[intInvoiceDetailId]
WHERE I.[intPeriodsToAccrue] <= 1
  AND (ARIDT.[dblAdjustedTax] <> @ZeroDecimal
  OR (ARIDT.[dblAdjustedTax] = @ZeroDecimal AND [intSalesTaxExemptionAccountId] > 0 AND [ysnAddToCost] = 1 AND [ysnTaxExempt] = 1 AND [ysnInvalidSetup] = 0))

--TAX DETAIL CREDIT
INSERT ##ARInvoiceGLEntries
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
     [dtmDate]                      = CAST(ISNULL(I.[dtmPostDate], I.[dtmDate]) AS DATE)
    ,[strBatchId]                   = I.[strBatchId]
    ,[intAccountId]                 = dbo.fnGetItemGLAccount(I.[intItemId], ICIL.[intItemLocationId], 'Cost of Goods')
    ,[dblDebit]                     = CASE WHEN I.[ysnIsInvoicePositive] = 0 
                                           THEN (CASE WHEN ARIDT.[dblBaseAdjustedTax] < @ZeroDecimal THEN ABS(ARIDT.[dblBaseAdjustedTax]) ELSE @ZeroDecimal END )
                                           ELSE (CASE WHEN ARIDT.[dblBaseAdjustedTax] < @ZeroDecimal THEN @ZeroDecimal ELSE ARIDT.[dblBaseAdjustedTax] END)
                                      END
    ,[dblCredit]                    = CASE WHEN I.[ysnIsInvoicePositive] = 1 
                                           THEN (CASE WHEN ARIDT.[dblBaseAdjustedTax] < @ZeroDecimal 
													  THEN ABS(ARIDT.[dblBaseAdjustedTax]) 
													  ELSE (CASE WHEN ARIDT.[dblAdjustedTax] = @ZeroDecimal AND [intSalesTaxExemptionAccountId] > 0 AND [ysnAddToCost] = 1 AND [ysnTaxExempt] = 1 
																 THEN ROUND(I.dblQtyShipped * ARIDT.dblRate, dbo.fnARGetDefaultDecimal())
																 ELSE @ZeroDecimal 
															END) 
												 END)
                                           ELSE (CASE WHEN ARIDT.[dblBaseAdjustedTax] < @ZeroDecimal THEN @ZeroDecimal ELSE ARIDT.[dblBaseAdjustedTax] END)
                                      END
    ,[dblDebitUnit]                 = @ZeroDecimal
    ,[dblCreditUnit]                = @ZeroDecimal
    ,[strDescription]               = I.[strDescription]
    ,[strCode]                      = @CODE
    ,[strReference]                 = I.[strCustomerNumber]
    ,[intCurrencyId]                = I.[intCurrencyId]
    ,[dblExchangeRate]              = I.[dblCurrencyExchangeRate]
    ,[dtmDateEntered]               = I.[dtmDatePosted]
    ,[dtmTransactionDate]           = I.[dtmDate]
    ,[strJournalLineDescription]    = @POSTDESC + I.[strTransactionType]
    ,[intJournalLineNo]             = ARIDT.[intInvoiceDetailTaxId]
    ,[ysnIsUnposted]                = 0
    ,[intUserId]                    = I.[intUserId]
    ,[intEntityId]                  = I.[intEntityId]
    ,[strTransactionId]             = I.[strInvoiceNumber]
    ,[intTransactionId]             = I.[intInvoiceId]
    ,[strTransactionType]           = I.[strTransactionType]
    ,[strTransactionForm]           = @SCREEN_NAME
    ,[strModuleName]                = @MODULE_NAME
    ,[intConcurrencyId]             = 1
    ,[dblDebitForeign]              = CASE WHEN I.[ysnIsInvoicePositive] = 0 
                                           THEN (CASE WHEN ARIDT.[dblBaseAdjustedTax] < @ZeroDecimal THEN ABS(ARIDT.[dblBaseAdjustedTax]) ELSE @ZeroDecimal END )
                                           ELSE (CASE WHEN ARIDT.[dblBaseAdjustedTax] < @ZeroDecimal THEN @ZeroDecimal ELSE ARIDT.[dblBaseAdjustedTax] END)
                                      END
    ,[dblDebitReport]               = CASE WHEN I.[ysnIsInvoicePositive] = 0 
                                           THEN (CASE WHEN ARIDT.[dblBaseAdjustedTax] < @ZeroDecimal THEN ABS(ARIDT.[dblBaseAdjustedTax]) ELSE @ZeroDecimal END )
                                           ELSE (CASE WHEN ARIDT.[dblBaseAdjustedTax] < @ZeroDecimal THEN @ZeroDecimal ELSE ARIDT.[dblBaseAdjustedTax] END)
                                      END
    ,[dblCreditForeign]             = CASE WHEN I.[ysnIsInvoicePositive] = 1 
                                           THEN (CASE WHEN ARIDT.[dblBaseAdjustedTax] < @ZeroDecimal 
													  THEN ABS(ARIDT.[dblBaseAdjustedTax]) 
													  ELSE (CASE WHEN ARIDT.[dblAdjustedTax] = @ZeroDecimal AND [intSalesTaxExemptionAccountId] > 0 AND [ysnAddToCost] = 1 AND [ysnTaxExempt] = 1 
																 THEN ROUND(I.dblQtyShipped * ARIDT.dblRate, dbo.fnARGetDefaultDecimal())
																 ELSE @ZeroDecimal 
															END) 
												 END)
                                           ELSE (CASE WHEN ARIDT.[dblBaseAdjustedTax] < @ZeroDecimal THEN @ZeroDecimal ELSE ARIDT.[dblBaseAdjustedTax] END)
                                      END
    ,[dblCreditReport]              = CASE WHEN I.[ysnIsInvoicePositive] = 1 
                                           THEN (CASE WHEN ARIDT.[dblBaseAdjustedTax] < @ZeroDecimal 
													  THEN ABS(ARIDT.[dblBaseAdjustedTax]) 
													  ELSE (CASE WHEN ARIDT.[dblAdjustedTax] = @ZeroDecimal AND [intSalesTaxExemptionAccountId] > 0 AND [ysnAddToCost] = 1 AND [ysnTaxExempt] = 1 
																 THEN ROUND(I.dblQtyShipped * ARIDT.dblRate, dbo.fnARGetDefaultDecimal())
																 ELSE @ZeroDecimal 
															END) 
												 END)
                                           ELSE (CASE WHEN ARIDT.[dblBaseAdjustedTax] < @ZeroDecimal THEN @ZeroDecimal ELSE ARIDT.[dblBaseAdjustedTax] END)
                                      END
    ,[dblReportingRate]             = I.[dblCurrencyExchangeRate]
    ,[dblForeignRate]               = I.[dblCurrencyExchangeRate]
    ,[strRateType]                  = I.[strCurrencyExchangeRateType]
    ,[strDocument]                  = NULL
    ,[strComments]                  = NULL
    ,[strSourceDocumentId]          = NULL
    ,[intSourceLocationId]          = NULL
    ,[intSourceUOMId]               = NULL
    ,[dblSourceUnitDebit]           = NULL
    ,[dblSourceUnitCredit]          = NULL
    ,[intCommodityId]               = NULL
    ,[intSourceEntityId]            = I.[intEntityCustomerId]
    ,[ysnRebuild]                   = NULL
FROM (
    SELECT IDT.[intTaxCodeId]
		 , IDT.[intInvoiceDetailId]
		 , IDT.[intInvoiceDetailTaxId]
		 , IDT.[intSalesTaxAccountId]
		 , [intSalesTaxExemptionAccountId]  = ISNULL(IDT.[intSalesTaxExemptionAccountId], TC.[intSalesTaxExemptionAccountId])
		 , IDT.[dblAdjustedTax]
		 , IDT.[dblBaseAdjustedTax]
		 , [ysnAddToCost]  = ISNULL(TC.[ysnAddToCost], 0)
		 , [ysnTaxExempt]  = ISNULL(IDT.[ysnTaxExempt], 0)
         , [ysnInvalidSetup]  = ISNULL(IDT.[ysnInvalidSetup], 0)
		 , IDT.[dblRate]
    FROM tblARInvoiceDetailTax IDT WITH (NOLOCK)
	INNER JOIN tblSMTaxCode TC ON IDT.intTaxCodeId = TC.intTaxCodeId
) ARIDT
INNER JOIN ##ARPostInvoiceDetail I ON ARIDT.[intInvoiceDetailId] = I.[intInvoiceDetailId]
INNER JOIN (
	SELECT [intItemId], [intLocationId], [intItemLocationId], [intAllowNegativeInventory], [intSubLocationId] FROM tblICItemLocation WITH(NOLOCK)
) ICIL ON I.[intItemId] = ICIL.[intItemId] AND I.[intCompanyLocationId] = ICIL.[intLocationId]
WHERE I.[intPeriodsToAccrue] <= 1
  AND ARIDT.[dblAdjustedTax] = @ZeroDecimal 
  AND [intSalesTaxExemptionAccountId] > 0 
  AND [ysnAddToCost] = 1
  AND [ysnTaxExempt] = 1
  AND [ysnInvalidSetup] = 0

--SALES DISCOUNT
INSERT ##ARInvoiceGLEntries
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
     [dtmDate]                      = CAST(ISNULL(I.[dtmPostDate], I.[dtmDate]) AS DATE)
    ,[strBatchId]                   = I.[strBatchId]
    ,[intAccountId]                 = ISNULL(I.[intDiscountAccountId], IA.[intDiscountAccountId])
    ,[dblDebit]                     = CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN I.[dblBaseDiscountAmount] ELSE @ZeroDecimal END
    ,[dblCredit]                    = CASE WHEN I.[ysnIsInvoicePositive] = 0 THEN I.[dblBaseDiscountAmount] ELSE @ZeroDecimal END
    ,[dblDebitUnit]                 = @ZeroDecimal
    ,[dblCreditUnit]                = @ZeroDecimal
    ,[strDescription]               = I.[strDescription]
    ,[strCode]                      = @CODE
    ,[strReference]                 = I.[strCustomerNumber]
    ,[intCurrencyId]                = I.[intCurrencyId]
    ,[dblExchangeRate]              = I.[dblCurrencyExchangeRate]
    ,[dtmDateEntered]               = I.[dtmDatePosted]
    ,[dtmTransactionDate]           = I.[dtmDate]
    ,[strJournalLineDescription]    = @POSTDESC + I.[strTransactionType]
    ,[intJournalLineNo]             = I.[intInvoiceId]
    ,[ysnIsUnposted]                = 0
    ,[intUserId]                    = I.[intUserId]
    ,[intEntityId]                  = I.[intEntityId]
    ,[strTransactionId]             = I.[strInvoiceNumber]
    ,[intTransactionId]             = I.[intInvoiceId]
    ,[strTransactionType]           = I.[strTransactionType]
    ,[strTransactionForm]           = @SCREEN_NAME
    ,[strModuleName]                = @MODULE_NAME
    ,[intConcurrencyId]             = 1
    ,[dblDebitForeign]              = CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN I.[dblDiscountAmount] ELSE @ZeroDecimal END
    ,[dblDebitReport]               = CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN I.[dblDiscountAmount] ELSE @ZeroDecimal END
    ,[dblCreditForeign]             = CASE WHEN I.[ysnIsInvoicePositive] = 0 THEN I.[dblDiscountAmount] ELSE @ZeroDecimal END
    ,[dblCreditReport]              = CASE WHEN I.[ysnIsInvoicePositive] = 0 THEN I.[dblDiscountAmount] ELSE @ZeroDecimal END
    ,[dblReportingRate]             = I.[dblCurrencyExchangeRate]
    ,[dblForeignRate]               = I.[dblCurrencyExchangeRate]
    ,[strRateType]                  = I.[strCurrencyExchangeRateType]
    ,[strDocument]                  = NULL
    ,[strComments]                  = NULL
    ,[strSourceDocumentId]          = NULL
    ,[intSourceLocationId]          = NULL
    ,[intSourceUOMId]               = NULL
    ,[dblSourceUnitDebit]           = NULL
    ,[dblSourceUnitCredit]          = NULL
    ,[intCommodityId]               = NULL
    ,[intSourceEntityId]            = I.[intEntityCustomerId]
    ,[ysnRebuild]                   = NULL
FROM
    ##ARPostInvoiceDetail I
LEFT OUTER JOIN
    ##ARInvoiceItemAccount IA
       ON I.[intItemId] = IA.[intItemId]
       AND I.[intCompanyLocationId] = IA.[intLocationId]
WHERE
    I.[dblBaseDiscountAmount] <> @ZeroDecimal

--DIRECT OUT TICKET (COGS)
INSERT ##ARInvoiceGLEntries
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
     [dtmDate]                      = CAST(ISNULL(I.[dtmPostDate], I.[dtmDate]) AS DATE)
    ,[strBatchId]                   = I.[strBatchId]
    ,[intAccountId]                 = ARID.[intAccountId]
    ,[dblDebit]                     = ARID.[dblCost]
    ,[dblCredit]                    = @ZeroDecimal
    ,[dblDebitUnit]                 = ARID.[dblUnitQtyShipped]
    ,[dblCreditUnit]                = @ZeroDecimal
    ,[strDescription]               = ARID.[strDescription]
    ,[strCode]                      = @CODE
    ,[strReference]                 = I.[strCustomerNumber]
    ,[intCurrencyId]                = I.[intCurrencyId]
    ,[dblExchangeRate]              = I.[dblAverageExchangeRate]
    ,[dtmDateEntered]               = I.[dtmDatePosted]
    ,[dtmTransactionDate]           = I.[dtmDate]
    ,[strJournalLineDescription]    = ARID.[strDescription]
    ,[intJournalLineNo]             = I.[intInvoiceId]
    ,[ysnIsUnposted]                = 0
    ,[intUserId]                    = I.[intUserId]
    ,[intEntityId]                  = I.[intEntityId]
    ,[strTransactionId]             = I.[strInvoiceNumber]
    ,[intTransactionId]             = I.[intInvoiceId]
    ,[strTransactionType]           = I.[strTransactionType]
    ,[strTransactionForm]           = @SCREEN_NAME
    ,[strModuleName]                = @MODULE_NAME
    ,[intConcurrencyId]             = 1
    ,[dblDebitForeign]              = ARID.[dblCost]
    ,[dblDebitReport]               = ARID.[dblCost]
    ,[dblCreditForeign]             = @ZeroDecimal
    ,[dblCreditReport]              = @ZeroDecimal
    ,[dblReportingRate]             = I.[dblAverageExchangeRate]
    ,[dblForeignRate]               = I.[dblAverageExchangeRate]
    ,[strRateType]                  = NULL
    ,[strDocument]                  = NULL
    ,[strComments]                  = NULL
    ,[strSourceDocumentId]          = NULL
    ,[intSourceLocationId]          = NULL
    ,[intSourceUOMId]               = NULL
    ,[dblSourceUnitDebit]           = NULL
    ,[dblSourceUnitCredit]          = NULL
    ,[intCommodityId]               = NULL
    ,[intSourceEntityId]            = I.[intEntityCustomerId]
    ,[ysnRebuild]                   = NULL
FROM
    ##ARPostInvoiceHeader I
LEFT OUTER JOIN
    (
    SELECT
         [dblUnitQtyShipped]	= SUM(ISNULL(ID.[dblUnitQtyShipped], @ZeroDecimal))
		,[dblTotal]				= SUM(ID.[dblTotal])
        ,[intInvoiceId]			= ID.[intInvoiceId]
		,[intAccountId]			= dbo.fnGetItemGLAccount(ID.[intItemId], ICIL.[intItemLocationId], 'Cost of Goods')
		,[ysnGLOnly]			= ISNULL(ARIFC.[ysnGLOnly], 0)
		,[dblCost]				= SUM(ISNULL(ARIFC.[dblCost], @ZeroDecimal) * ISNULL(ID.[dblUnitQtyShipped], @ZeroDecimal))
		,[strDescription]		= ICI.[strDescription]
    FROM
        ##ARPostInvoiceDetail ID
	INNER JOIN (
		SELECT [intItemId], [strItemNo], [strType], [strManufactureType], [strDescription], [ysnAutoBlend], [intCategoryId] FROM tblICItem WITH(NOLOCK)
	) ICI ON ID.[intItemId] = ICI.[intItemId]
	INNER JOIN (
        SELECT [intItemId], [intLocationId], [intItemLocationId], [intAllowNegativeInventory], [intSubLocationId] FROM tblICItemLocation WITH(NOLOCK)
	) ICIL ON ICI.[intItemId] = ICIL.[intItemId] AND ID.[intCompanyLocationId] = ICIL.[intLocationId]
    INNER JOIN (
        SELECT [intTransactionId], [intTransactionDetailId], [ysnGLOnly], [dblCost] FROM ##ARItemsForCosting
	) ARIFC ON ID.[intInvoiceId] = ARIFC.[intTransactionId] AND ID.[intInvoiceDetailId] = ARIFC.[intTransactionDetailId]
    GROUP BY
        ID.[intInvoiceId], ID.[intItemId], ICIL.[intItemLocationId], ARIFC.[ysnGLOnly], ARIFC.[dblCost], ICI.[strDescription]
    ) ARID
        ON I.[intInvoiceId] = ARID.[intInvoiceId]
WHERE ISNULL(ARID.[ysnGLOnly], 0) = CAST(1 AS BIT)

--DIRECT OUT TICKET (General)
INSERT ##ARInvoiceGLEntries
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
     [dtmDate]                      = CAST(ISNULL(I.[dtmPostDate], I.[dtmDate]) AS DATE)
    ,[strBatchId]                   = I.[strBatchId]
    ,[intAccountId]                 = ARID.[intAccountId]
    ,[dblDebit]                     = @ZeroDecimal
    ,[dblCredit]                    = ARID.[dblCost]
    ,[dblDebitUnit]                 = @ZeroDecimal
    ,[dblCreditUnit]                = ARID.[dblUnitQtyShipped]
    ,[strDescription]               = ARID.[strDescription]
    ,[strCode]                      = @CODE
    ,[strReference]                 = I.[strCustomerNumber]
    ,[intCurrencyId]                = I.[intCurrencyId]
    ,[dblExchangeRate]              = I.[dblAverageExchangeRate]
    ,[dtmDateEntered]               = I.[dtmDatePosted]
    ,[dtmTransactionDate]           = I.[dtmDate]
    ,[strJournalLineDescription]    = ARID.[strDescription]
    ,[intJournalLineNo]             = I.[intInvoiceId]
    ,[ysnIsUnposted]                = 0
    ,[intUserId]                    = I.[intUserId]
    ,[intEntityId]                  = I.[intEntityId]
    ,[strTransactionId]             = I.[strInvoiceNumber]
    ,[intTransactionId]             = I.[intInvoiceId]
    ,[strTransactionType]           = I.[strTransactionType]
    ,[strTransactionForm]           = @SCREEN_NAME
    ,[strModuleName]                = @MODULE_NAME
    ,[intConcurrencyId]             = 1
    ,[dblDebitForeign]              = @ZeroDecimal
    ,[dblDebitReport]               = @ZeroDecimal
    ,[dblCreditForeign]             = ARID.[dblCost]
    ,[dblCreditReport]              = ARID.[dblCost]
    ,[dblReportingRate]             = I.[dblAverageExchangeRate]
    ,[dblForeignRate]               = I.[dblAverageExchangeRate]
    ,[strRateType]                  = NULL
    ,[strDocument]                  = NULL
    ,[strComments]                  = NULL
    ,[strSourceDocumentId]          = NULL
    ,[intSourceLocationId]          = NULL
    ,[intSourceUOMId]               = NULL
    ,[dblSourceUnitDebit]           = NULL
    ,[dblSourceUnitCredit]          = NULL
    ,[intCommodityId]               = NULL
    ,[intSourceEntityId]            = I.[intEntityCustomerId]
    ,[ysnRebuild]                   = NULL
FROM
    ##ARPostInvoiceHeader I
INNER JOIN
    (
    SELECT
         [dblUnitQtyShipped]	= SUM(ISNULL(ID.[dblUnitQtyShipped], @ZeroDecimal))
		,[dblTotal]				= SUM(ID.[dblTotal])
        ,[intInvoiceId]			= ID.[intInvoiceId]
		,[intAccountId]			= dbo.fnGetItemGLAccount(ID.[intItemId], ICIL.[intItemLocationId], 'General')
		,[ysnGLOnly]			= ISNULL(ARIFC.[ysnGLOnly], 0)
		,[dblCost]				= SUM(ISNULL(ARIFC.[dblCost], @ZeroDecimal) * ISNULL(ID.[dblUnitQtyShipped], @ZeroDecimal))
		,[strDescription]		= ICI.[strDescription]

    FROM
        ##ARPostInvoiceDetail ID
	INNER JOIN (
		SELECT [intItemId], [strItemNo], [strType], [strManufactureType], [strDescription], [ysnAutoBlend], [intCategoryId] FROM tblICItem WITH(NOLOCK)
	) ICI ON ID.[intItemId] = ICI.[intItemId]
	INNER JOIN (
        SELECT [intItemId], [intLocationId], [intItemLocationId], [intAllowNegativeInventory], [intSubLocationId] FROM tblICItemLocation WITH(NOLOCK)
	) ICIL ON ICI.[intItemId] = ICIL.[intItemId] AND ID.[intCompanyLocationId] = ICIL.[intLocationId]
    INNER JOIN (
        SELECT [intTransactionId], [intTransactionDetailId], [ysnGLOnly], [dblCost] FROM ##ARItemsForCosting
	) ARIFC ON ID.[intInvoiceId] = ARIFC.[intTransactionId] AND ID.[intInvoiceDetailId] = ARIFC.[intTransactionDetailId]
    GROUP BY
        ID.[intInvoiceId], ID.[intItemId], ICIL.[intItemLocationId], ARIFC.[ysnGLOnly], ARIFC.[dblCost], ICI.[strDescription]
    ) ARID
        ON I.[intInvoiceId] = ARID.[intInvoiceId]
WHERE ISNULL(ARID.[ysnGLOnly], 0) = CAST(1 AS BIT)

RETURN 1 
