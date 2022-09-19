﻿CREATE PROCEDURE [dbo].[uspARGenerateGLEntriesForInvoices]
    @strSessionId		NVARCHAR(50) = NULL
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET ANSI_WARNINGS OFF

DECLARE  @MODULE_NAME		        NVARCHAR(25) = 'Accounts Receivable'
        ,@SCREEN_NAME		        NVARCHAR(25) = 'Invoice'
	    ,@CODE				        NVARCHAR(25) = 'AR'
	    ,@POSTDESC			        NVARCHAR(10) = 'Posted '
	    ,@ZeroDecimal		        DECIMAL(18,6) = 0
	    ,@OneDecimal	            DECIMAL(18,6) = 1
	    ,@OneHundredDecimal	        DECIMAL(18,6) = 100
	    ,@PostDate		            DATETIME = CAST(GETDATE() AS DATE)
        ,@AllowIntraEntries         BIT
        ,@DueToAccountId            INT
        ,@DueFromAccountId          INT
        ,@AllowIntraCompanyEntries  BIT
        ,@AllowIntraLocationEntries BIT

SELECT TOP 1
     @AllowIntraEntries         = CASE WHEN ISNULL(ysnAllowIntraCompanyEntries, 0) = 1 OR ISNULL(ysnAllowIntraLocationEntries, 0) = 1 THEN 1 ELSE 0 END
    ,@AllowIntraCompanyEntries  = ISNULL(ysnAllowIntraCompanyEntries, 0)
    ,@AllowIntraLocationEntries = ISNULL(ysnAllowIntraLocationEntries, 0)
    ,@DueToAccountId            = ISNULL([intDueToAccountId], 0)
    ,@DueFromAccountId          = ISNULL([intDueFromAccountId], 0)
FROM tblARCompanyPreference

--REVERSE PROVISIONAL INVOICE
INSERT INTO tblARPostInvoiceGLEntries WITH (TABLOCK) (
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
    ,[intSourceEntityId]
    ,[strSessionId])
SELECT [dtmDate]					= CAST(ISNULL(P.[dtmPostDate], P.[dtmDate]) AS DATE)
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
    ,[strSessionId]                 = @strSessionId
FROM tblARPostInvoiceHeader P
INNER JOIN tblGLDetail GL ON P.[intOriginalInvoiceId] = GL.[intTransactionId] AND P.[strInvoiceOriginId] = GL.[strTransactionId]
WHERE P.[intOriginalInvoiceId] IS NOT NULL
  AND P.[ysnFromProvisional] = 1
  AND P.[ysnProvisionalWithGL] = 1 
  AND P.[ysnPost] = 1
  AND (
    (P.[strTransactionType] <> 'Credit Memo' AND P.[dblBaseInvoiceTotal] = 0.000000 AND P.[dblInvoiceTotal] = 0.000000)
    OR
    (P.[strTransactionType] IN ('Credit Memo', 'Invoice') AND P.[dblBaseInvoiceTotal] <> 0.000000 AND P.[dblProvisionalAmount] <> 0.000000)
   )
  AND GL.[ysnIsUnposted] = 0
  AND GL.[strModuleName] = @MODULE_NAME
  AND P.strSessionId = @strSessionId
ORDER BY GL.intGLDetailId	

--NORMAL INVOICES
INSERT tblARPostInvoiceGLEntries WITH (TABLOCK) (
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
    ,[intSourceEntityId]
    ,[strSessionId])
SELECT [dtmDate]                    = CAST(ISNULL(I.[dtmPostDate], I.[dtmDate]) AS DATE)
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
    ,[intSourceEntityId]            = I.[intEntityCustomerId]
    ,[strSessionId]                 = @strSessionId    
FROM tblARPostInvoiceHeader I
LEFT OUTER JOIN (
    SELECT [dblUnitQtyShipped]		= SUM([dblUnitQtyShipped])		
         , [intInvoiceId]			= [intInvoiceId]
    FROM tblARPostInvoiceDetail
    WHERE strSessionId = @strSessionId
    GROUP BY [intInvoiceId]
) ARID ON I.[intInvoiceId] = ARID.[intInvoiceId]
WHERE I.[intPeriodsToAccrue] <= 1
  AND I.[ysnFromProvisional] = 0
  AND (
    I.[dblInvoiceTotal] <> @ZeroDecimal
    OR
    EXISTS(SELECT NULL FROM tblARPostInvoiceDetail ARID WHERE ARID.[intItemId] IS NOT NULL AND ARID.[strItemType] <> 'Comment' AND ARID.intInvoiceId  = I.[intInvoiceId] AND ARID.strSessionId = @strSessionId)
  )
  AND I.strType <> 'Tax Adjustment'
  AND I.strSessionId = @strSessionId

--DUE TO ACCOUNT CREDIT
INSERT tblARPostInvoiceGLEntries WITH (TABLOCK) (
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
    ,[intSourceEntityId]
    ,[strSessionId])
SELECT [dtmDate]                    = CAST(ISNULL(I.[dtmPostDate], I.[dtmDate]) AS DATE)
    ,[strBatchId]                   = I.[strBatchId]
    ,[intAccountId]                 = OVERRIDESEGMENT.intOverrideAccount
    ,[dblDebit]                     = CASE WHEN I.[strTransactionType] NOT IN ('Credit Memo', 'Overpayment', 'Credit', 'Customer Prepayment', 'Cash Refund') THEN @ZeroDecimal ELSE I.[dblBaseInvoiceTotal] END
    ,[dblCredit]                    = CASE WHEN I.[strTransactionType] IN ('Credit Memo', 'Overpayment', 'Credit', 'Customer Prepayment', 'Cash Refund') THEN @ZeroDecimal ELSE I.[dblBaseInvoiceTotal] END
    ,[dblDebitUnit]                 = CASE WHEN I.[strTransactionType] NOT IN ('Credit Memo', 'Overpayment', 'Credit', 'Customer Prepayment', 'Cash Refund') THEN @ZeroDecimal ELSE ARID.[dblUnitQtyShipped] END
    ,[dblCreditUnit]                = CASE WHEN I.[strTransactionType] IN ('Credit Memo', 'Overpayment', 'Credit', 'Customer Prepayment', 'Cash Refund') THEN @ZeroDecimal ELSE ARID.[dblUnitQtyShipped] END
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
    ,[dblDebitForeign]              = CASE WHEN I.[strTransactionType] NOT IN ('Credit Memo', 'Overpayment', 'Credit', 'Customer Prepayment', 'Cash Refund') THEN @ZeroDecimal ELSE I.[dblInvoiceTotal] END
    ,[dblDebitReport]               = CASE WHEN I.[strTransactionType] NOT IN ('Credit Memo', 'Overpayment', 'Credit', 'Customer Prepayment', 'Cash Refund') THEN @ZeroDecimal ELSE I.[dblInvoiceTotal] END
    ,[dblCreditForeign]             = CASE WHEN I.[strTransactionType] IN ('Credit Memo', 'Overpayment', 'Credit', 'Customer Prepayment', 'Cash Refund') THEN @ZeroDecimal ELSE I.[dblInvoiceTotal] END
    ,[dblCreditReport]              = CASE WHEN I.[strTransactionType] IN ('Credit Memo', 'Overpayment', 'Credit', 'Customer Prepayment', 'Cash Refund') THEN @ZeroDecimal ELSE I.[dblInvoiceTotal] END
    ,[dblReportingRate]             = I.[dblAverageExchangeRate]
    ,[dblForeignRate]               = I.[dblAverageExchangeRate]    
    ,[intSourceEntityId]            = I.[intEntityCustomerId]
    ,[strSessionId]                 = @strSessionId    
FROM tblARPostInvoiceHeader I
LEFT OUTER JOIN (
    SELECT 
         [dblUnitQtyShipped]    = SUM([dblUnitQtyShipped])
        ,[intInvoiceId]
        ,[intSalesAccountId]
    FROM tblARPostInvoiceDetail
    WHERE strSessionId = @strSessionId
    GROUP BY 
         [intInvoiceId]
        ,[intSalesAccountId]
) ARID ON I.[intInvoiceId] = ARID.[intInvoiceId]
OUTER APPLY (
	SELECT intOverrideAccount
	FROM dbo.[fnARGetOverrideAccount](I.[intAccountId], @DueToAccountId, @AllowIntraCompanyEntries, @AllowIntraLocationEntries, 0)
) OVERRIDESEGMENT
WHERE I.[intPeriodsToAccrue] <= 1
  AND I.[ysnFromProvisional] = 0
  AND (
    I.[dblInvoiceTotal] <> @ZeroDecimal
    OR
    EXISTS(SELECT NULL FROM tblARPostInvoiceDetail ARID WHERE ARID.[intItemId] IS NOT NULL AND ARID.[strItemType] <> 'Comment' AND ARID.intInvoiceId  = I.[intInvoiceId] AND ARID.strSessionId = @strSessionId)
  )
  AND I.strType <> 'Tax Adjustment'
  AND I.strSessionId = @strSessionId
  AND @AllowIntraEntries = 1
  AND @DueFromAccountId <> 0
  AND ([dbo].[fnARCompareAccountSegment](I.[intAccountId], ARID.[intSalesAccountId], 6) = 0 OR [dbo].[fnARCompareAccountSegment](I.[intAccountId], ARID.[intSalesAccountId], 3) = 0)

--PROVISIONAL INVOICES
INSERT tblARPostInvoiceGLEntries WITH (TABLOCK) (
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
    ,[intSourceEntityId]
    ,[strSessionId]
)
SELECT [dtmDate]                    = CAST(ISNULL(I.[dtmPostDate], I.[dtmDate]) AS DATE)
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
    ,[intSourceEntityId]            = I.[intEntityCustomerId]
    ,[strSessionId]                 = @strSessionId
FROM tblARPostInvoiceHeader I
LEFT OUTER JOIN (
    SELECT [dblUnitQtyShipped]		= SUM([dblUnitQtyShipped])
         , [intInvoiceId]			= [intInvoiceId]
    FROM tblARPostInvoiceDetail
    WHERE strSessionId = @strSessionId
    GROUP BY [intInvoiceId]
) ARID ON I.[intInvoiceId] = ARID.[intInvoiceId]
WHERE I.[intPeriodsToAccrue] <= 1
  AND I.[ysnFromProvisional] = 1
  AND I.[dblInvoiceTotal] <> @ZeroDecimal
  AND I.strSessionId = @strSessionId

--APPLIED CREDIT/PREPAIDS
INSERT tblARPostInvoiceGLEntries WITH (TABLOCK) (
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
   ,[intSourceEntityId]
   ,[strSessionId]
)
SELECT [dtmDate]                    = CAST(ISNULL(I.[dtmPostDate], I.[dtmDate]) AS DATE)
   ,[strBatchId]                   = I.[strBatchId]
   ,[intAccountId]                 = PPCI.[intAccountId]
   ,[dblDebit]                     = CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN PPC.[dblBaseAppliedInvoiceDetailAmount] ELSE @ZeroDecimal END
   ,[dblCredit]                    = CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN @ZeroDecimal ELSE PPC.[dblBaseAppliedInvoiceDetailAmount] END
   ,[dblDebitUnit]                 = @ZeroDecimal
   ,[dblCreditUnit]                = @ZeroDecimal
   ,[strDescription]               = I.[strDescription]
   ,[strCode]                      = @CODE
   ,[strReference]                 = I.[strCustomerNumber]
   ,[intCurrencyId]                = I.[intCurrencyId]
   ,[dblExchangeRate]              = I.[dblAverageExchangeRate]
   ,[dtmDateEntered]               = I.[dtmDatePosted]
   ,[dtmTransactionDate]           = I.[dtmDate]
   ,[strJournalLineDescription]    = 'Applied Prepaid - ' + PPCI.[strInvoiceNumber]
   ,[intJournalLineNo]             = PPC.[intPrepaidAndCreditId]
   ,[ysnIsUnposted]                = 0
   ,[intUserId]                    = I.[intUserId]
   ,[intEntityId]                  = I.[intEntityId]
   ,[strTransactionId]             = I.[strInvoiceNumber]
   ,[intTransactionId]             = I.[intInvoiceId]
   ,[strTransactionType]           = I.[strTransactionType]
   ,[strTransactionForm]           = @SCREEN_NAME
   ,[strModuleName]                = @MODULE_NAME
   ,[intConcurrencyId]             = 1
   ,[dblDebitForeign]              = CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN PPC.[dblAppliedInvoiceDetailAmount] ELSE @ZeroDecimal END
   ,[dblDebitReport]               = CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN PPC.[dblAppliedInvoiceDetailAmount] ELSE @ZeroDecimal END
   ,[dblCreditForeign]             = CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN @ZeroDecimal ELSE PPC.[dblAppliedInvoiceDetailAmount] END
   ,[dblCreditReport]              = CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN @ZeroDecimal ELSE PPC.[dblAppliedInvoiceDetailAmount] END
   ,[dblReportingRate]             = I.[dblAverageExchangeRate]
   ,[dblForeignRate]               = I.[dblAverageExchangeRate]  
   ,[intSourceEntityId]            = I.[intEntityCustomerId]
   ,[strSessionId]                 = @strSessionId
FROM tblARPostInvoiceHeader I
INNER JOIN tblARPrepaidAndCredit PPC ON PPC.[intInvoiceId] = I.[intInvoiceId]
INNER JOIN tblARInvoice PPCI ON PPCI.intInvoiceId = PPC.intPrepaymentId
WHERE I.[intPeriodsToAccrue] <= 1
  AND PPC.ysnApplied = 1
  AND PPC.[dblAppliedInvoiceDetailAmount] <> @ZeroDecimal
  AND I.strTransactionType = 'Cash Refund'
  AND I.strSessionId = @strSessionId

--CASH TRANSACTION TYPE
INSERT tblARPostInvoiceGLEntries WITH (TABLOCK) (
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
    ,[intSourceEntityId]
    ,[strSessionId]
)
SELECT [dtmDate]                    = CAST(ISNULL(I.[dtmPostDate], I.[dtmDate]) AS DATE)
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
    ,[intSourceEntityId]            = I.[intEntityCustomerId]
    ,[strSessionId]                 = @strSessionId
FROM tblARPostInvoiceHeader I
WHERE I.[intPeriodsToAccrue] <= 1
  AND I.[dblPayment] <> @ZeroDecimal
  AND I.strSessionId = @strSessionId

--SALES ACCOUNT 
INSERT tblARPostInvoiceGLEntries WITH (TABLOCK) (
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
    ,[intSourceEntityId]
    ,[strSessionId]
)
SELECT [dtmDate]                    = CAST(ISNULL(I.[dtmPostDate], I.[dtmDate]) AS DATE)
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
    ,[intSourceEntityId]            = I.[intEntityCustomerId]
    ,[strSessionId]                 = @strSessionId
FROM tblARPostInvoiceDetail I
WHERE I.[intPeriodsToAccrue] <= 1
  AND (I.[dblTotal] <> @ZeroDecimal OR I.[dblQtyShipped] <> @ZeroDecimal)
  AND I.[strTransactionType] NOT IN ('Debit Memo', 'Cash Refund')
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
 AND I.strSessionId = @strSessionId
   
--SOFTWARE LICENSE DEBIT
INSERT tblARPostInvoiceGLEntries WITH (TABLOCK) (
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
    ,[intSourceEntityId]
    ,[strSessionId]
)
SELECT [dtmDate]                    = CAST(ISNULL(I.[dtmPostDate], I.[dtmDate]) AS DATE)
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
    ,[intSourceEntityId]            = I.[intEntityCustomerId]
    ,[strSessionId]                 = @strSessionId
FROM tblARPostInvoiceDetail I
WHERE I.[dblLicenseAmount] <> @ZeroDecimal
  AND I.[strMaintenanceType] IN ('License/Maintenance', 'License Only')
  AND I.[strItemType] = 'Software'
  AND I.[strTransactionType] NOT IN ('Cash Refund', 'Debit Memo')
  AND (I.[intPeriodsToAccrue] <= 1 OR (I.[intPeriodsToAccrue] > 1 AND I.[ysnAccrueLicense] = 0))
  AND I.strSessionId = @strSessionId

--SOFTWARE LICENSE CREDIT
INSERT tblARPostInvoiceGLEntries WITH (TABLOCK) (
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
    ,[intSourceEntityId]
    ,[strSessionId]
)
SELECT [dtmDate]                    = CAST(ISNULL(I.[dtmPostDate], I.[dtmDate]) AS DATE)
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
    ,[intSourceEntityId]            = I.[intEntityCustomerId]
    ,[strSessionId]                 = @strSessionId
FROM tblARPostInvoiceDetail I
WHERE I.[intPeriodsToAccrue] > 1
  AND I.[dblLicenseAmount] <> @ZeroDecimal
  AND I.[strMaintenanceType] IN ('License/Maintenance', 'License Only')
  AND I.[strItemType] = 'Software'
  AND I.[strTransactionType] NOT IN ('Cash Refund', 'Debit Memo')
  AND I.[ysnAccrueLicense] = 0
  AND I.strSessionId = @strSessionId

--SOFTWARE MAINTENANCE/SAAS DEBIT
INSERT tblARPostInvoiceGLEntries WITH (TABLOCK) (
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
    ,[intSourceEntityId]
    ,[strSessionId]
)
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
    ,[intSourceEntityId]            = I.[intEntityCustomerId]
    ,[strSessionId]                 = @strSessionId
FROM tblARPostInvoiceDetail I
WHERE I.[intPeriodsToAccrue] <= 1
  AND I.[dblMaintenanceAmount] <> @ZeroDecimal
  AND I.[strMaintenanceType] IN ('License/Maintenance', 'Maintenance Only', 'SaaS')
  AND I.[strItemType] = 'Software'
  AND I.[strTransactionType] NOT IN ('Cash Refund', 'Debit Memo')
  AND I.strSessionId = @strSessionId

--DUE FROM ACCOUNT DEBIT
INSERT tblARPostInvoiceGLEntries WITH (TABLOCK) (
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
    ,[intSourceEntityId]
    ,[strSessionId]
)
SELECT [dtmDate]                    = CAST(ISNULL(I.[dtmPostDate], I.[dtmDate]) AS DATE)
    ,[strBatchId]                   = I.[strBatchId]
    ,[intAccountId]                 = OVERRIDESEGMENT.intOverrideAccount
    ,[dblDebit]                     = CASE WHEN I.[strTransactionType] IN ('Invoice', 'Cash') THEN I.[dblBaseLineItemGLAmount] ELSE @ZeroDecimal END
    ,[dblCredit]                    = CASE WHEN I.[strTransactionType] IN ('Invoice', 'Cash') THEN @ZeroDecimal ELSE I.[dblBaseLineItemGLAmount] END
    ,[dblDebitUnit]                 = CASE WHEN I.[strTransactionType] IN ('Invoice', 'Cash') THEN I.[dblUnitQtyShipped] ELSE @ZeroDecimal END
    ,[dblCreditUnit]                = CASE WHEN I.[strTransactionType] IN ('Invoice', 'Cash') THEN @ZeroDecimal ELSE I.[dblUnitQtyShipped] END
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
    ,[dblDebitForeign]              = CASE WHEN I.[strTransactionType] IN ('Invoice', 'Cash') THEN I.[dblLineItemGLAmount] ELSE @ZeroDecimal END
    ,[dblDebitReport]               = CASE WHEN I.[strTransactionType] IN ('Invoice', 'Cash') THEN I.[dblLineItemGLAmount] ELSE @ZeroDecimal END
    ,[dblCreditForeign]             = CASE WHEN I.[strTransactionType] IN ('Invoice', 'Cash') THEN @ZeroDecimal ELSE I.[dblLineItemGLAmount] END
    ,[dblCreditReport]              = CASE WHEN I.[strTransactionType] IN ('Invoice', 'Cash') THEN @ZeroDecimal ELSE I.[dblLineItemGLAmount] END
    ,[dblReportingRate]             = I.[dblCurrencyExchangeRate]
    ,[dblForeignRate]               = I.[dblCurrencyExchangeRate]
    ,[strRateType]                  = I.[strCurrencyExchangeRateType]    
    ,[intSourceEntityId]            = I.[intEntityCustomerId]
    ,[strSessionId]                 = @strSessionId    
FROM tblARPostInvoiceDetail I
OUTER APPLY (
	SELECT intOverrideAccount
	FROM dbo.[fnARGetOverrideAccount](I.[intSalesAccountId], @DueFromAccountId, @AllowIntraCompanyEntries, @AllowIntraLocationEntries, 0)
) OVERRIDESEGMENT
WHERE I.[intPeriodsToAccrue] <= 1
  AND I.[ysnFromProvisional] = 0
  AND I.[strItemType] NOT IN ('Non-Inventory','Service','Other Charge','Software','Comment')
  AND I.[strTransactionType] NOT IN ('Cash Refund', 'Debit Memo')
  AND (I.[dblQtyShipped] <> @ZeroDecimal OR (I.[dblQtyShipped] = @ZeroDecimal AND I.[dblInvoiceTotal] = @ZeroDecimal))
  AND I.strType <> 'Tax Adjustment'
  AND @AllowIntraEntries = 1
  AND @DueFromAccountId <> 0
  AND ([dbo].[fnARCompareAccountSegment](I.[intAccountId], I.[intSalesAccountId], 6) = 0 OR [dbo].[fnARCompareAccountSegment](I.[intAccountId], I.[intSalesAccountId], 3) = 0)
  AND I.strSessionId = @strSessionId

--SOFTWARE MAINTENANCE/SAAS CREDIT
INSERT tblARPostInvoiceGLEntries WITH (TABLOCK) (
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
    ,[intSourceEntityId]
    ,[strSessionId]
)
SELECT [dtmDate]                    = CAST(ISNULL(I.[dtmPostDate], I.[dtmDate]) AS DATE)
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
    ,[intSourceEntityId]            = I.[intEntityCustomerId]
    ,[strSessionId]                 = @strSessionId
FROM tblARPostInvoiceDetail I
WHERE I.[intPeriodsToAccrue] <= 1
  AND I.[ysnFromProvisional] = 0
  AND I.[intItemId] IS NOT NULL
  AND I.[strItemType] NOT IN ('Non-Inventory','Service','Other Charge','Software','Comment')
  AND I.[strTransactionType] NOT IN ('Cash Refund', 'Debit Memo')
  AND (I.[dblQtyShipped] <> @ZeroDecimal OR (I.[dblQtyShipped] = @ZeroDecimal AND I.[dblInvoiceTotal] = @ZeroDecimal))
  AND I.strType <> 'Tax Adjustment'
  AND I.strSessionId = @strSessionId

--FINAL INVOICE CREDIT
INSERT tblARPostInvoiceGLEntries WITH (TABLOCK) (
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
    ,[intSourceEntityId]
    ,[strSessionId]
)
SELECT [dtmDate]                    = CAST(ISNULL(I.[dtmPostDate], I.[dtmDate]) AS DATE)
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
    ,[intSourceEntityId]            = I.[intEntityCustomerId]
    ,[strSessionId]                 = @strSessionId
FROM tblARPostInvoiceDetail I
WHERE I.[intPeriodsToAccrue] <= 1
  AND I.[ysnFromProvisional] = 1
  AND I.[dblBaseLineItemGLAmount] <> @ZeroDecimal
  AND I.[intItemId] IS NOT NULL
  AND I.[strItemType] NOT IN ('Non-Inventory','Service','Other Charge','Software','Comment')
  AND I.[strTransactionType] NOT IN ('Cash Refund', 'Debit Memo')
  AND I.strSessionId = @strSessionId

--FINAL INVOICES (DROP SHIP/ COGS)
INSERT tblARPostInvoiceGLEntries WITH (TABLOCK) (
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
    ,[intSourceEntityId]
    ,[strSessionId]
)
SELECT [dtmDate]                    = CAST(ISNULL(I.[dtmPostDate], I.[dtmDate]) AS DATE)
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
    ,[intSourceEntityId]            = I.[intEntityCustomerId]
    ,[strSessionId]                 = @strSessionId
FROM tblARPostInvoiceHeader I
INNER JOIN (
    SELECT
         [dblUnitQtyShipped]	= SUM(ISNULL(dbo.fnARCalculateQtyBetweenUOM(IDP.[intItemWeightUOMId], IDP.[intOrderUOMId], ID.[dblShipmentNetWt] - IDP.[dblShipmentNetWt], ICI.[intItemId], ICI.[strType]), @ZeroDecimal)) -- SUM(ISNULL([dblUnitQtyShipped], @ZeroDecimal) - ISNULL(dbo.fnARCalculateQtyBetweenUOM(IDP.[intItemUOMId], ICSUOM.[intItemUOMId], IDP.[dblQtyShipped], ICI.[intItemId], ICI.[strType]), @ZeroDecimal))
		,[dblTotal]				= SUM(ID.[dblTotal] - IDP.[dblTotal])
        ,[intInvoiceId]			= ID.[intInvoiceId]
		,[intAccountId]			= dbo.fnGetItemGLAccount(IDP.[intItemId], ICIL.[intItemLocationId], 'Cost of Goods')
    FROM tblARPostInvoiceDetail ID
	INNER JOIN tblARInvoiceDetail IDP ON ID.intOriginalInvoiceDetailId = IDP.intInvoiceDetailId
	INNER JOIN tblARInvoice ARI ON ARI.intInvoiceId = IDP.intInvoiceId AND ID.[dblTotal] > IDP.[dblTotal]
	INNER JOIN tblICItem ICI WITH(NOLOCK) ON IDP.[intItemId] = ICI.[intItemId]
	INNER JOIN tblICItemLocation ICIL WITH(NOLOCK) ON ICI.[intItemId] = ICIL.[intItemId] AND ARI.[intCompanyLocationId] = ICIL.[intLocationId]
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
		INNER JOIN tblLGLoad L ON LD.intLoadId = L.intLoadId
		WHERE LD.intLoadDetailId = IDP.intLoadDetailId
	) LG
	WHERE LG.[intSourceType] = 4
      AND ID.strSessionId = @strSessionId
    GROUP BY ID.[intInvoiceId], IDP.[intItemId], ICIL.[intItemLocationId]
	HAVING SUM(ID.[dblTotal] - IDP.[dblTotal]) > 0
) ARID ON I.[intInvoiceId] = ARID.[intInvoiceId]
WHERE I.[intPeriodsToAccrue] <= 1
  AND I.[ysnFromProvisional] = 1
  AND I.[dblInvoiceTotal] <> @ZeroDecimal
  AND I.strSessionId = @strSessionId

--FINAL INVOICES (DROP SHIP / COGS)
INSERT tblARPostInvoiceGLEntries WITH (TABLOCK) (
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
    ,[strSessionId])
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
    ,[strSessionId]                 = @strSessionId
FROM tblARPostInvoiceHeader I
INNER JOIN (
    SELECT
         [dblUnitQtyShipped]	= SUM(ISNULL(dbo.fnARCalculateQtyBetweenUOM(IDP.[intItemWeightUOMId], IDP.[intOrderUOMId], ID.[dblShipmentNetWt] - IDP.[dblShipmentNetWt], ICI.[intItemId], ICI.[strType]), @ZeroDecimal))
		,[dblTotal]				= SUM(ID.[dblTotal] - IDP.[dblTotal])
        ,[intInvoiceId]			= ID.[intInvoiceId]
		,[intAccountId]			= dbo.fnGetItemGLAccount(IDP.[intItemId], ICIL.[intItemLocationId], 'Cost of Goods')
    FROM tblARPostInvoiceDetail ID
	INNER JOIN tblARInvoiceDetail IDP ON ID.intOriginalInvoiceDetailId = IDP.intInvoiceDetailId
	INNER JOIN tblARInvoice ARI ON ARI.intInvoiceId = IDP.intInvoiceId AND ID.[dblTotal] > IDP.[dblTotal]
	INNER JOIN tblICItem ICI WITH(NOLOCK) ON IDP.[intItemId] = ICI.[intItemId]
	INNER JOIN tblICItemLocation ICIL WITH(NOLOCK) ON ICI.[intItemId] = ICIL.[intItemId] AND ARI.[intCompanyLocationId] = ICIL.[intLocationId]
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
		INNER JOIN tblLGLoad L ON LD.intLoadId = L.intLoadId
		WHERE LD.intLoadDetailId = IDP.intLoadDetailId
	) LG
	WHERE LG.[intSourceType] = 4
      AND ID.strSessionId = @strSessionId
    GROUP BY ID.[intInvoiceId], IDP.[intItemId], ICIL.[intItemLocationId]
	HAVING SUM(ID.[dblTotal] - IDP.[dblTotal]) > 0
) ARID ON I.[intInvoiceId] = ARID.[intInvoiceId]
WHERE I.[intPeriodsToAccrue] <= 1
  AND I.[ysnFromProvisional] = 1
  AND I.[dblInvoiceTotal] <> @ZeroDecimal
  AND I.strSessionId = @strSessionId

--CarQuest Import (Inventory)
INSERT tblARPostInvoiceGLEntries WITH (TABLOCK) (
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
    ,[intSourceEntityId]
    ,[strSessionId]
)
SELECT [dtmDate]                    = CAST(ISNULL(I.[dtmPostDate], I.[dtmDate]) AS DATE)
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
    ,[intSourceEntityId]            = I.[intEntityCustomerId]
    ,[strSessionId]                 = @strSessionId
FROM tblARPostInvoiceHeader I
INNER JOIN tblARPostInvoiceDetail ARID ON I.[intInvoiceId] = ARID.[intInvoiceId]
INNER JOIN tblICItemLocation ICIL WITH(NOLOCK) ON ARID.[intItemId] = ICIL.[intItemId] AND I.[intCompanyLocationId] = ICIL.[intLocationId]
CROSS APPLY (
	SELECT TOP 1 dblCOGSAmount
	FROM tblARImportLogDetail WITH(NOLOCK) 
	WHERE strTransactionNumber = I.strInvoiceNumber
    ORDER BY intImportLogDetailId DESC
) IM
WHERE I.[strImportFormat] = 'CarQuest'
  AND I.strSessionId = @strSessionId
  AND ARID.strSessionId = @strSessionId

--CarQuest Import (COGS)
INSERT tblARPostInvoiceGLEntries WITH (TABLOCK) (
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
    ,[intSourceEntityId]
    ,[strSessionId]
)
SELECT [dtmDate]                    = CAST(ISNULL(I.[dtmPostDate], I.[dtmDate]) AS DATE)
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
    ,[intSourceEntityId]            = I.[intEntityCustomerId]
    ,[strSessionId]                 = @strSessionId
FROM tblARPostInvoiceHeader I
INNER JOIN tblARPostInvoiceDetail ARID ON I.[intInvoiceId] = ARID.[intInvoiceId]
INNER JOIN tblICItemLocation ICIL WITH(NOLOCK) ON ARID.[intItemId] = ICIL.[intItemId] AND I.[intCompanyLocationId] = ICIL.[intLocationId]
CROSS APPLY (
	SELECT TOP 1 dblCOGSAmount
	FROM tblARImportLogDetail WITH(NOLOCK) 
	WHERE strTransactionNumber = I.strInvoiceNumber
    ORDER BY intImportLogDetailId DESC
) IM
WHERE I.[strImportFormat] = 'CarQuest'
  AND I.strSessionId = @strSessionId
  AND ARID.strSessionId = @strSessionId

--DEBIT MEMO DEBIT
INSERT tblARPostInvoiceGLEntries WITH (TABLOCK) (
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
    ,[intSourceEntityId]
    ,[strSessionId]
)
SELECT [dtmDate]                    = CAST(ISNULL(I.[dtmPostDate], I.[dtmDate]) AS DATE)
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
    ,[intSourceEntityId]            = I.[intEntityCustomerId]   
    ,[strSessionId]                 = @strSessionId 
FROM tblARPostInvoiceDetail I
WHERE I.[intPeriodsToAccrue] <= 1
  AND I.[dblQtyShipped] <> @ZeroDecimal
  AND I.[strTransactionType] = 'Debit Memo'
  AND I.[strItemType] <> 'Comment'
  AND I.strSessionId = @strSessionId

--dblShipping <> 0
INSERT tblARPostInvoiceGLEntries WITH (TABLOCK) (
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
    ,[intSourceEntityId]
    ,[strSessionId]
)
SELECT [dtmDate]                    = CAST(ISNULL(I.[dtmPostDate], I.[dtmDate]) AS DATE)
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
    ,[intSourceEntityId]            = I.[intEntityCustomerId]  
    ,[strSessionId]                 = @strSessionId  
FROM tblARPostInvoiceHeader I
WHERE I.[dblShipping] <> @ZeroDecimal
  AND I.strSessionId = @strSessionId

--TAX ADJUSTMENT DEBIT
INSERT tblARPostInvoiceGLEntries WITH (TABLOCK) (
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
    ,[intSourceEntityId]
    ,[strSessionId]
)
SELECT [dtmDate]                    = CAST(ISNULL(I.[dtmPostDate], I.[dtmDate]) AS DATE)
    ,[strBatchId]                   = I.[strBatchId]
    ,[intAccountId]                 = ARIDT.intTaxAdjustmentAccountId
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
	,[dblDebitForeign]             = CASE WHEN I.[ysnIsInvoicePositive] = 0 
                                           THEN (CASE WHEN ARIDT.[dblAdjustedTax] < @ZeroDecimal THEN ABS(ARIDT.[dblAdjustedTax]) ELSE @ZeroDecimal END )
                                           ELSE (CASE WHEN ARIDT.[dblAdjustedTax] < @ZeroDecimal THEN @ZeroDecimal ELSE ARIDT.[dblAdjustedTax] END)
                                      END
    ,[dblDebitReport]              = CASE WHEN I.[ysnIsInvoicePositive] = 0 
                                           THEN (CASE WHEN ARIDT.[dblAdjustedTax] < @ZeroDecimal THEN ABS(ARIDT.[dblAdjustedTax]) ELSE @ZeroDecimal END )
                                           ELSE (CASE WHEN ARIDT.[dblAdjustedTax] < @ZeroDecimal THEN @ZeroDecimal ELSE ARIDT.[dblAdjustedTax] END)
                                      END
    ,[dblCreditForeign]              = CASE WHEN I.[ysnIsInvoicePositive] = 1 
                                           THEN (CASE WHEN ARIDT.[dblAdjustedTax] < @ZeroDecimal THEN ABS(ARIDT.[dblAdjustedTax]) ELSE @ZeroDecimal END )
                                           ELSE (CASE WHEN ARIDT.[dblAdjustedTax] < @ZeroDecimal THEN @ZeroDecimal ELSE ARIDT.[dblAdjustedTax] END)
                                      END
    ,[dblCreditReport]               = CASE WHEN I.[ysnIsInvoicePositive] = 1 
                                           THEN (CASE WHEN ARIDT.[dblAdjustedTax] < @ZeroDecimal THEN ABS(ARIDT.[dblAdjustedTax]) ELSE @ZeroDecimal END )
                                           ELSE (CASE WHEN ARIDT.[dblAdjustedTax] < @ZeroDecimal THEN @ZeroDecimal ELSE ARIDT.[dblAdjustedTax] END)
                                      END
    ,[dblReportingRate]             = I.[dblCurrencyExchangeRate]
    ,[dblForeignRate]               = I.[dblCurrencyExchangeRate]
    ,[strRateType]                  = I.[strCurrencyExchangeRateType]    
    ,[intSourceEntityId]            = I.[intEntityCustomerId] 
    ,[strSessionId]                 = @strSessionId   
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
		 , TC.intTaxAdjustmentAccountId
    FROM tblARInvoiceDetailTax IDT WITH (NOLOCK)
	INNER JOIN tblSMTaxCode TC ON IDT.intTaxCodeId = TC.intTaxCodeId
) ARIDT
INNER JOIN tblARPostInvoiceDetail I ON ARIDT.[intInvoiceDetailId] = I.[intInvoiceDetailId]
WHERE I.[intPeriodsToAccrue] <= 1
  AND (ARIDT.[dblAdjustedTax] <> @ZeroDecimal
   OR (ARIDT.[dblAdjustedTax] = @ZeroDecimal AND [intSalesTaxExemptionAccountId] > 0 AND [ysnAddToCost] = 1 AND [ysnTaxExempt] = 1 AND [ysnInvalidSetup] = 0))
  AND I.strType = 'Tax Adjustment'
  AND ISNULL(I.intOriginalInvoiceDetailId, 0) = 0
  AND I.strSessionId = @strSessionId

--TAX ADJUSTMENT CREDIT WITH RELATED INVOICE
INSERT tblARPostInvoiceGLEntries WITH (TABLOCK) (
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
    ,[intSourceEntityId]
    ,[strSessionId]
)
SELECT [dtmDate]                    = CAST(ISNULL(I.[dtmPostDate], I.[dtmDate]) AS DATE)
    ,[strBatchId]                   = I.[strBatchId]
    ,[intAccountId]                 = ARIDT.intTaxAdjustmentAccountId
    ,[dblDebit]                     = ABS(CASE WHEN I.[ysnIsInvoicePositive] = 1 
                                           THEN (CASE WHEN ARIDT.[dblBaseAdjustedTax] < @ZeroDecimal THEN ABS(ARIDT.[dblBaseAdjustedTax]) ELSE @ZeroDecimal END )
                                           ELSE (CASE WHEN ARIDT.[dblBaseAdjustedTax] < @ZeroDecimal THEN @ZeroDecimal ELSE ARIDT.[dblBaseAdjustedTax] END)
                                      END
									  -
									  CASE WHEN I.[ysnIsInvoicePositive] = 1 
											THEN (CASE WHEN ARIDT_RELATED.[dblBaseAdjustedTax] < @ZeroDecimal THEN ABS(ARIDT_RELATED.[dblBaseAdjustedTax]) ELSE @ZeroDecimal END )
											ELSE (CASE WHEN ARIDT_RELATED.[dblBaseAdjustedTax] < @ZeroDecimal THEN @ZeroDecimal ELSE ARIDT_RELATED.[dblBaseAdjustedTax] END)
									  END)
    ,[dblCredit]                    = ABS(CASE WHEN I.[ysnIsInvoicePositive] = 0 
                                           THEN (CASE WHEN ARIDT.[dblBaseAdjustedTax] < @ZeroDecimal THEN ABS(ARIDT.[dblBaseAdjustedTax]) ELSE @ZeroDecimal END )
                                           ELSE (CASE WHEN ARIDT.[dblBaseAdjustedTax] < @ZeroDecimal THEN @ZeroDecimal ELSE ARIDT.[dblBaseAdjustedTax] END)
                                      END
									  -
									  CASE WHEN I.[ysnIsInvoicePositive] = 0 
                                           THEN (CASE WHEN ARIDT_RELATED.[dblBaseAdjustedTax] < @ZeroDecimal THEN ABS(ARIDT_RELATED.[dblBaseAdjustedTax]) ELSE @ZeroDecimal END )
                                           ELSE (CASE WHEN ARIDT_RELATED.[dblBaseAdjustedTax] < @ZeroDecimal THEN @ZeroDecimal ELSE ARIDT_RELATED.[dblBaseAdjustedTax] END)
                                      END)
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
    ,[intConcurrencyId]				= 1
	,[dblDebitForeign]              = ABS(CASE WHEN I.[ysnIsInvoicePositive] = 1 
                                           THEN (CASE WHEN ARIDT.[dblAdjustedTax] < @ZeroDecimal THEN ABS(ARIDT.[dblAdjustedTax]) ELSE @ZeroDecimal END )
                                           ELSE (CASE WHEN ARIDT.[dblAdjustedTax] < @ZeroDecimal THEN @ZeroDecimal ELSE ARIDT.[dblAdjustedTax] END)
                                      END
									  -
									  CASE WHEN I.[ysnIsInvoicePositive] = 1 
                                           THEN (CASE WHEN ARIDT_RELATED.[dblAdjustedTax] < @ZeroDecimal THEN ABS(ARIDT_RELATED.[dblAdjustedTax]) ELSE @ZeroDecimal END )
                                           ELSE (CASE WHEN ARIDT_RELATED.[dblAdjustedTax] < @ZeroDecimal THEN @ZeroDecimal ELSE ARIDT_RELATED.[dblAdjustedTax] END)
                                      END)
    ,[dblDebitReport]               = ABS(CASE WHEN I.[ysnIsInvoicePositive] = 1 
                                           THEN (CASE WHEN ARIDT.[dblAdjustedTax] < @ZeroDecimal THEN ABS(ARIDT.[dblAdjustedTax]) ELSE @ZeroDecimal END )
                                           ELSE (CASE WHEN ARIDT.[dblAdjustedTax] < @ZeroDecimal THEN @ZeroDecimal ELSE ARIDT.[dblAdjustedTax] END)
                                      END
									  -
									  CASE WHEN I.[ysnIsInvoicePositive] = 1
                                           THEN (CASE WHEN ARIDT_RELATED.[dblAdjustedTax] < @ZeroDecimal THEN ABS(ARIDT_RELATED.[dblAdjustedTax]) ELSE @ZeroDecimal END )
                                           ELSE (CASE WHEN ARIDT_RELATED.[dblAdjustedTax] < @ZeroDecimal THEN @ZeroDecimal ELSE ARIDT_RELATED.[dblAdjustedTax] END)
                                      END)
    ,[dblCreditForeign]              = ABS(CASE WHEN I.[ysnIsInvoicePositive] = 0 
                                           THEN (CASE WHEN ARIDT.[dblAdjustedTax] < @ZeroDecimal THEN ABS(ARIDT.[dblAdjustedTax]) ELSE @ZeroDecimal END )
                                           ELSE (CASE WHEN ARIDT.[dblAdjustedTax] < @ZeroDecimal THEN @ZeroDecimal ELSE ARIDT.[dblAdjustedTax] END)
                                       END
									   -
									   CASE WHEN I.[ysnIsInvoicePositive] = 0 
                                           THEN (CASE WHEN ARIDT_RELATED.[dblAdjustedTax] < @ZeroDecimal THEN ABS(ARIDT_RELATED.[dblAdjustedTax]) ELSE @ZeroDecimal END )
                                           ELSE (CASE WHEN ARIDT_RELATED.[dblAdjustedTax] < @ZeroDecimal THEN @ZeroDecimal ELSE ARIDT_RELATED.[dblAdjustedTax] END)
                                       END)
    ,[dblCreditReport]               = ABS(CASE WHEN I.[ysnIsInvoicePositive] = 0 
                                           THEN (CASE WHEN ARIDT.[dblAdjustedTax] < @ZeroDecimal THEN ABS(ARIDT.[dblAdjustedTax]) ELSE @ZeroDecimal END )
                                           ELSE (CASE WHEN ARIDT.[dblAdjustedTax] < @ZeroDecimal THEN @ZeroDecimal ELSE ARIDT.[dblAdjustedTax] END)
                                       END
									   -
									   CASE WHEN I.[ysnIsInvoicePositive] = 0 
                                           THEN (CASE WHEN ARIDT_RELATED.[dblAdjustedTax] < @ZeroDecimal THEN ABS(ARIDT_RELATED.[dblAdjustedTax]) ELSE @ZeroDecimal END )
                                           ELSE (CASE WHEN ARIDT_RELATED.[dblAdjustedTax] < @ZeroDecimal THEN @ZeroDecimal ELSE ARIDT_RELATED.[dblAdjustedTax] END)
                                       END)
    ,[dblReportingRate]				= I.[dblCurrencyExchangeRate]
    ,[dblForeignRate]				= I.[dblCurrencyExchangeRate]
    ,[strRateType]                  = I.[strCurrencyExchangeRateType]    
    ,[intSourceEntityId]            = I.[intEntityCustomerId] 
    ,[strSessionId]                 = @strSessionId   
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
		 , TC.intTaxAdjustmentAccountId
    FROM tblARInvoiceDetailTax IDT WITH (NOLOCK)
	INNER JOIN tblSMTaxCode TC ON IDT.intTaxCodeId = TC.intTaxCodeId
) ARIDT
INNER JOIN tblARPostInvoiceDetail I ON ARIDT.[intInvoiceDetailId] = I.[intInvoiceDetailId]
LEFT JOIN tblARInvoiceDetail I_RELATED ON I.[intOriginalInvoiceDetailId] = I_RELATED.[intInvoiceDetailId]
LEFT JOIN (
    SELECT IDT.[intTaxCodeId]
		 , IDT.[intInvoiceDetailId]
		 , IDT.[dblAdjustedTax]
		 , IDT.[dblBaseAdjustedTax]
    FROM tblARInvoiceDetailTax IDT WITH (NOLOCK)
	INNER JOIN tblSMTaxCode TC ON IDT.intTaxCodeId = TC.intTaxCodeId
) ARIDT_RELATED ON ARIDT_RELATED.[intInvoiceDetailId] = I_RELATED.[intInvoiceDetailId] AND ARIDT_RELATED.intTaxCodeId = ARIDT.intTaxCodeId
WHERE I.[intPeriodsToAccrue] <= 1
  AND (ARIDT.[dblAdjustedTax] <> @ZeroDecimal
   OR (ARIDT.[dblAdjustedTax] = @ZeroDecimal AND [intSalesTaxExemptionAccountId] > 0 AND [ysnAddToCost] = 1 AND [ysnTaxExempt] = 1 AND [ysnInvalidSetup] = 0))
  AND I.strType = 'Tax Adjustment'
  AND ISNULL(I.intOriginalInvoiceDetailId, 0) <> 0
  AND I.strSessionId = @strSessionId

--TAX ADJUSTMENT DEBIT REVERSAL OF RELATED INVOICE
INSERT tblARPostInvoiceGLEntries WITH (TABLOCK) (
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
    ,[intSourceEntityId]
    ,[strSessionId]
)
SELECT [dtmDate]                    = CAST(ISNULL(I.[dtmPostDate], I.[dtmDate]) AS DATE)
    ,[strBatchId]                   = I.[strBatchId]
    ,[intAccountId]                 = ARIDT.intSalesTaxAccountId
    ,[dblDebit]                     = CASE WHEN I.[ysnIsInvoicePositive] = 0 
											THEN (CASE WHEN ARIDT_RELATED.[dblBaseAdjustedTax] < @ZeroDecimal THEN ABS(ARIDT_RELATED.[dblBaseAdjustedTax]) ELSE @ZeroDecimal END )
											ELSE (CASE WHEN ARIDT_RELATED.[dblBaseAdjustedTax] < @ZeroDecimal THEN @ZeroDecimal ELSE ARIDT_RELATED.[dblBaseAdjustedTax] END)
									  END
    ,[dblCredit]                    = CASE WHEN I.[ysnIsInvoicePositive] = 1 
                                           THEN (CASE WHEN ARIDT_RELATED.[dblBaseAdjustedTax] < @ZeroDecimal THEN ABS(ARIDT_RELATED.[dblBaseAdjustedTax]) ELSE @ZeroDecimal END )
                                           ELSE (CASE WHEN ARIDT_RELATED.[dblBaseAdjustedTax] < @ZeroDecimal THEN @ZeroDecimal ELSE ARIDT_RELATED.[dblBaseAdjustedTax] END)
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
                                           THEN (CASE WHEN ARIDT_RELATED.[dblAdjustedTax] < @ZeroDecimal THEN ABS(ARIDT_RELATED.[dblAdjustedTax]) ELSE @ZeroDecimal END )
                                           ELSE (CASE WHEN ARIDT_RELATED.[dblAdjustedTax] < @ZeroDecimal THEN @ZeroDecimal ELSE ARIDT_RELATED.[dblAdjustedTax] END)
                                      END
    ,[dblDebitReport]               = CASE WHEN I.[ysnIsInvoicePositive] = 0 
                                           THEN (CASE WHEN ARIDT_RELATED.[dblAdjustedTax] < @ZeroDecimal THEN ABS(ARIDT_RELATED.[dblAdjustedTax]) ELSE @ZeroDecimal END )
                                           ELSE (CASE WHEN ARIDT_RELATED.[dblAdjustedTax] < @ZeroDecimal THEN @ZeroDecimal ELSE ARIDT_RELATED.[dblAdjustedTax] END)
                                      END
    ,[dblCreditForeign]				= CASE WHEN I.[ysnIsInvoicePositive] = 1 
                                           THEN (CASE WHEN ARIDT_RELATED.[dblAdjustedTax] < @ZeroDecimal THEN ABS(ARIDT_RELATED.[dblAdjustedTax]) ELSE @ZeroDecimal END )
                                           ELSE (CASE WHEN ARIDT_RELATED.[dblAdjustedTax] < @ZeroDecimal THEN @ZeroDecimal ELSE ARIDT_RELATED.[dblAdjustedTax] END)
                                      END
    ,[dblCreditReport]              = CASE WHEN I.[ysnIsInvoicePositive] = 1 
                                           THEN (CASE WHEN ARIDT_RELATED.[dblAdjustedTax] < @ZeroDecimal THEN ABS(ARIDT_RELATED.[dblAdjustedTax]) ELSE @ZeroDecimal END )
                                           ELSE (CASE WHEN ARIDT_RELATED.[dblAdjustedTax] < @ZeroDecimal THEN @ZeroDecimal ELSE ARIDT_RELATED.[dblAdjustedTax] END)
                                      END
    ,[dblReportingRate]             = I.[dblCurrencyExchangeRate]
    ,[dblForeignRate]               = I.[dblCurrencyExchangeRate]
    ,[strRateType]                  = I.[strCurrencyExchangeRateType]    
    ,[intSourceEntityId]            = I.[intEntityCustomerId] 
    ,[strSessionId]                 = @strSessionId   
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
		 , TC.intTaxAdjustmentAccountId
    FROM tblARInvoiceDetailTax IDT WITH (NOLOCK)
	INNER JOIN tblSMTaxCode TC ON IDT.intTaxCodeId = TC.intTaxCodeId
) ARIDT
INNER JOIN tblARPostInvoiceDetail I ON ARIDT.[intInvoiceDetailId] = I.[intInvoiceDetailId]
LEFT JOIN tblARInvoiceDetail I_RELATED ON I.[intOriginalInvoiceDetailId] = I_RELATED.[intInvoiceDetailId]
LEFT JOIN (
    SELECT IDT.[intTaxCodeId]
		 , IDT.[intInvoiceDetailId]
		 , IDT.[dblAdjustedTax]
		 , IDT.[dblBaseAdjustedTax]
    FROM tblARInvoiceDetailTax IDT WITH (NOLOCK)
	INNER JOIN tblSMTaxCode TC ON IDT.intTaxCodeId = TC.intTaxCodeId
) ARIDT_RELATED ON ARIDT_RELATED.[intInvoiceDetailId] = I_RELATED.[intInvoiceDetailId] AND ARIDT_RELATED.intTaxCodeId = ARIDT.intTaxCodeId
WHERE I.[intPeriodsToAccrue] <= 1
  AND (ARIDT.[dblAdjustedTax] <> @ZeroDecimal
   OR (ARIDT.[dblAdjustedTax] = @ZeroDecimal AND [intSalesTaxExemptionAccountId] > 0 AND [ysnAddToCost] = 1 AND [ysnTaxExempt] = 1 AND [ysnInvalidSetup] = 0))
  AND I.strType = 'Tax Adjustment'
  AND ISNULL(I.intOriginalInvoiceDetailId, 0) <> 0
  AND I.strSessionId = @strSessionId

--TAX DETAIL DEBIT / TAX ADJUSTMENT CREDIT
INSERT tblARPostInvoiceGLEntries WITH (TABLOCK) (
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
    ,[intSourceEntityId]
    ,[strSessionId]
)
SELECT [dtmDate]                    = CAST(ISNULL(I.[dtmPostDate], I.[dtmDate]) AS DATE)
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
    ,[intSourceEntityId]            = I.[intEntityCustomerId]
    ,[strSessionId]                 = @strSessionId    
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
INNER JOIN tblARPostInvoiceDetail I ON ARIDT.[intInvoiceDetailId] = I.[intInvoiceDetailId]
WHERE I.[intPeriodsToAccrue] <= 1
  AND (ARIDT.[dblAdjustedTax] <> @ZeroDecimal
   OR (ARIDT.[dblAdjustedTax] = @ZeroDecimal AND [intSalesTaxExemptionAccountId] > 0 AND [ysnAddToCost] = 1 AND [ysnTaxExempt] = 1 AND [ysnInvalidSetup] = 0))
  AND I.strSessionId = @strSessionId

--TAX DETAIL CREDIT
INSERT tblARPostInvoiceGLEntries WITH (TABLOCK) (
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
    ,[intSourceEntityId]
    ,[strSessionId]
)
SELECT [dtmDate]                    = CAST(ISNULL(I.[dtmPostDate], I.[dtmDate]) AS DATE)
    ,[strBatchId]                   = I.[strBatchId]
    ,[intAccountId]                 = dbo.fnGetItemGLAccount(I.[intItemId], ICIL.[intItemLocationId], 'Cost of Goods')
    ,[dblDebit]                     = CASE WHEN I.[ysnIsInvoicePositive] = 0 
                                           THEN (CASE WHEN ARIDT.[dblBaseAdjustedTax] < @ZeroDecimal THEN ABS(ARIDT.[dblBaseAdjustedTax]) ELSE @ZeroDecimal END )
                                           ELSE (CASE WHEN ARIDT.[dblBaseAdjustedTax] < @ZeroDecimal THEN @ZeroDecimal ELSE ARIDT.[dblBaseAdjustedTax] END)
                                      END
    ,[dblCredit]                    = CASE WHEN I.[ysnIsInvoicePositive] = 1 
                                           THEN (CASE WHEN ARIDT.[dblBaseAdjustedTax] < @ZeroDecimal 
													  THEN ABS(ARIDT.[dblBaseAdjustedTax]) 
													  ELSE ROUND(I.dblQtyShipped * ARIDT.dblRate, dbo.fnARGetDefaultDecimal()) 
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
													  ELSE ROUND(I.dblQtyShipped * ARIDT.dblRate, dbo.fnARGetDefaultDecimal()) 
												 END)
                                           ELSE (CASE WHEN ARIDT.[dblBaseAdjustedTax] < @ZeroDecimal THEN @ZeroDecimal ELSE ARIDT.[dblBaseAdjustedTax] END)
                                      END
    ,[dblCreditReport]              = CASE WHEN I.[ysnIsInvoicePositive] = 1 
                                           THEN (CASE WHEN ARIDT.[dblBaseAdjustedTax] < @ZeroDecimal 
													  THEN ABS(ARIDT.[dblBaseAdjustedTax]) 
													  ELSE ROUND(I.dblQtyShipped * ARIDT.dblRate, dbo.fnARGetDefaultDecimal())
												 END)
                                           ELSE (CASE WHEN ARIDT.[dblBaseAdjustedTax] < @ZeroDecimal THEN @ZeroDecimal ELSE ARIDT.[dblBaseAdjustedTax] END)
                                      END
    ,[dblReportingRate]             = I.[dblCurrencyExchangeRate]
    ,[dblForeignRate]               = I.[dblCurrencyExchangeRate]
    ,[strRateType]                  = I.[strCurrencyExchangeRateType]    
    ,[intSourceEntityId]            = I.[intEntityCustomerId]
    ,[strSessionId]                 = @strSessionId
FROM (
    SELECT IDT.[intInvoiceDetailId]
		 , IDT.[intInvoiceDetailTaxId]
		 , IDT.[dblBaseAdjustedTax]
		 , IDT.[dblRate]
    FROM tblARInvoiceDetailTax IDT WITH (NOLOCK)
	INNER JOIN tblSMTaxCode TC ON IDT.intTaxCodeId = TC.intTaxCodeId
	WHERE TC.ysnAddToCost = 1
	  AND IDT.ysnTaxExempt = 1
	  AND (IDT.intSalesTaxExemptionAccountId IS NOT NULL OR TC.intSalesTaxExemptionAccountId IS NOT NULL)
	  AND IDT.dblAdjustedTax = 0
      AND IDT.ysnInvalidSetup = 0
) ARIDT
INNER JOIN tblARPostInvoiceDetail I ON ARIDT.[intInvoiceDetailId] = I.[intInvoiceDetailId]
INNER JOIN tblICItemLocation ICIL WITH(NOLOCK) ON I.[intItemId] = ICIL.[intItemId] AND I.[intCompanyLocationId] = ICIL.[intLocationId]
WHERE I.[intPeriodsToAccrue] <= 1
  AND I.strSessionId = @strSessionId

--DUE FROM ACCOUNT DEBIT OF TAX DETAIL
INSERT tblARPostInvoiceGLEntries WITH (TABLOCK) (
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
    ,[intSourceEntityId]
    ,[strSessionId]
)
SELECT [dtmDate]                    = CAST(ISNULL(I.[dtmPostDate], I.[dtmDate]) AS DATE)
    ,[strBatchId]                   = I.[strBatchId]
    ,[intAccountId]                 = OVERRIDESEGMENT.intOverrideAccount
	,[dblCredit]                    = CASE WHEN I.[ysnIsInvoicePositive] = 0 
                                           THEN (CASE WHEN ARIDT.[dblBaseAdjustedTax] < @ZeroDecimal THEN ABS(ARIDT.[dblBaseAdjustedTax]) ELSE @ZeroDecimal END )
                                           ELSE (CASE WHEN ARIDT.[dblBaseAdjustedTax] < @ZeroDecimal THEN @ZeroDecimal ELSE ARIDT.[dblBaseAdjustedTax] END)
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
	,[dblCreditUnit]                = @ZeroDecimal
    ,[dblDebitUnit]                 = @ZeroDecimal
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
	,[dblCreditForeign]             = CASE WHEN I.[ysnIsInvoicePositive] = 0 
                                           THEN (CASE WHEN ARIDT.[dblAdjustedTax] < @ZeroDecimal THEN ABS(ARIDT.[dblAdjustedTax]) ELSE @ZeroDecimal END )
                                           ELSE (CASE WHEN ARIDT.[dblAdjustedTax] < @ZeroDecimal THEN @ZeroDecimal ELSE ARIDT.[dblAdjustedTax] END)
                                      END
    ,[dblCreditReport]              = CASE WHEN I.[ysnIsInvoicePositive] = 0 
                                           THEN (CASE WHEN ARIDT.[dblAdjustedTax] < @ZeroDecimal THEN ABS(ARIDT.[dblAdjustedTax]) ELSE @ZeroDecimal END )
                                           ELSE (CASE WHEN ARIDT.[dblAdjustedTax] < @ZeroDecimal THEN @ZeroDecimal ELSE ARIDT.[dblAdjustedTax] END)
                                      END
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
    ,[dblReportingRate]             = I.[dblCurrencyExchangeRate]
    ,[dblForeignRate]               = I.[dblCurrencyExchangeRate]
    ,[strRateType]                  = I.[strCurrencyExchangeRateType]    
    ,[intSourceEntityId]            = I.[intEntityCustomerId]
    ,[strSessionId]                 = @strSessionId
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
INNER JOIN tblARPostInvoiceDetail I ON ARIDT.[intInvoiceDetailId] = I.[intInvoiceDetailId]
OUTER APPLY (
	SELECT intOverrideAccount
	FROM dbo.[fnARGetOverrideAccount](I.[intSalesAccountId], @DueFromAccountId, @AllowIntraCompanyEntries, @AllowIntraLocationEntries, 0)
) OVERRIDESEGMENT
WHERE I.[intPeriodsToAccrue] <= 1
  AND (ARIDT.[dblAdjustedTax] <> @ZeroDecimal
   OR (ARIDT.[dblAdjustedTax] = @ZeroDecimal AND [intSalesTaxExemptionAccountId] > 0 AND [ysnAddToCost] = 1 AND [ysnTaxExempt] = 1 AND [ysnInvalidSetup] = 0))
  AND @AllowIntraEntries = 1
  AND @DueFromAccountId <> 0
  AND ([dbo].[fnARCompareAccountSegment](I.[intAccountId], I.[intSalesAccountId], 6) = 0 OR [dbo].[fnARCompareAccountSegment](I.[intAccountId], I.[intSalesAccountId], 3) = 0)
  AND I.strSessionId = @strSessionId

--SALES DISCOUNT
INSERT tblARPostInvoiceGLEntries WITH (TABLOCK) (
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
    ,[intSourceEntityId]
    ,[strSessionId]
)
SELECT [dtmDate]                    = CAST(ISNULL(I.[dtmPostDate], I.[dtmDate]) AS DATE)
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
    ,[intSourceEntityId]            = I.[intEntityCustomerId]
    ,[strSessionId]                 = @strSessionId
FROM tblARPostInvoiceDetail I
LEFT OUTER JOIN tblARPostInvoiceItemAccount IA ON I.[intItemId] = IA.[intItemId] AND I.[intCompanyLocationId] = IA.[intLocationId]
WHERE I.[dblBaseDiscountAmount] <> @ZeroDecimal
  AND I.strSessionId = @strSessionId
  AND IA.strSessionId = @strSessionId

--DIRECT OUT TICKET (COGS)
INSERT tblARPostInvoiceGLEntries WITH (TABLOCK) (
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
    ,[intSourceEntityId]
    ,[strSessionId]
)
SELECT [dtmDate]                    = CAST(ISNULL(I.[dtmPostDate], I.[dtmDate]) AS DATE)
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
    ,[intSourceEntityId]            = I.[intEntityCustomerId]
    ,[strSessionId]                 = @strSessionId
FROM tblARPostInvoiceHeader I
INNER JOIN (
    SELECT
         [dblUnitQtyShipped]	= SUM(ISNULL(ID.[dblUnitQtyShipped], @ZeroDecimal))
		,[dblTotal]				= SUM(ID.[dblTotal])
        ,[intInvoiceId]			= ID.[intInvoiceId]
		,[intAccountId]			= dbo.fnGetItemGLAccount(ID.[intItemId], ICIL.[intItemLocationId], 'Cost of Goods')
		,[dblCost]				= SUM(ISNULL(ARIFC.[dblCost], @ZeroDecimal) * ISNULL(ID.[dblUnitQtyShipped], @ZeroDecimal))
		,[strDescription]		= ICI.[strDescription]
    FROM tblARPostInvoiceDetail ID
	INNER JOIN tblICItem ICI WITH(NOLOCK) ON ID.[intItemId] = ICI.[intItemId]
	INNER JOIN tblICItemLocation ICIL WITH(NOLOCK) ON ICI.[intItemId] = ICIL.[intItemId] AND ID.[intCompanyLocationId] = ICIL.[intLocationId]
    INNER JOIN tblARPostItemsForCosting ARIFC ON ID.[intInvoiceId] = ARIFC.[intTransactionId] AND ID.[intInvoiceDetailId] = ARIFC.[intTransactionDetailId]
	WHERE ARIFC.[ysnGLOnly] = 1
      AND ID.strSessionId = @strSessionId
      AND ARIFC.strSessionId = @strSessionId
    GROUP BY ID.[intInvoiceId], ID.[intItemId], ICIL.[intItemLocationId], ARIFC.[dblCost], ICI.[strDescription]
) ARID ON I.[intInvoiceId] = ARID.[intInvoiceId]
WHERE I.strSessionId = @strSessionId  

--DIRECT OUT TICKET (General)
INSERT tblARPostInvoiceGLEntries WITH (TABLOCK) (
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
    ,[intSourceEntityId]
    ,[strSessionId]
)
SELECT [dtmDate]                    = CAST(ISNULL(I.[dtmPostDate], I.[dtmDate]) AS DATE)
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
    ,[intSourceEntityId]            = I.[intEntityCustomerId]
    ,[strSessionId]                 = @strSessionId
FROM tblARPostInvoiceHeader I
INNER JOIN (
    SELECT
         [dblUnitQtyShipped]	= SUM(ISNULL(ID.[dblUnitQtyShipped], @ZeroDecimal))
		,[dblTotal]				= SUM(ID.[dblTotal])
        ,[intInvoiceId]			= ID.[intInvoiceId]
		,[intAccountId]			= dbo.fnGetItemGLAccount(ID.[intItemId], ICIL.[intItemLocationId], 'General')
		,[dblCost]				= SUM(ISNULL(ARIFC.[dblCost], @ZeroDecimal) * ISNULL(ID.[dblUnitQtyShipped], @ZeroDecimal))
		,[strDescription]		= ICI.[strDescription]
    FROM tblARPostInvoiceDetail ID
	INNER JOIN tblICItem ICI WITH(NOLOCK) ON ID.[intItemId] = ICI.[intItemId]
	INNER JOIN tblICItemLocation ICIL WITH(NOLOCK) ON ICI.[intItemId] = ICIL.[intItemId] AND ID.[intCompanyLocationId] = ICIL.[intLocationId]
    INNER JOIN tblARPostItemsForCosting ARIFC ON ID.[intInvoiceId] = ARIFC.[intTransactionId] AND ID.[intInvoiceDetailId] = ARIFC.[intTransactionDetailId]
	WHERE ARIFC.ysnGLOnly = 1
      AND ID.strSessionId = @strSessionId
      AND ARIFC.strSessionId = @strSessionId
    GROUP BY ID.[intInvoiceId], ID.[intItemId], ICIL.[intItemLocationId], ARIFC.[dblCost], ICI.[strDescription]
) ARID ON I.[intInvoiceId] = ARID.[intInvoiceId]
WHERE I.strSessionId = @strSessionId
  
RETURN 1 