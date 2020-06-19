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

--NORMAL INVOICES
INSERT #ARInvoiceGLEntries
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
    ,[dblDebit]                     = CASE WHEN I.[strTransactionType] NOT IN ('Credit Memo', 'Overpayment', 'Credit', 'Customer Prepayment', 'Cash Refund') THEN I.[dblBaseInvoiceTotal] - ISNULL(ARID.[dblBaseTaxesAddToCost], 0) ELSE @ZeroDecimal END
    ,[dblCredit]                    = CASE WHEN I.[strTransactionType] IN ('Credit Memo', 'Overpayment', 'Credit', 'Customer Prepayment', 'Cash Refund') THEN I.[dblBaseInvoiceTotal] - ISNULL(ARID.[dblBaseTaxesAddToCost], 0) ELSE @ZeroDecimal END
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
    ,[dblDebitForeign]              = CASE WHEN I.[strTransactionType] NOT IN ('Credit Memo', 'Overpayment', 'Credit', 'Customer Prepayment', 'Cash Refund') THEN I.[dblInvoiceTotal] - ISNULL(ARID.[dblTaxesAddToCost], 0) ELSE @ZeroDecimal END
    ,[dblDebitReport]               = CASE WHEN I.[strTransactionType] NOT IN ('Credit Memo', 'Overpayment', 'Credit', 'Customer Prepayment', 'Cash Refund') THEN I.[dblInvoiceTotal] - ISNULL(ARID.[dblTaxesAddToCost], 0) ELSE @ZeroDecimal END
    ,[dblCreditForeign]             = CASE WHEN I.[strTransactionType] IN ('Credit Memo', 'Overpayment', 'Credit', 'Customer Prepayment', 'Cash Refund') THEN I.[dblInvoiceTotal] - ISNULL(ARID.[dblTaxesAddToCost], 0) ELSE @ZeroDecimal END
    ,[dblCreditReport]              = CASE WHEN I.[strTransactionType] IN ('Credit Memo', 'Overpayment', 'Credit', 'Customer Prepayment', 'Cash Refund') THEN I.[dblInvoiceTotal] - ISNULL(ARID.[dblTaxesAddToCost], 0) ELSE @ZeroDecimal END
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
    #ARPostInvoiceHeader I
LEFT OUTER JOIN
    (
    SELECT
         [dblUnitQtyShipped]		= SUM([dblUnitQtyShipped])		
		,[dblTaxesAddToCost]		= SUM(CASE WHEN ysnImpactInventory = 1 THEN ISNULL([dblTaxesAddToCost], 0) ELSE 0 END)
		,[dblBaseTaxesAddToCost]	= SUM(CASE WHEN ysnImpactInventory = 1 THEN ISNULL([dblBaseTaxesAddToCost], 0) ELSE 0 END)
        ,[intInvoiceId]				= [intInvoiceId]
    FROM
        #ARPostInvoiceDetail
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
        EXISTS(SELECT NULL FROM #ARPostInvoiceDetail ARID WHERE ARID.[intItemId] IS NOT NULL AND ARID.[strItemType] <> 'Comment' AND ARID.intInvoiceId  = I.[intInvoiceId])
        )

--PROVISIONAL INVOICES
INSERT #ARInvoiceGLEntries
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
    ,[dblDebit]                     = CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN I.[dblBaseInvoiceTotal] - ISNULL(ARID.[dblBaseTaxesAddToCost], 0) ELSE @ZeroDecimal END
    ,[dblCredit]                    = CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN @ZeroDecimal ELSE I.[dblBaseInvoiceTotal] - ISNULL(ARID.[dblBaseTaxesAddToCost], 0) END
    ,[dblDebitUnit]                 = @ZeroDecimal
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
    ,[dblDebitForeign]              = CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN I.[dblInvoiceTotal] - ISNULL(ARID.[dblTaxesAddToCost], 0) ELSE @ZeroDecimal END
    ,[dblDebitReport]               = CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN I.[dblInvoiceTotal] - ISNULL(ARID.[dblTaxesAddToCost], 0) ELSE @ZeroDecimal END
    ,[dblCreditForeign]             = CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN @ZeroDecimal ELSE I.[dblInvoiceTotal] - ISNULL(ARID.[dblTaxesAddToCost], 0) END
    ,[dblCreditReport]              = CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN @ZeroDecimal ELSE I.[dblInvoiceTotal] - ISNULL(ARID.[dblTaxesAddToCost], 0) END
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
    #ARPostInvoiceHeader I
LEFT OUTER JOIN
    (
    SELECT
         [dblUnitQtyShipped]		= SUM([dblUnitQtyShipped])
		,[dblTaxesAddToCost]		= SUM(CASE WHEN ysnImpactInventory = 1 THEN ISNULL([dblTaxesAddToCost], 0) ELSE 0 END)
		,[dblBaseTaxesAddToCost]	= SUM(CASE WHEN ysnImpactInventory = 1 THEN ISNULL([dblBaseTaxesAddToCost], 0) ELSE 0 END)
        ,[intInvoiceId]				= [intInvoiceId]
    FROM
        #ARPostInvoiceDetail
    GROUP BY
        [intInvoiceId]
    ) ARID
        ON I.[intInvoiceId] = ARID.[intInvoiceId]
WHERE
    I.[intPeriodsToAccrue] <= 1
    AND I.[ysnFromProvisional] = 1
	AND I.[dblInvoiceTotal] <> @ZeroDecimal

--APPLIED CREDIT/PREPAIDS
INSERT #ARInvoiceGLEntries
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
   #ARPostInvoiceHeader I
       ON ARPAC.[intInvoiceId] = I.[intInvoiceId]
       AND ISNULL(ARPAC.[ysnApplied],0) = 1 
       AND ARPAC.[dblAppliedInvoiceDetailAmount] <> @ZeroDecimal
       AND I.strTransactionType = 'Cash Refund'
WHERE
   I.[intPeriodsToAccrue] <= 1

--CASH TRANSACTION TYPE
INSERT #ARInvoiceGLEntries
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
    #ARPostInvoiceHeader I
WHERE
    I.[intPeriodsToAccrue] <= 1
    AND I.[dblPayment] <> @ZeroDecimal

--SALES ACCOUNT 
INSERT #ARInvoiceGLEntries
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
    ,[intAccountId]                 = CASE WHEN I.[strItemType] IN ('Non-Inventory','Inventory') THEN  ISNULL([dbo].fnARGetItemGLAccount(I.[intItemId]), I.[intItemAccountId])  ELSE  I.[intItemAccountId] END
    ,[dblDebit]                     = CASE WHEN I.strTransactionType IN ('Invoice', 'Cash') OR (I.strTransactionType = 'Debit Memo' AND I.strType IN ('CF Tran', 'CF Invoice', 'Card Fueling Transaction')) OR (I.strTransactionType = 'Credit Memo' AND I.[ysnFromProvisional] = 1) THEN @ZeroDecimal ELSE I.[dblBaseLineItemGLAmount] + CASE WHEN I.[ysnImpactInventory] = 0 THEN ISNULL(I.[dblBaseTaxesAddToCost], 0) ELSE @ZeroDecimal END END
    ,[dblCredit]                    = CASE WHEN I.strTransactionType IN ('Invoice', 'Cash') OR (I.strTransactionType = 'Debit Memo' AND I.strType IN ('CF Tran', 'CF Invoice', 'Card Fueling Transaction')) OR (I.strTransactionType = 'Credit Memo' AND I.[ysnFromProvisional] = 1) THEN I.[dblBaseLineItemGLAmount] + CASE WHEN I.[ysnImpactInventory] = 0 THEN ISNULL(I.[dblBaseTaxesAddToCost], 0) ELSE @ZeroDecimal END ELSE @ZeroDecimal END
    ,[dblDebitUnit]                 = CASE WHEN I.strTransactionType IN ('Invoice', 'Cash') OR (I.strTransactionType = 'Debit Memo' AND I.strType IN ('CF Tran', 'CF Invoice', 'Card Fueling Transaction')) OR (I.strTransactionType = 'Credit Memo' AND I.[ysnFromProvisional] = 1) THEN @ZeroDecimal ELSE I.[dblUnitQtyShipped] END
    ,[dblCreditUnit]                = CASE WHEN I.strTransactionType IN ('Invoice', 'Cash') OR (I.strTransactionType = 'Debit Memo' AND I.strType IN ('CF Tran', 'CF Invoice', 'Card Fueling Transaction')) OR (I.strTransactionType = 'Credit Memo' AND I.[ysnFromProvisional] = 1) THEN I.[dblUnitQtyShipped] ELSE @ZeroDecimal END
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
    ,[dblDebitForeign]              = CASE WHEN I.strTransactionType IN ('Invoice', 'Cash') OR (I.strTransactionType = 'Debit Memo' AND I.strType IN ('CF Tran', 'CF Invoice', 'Card Fueling Transaction')) OR (I.strTransactionType = 'Credit Memo' AND I.[ysnFromProvisional] = 1) THEN @ZeroDecimal ELSE I.[dblLineItemGLAmount] + CASE WHEN I.[ysnImpactInventory] = 0 THEN ISNULL(I.[dblTaxesAddToCost], 0) ELSE @ZeroDecimal END END
    ,[dblDebitReport]               = CASE WHEN I.strTransactionType IN ('Invoice', 'Cash') OR (I.strTransactionType = 'Debit Memo' AND I.strType IN ('CF Tran', 'CF Invoice', 'Card Fueling Transaction')) OR (I.strTransactionType = 'Credit Memo' AND I.[ysnFromProvisional] = 1) THEN @ZeroDecimal ELSE I.[dblLineItemGLAmount] + CASE WHEN I.[ysnImpactInventory] = 0 THEN ISNULL(I.[dblTaxesAddToCost], 0) ELSE @ZeroDecimal END END
    ,[dblCreditForeign]             = CASE WHEN I.strTransactionType IN ('Invoice', 'Cash') OR (I.strTransactionType = 'Debit Memo' AND I.strType IN ('CF Tran', 'CF Invoice', 'Card Fueling Transaction')) OR (I.strTransactionType = 'Credit Memo' AND I.[ysnFromProvisional] = 1) THEN I.[dblLineItemGLAmount] + CASE WHEN I.[ysnImpactInventory] = 0 THEN ISNULL(I.[dblTaxesAddToCost], 0) ELSE @ZeroDecimal END ELSE @ZeroDecimal END
    ,[dblCreditReport]              = CASE WHEN I.strTransactionType IN ('Invoice', 'Cash') OR (I.strTransactionType = 'Debit Memo' AND I.strType IN ('CF Tran', 'CF Invoice', 'Card Fueling Transaction')) OR (I.strTransactionType = 'Credit Memo' AND I.[ysnFromProvisional] = 1) THEN I.[dblLineItemGLAmount] + CASE WHEN I.[ysnImpactInventory] = 0 THEN ISNULL(I.[dblTaxesAddToCost], 0) ELSE @ZeroDecimal END ELSE @ZeroDecimal END
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
FROM #ARPostInvoiceDetail I
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
INSERT #ARInvoiceGLEntries
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
    ,[dblDebit]                     = CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN @ZeroDecimal ELSE I.[dblBaseLicenseGLAmount] + CASE WHEN I.[ysnImpactInventory] = 0 THEN ISNULL(I.[dblBaseTaxesAddToCost], 0) ELSE @ZeroDecimal END END
    ,[dblCredit]                    = CASE WHEN I.[ysnIsInvoicePositive] = 0 THEN @ZeroDecimal ELSE I.[dblBaseLicenseGLAmount] + CASE WHEN I.[ysnImpactInventory] = 0 THEN ISNULL(I.[dblBaseTaxesAddToCost], 0) ELSE @ZeroDecimal END END
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
    ,[dblDebitForeign]              = CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN @ZeroDecimal ELSE I.[dblLicenseGLAmount] + CASE WHEN I.[ysnImpactInventory] = 0 THEN ISNULL(I.[dblTaxesAddToCost], 0) ELSE @ZeroDecimal END END
    ,[dblDebitReport]               = CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN @ZeroDecimal ELSE I.[dblLicenseGLAmount] + CASE WHEN I.[ysnImpactInventory] = 0 THEN ISNULL(I.[dblTaxesAddToCost], 0) ELSE @ZeroDecimal END END
    ,[dblCreditForeign]             = CASE WHEN I.[ysnIsInvoicePositive] = 0 THEN @ZeroDecimal ELSE I.[dblLicenseGLAmount] + CASE WHEN I.[ysnImpactInventory] = 0 THEN ISNULL(I.[dblTaxesAddToCost], 0) ELSE @ZeroDecimal END END
    ,[dblCreditReport]              = CASE WHEN I.[ysnIsInvoicePositive] = 0 THEN @ZeroDecimal ELSE I.[dblLicenseGLAmount] + CASE WHEN I.[ysnImpactInventory] = 0 THEN ISNULL(I.[dblTaxesAddToCost], 0) ELSE @ZeroDecimal END END
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
    #ARPostInvoiceDetail I
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
INSERT #ARInvoiceGLEntries
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
    ,[dblDebit]                     = CASE WHEN I.[ysnIsInvoicePositive] = 0 THEN @ZeroDecimal ELSE I.[dblBaseLicenseGLAmount] + CASE WHEN I.[ysnImpactInventory] = 0 THEN ISNULL(I.[dblBaseTaxesAddToCost], 0) ELSE @ZeroDecimal END END
    ,[dblCredit]                    = CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN @ZeroDecimal ELSE I.[dblBaseLicenseGLAmount] + CASE WHEN I.[ysnImpactInventory] = 0 THEN ISNULL(I.[dblBaseTaxesAddToCost], 0) ELSE @ZeroDecimal END END
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
    ,[dblDebitForeign]              = CASE WHEN I.[ysnIsInvoicePositive] = 0 THEN @ZeroDecimal ELSE I.[dblLicenseGLAmount] + CASE WHEN I.[ysnImpactInventory] = 0 THEN ISNULL(I.[dblTaxesAddToCost], 0) ELSE @ZeroDecimal END END
    ,[dblDebitReport]               = CASE WHEN I.[ysnIsInvoicePositive] = 0 THEN @ZeroDecimal ELSE I.[dblLicenseGLAmount] + CASE WHEN I.[ysnImpactInventory] = 0 THEN ISNULL(I.[dblTaxesAddToCost], 0) ELSE @ZeroDecimal END END
    ,[dblCreditForeign]             = CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN @ZeroDecimal ELSE I.[dblLicenseGLAmount] + CASE WHEN I.[ysnImpactInventory] = 0 THEN ISNULL(I.[dblTaxesAddToCost], 0) ELSE @ZeroDecimal END END
    ,[dblCreditReport]              = CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN @ZeroDecimal ELSE I.[dblLicenseGLAmount] + CASE WHEN I.[ysnImpactInventory] = 0 THEN ISNULL(I.[dblTaxesAddToCost], 0) ELSE @ZeroDecimal END END
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
    #ARPostInvoiceDetail I
WHERE
    I.[intPeriodsToAccrue] > 1
    AND I.[dblLicenseAmount] <> @ZeroDecimal
    AND I.[strMaintenanceType] IN ('License/Maintenance', 'License Only')
    AND I.[strItemType] = 'Software'
    AND I.[strTransactionType] NOT IN ('Cash Refund', 'Debit Memo')
    AND I.[ysnAccrueLicense] = 0

--SOFTWARE MAINTENANCE/SAAS DEBIT
INSERT #ARInvoiceGLEntries
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
    ,[dblDebit]                     = CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN @ZeroDecimal ELSE I.[dblBaseMaintenanceGLAmount] + CASE WHEN I.[ysnImpactInventory] = 0 THEN ISNULL(I.[dblBaseTaxesAddToCost], 0) ELSE @ZeroDecimal END END
    ,[dblCredit]                    = CASE WHEN I.[ysnIsInvoicePositive] = 0 THEN @ZeroDecimal ELSE I.[dblBaseMaintenanceGLAmount] + CASE WHEN I.[ysnImpactInventory] = 0 THEN ISNULL(I.[dblBaseTaxesAddToCost], 0) ELSE @ZeroDecimal END END
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
    ,[dblDebitForeign]              = CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN @ZeroDecimal ELSE I.[dblMaintenanceGLAmount] + CASE WHEN I.[ysnImpactInventory] = 0 THEN ISNULL(I.[dblTaxesAddToCost], 0) ELSE @ZeroDecimal END END
    ,[dblDebitReport]               = CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN @ZeroDecimal ELSE I.[dblMaintenanceGLAmount] + CASE WHEN I.[ysnImpactInventory] = 0 THEN ISNULL(I.[dblTaxesAddToCost], 0) ELSE @ZeroDecimal END END
    ,[dblCreditForeign]             = CASE WHEN I.[ysnIsInvoicePositive] = 0 THEN @ZeroDecimal ELSE I.[dblMaintenanceGLAmount] + CASE WHEN I.[ysnImpactInventory] = 0 THEN ISNULL(I.[dblTaxesAddToCost], 0) ELSE @ZeroDecimal END END
    ,[dblCreditReport]              = CASE WHEN I.[ysnIsInvoicePositive] = 0 THEN @ZeroDecimal ELSE I.[dblMaintenanceGLAmount] + CASE WHEN I.[ysnImpactInventory] = 0 THEN ISNULL(I.[dblTaxesAddToCost], 0) ELSE @ZeroDecimal END END
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
    #ARPostInvoiceDetail I
WHERE
    I.[intPeriodsToAccrue] <= 1
    AND I.[dblMaintenanceAmount] <> @ZeroDecimal
    AND I.[strMaintenanceType] IN ('License/Maintenance', 'Maintenance Only', 'SaaS')
    AND I.[strItemType] = 'Software'
    AND I.[strTransactionType] NOT IN ('Cash Refund', 'Debit Memo')

--SOFTWARE MAINTENANCE/SAAS CREDIT
INSERT #ARInvoiceGLEntries
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
    ,[dblDebit]                     = CASE WHEN I.[strTransactionType] IN ('Invoice', 'Cash') THEN @ZeroDecimal ELSE I.[dblBaseLineItemGLAmount] + CASE WHEN I.[ysnImpactInventory] = 0 THEN ISNULL(I.[dblBaseTaxesAddToCost], 0) ELSE @ZeroDecimal END END
    ,[dblCredit]                    = CASE WHEN I.[strTransactionType] IN ('Invoice', 'Cash') THEN I.[dblBaseLineItemGLAmount] + CASE WHEN I.[ysnImpactInventory] = 0 THEN ISNULL(I.[dblBaseTaxesAddToCost], 0) ELSE @ZeroDecimal END ELSE @ZeroDecimal END
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
    ,[dblDebitForeign]              = CASE WHEN I.[strTransactionType] IN ('Invoice', 'Cash') THEN @ZeroDecimal ELSE I.[dblLineItemGLAmount] + CASE WHEN I.[ysnImpactInventory] = 0 THEN ISNULL(I.[dblTaxesAddToCost], 0) ELSE @ZeroDecimal END END
    ,[dblDebitReport]               = CASE WHEN I.[strTransactionType] IN ('Invoice', 'Cash') THEN @ZeroDecimal ELSE I.[dblLineItemGLAmount] + CASE WHEN I.[ysnImpactInventory] = 0 THEN ISNULL(I.[dblTaxesAddToCost], 0) ELSE @ZeroDecimal END END
    ,[dblCreditForeign]             = CASE WHEN I.[strTransactionType] IN ('Invoice', 'Cash') THEN I.[dblLineItemGLAmount] + CASE WHEN I.[ysnImpactInventory] = 0 THEN ISNULL(I.[dblTaxesAddToCost], 0) ELSE @ZeroDecimal END ELSE @ZeroDecimal END
    ,[dblCreditReport]              = CASE WHEN I.[strTransactionType] IN ('Invoice', 'Cash') THEN I.[dblLineItemGLAmount] + CASE WHEN I.[ysnImpactInventory] = 0 THEN ISNULL(I.[dblTaxesAddToCost], 0) ELSE @ZeroDecimal END ELSE @ZeroDecimal END
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
    #ARPostInvoiceDetail I
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

-- --FINAL INVOICE DEBIT
-- INSERT #ARInvoiceGLEntries
--     ([dtmDate]
--     ,[strBatchId]
--     ,[intAccountId]
--     ,[dblDebit]
--     ,[dblCredit]
--     ,[dblDebitUnit]
--     ,[dblCreditUnit]
--     ,[strDescription]
--     ,[strCode]
--     ,[strReference]
--     ,[intCurrencyId]
--     ,[dblExchangeRate]
--     ,[dtmDateEntered]
--     ,[dtmTransactionDate]
--     ,[strJournalLineDescription]
--     ,[intJournalLineNo]
--     ,[ysnIsUnposted]
--     ,[intUserId]
--     ,[intEntityId]
--     ,[strTransactionId]
--     ,[intTransactionId]
--     ,[strTransactionType]
--     ,[strTransactionForm]
--     ,[strModuleName]
--     ,[intConcurrencyId]
--     ,[dblDebitForeign]
--     ,[dblDebitReport]
--     ,[dblCreditForeign]
--     ,[dblCreditReport]
--     ,[dblReportingRate]
--     ,[dblForeignRate]
--     ,[strRateType]
--     ,[strDocument]
--     ,[strComments]
--     ,[strSourceDocumentId]
--     ,[intSourceLocationId]
--     ,[intSourceUOMId]
--     ,[dblSourceUnitDebit]
--     ,[dblSourceUnitCredit]
--     ,[intCommodityId]
--     ,[intSourceEntityId]
--     ,[ysnRebuild])
-- SELECT
--      [dtmDate]                      = CAST(ISNULL(I.[dtmPostDate], I.[dtmDate]) AS DATE)
--     ,[strBatchId]                   = I.[strBatchId]
--     ,[intAccountId]                 = I.[intSalesAccountId]
--     ,[dblDebit]                     = CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN I.[dblBaseInvoiceTotal] + CASE WHEN I.[ysnImpactInventory] = 0 THEN ISNULL(I.[dblBaseTaxesAddToCost], 0) ELSE @ZeroDecimal END ELSE @ZeroDecimal END
--     ,[dblCredit]                    = CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN @ZeroDecimal ELSE I.[dblBaseInvoiceTotal] + CASE WHEN I.[ysnImpactInventory] = 0 THEN ISNULL(I.[dblBaseTaxesAddToCost], 0) ELSE @ZeroDecimal END END
--     ,[dblDebitUnit]                 = @ZeroDecimal
--     ,[dblCreditUnit]                = @ZeroDecimal
--     ,[strDescription]               = I.[strDescription]
--     ,[strCode]                      = @CODE
--     ,[strReference]                 = I.[strCustomerNumber]
--     ,[intCurrencyId]                = I.[intCurrencyId]
--     ,[dblExchangeRate]              = I.[dblCurrencyExchangeRate]
--     ,[dtmDateEntered]               = I.[dtmDatePosted]
--     ,[dtmTransactionDate]           = I.[dtmDate]
--     ,[strJournalLineDescription]    = I.[strItemDescription]
--     ,[intJournalLineNo]             = I.[intInvoiceDetailId]
--     ,[ysnIsUnposted]                = 0
--     ,[intUserId]                    = I.[intUserId]
--     ,[intEntityId]                  = I.[intEntityId]
--     ,[strTransactionId]             = I.[strInvoiceNumber]
--     ,[intTransactionId]             = I.[intInvoiceId]
--     ,[strTransactionType]           = I.[strTransactionType]
--     ,[strTransactionForm]           = @SCREEN_NAME
--     ,[strModuleName]                = @MODULE_NAME
--     ,[intConcurrencyId]             = 1
--     ,[dblDebitForeign]              = CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN I.[dblInvoiceTotal] + CASE WHEN I.[ysnImpactInventory] = 0 THEN ISNULL(I.[dblTaxesAddToCost], 0) ELSE @ZeroDecimal END ELSE @ZeroDecimal END
--     ,[dblDebitReport]               = CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN I.[dblInvoiceTotal] + CASE WHEN I.[ysnImpactInventory] = 0 THEN ISNULL(I.[dblTaxesAddToCost], 0) ELSE @ZeroDecimal END ELSE @ZeroDecimal END
--     ,[dblCreditForeign]             = CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN @ZeroDecimal ELSE I.[dblInvoiceTotal] + CASE WHEN I.[ysnImpactInventory] = 0 THEN ISNULL(I.[dblTaxesAddToCost], 0) ELSE @ZeroDecimal END END
--     ,[dblCreditReport]              = CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN @ZeroDecimal ELSE I.[dblInvoiceTotal] + CASE WHEN I.[ysnImpactInventory] = 0 THEN ISNULL(I.[dblTaxesAddToCost], 0) ELSE @ZeroDecimal END END
--     ,[dblReportingRate]             = I.[dblCurrencyExchangeRate]
--     ,[dblForeignRate]               = I.[dblCurrencyExchangeRate]
--     ,[strRateType]                  = I.[strCurrencyExchangeRateType]
--     ,[strDocument]                  = NULL
--     ,[strComments]                  = NULL
--     ,[strSourceDocumentId]          = NULL
--     ,[intSourceLocationId]          = NULL
--     ,[intSourceUOMId]               = NULL
--     ,[dblSourceUnitDebit]           = NULL
--     ,[dblSourceUnitCredit]          = NULL
--     ,[intCommodityId]               = NULL
--     ,[intSourceEntityId]            = I.[intEntityCustomerId]
--     ,[ysnRebuild]                   = NULL
-- FROM
--     #ARPostInvoiceDetail I
-- WHERE
--     I.[intPeriodsToAccrue] <= 1
-- 	AND I.[ysnFromProvisional] = 1
--     --AND ((I.[dblInvoiceTotal] - I.[dblProvisionalAmount]) <> @ZeroDecimal)
-- 	AND I.[dblInvoiceTotal] <> @ZeroDecimal
-- 	AND I.[dblProvisionalAmount] = @ZeroDecimal
--     AND I.[intItemId] IS NOT NULL
--     AND I.[strItemType] NOT IN ('Non-Inventory','Service','Other Charge','Software','Comment')
--     AND I.[strTransactionType] NOT IN ('Cash Refund', 'Debit Memo')

--FINAL INVOICE CREDIT
INSERT #ARInvoiceGLEntries
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
    ,[dblDebit]                     = CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN @ZeroDecimal ELSE I.[dblBaseLineItemGLAmount] + CASE WHEN I.[ysnImpactInventory] = 0 THEN ISNULL(I.[dblBaseTaxesAddToCost], 0) ELSE @ZeroDecimal END END
    ,[dblCredit]                    = CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN I.[dblBaseLineItemGLAmount] + CASE WHEN I.[ysnImpactInventory] = 0 THEN ISNULL(I.[dblBaseTaxesAddToCost], 0) ELSE @ZeroDecimal END ELSE @ZeroDecimal END
    ,[dblDebitUnit]                 = @ZeroDecimal
    ,[dblCreditUnit]                = @ZeroDecimal
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
    ,[dblDebitForeign]              = CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN @ZeroDecimal ELSE I.[dblLineItemGLAmount] + CASE WHEN I.[ysnImpactInventory] = 0 THEN ISNULL(I.[dblTaxesAddToCost], 0) ELSE @ZeroDecimal END END
    ,[dblDebitReport]               = CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN @ZeroDecimal ELSE I.[dblLineItemGLAmount] + CASE WHEN I.[ysnImpactInventory] = 0 THEN ISNULL(I.[dblTaxesAddToCost], 0) ELSE @ZeroDecimal END END
    ,[dblCreditForeign]             = CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN I.[dblLineItemGLAmount] + CASE WHEN I.[ysnImpactInventory] = 0 THEN ISNULL(I.[dblTaxesAddToCost], 0) ELSE @ZeroDecimal END ELSE @ZeroDecimal END
    ,[dblCreditReport]              = CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN I.[dblLineItemGLAmount] + CASE WHEN I.[ysnImpactInventory] = 0 THEN ISNULL(I.[dblTaxesAddToCost], 0) ELSE @ZeroDecimal END ELSE @ZeroDecimal END
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
    #ARPostInvoiceDetail I
WHERE
    I.[intPeriodsToAccrue] <= 1
	AND I.[ysnFromProvisional] = 1
	AND I.[dblBaseLineItemGLAmount] <> @ZeroDecimal
	--AND I.[dblProvisionalAmount] <> @ZeroDecimal
    AND I.[intItemId] IS NOT NULL
    AND I.[strItemType] NOT IN ('Non-Inventory','Service','Other Charge','Software','Comment')
    AND I.[strTransactionType] NOT IN ('Cash Refund', 'Debit Memo')

--DEBIT MEMO DEBIT
INSERT #ARInvoiceGLEntries
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
    ,[dblDebit]                     = CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN @ZeroDecimal ELSE I.[dblBaseLineItemGLAmount] + CASE WHEN I.[ysnImpactInventory] = 0 THEN ISNULL(I.[dblBaseTaxesAddToCost], 0) ELSE @ZeroDecimal END END
    ,[dblCredit]                    = CASE WHEN I.[ysnIsInvoicePositive] = 0 THEN @ZeroDecimal ELSE I.[dblBaseLineItemGLAmount] + CASE WHEN I.[ysnImpactInventory] = 0 THEN ISNULL(I.[dblBaseTaxesAddToCost], 0) ELSE @ZeroDecimal END END
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
    ,[dblDebitForeign]              = CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN @ZeroDecimal ELSE I.[dblLineItemGLAmount] + CASE WHEN I.[ysnImpactInventory] = 0 THEN ISNULL(I.[dblTaxesAddToCost], 0) ELSE @ZeroDecimal END END
    ,[dblDebitReport]               = CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN @ZeroDecimal ELSE I.[dblLineItemGLAmount] + CASE WHEN I.[ysnImpactInventory] = 0 THEN ISNULL(I.[dblTaxesAddToCost], 0) ELSE @ZeroDecimal END END
    ,[dblCreditForeign]             = CASE WHEN I.[ysnIsInvoicePositive] = 0 THEN @ZeroDecimal ELSE I.[dblLineItemGLAmount] + CASE WHEN I.[ysnImpactInventory] = 0 THEN ISNULL(I.[dblTaxesAddToCost], 0) ELSE @ZeroDecimal END END
    ,[dblCreditReport]              = CASE WHEN I.[ysnIsInvoicePositive] = 0 THEN @ZeroDecimal ELSE I.[dblLineItemGLAmount] + CASE WHEN I.[ysnImpactInventory] = 0 THEN ISNULL(I.[dblTaxesAddToCost], 0) ELSE @ZeroDecimal END END
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
    #ARPostInvoiceDetail I
WHERE
    I.[intPeriodsToAccrue] <= 1
    AND I.[dblQtyShipped] <> @ZeroDecimal
    -- AND I.[strType] NOT IN ('CF Tran', 'CF Invoice', 'Card Fueling Transaction')
    AND I.[strTransactionType] = 'Debit Memo'
    AND I.[strItemType] <> 'Comment'

--dblShipping <> 0
INSERT #ARInvoiceGLEntries
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
    #ARPostInvoiceHeader I
WHERE
    I.[dblShipping] <> @ZeroDecimal

--TAX DETAIL DEBIT
INSERT #ARInvoiceGLEntries
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
    ,[intAccountId]                 = CASE WHEN ARIDT.[ysnAddToCost] = 0 THEN ARIDT.[intSalesTaxAccountId] ELSE dbo.fnGetItemGLAccount(I.intItemId, I.intItemLocationId, 'Cost of Goods') END
    ,[dblDebit]                     = CASE WHEN I.[ysnIsInvoicePositive] = 1 
                                           THEN (CASE WHEN ARIDT.[dblBaseAdjustedTax] < @ZeroDecimal THEN ABS(ARIDT.[dblBaseAdjustedTax]) ELSE @ZeroDecimal END )
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
                                           THEN (CASE WHEN ARIDT.[dblAdjustedTax] < @ZeroDecimal THEN ABS(ARIDT.[dblAdjustedTax]) ELSE @ZeroDecimal END )
                                           ELSE (CASE WHEN ARIDT.[dblAdjustedTax] < @ZeroDecimal THEN @ZeroDecimal ELSE ARIDT.[dblAdjustedTax] END)
                                      END
    ,[dblDebitReport]               = CASE WHEN I.[ysnIsInvoicePositive] = 1 
                                           THEN (CASE WHEN ARIDT.[dblAdjustedTax] < @ZeroDecimal THEN ABS(ARIDT.[dblAdjustedTax]) ELSE @ZeroDecimal END )
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
		 , IDT.[intSalesTaxExemptionAccountId]
		 , IDT.[dblAdjustedTax]
		 , IDT.[dblBaseAdjustedTax]
		 , [ysnAddToCost]  = ISNULL(TC.[ysnAddToCost], 0)
    FROM tblARInvoiceDetailTax IDT WITH (NOLOCK)
	INNER JOIN tblSMTaxCode TC ON IDT.intTaxCodeId = TC.intTaxCodeId	
) ARIDT
INNER JOIN #ARPostInvoiceDetail I ON ARIDT.[intInvoiceDetailId] = I.[intInvoiceDetailId]
WHERE I.[intPeriodsToAccrue] <= 1
  AND ARIDT.[dblAdjustedTax] <> @ZeroDecimal
  AND (I.[ysnImpactInventory] = 1 OR (I.[ysnImpactInventory] = 0 AND ARIDT.[ysnAddToCost] = 0))

--TAX DETAIL ADD TO COST
INSERT #ARInvoiceGLEntries
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
    ,[intAccountId]                 = ARIDT.[intSalesTaxExemptionAccountId]
    ,[dblDebit]                     = CASE WHEN I.[ysnIsInvoicePositive] = 0 
                                           THEN (CASE WHEN ARIDT.[dblBaseAdjustedTax] < @ZeroDecimal THEN ABS(ARIDT.[dblBaseAdjustedTax]) ELSE @ZeroDecimal END )
                                           ELSE (CASE WHEN ARIDT.[dblBaseAdjustedTax] < @ZeroDecimal THEN @ZeroDecimal ELSE ARIDT.[dblBaseAdjustedTax] END)
                                      END
    ,[dblCredit]                    = CASE WHEN I.[ysnIsInvoicePositive] = 1 
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
    ,[dblDebitForeign]              = CASE WHEN I.[ysnIsInvoicePositive] = 0 
                                           THEN (CASE WHEN ARIDT.[dblAdjustedTax] < @ZeroDecimal THEN ABS(ARIDT.[dblAdjustedTax]) ELSE @ZeroDecimal END )
                                           ELSE (CASE WHEN ARIDT.[dblAdjustedTax] < @ZeroDecimal THEN @ZeroDecimal ELSE ARIDT.[dblAdjustedTax] END)
                                      END
    ,[dblDebitReport]               = CASE WHEN I.[ysnIsInvoicePositive] = 0 
                                           THEN (CASE WHEN ARIDT.[dblAdjustedTax] < @ZeroDecimal THEN ABS(ARIDT.[dblAdjustedTax]) ELSE @ZeroDecimal END )
                                           ELSE (CASE WHEN ARIDT.[dblAdjustedTax] < @ZeroDecimal THEN @ZeroDecimal ELSE ARIDT.[dblAdjustedTax] END)
                                      END
    ,[dblCreditForeign]             = CASE WHEN I.[ysnIsInvoicePositive] = 1 
                                           THEN (CASE WHEN ARIDT.[dblAdjustedTax] < @ZeroDecimal THEN ABS(ARIDT.[dblAdjustedTax]) ELSE @ZeroDecimal END )
                                           ELSE (CASE WHEN ARIDT.[dblAdjustedTax] < @ZeroDecimal THEN @ZeroDecimal ELSE ARIDT.[dblAdjustedTax] END)
                                      END
    ,[dblCreditReport]              = CASE WHEN I.[ysnIsInvoicePositive] = 1 
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
		 , IDT.[intSalesTaxExemptionAccountId]
		 , IDT.[dblAdjustedTax]
		 , IDT.[dblBaseAdjustedTax]
    FROM tblARInvoiceDetailTax IDT WITH (NOLOCK)
	INNER JOIN tblSMTaxCode TC ON IDT.intTaxCodeId = TC.intTaxCodeId
	WHERE ISNULL(TC.[ysnAddToCost], 0) = 1
) ARIDT
INNER JOIN #ARPostInvoiceDetail I ON ARIDT.[intInvoiceDetailId] = I.[intInvoiceDetailId]
WHERE I.[intPeriodsToAccrue] <= 1
  AND I.[ysnImpactInventory] = 1
  AND ARIDT.[dblAdjustedTax] <> @ZeroDecimal  

--SALES DISCOUNT
INSERT #ARInvoiceGLEntries
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
    #ARPostInvoiceDetail I
LEFT OUTER JOIN
    #ARInvoiceItemAccount IA
       ON I.[intItemId] = IA.[intItemId]
       AND I.[intCompanyLocationId] = IA.[intLocationId]
WHERE
    I.[dblBaseDiscountAmount] <> @ZeroDecimal

RETURN 1 
