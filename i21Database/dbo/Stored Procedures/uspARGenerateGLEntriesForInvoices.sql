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
    ,[intSourceEntityId]            = NULL
    ,[ysnRebuild]                   = NULL
FROM
    #ARPostInvoiceHeader I
LEFT OUTER JOIN
    (
    SELECT
         [dblUnitQtyShipped]    = SUM([dblUnitQtyShipped])
        ,[intInvoiceId]         = [intInvoiceId]
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

-- UNION ALL
-- --DEBIT Amount Due - Final Invoice
-- SELECT
-- 	 dtmDate					= CAST(ISNULL(A.dtmPostDate, A.dtmDate) AS DATE)
-- 	,strBatchID					= @batchIdUsed
-- 	,intAccountId				= A.intAccountId
-- 	,dblDebit					= CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash') THEN A.dblBaseAmountDue ELSE @ZeroDecimal END
-- 	,dblCredit					= CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash') THEN @ZeroDecimal ELSE A.dblBaseAmountDue END
-- 	,dblDebitUnit				= CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash') THEN  
-- 																					(
-- 																						SELECT
-- 																							SUM(dbo.fnARCalculateQtyBetweenUOM(ARID.intItemUOMId, ICIS.intStockUOMId, ARID.dblQtyShipped, null, I.strType))
-- 																						FROM
-- 																							(SELECT intInvoiceId, intItemId, intItemUOMId, dblQtyShipped 
-- 																							 FROM tblARInvoiceDetail WITH (NOLOCK)) ARID 
-- 																						INNER JOIN
-- 																							(SELECT intInvoiceId, intCompanyLocationId FROM tblARInvoice WITH (NOLOCK)) ARI
-- 																								ON ARID.intInvoiceId = ARI.intInvoiceId	
-- 																						LEFT OUTER JOIN
-- 																							(SELECT intItemId, strType FROM tblICItem WITH (NOLOCK)) I
-- 																								ON ARID.intItemId = I.intItemId
-- 																						LEFT OUTER JOIN
-- 																							(SELECT intItemId, intLocationId FROM vyuARGetItemAccount WITH (NOLOCK)) IST
-- 																								ON ARID.intItemId = IST.intItemId 
-- 																								AND ARI.intCompanyLocationId = IST.intLocationId 
-- 																						LEFT OUTER JOIN
-- 																							(SELECT intItemId, intLocationId, intStockUOMId FROM vyuICGetItemStock WITH (NOLOCK)) ICIS ON ARID.intItemId = ICIS.intItemId 
-- 																								AND ARI.intCompanyLocationId = ICIS.intLocationId 
-- 																						WHERE
-- 																							ARI.intInvoiceId = A.intInvoiceId
-- 																							AND ARID.dblQtyShipped <> @ZeroDecimal  
-- 																					)
-- 																				ELSE 
-- 																					@ZeroDecimal
-- 																				END
-- 	,dblCreditUnit				=  CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash') THEN  
-- 																					@ZeroDecimal
-- 																				ELSE 
-- 																					(
-- 																					SELECT
-- 																						SUM(dbo.fnARCalculateQtyBetweenUOM(ARID.intItemUOMId, ICIS.intStockUOMId, ARID.dblQtyShipped, null, I.strType))
-- 																					FROM
-- 																						(SELECT intInvoiceId, intItemId, intItemUOMId, dblQtyShipped 
-- 																						 FROM tblARInvoiceDetail WITH (NOLOCK)) ARID 
-- 																					INNER JOIN
-- 																						(SELECT intInvoiceId, intCompanyLocationId FROM tblARInvoice WITH (NOLOCK)) ARI
-- 																							ON ARID.intInvoiceId = ARI.intInvoiceId	
-- 																					LEFT OUTER JOIN
-- 																						(SELECT intItemId, strType FROM tblICItem WITH (NOLOCK)) I
-- 																							ON ARID.intItemId = I.intItemId
-- 																					LEFT OUTER JOIN
-- 																						(SELECT intItemId, intLocationId FROM vyuARGetItemAccount WITH (NOLOCK)) IST
-- 																							ON ARID.intItemId = IST.intItemId 
-- 																							AND ARI.intCompanyLocationId = IST.intLocationId 
-- 																					LEFT OUTER JOIN
-- 																						(SELECT intItemId, intLocationId, intStockUOMId FROM vyuICGetItemStock WITH (NOLOCK)) ICIS
-- 																							ON ARID.intItemId = ICIS.intItemId 
-- 																							AND ARI.intCompanyLocationId = ICIS.intLocationId 
-- 																					WHERE
-- 																						ARI.intInvoiceId = A.intInvoiceId
-- 																						AND ARID.dblQtyShipped <> @ZeroDecimal  
-- 																					)
-- 																				END																					
-- 	,strDescription				= P.[strDescription]
-- 	,strCode					= @CODE
-- 	,strReference				= C.strCustomerNumber
-- 	,intCurrencyId				= A.intCurrencyId 
-- 	,dblExchangeRate			= A.dblCurrencyExchangeRate
-- 	,dtmDateEntered				= @PostDate
-- 	,dtmTransactionDate			= A.dtmDate
-- 	,strJournalLineDescription	= @POSTDESC + A.strTransactionType 
-- 	,intJournalLineNo			= A.intInvoiceId
-- 	,ysnIsUnposted				= 0
-- 	,intUserId					= @userId
-- 	,intEntityId				= @UserEntityID				
-- 	,strTransactionId			= A.strInvoiceNumber
-- 	,intTransactionId			= A.intInvoiceId
-- 	,strTransactionType			= A.strTransactionType
-- 	,strTransactionForm			= @SCREEN_NAME
-- 	,strModuleName				= @MODULE_NAME
-- 	,intConcurrencyId			= 1
-- 	,[dblDebitForeign]			= CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash') THEN A.dblAmountDue ELSE @ZeroDecimal END
-- 	,[dblDebitReport]			= CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash') THEN A.dblAmountDue ELSE @ZeroDecimal END
-- 	,[dblCreditForeign]			= CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash') THEN @ZeroDecimal ELSE A.dblAmountDue END
-- 	,[dblCreditReport]			= CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash') THEN @ZeroDecimal ELSE A.dblAmountDue END
-- 	,[dblReportingRate]			= A.dblCurrencyExchangeRate
-- 	,[dblForeignRate]			= A.dblCurrencyExchangeRate
-- 	,[strRateType]				= ''
-- FROM
-- 	(SELECT intInvoiceId, strInvoiceNumber, intEntityCustomerId, strTransactionType, intCurrencyId, dtmDate, dtmPostDate, strComments, dblAmountDue, intAccountId, intPeriodsToAccrue, dblBaseAmountDue, intSourceId, intOriginalInvoiceId, dblBaseInvoiceTotal,dblInvoiceTotal, ISNULL(dblCurrencyExchangeRate, @OneDecimal) AS dblCurrencyExchangeRate
-- 	 FROM tblARInvoice WITH (NOLOCK)) A
-- LEFT JOIN 
-- 	(SELECT [intEntityId], [strCustomerNumber] FROM tblARCustomer WITH (NOLOCK)) C
-- 		ON A.[intEntityCustomerId] = C.[intEntityId]
-- INNER JOIN 
-- 	(SELECT intInvoiceId, [strDescription] FROM #ARPostInvoiceData )	P ON A.intInvoiceId = P.intInvoiceId	
-- WHERE
-- 	ISNULL(A.intPeriodsToAccrue,0) <= 1
-- 	AND (
-- 			A.dblAmountDue <> @ZeroDecimal
-- 			OR
-- 			EXISTS(SELECT NULL FROM tblARInvoiceDetail ARID INNER JOIN (SELECT intItemId, strType FROM tblICItem) ICI ON ARID.intItemId = ICI.intItemId AND ICI.strType <> 'Comment' WHERE ARID.intInvoiceId  = A.[intInvoiceId])
-- 		)
-- 	AND A.intSourceId = 2 
-- 	AND A.intOriginalInvoiceId IS NOT NULL

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
    --,[dblDebit]                     = CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN I.[dblBaseInvoiceTotal] - I.[dblBaseProvisionalAmount] ELSE @ZeroDecimal END
    --,[dblCredit]                    = CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN @ZeroDecimal ELSE I.[dblBaseInvoiceTotal] - I.[dblBaseProvisionalAmount] END
    ,[dblDebit]                     = CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN I.[dblBaseInvoiceTotal] ELSE @ZeroDecimal END
    ,[dblCredit]                    = CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN @ZeroDecimal ELSE I.[dblBaseInvoiceTotal] END
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
    --,[dblDebitForeign]              = CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN I.[dblInvoiceTotal] - I.[dblProvisionalAmount] ELSE @ZeroDecimal END
    --,[dblDebitReport]               = CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN I.[dblInvoiceTotal] - I.[dblProvisionalAmount] ELSE @ZeroDecimal END
    --,[dblCreditForeign]             = CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN @ZeroDecimal ELSE I.[dblInvoiceTotal] - I.[dblProvisionalAmount] END
    --,[dblCreditReport]              = CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN @ZeroDecimal ELSE I.[dblInvoiceTotal] - I.[dblProvisionalAmount] END
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
    ,[intSourceEntityId]            = NULL
    ,[ysnRebuild]                   = NULL
FROM
    #ARPostInvoiceHeader I
LEFT OUTER JOIN
    (
    SELECT
         [dblUnitQtyShipped]    = SUM([dblUnitQtyShipped])
        ,[intInvoiceId]         = [intInvoiceId]
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
	AND I.[dblProvisionalAmount] = @ZeroDecimal
    --AND ((I.[dblInvoiceTotal] - I.[dblProvisionalAmount]) <> @ZeroDecimal)
    --AND
    --    (
    --    (I.[dblInvoiceTotal] - I.[dblProvisionalAmount]) <> @ZeroDecimal
    --    OR
    --    EXISTS(SELECT NULL FROM #ARPostInvoiceDetail ARID WHERE ARID.[intItemId] IS NOT NULL AND ARID.[strItemType] <> 'Comment' AND ARID.intInvoiceId  = I.[intInvoiceId])
    --    )

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
    ,[dblDebit]                     = CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN @ZeroDecimal ELSE I.[dblBaseInvoiceTotal] END
    ,[dblCredit]                    = CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN I.[dblBaseInvoiceTotal] ELSE @ZeroDecimal END
    ,[dblDebitUnit]                 = CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN @ZeroDecimal ELSE ARID.[dblUnitQtyShipped] END
    ,[dblCreditUnit]                = CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN ARID.[dblUnitQtyShipped] ELSE @ZeroDecimal END
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
    ,[dblDebitForeign]              = CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN  @ZeroDecimal ELSE I.[dblInvoiceTotal] END
    ,[dblDebitReport]               = CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN  @ZeroDecimal ELSE I.[dblInvoiceTotal] END
    ,[dblCreditForeign]             = CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN I.[dblInvoiceTotal] ELSE @ZeroDecimal END
    ,[dblCreditReport]              = CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN I.[dblInvoiceTotal] ELSE @ZeroDecimal END
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
    ,[intSourceEntityId]            = NULL
    ,[ysnRebuild]                   = NULL
FROM
    #ARPostInvoiceHeader I
LEFT OUTER JOIN
    (
    SELECT
         [dblUnitQtyShipped]    = SUM([dblUnitQtyShipped])
        ,[intInvoiceId]         = [intInvoiceId]
    FROM
        #ARPostInvoiceDetail
    WHERE
		[intOriginalInvoiceDetailId] IS NULL
    GROUP BY
        [intInvoiceId]
    ) ARID
        ON I.[intInvoiceId] = ARID.[intInvoiceId]
WHERE
    I.[intPeriodsToAccrue] <= 1
    AND I.[ysnFromProvisional] = 1
	AND I.[dblInvoiceTotal] <> @ZeroDecimal
	AND I.[dblProvisionalAmount] <> @ZeroDecimal


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
   ,[intSourceEntityId]            = NULL
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
    ,[intSourceEntityId]            = NULL
    ,[ysnRebuild]                   = NULL
FROM
    #ARPostInvoiceHeader I
WHERE
    I.[intPeriodsToAccrue] <= 1
    AND I.[dblPayment] <> @ZeroDecimal

--INSERT #ARInvoiceGLEntries
--    ([dtmDate]
--    ,[strBatchId]
--    ,[intAccountId]
--    ,[dblDebit]
--    ,[dblCredit]
--    ,[dblDebitUnit]
--    ,[dblCreditUnit]
--    ,[strDescription]
--    ,[strCode]
--    ,[strReference]
--    ,[intCurrencyId]
--    ,[dblExchangeRate]
--    ,[dtmDateEntered]
--    ,[dtmTransactionDate]
--    ,[strJournalLineDescription]
--    ,[intJournalLineNo]
--    ,[ysnIsUnposted]
--    ,[intUserId]
--    ,[intEntityId]
--    ,[strTransactionId]
--    ,[intTransactionId]
--    ,[strTransactionType]
--    ,[strTransactionForm]
--    ,[strModuleName]
--    ,[intConcurrencyId]
--    ,[dblDebitForeign]
--    ,[dblDebitReport]
--    ,[dblCreditForeign]
--    ,[dblCreditReport]
--    ,[dblReportingRate]
--    ,[dblForeignRate]
--    ,[strRateType]
--    ,[strDocument]
--    ,[strComments]
--    ,[strSourceDocumentId]
--    ,[intSourceLocationId]
--    ,[intSourceUOMId]
--    ,[dblSourceUnitDebit]
--    ,[dblSourceUnitCredit]
--    ,[intCommodityId]
--    ,[intSourceEntityId]
--    ,[ysnRebuild])
--SELECT
--     [dtmDate]                      = CAST(ISNULL(I.[dtmPostDate], I.[dtmDate]) AS DATE)
--    ,[strBatchId]                   = I.[strBatchId]
--    ,[intAccountId]                 = ARPAC.[intAccountId]
--    ,[dblDebit]                     = CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN @ZeroDecimal ELSE ARPAC.[dblBaseAppliedInvoiceDetailAmount] END
--    ,[dblCredit]                    = CASE WHEN I.[ysnIsInvoicePositive] = 0 THEN @ZeroDecimal ELSE ARPAC.[dblBaseAppliedInvoiceDetailAmount] END
--    ,[dblDebitUnit]                 = @ZeroDecimal
--    ,[dblCreditUnit]                = @ZeroDecimal
--    ,[strDescription]               = I.[strDescription]
--    ,[strCode]                      = @CODE
--    ,[strReference]                 = I.[strCustomerNumber]
--    ,[intCurrencyId]                = I.[intCurrencyId]
--    ,[dblExchangeRate]              = I.[dblAverageExchangeRate]
--    ,[dtmDateEntered]               = I.[dtmDatePosted]
--    ,[dtmTransactionDate]           = I.[dtmDate]
--    ,[strJournalLineDescription]    = 'Applied Prepaid - ' + ARPAC.[strInvoiceNumber] 
--    ,[intJournalLineNo]             = I.[intInvoiceId]
--    ,[ysnIsUnposted]                = 0
--    ,[intUserId]                    = I.[intUserId]
--    ,[intEntityId]                  = I.[intEntityId]
--    ,[strTransactionId]             = I.[strInvoiceNumber]
--    ,[intTransactionId]             = I.[intInvoiceId]
--    ,[strTransactionType]           = I.[strTransactionType]
--    ,[strTransactionForm]           = @SCREEN_NAME
--    ,[strModuleName]                = @MODULE_NAME
--    ,[intConcurrencyId]             = 1
--    ,[dblDebitForeign]              = CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN @ZeroDecimal ELSE ARPAC.[dblAppliedInvoiceDetailAmount] END
--    ,[dblDebitReport]               = CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN @ZeroDecimal ELSE ARPAC.[dblAppliedInvoiceDetailAmount] END
--    ,[dblCreditForeign]             = CASE WHEN I.[ysnIsInvoicePositive] = 0 THEN @ZeroDecimal ELSE ARPAC.[dblAppliedInvoiceDetailAmount] END
--    ,[dblCreditReport]              = CASE WHEN I.[ysnIsInvoicePositive] = 0 THEN @ZeroDecimal ELSE ARPAC.[dblAppliedInvoiceDetailAmount] END
--    ,[dblReportingRate]             = I.[dblAverageExchangeRate]
--    ,[dblForeignRate]               = I.[dblAverageExchangeRate]
--    ,[strRateType]                  = NULL
--    ,[strDocument]                  = NULL
--    ,[strComments]                  = NULL
--    ,[strSourceDocumentId]          = NULL
--    ,[intSourceLocationId]          = NULL
--    ,[intSourceUOMId]               = NULL
--    ,[dblSourceUnitDebit]           = NULL
--    ,[dblSourceUnitCredit]          = NULL
--    ,[intCommodityId]               = NULL
--    ,[intSourceEntityId]            = NULL
--    ,[ysnRebuild]                   = NULL
--FROM
--    (SELECT
--     I.[strInvoiceNumber]
--    ,PPC.[intInvoiceId]
--    ,I.[strTransactionType]
--    ,I.[intAccountId]
--    ,[intPrepaidAndCreditId]
--    ,[intPrepaymentId]
--    ,[ysnApplied]
--    ,[dblAppliedInvoiceDetailAmount]
--    ,[dblBaseAppliedInvoiceDetailAmount]
--    FROM
--        tblARPrepaidAndCredit PPC WITH (NOLOCK)
--    INNER JOIN
--        tblARInvoice I
--            ON I.intInvoiceId = PPC.intPrepaymentId
--    ) ARPAC
--INNER JOIN
--    #ARPostInvoiceHeader I
--        ON ARPAC.[intInvoiceId] = I.[intInvoiceId]
--        AND ISNULL(ARPAC.[ysnApplied],0) = 1 
--        AND ARPAC.[dblAppliedInvoiceDetailAmount] <> @ZeroDecimal
--WHERE
--    I.[intPeriodsToAccrue] <= 1
--    AND I.[strTransactionType] <> 'Cash Refund'

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
    ,[intAccountId]                 = I.[intItemAccountId]
    ,[dblDebit]                     = CASE WHEN I.strTransactionType IN ('Invoice', 'Cash') OR (I.strTransactionType = 'Debit Memo' AND I.strType IN ('CF Tran', 'CF Invoice', 'Card Fueling Transaction')) OR (I.strTransactionType = 'Credit Memo' AND I.[ysnFromProvisional] = 1) THEN @ZeroDecimal ELSE I.[dblBaseLineItemGLAmount] END
    ,[dblCredit]                    = CASE WHEN I.strTransactionType IN ('Invoice', 'Cash') OR (I.strTransactionType = 'Debit Memo' AND I.strType IN ('CF Tran', 'CF Invoice', 'Card Fueling Transaction')) OR (I.strTransactionType = 'Credit Memo' AND I.[ysnFromProvisional] = 1) THEN I.[dblBaseLineItemGLAmount] ELSE @ZeroDecimal END
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
    ,[dblDebitForeign]              = CASE WHEN I.strTransactionType IN ('Invoice', 'Cash') OR (I.strTransactionType = 'Debit Memo' AND I.strType IN ('CF Tran', 'CF Invoice', 'Card Fueling Transaction')) OR (I.strTransactionType = 'Credit Memo' AND I.[ysnFromProvisional] = 1) THEN @ZeroDecimal ELSE I.[dblLineItemGLAmount] END
    ,[dblDebitReport]               = CASE WHEN I.strTransactionType IN ('Invoice', 'Cash') OR (I.strTransactionType = 'Debit Memo' AND I.strType IN ('CF Tran', 'CF Invoice', 'Card Fueling Transaction')) OR (I.strTransactionType = 'Credit Memo' AND I.[ysnFromProvisional] = 1) THEN @ZeroDecimal ELSE I.[dblLineItemGLAmount] END
    ,[dblCreditForeign]             = CASE WHEN I.strTransactionType IN ('Invoice', 'Cash') OR (I.strTransactionType = 'Debit Memo' AND I.strType IN ('CF Tran', 'CF Invoice', 'Card Fueling Transaction')) OR (I.strTransactionType = 'Credit Memo' AND I.[ysnFromProvisional] = 1) THEN I.[dblLineItemGLAmount] ELSE @ZeroDecimal END
    ,[dblCreditReport]              = CASE WHEN I.strTransactionType IN ('Invoice', 'Cash') OR (I.strTransactionType = 'Debit Memo' AND I.strType IN ('CF Tran', 'CF Invoice', 'Card Fueling Transaction')) OR (I.strTransactionType = 'Credit Memo' AND I.[ysnFromProvisional] = 1) THEN I.[dblLineItemGLAmount] ELSE @ZeroDecimal END
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
    ,[intSourceEntityId]            = NULL
    ,[ysnRebuild]                   = NULL
FROM
    #ARPostInvoiceDetail I
WHERE
    I.[intPeriodsToAccrue] <= 1
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
    AND (
        I.[dblTotal] <> @ZeroDecimal
        OR
	    I.[dblQtyShipped] <> @ZeroDecimal
        )
    AND I.[strTransactionType] NOT IN ('Debit Memo', 'Cash Refund')

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
    ,[intSourceEntityId]            = NULL
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
    ,[intSourceEntityId]            = NULL
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
    ,[intSourceEntityId]            = NULL
    ,[ysnRebuild]                   = NULL
FROM
    #ARPostInvoiceDetail I
WHERE
    I.[intPeriodsToAccrue] <= 1
    AND I.[dblMaintenanceAmount] <> @ZeroDecimal
    AND I.[strMaintenanceType] IN ('License/Maintenance', 'Maintenance Only', 'SaaS')
    AND I.[strItemType] = 'Software'
    AND I.[strTransactionType] NOT IN ('Cash Refund', 'Debit Memo')

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
    ,[dblCreditReport]              = CASE WHEN I.[strTransactionType] IN ('Invoice', 'Cash')  THEN I.[dblLineItemGLAmount] ELSE @ZeroDecimal END
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
    ,[intSourceEntityId]            = NULL
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
    --,[dblDebit]                     = CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN @ZeroDecimal ELSE I.[dblBaseInvoiceTotal] - I.[dblBaseProvisionalAmount] END
    --,[dblCredit]                    = CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN I.[dblBaseInvoiceTotal] - I.[dblBaseProvisionalAmount] ELSE @ZeroDecimal END
    ,[dblDebit]                     = CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN @ZeroDecimal ELSE I.[dblBaseInvoiceTotal] END
    ,[dblCredit]                    = CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN I.[dblBaseInvoiceTotal] ELSE @ZeroDecimal END
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
    --,[dblDebitForeign]              = CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN @ZeroDecimal ELSE I.[dblInvoiceTotal] - I.[dblProvisionalAmount] END
    --,[dblDebitReport]               = CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN @ZeroDecimal ELSE I.[dblInvoiceTotal] - I.[dblProvisionalAmount] END
    --,[dblCreditForeign]             = CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN I.[dblInvoiceTotal] - I.[dblProvisionalAmount] ELSE @ZeroDecimal END
    --,[dblCreditReport]              = CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN I.[dblInvoiceTotal] - I.[dblProvisionalAmount] ELSE @ZeroDecimal END
    ,[dblDebitForeign]              = CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN @ZeroDecimal ELSE I.[dblInvoiceTotal] END
    ,[dblDebitReport]               = CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN @ZeroDecimal ELSE I.[dblInvoiceTotal] END
    ,[dblCreditForeign]             = CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN I.[dblInvoiceTotal] ELSE @ZeroDecimal END
    ,[dblCreditReport]              = CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN I.[dblInvoiceTotal] ELSE @ZeroDecimal END
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
    ,[intSourceEntityId]            = NULL
    ,[ysnRebuild]                   = NULL
FROM
    #ARPostInvoiceDetail I
WHERE
    I.[intPeriodsToAccrue] <= 1
	AND I.[ysnFromProvisional] = 1
    --AND ((I.[dblInvoiceTotal] - I.[dblProvisionalAmount]) <> @ZeroDecimal)
	AND I.[dblInvoiceTotal] <> @ZeroDecimal
	AND I.[dblProvisionalAmount] = @ZeroDecimal
    AND I.[intItemId] IS NOT NULL
    AND I.[strItemType] NOT IN ('Non-Inventory','Service','Other Charge','Software','Comment')
    AND I.[strTransactionType] NOT IN ('Cash Refund', 'Debit Memo')

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
    ,[dblDebit]                     = CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN I.[dblBaseLineItemGLAmount] ELSE @ZeroDecimal END
    ,[dblCredit]                    = CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN @ZeroDecimal ELSE I.[dblBaseLineItemGLAmount] END
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
    ,[dblDebitForeign]              = CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN I.[dblLineItemGLAmount] ELSE @ZeroDecimal END
    ,[dblDebitReport]               = CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN I.[dblLineItemGLAmount] ELSE @ZeroDecimal END
    ,[dblCreditForeign]             = CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN @ZeroDecimal ELSE I.[dblLineItemGLAmount] END
    ,[dblCreditReport]              = CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN @ZeroDecimal ELSE I.[dblLineItemGLAmount] END
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
    ,[intSourceEntityId]            = NULL
    ,[ysnRebuild]                   = NULL
FROM
    #ARPostInvoiceDetail I
WHERE
    I.[intPeriodsToAccrue] <= 1
	AND I.[ysnFromProvisional] = 1
	AND I.[dblBaseLineItemGLAmount] <> @ZeroDecimal
	AND I.[dblProvisionalAmount] <> @ZeroDecimal
    AND I.[intItemId] IS NOT NULL
    AND I.[strItemType] NOT IN ('Non-Inventory','Service','Other Charge','Software','Comment')
    AND I.[strTransactionType] NOT IN ('Cash Refund', 'Debit Memo')


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
    ,[intSourceEntityId]            = NULL
    ,[ysnRebuild]                   = NULL
FROM
    #ARPostInvoiceDetail I
WHERE
    I.[intPeriodsToAccrue] <= 1
    AND I.[dblQtyShipped] <> @ZeroDecimal
    -- AND I.[strType] NOT IN ('CF Tran', 'CF Invoice', 'Card Fueling Transaction')
    AND I.[strTransactionType] = 'Debit Memo'
    AND I.[strItemType] <> 'Comment'

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
    ,[intSourceEntityId]            = NULL
    ,[ysnRebuild]                   = NULL
FROM
    #ARPostInvoiceHeader I
WHERE
    I.[dblShipping] <> @ZeroDecimal

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
    ,[intAccountId]                 = ARIDT.[intSalesTaxAccountId]
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
    ,[intSourceEntityId]            = NULL
    ,[ysnRebuild]                   = NULL
FROM
    (
    SELECT
	     [intTaxCodeId]
		,[intInvoiceDetailId]
		,[intInvoiceDetailTaxId]
		,[intSalesTaxAccountId]
		,[dblAdjustedTax]
		,[dblBaseAdjustedTax]
    FROM tblARInvoiceDetailTax WITH (NOLOCK)
	) ARIDT
INNER JOIN
    #ARPostInvoiceDetail I
        ON ARIDT.[intInvoiceDetailId] = I.[intInvoiceDetailId]
WHERE
    I.[intPeriodsToAccrue] <= 1
    AND ARIDT.[dblAdjustedTax] <> @ZeroDecimal

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
    ,[intAccountId]                 = ISNULL(IA.[intDiscountAccountId], I.[intDiscountAccountId])
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
    ,[intSourceEntityId]            = NULL
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
