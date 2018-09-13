CREATE FUNCTION [dbo].[fnARGenerateGLEntriesForInvoices]
(
     @PostInvoiceData [dbo].[InvoicePostingTable] READONLY
    ,@ItemAccounts    [InvoiceItemAccount] READONLY
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

----DEBIT Total
--SELECT
--		dtmDate					= CAST(ISNULL(A.dtmPostDate, A.dtmDate) AS DATE)
--	,strBatchID					= @batchIdUsed
--	,intAccountId				= A.intAccountId
--	,dblDebit					= CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash') THEN A.dblBaseInvoiceTotal ELSE @ZeroDecimal END
--	,dblCredit					= CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash') THEN @ZeroDecimal ELSE A.dblBaseInvoiceTotal END
--	,dblDebitUnit				= CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash') THEN  
--																					(
--																						SELECT
--																							SUM(dbo.fnARCalculateQtyBetweenUOM(ARID.intItemUOMId, ICIS.intStockUOMId, ARID.dblQtyShipped, null, I.strType))
--																						FROM
--																							(SELECT intInvoiceId, intItemId, intItemUOMId, dblQtyShipped 
--																								FROM tblARInvoiceDetail WITH (NOLOCK)) ARID 
--																						INNER JOIN
--																							(SELECT intInvoiceId, intCompanyLocationId FROM tblARInvoice WITH (NOLOCK)) ARI
--																								ON ARID.intInvoiceId = ARI.intInvoiceId	
--																						LEFT OUTER JOIN
--																							(SELECT intItemId, strType FROM tblICItem WITH (NOLOCK)) I
--																								ON ARID.intItemId = I.intItemId
--																						LEFT OUTER JOIN
--																							(SELECT intItemId, intLocationId FROM vyuARGetItemAccount WITH (NOLOCK)) IST
--																								ON ARID.intItemId = IST.intItemId 
--																								AND ARI.intCompanyLocationId = IST.intLocationId 
--																						LEFT OUTER JOIN
--																							(SELECT intItemId, intLocationId, intStockUOMId FROM vyuICGetItemStock WITH (NOLOCK)) ICIS ON ARID.intItemId = ICIS.intItemId 
--																								AND ARI.intCompanyLocationId = ICIS.intLocationId 
--																						WHERE
--																							ARI.intInvoiceId = A.intInvoiceId
--																							AND ARID.dblQtyShipped <> @ZeroDecimal  
--																					)
--																				ELSE 
--																					@ZeroDecimal
--																				END
--	,dblCreditUnit				=  CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash') THEN  
--																					@ZeroDecimal
--																				ELSE 
--																					(
--																					SELECT
--																						SUM(dbo.fnARCalculateQtyBetweenUOM(ARID.intItemUOMId, ICIS.intStockUOMId, ARID.dblQtyShipped, null, I.strType))
--																					FROM
--																						(SELECT intInvoiceId, intItemId, intItemUOMId, dblQtyShipped 
--																							FROM tblARInvoiceDetail WITH (NOLOCK)) ARID 
--																					INNER JOIN
--																						(SELECT intInvoiceId, intCompanyLocationId FROM tblARInvoice WITH (NOLOCK)) ARI
--																							ON ARID.intInvoiceId = ARI.intInvoiceId	
--																					LEFT OUTER JOIN
--																						(SELECT intItemId, strType FROM tblICItem WITH (NOLOCK)) I
--																							ON ARID.intItemId = I.intItemId
--																					LEFT OUTER JOIN
--																						(SELECT intItemId, intLocationId FROM vyuARGetItemAccount WITH (NOLOCK)) IST
--																							ON ARID.intItemId = IST.intItemId 
--																							AND ARI.intCompanyLocationId = IST.intLocationId 
--																					LEFT OUTER JOIN
--																						(SELECT intItemId, intLocationId, intStockUOMId FROM vyuICGetItemStock WITH (NOLOCK)) ICIS
--																							ON ARID.intItemId = ICIS.intItemId 
--																							AND ARI.intCompanyLocationId = ICIS.intLocationId 
--																					WHERE
--																						ARI.intInvoiceId = A.intInvoiceId
--																						AND ARID.dblQtyShipped <> @ZeroDecimal  
--																					)
--																				END																						
--	,strDescription				= P.[strDescription]
--	,strCode					= @CODE
--	,strReference				= C.strCustomerNumber
--	,intCurrencyId				= A.intCurrencyId 
--	,dblExchangeRate			= A.dblCurrencyExchangeRate
--	,dtmDateEntered				= @PostDate
--	,dtmTransactionDate			= A.dtmDate
--	,strJournalLineDescription	= @POSTDESC + A.strTransactionType 
--	,intJournalLineNo			= A.intInvoiceId
--	,ysnIsUnposted				= 0
--	,intUserId					= @userId
--	,intEntityId				= @UserEntityID				
--	,strTransactionId			= A.strInvoiceNumber
--	,intTransactionId			= A.intInvoiceId
--	,strTransactionType			= A.strTransactionType
--	,strTransactionForm			= @SCREEN_NAME
--	,strModuleName				= @MODULE_NAME
--	,intConcurrencyId			= 1
--	,[dblDebitForeign]			= CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash') THEN A.dblInvoiceTotal - ISNULL(@ZeroDecimal, @ZeroDecimal) ELSE @ZeroDecimal END
--	,[dblDebitReport]			= CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash') THEN A.dblInvoiceTotal - ISNULL(@ZeroDecimal, @ZeroDecimal) ELSE @ZeroDecimal END
--	,[dblCreditForeign]			= CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash') THEN @ZeroDecimal ELSE A.dblInvoiceTotal - ISNULL(@ZeroDecimal, @ZeroDecimal) END
--	,[dblCreditReport]			= CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash') THEN @ZeroDecimal ELSE A.dblInvoiceTotal - ISNULL(@ZeroDecimal, @ZeroDecimal) END
--	,[dblReportingRate]			= A.dblCurrencyExchangeRate
--	,[dblForeignRate]			= A.dblCurrencyExchangeRate
--	,[strRateType]				= ''
--FROM
--	(SELECT intInvoiceId, strInvoiceNumber, intEntityCustomerId, strTransactionType, intCurrencyId, dtmDate, dtmPostDate, strComments, dblInvoiceTotal, intAccountId, intPeriodsToAccrue, dblBaseInvoiceTotal, intSourceId, intOriginalInvoiceId, ISNULL(dblCurrencyExchangeRate, @OneDecimal) AS dblCurrencyExchangeRate
--		FROM tblARInvoice WITH (NOLOCK)) A
--LEFT JOIN 
--	(SELECT [intEntityId], [strCustomerNumber] FROM tblARCustomer WITH (NOLOCK)) C
--		ON A.[intEntityCustomerId] = C.[intEntityId]
--INNER JOIN 
--	(SELECT intInvoiceId, [strDescription] FROM @PostInvoiceData )	P ON A.intInvoiceId = P.intInvoiceId				
--WHERE
--	ISNULL(A.intPeriodsToAccrue,0) <= 1
--	AND (
--			A.dblInvoiceTotal <> @ZeroDecimal
--			OR
--			EXISTS(SELECT NULL FROM tblARInvoiceDetail ARID INNER JOIN (SELECT intItemId, strType FROM tblICItem) ICI ON ARID.intItemId = ICI.intItemId AND ICI.strType <> 'Comment' WHERE ARID.intInvoiceId  = A.[intInvoiceId])
--		)
--	AND NOT(A.intSourceId = 2 AND A.intOriginalInvoiceId IS NOT NULL)
SELECT
     [dtmDate]                      = CAST(ISNULL(I.[dtmPostDate], I.[dtmDate]) AS DATE)
    ,[strBatchId]                   = I.[strBatchId]
    ,[intAccountId]                 = I.[intAccountId]
    ,[dblDebit]                     = CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN I.[dblBaseInvoiceTotal] ELSE @ZeroDecimal END
    ,[dblCredit]                    = CASE WHEN I.[ysnIsInvoicePositive] = 0 THEN I.[dblBaseInvoiceTotal] ELSE @ZeroDecimal END
    ,[dblDebitUnit]                 = CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN ARID.[dblUnitQtyShipped] ELSE @ZeroDecimal END
    ,[dblCreditUnit]                = CASE WHEN I.[ysnIsInvoicePositive] = 0 THEN ARID.[dblUnitQtyShipped] ELSE @ZeroDecimal END
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
    ,[dblDebitForeign]              = CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN I.[dblInvoiceTotal] ELSE @ZeroDecimal END
    ,[dblDebitReport]               = CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN I.[dblInvoiceTotal] ELSE @ZeroDecimal END
    ,[dblCreditForeign]             = CASE WHEN I.[ysnIsInvoicePositive] = 0 THEN I.[dblInvoiceTotal] ELSE @ZeroDecimal END
    ,[dblCreditReport]              = CASE WHEN I.[ysnIsInvoicePositive] = 0 THEN I.[dblInvoiceTotal] ELSE @ZeroDecimal END
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
    @PostInvoiceData I
LEFT OUTER JOIN
    (
    SELECT
         [dblUnitQtyShipped]    = SUM([dblUnitQtyShipped])
        ,[intInvoiceId]         = [intInvoiceId]
    FROM
        @PostInvoiceData
    WHERE
        [intInvoiceDetailId] IS NOT NULL
    GROUP BY
        [intInvoiceId]
    ) ARID
        ON I.[intInvoiceId] = ARID.[intInvoiceId]
WHERE
    I.[intInvoiceDetailId] IS NULL
    AND I.[ysnPost] = 1
    AND I.[intPeriodsToAccrue] <= 1
    AND
        (
        I.[dblInvoiceTotal] <> @ZeroDecimal
        OR
        EXISTS(SELECT NULL FROM @PostInvoiceData ARID WHERE ARID.[intInvoiceDetailId] IS NOT NULL AND ARID.[intItemId] IS NOT NULL AND ARID.[strItemType] <> 'Comment' AND ARID.intInvoiceId  = I.[intInvoiceId])
        )
    AND NOT(I.[intSourceId] = 2 AND I.[intOriginalInvoiceId] IS NOT NULL)

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
-- 	(SELECT intInvoiceId, [strDescription] FROM @PostInvoiceData )	P ON A.intInvoiceId = P.intInvoiceId	
-- WHERE
-- 	ISNULL(A.intPeriodsToAccrue,0) <= 1
-- 	AND (
-- 			A.dblAmountDue <> @ZeroDecimal
-- 			OR
-- 			EXISTS(SELECT NULL FROM tblARInvoiceDetail ARID INNER JOIN (SELECT intItemId, strType FROM tblICItem) ICI ON ARID.intItemId = ICI.intItemId AND ICI.strType <> 'Comment' WHERE ARID.intInvoiceId  = A.[intInvoiceId])
-- 		)
-- 	AND A.intSourceId = 2 
-- 	AND A.intOriginalInvoiceId IS NOT NULL

UNION ALL
--CREDIT - Provisional Invoice Amount + Sales
--SELECT
--		dtmDate					= CAST(ISNULL(A.dtmPostDate, A.dtmDate) AS DATE)
--	,strBatchID					= @batchIdUsed
--	,intAccountId				= A.intAccountId
--	,dblDebit					= CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash') THEN @ZeroDecimal ELSE A.dblBaseInvoiceTotal END
--	,dblCredit					= CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash') THEN A.dblBaseInvoiceTotal ELSE @ZeroDecimal END
--	,dblDebitUnit				= @ZeroDecimal
--	,dblCreditUnit				= @ZeroDecimal																				
--	,strDescription				= P.[strDescription]
--	,strCode					= @CODE
--	,strReference				= C.strCustomerNumber
--	,intCurrencyId				= A.intCurrencyId 
--	,dblExchangeRate			= A.dblCurrencyExchangeRate
--	,dtmDateEntered				= @PostDate
--	,dtmTransactionDate			= A.dtmDate
--	,strJournalLineDescription	= 'Provisional Amount'
--	,intJournalLineNo			= A.intInvoiceId
--	,ysnIsUnposted				= 0
--	,intUserId					= @userId
--	,intEntityId				= @UserEntityID				
--	,strTransactionId			= A.strInvoiceNumber
--	,intTransactionId			= A.intInvoiceId
--	,strTransactionType			= A.strTransactionType
--	,strTransactionForm			= @SCREEN_NAME
--	,strModuleName				= @MODULE_NAME
--	,intConcurrencyId			= 1
--	,[dblDebitForeign]			= CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash') THEN @ZeroDecimal ELSE A.dblInvoiceTotal END
--	,[dblDebitReport]			= CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash') THEN @ZeroDecimal ELSE A.dblInvoiceTotal END
--	,[dblCreditForeign]			= CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash') THEN A.dblInvoiceTotal ELSE @ZeroDecimal END
--	,[dblCreditReport]			= CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash') THEN A.dblInvoiceTotal ELSE @ZeroDecimal END
--	,[dblReportingRate]			= A.dblCurrencyExchangeRate
--	,[dblForeignRate]			= A.dblCurrencyExchangeRate
--	,[strRateType]				= ''
--FROM
--	(SELECT intInvoiceId, strInvoiceNumber, intEntityCustomerId, strTransactionType, intCurrencyId, dtmDate, dtmPostDate, strComments, dblAmountDue, intAccountId, intPeriodsToAccrue, dblBaseAmountDue, intSourceId, intOriginalInvoiceId, dblInvoiceTotal, dblBaseInvoiceTotal, ISNULL(dblCurrencyExchangeRate, @OneDecimal) AS dblCurrencyExchangeRate
--		FROM tblARInvoice WITH (NOLOCK)) A
--LEFT JOIN 
--	(SELECT [intEntityId], [strCustomerNumber] FROM tblARCustomer WITH (NOLOCK)) C
--		ON A.[intEntityCustomerId] = C.[intEntityId]
--INNER JOIN 
--	(SELECT intInvoiceId, [strDescription] FROM @PostInvoiceData )	P ON A.intInvoiceId = P.intInvoiceId	
--WHERE
--	ISNULL(A.intPeriodsToAccrue,0) <= 1
--	AND (
--			(A.dblBaseAmountDue - A.dblBaseInvoiceTotal) <> @ZeroDecimal
--			OR
--			EXISTS(SELECT NULL FROM tblARInvoiceDetail ARID INNER JOIN (SELECT intItemId, strType FROM tblICItem) ICI ON ARID.intItemId = ICI.intItemId AND ICI.strType <> 'Comment' WHERE ARID.intInvoiceId  = A.[intInvoiceId])
--		)
--	AND A.intSourceId = 2 
--	AND A.intOriginalInvoiceId IS NOT NULL
SELECT
     [dtmDate]                      = CAST(ISNULL(I.[dtmPostDate], I.[dtmDate]) AS DATE)
    ,[strBatchId]                   = I.[strBatchId]
    ,[intAccountId]                 = I.[intAccountId]
    ,[dblDebit]                     = CASE WHEN I.[ysnIsInvoicePositive] = 0 THEN I.[dblBaseInvoiceTotal] ELSE @ZeroDecimal END
    ,[dblCredit]                    = CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN I.[dblBaseInvoiceTotal] ELSE @ZeroDecimal END
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
    ,[dblDebitForeign]              = CASE WHEN I.[ysnIsInvoicePositive] = 0 THEN I.[dblInvoiceTotal] ELSE @ZeroDecimal END
    ,[dblDebitReport]               = CASE WHEN I.[ysnIsInvoicePositive] = 0 THEN I.[dblInvoiceTotal] ELSE @ZeroDecimal END
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
    @PostInvoiceData I
WHERE
    I.[intInvoiceDetailId] IS NULL
    AND I.[ysnPost] = 1
    AND I.[intPeriodsToAccrue] <= 1
    AND
        (
        (I.[dblBaseAmountDue] - I.[dblBaseInvoiceTotal]) <> @ZeroDecimal
        OR
        EXISTS(SELECT NULL FROM @PostInvoiceData ARID WHERE ARID.[intInvoiceDetailId] IS NOT NULL AND ARID.[intItemId] IS NOT NULL AND ARID.[strItemType] <> 'Comment' AND ARID.intInvoiceId  = I.[intInvoiceId])
        )
    AND I.[intSourceId] = 2 
    AND I.[intOriginalInvoiceId] IS NOT NULL

UNION ALL
--DEBIT Prepaids
--SELECT
--	 dtmDate					= CAST(ISNULL(A.dtmPostDate, A.dtmDate) AS DATE)
--	,strBatchID					= @batchIdUsed
--	,intAccountId				= ARPAC.intAccountId
--	,dblDebit					= CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash', 'Cash Refund') THEN  ARPAC.[dblAppliedInvoiceDetailAmount] ELSE @ZeroDecimal END
--	,dblCredit					= CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash', 'Cash Refund') THEN  @ZeroDecimal ELSE ARPAC.[dblAppliedInvoiceDetailAmount] END
--	,dblDebitUnit				= @ZeroDecimal 
--	,dblCreditUnit				= @ZeroDecimal
--	,strDescription				= A.strComments
--	,strCode					= @CODE
--	,strReference				= C.strCustomerNumber
--	,intCurrencyId				= A.intCurrencyId 
--	,dblExchangeRate			= A.dblCurrencyExchangeRate
--	,dtmDateEntered				= @PostDate
--	,dtmTransactionDate			= A.dtmDate
--	,strJournalLineDescription	= 'Applied Prepaid - ' + ARPAC.[strInvoiceNumber] 
--	,intJournalLineNo			= ARPAC.[intPrepaidAndCreditId]
--	,ysnIsUnposted				= 0
--	,intUserId					= @userId
--	,intEntityId				= @UserEntityID				
--	,strTransactionId			= A.strInvoiceNumber
--	,intTransactionId			= A.intInvoiceId
--	,strTransactionType			= A.strTransactionType
--	,strTransactionForm			= @SCREEN_NAME
--	,strModuleName				= @MODULE_NAME
--	,intConcurrencyId			= 1
--	,[dblDebitForeign]			= CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash', 'Cash Refund') THEN  ARPAC.[dblAppliedInvoiceDetailAmount] ELSE @ZeroDecimal END
--	,[dblDebitReport]			= CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash', 'Cash Refund') THEN  ARPAC.[dblAppliedInvoiceDetailAmount] ELSE @ZeroDecimal END
--	,[dblCreditForeign]			= CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash', 'Cash Refund') THEN  @ZeroDecimal ELSE ARPAC.[dblAppliedInvoiceDetailAmount] END
--	,[dblCreditReport]			= CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash', 'Cash Refund') THEN  @ZeroDecimal ELSE ARPAC.[dblAppliedInvoiceDetailAmount] END
--	,[dblReportingRate]			= A.dblCurrencyExchangeRate
--	,[dblForeignRate]			= A.dblCurrencyExchangeRate
--	,[strRateType]				= ''	 
--FROM
--	(SELECT I.strInvoiceNumber,PPC.[intInvoiceId],I.intAccountId, [intPrepaidAndCreditId], [intPrepaymentId], [ysnApplied], [dblAppliedInvoiceDetailAmount], [dblBaseAppliedInvoiceDetailAmount]
--		FROM tblARPrepaidAndCredit PPC WITH (NOLOCK)
--		INNER JOIN tblARInvoice I
--		ON I.intInvoiceId = PPC.intPrepaymentId) ARPAC
--INNER JOIN
--	(SELECT [intInvoiceId],intAccountId, strInvoiceNumber, dtmDate, dtmPostDate, strTransactionType, intCurrencyId, [intEntityCustomerId], strComments, intPeriodsToAccrue, ISNULL(dblCurrencyExchangeRate, @OneDecimal) AS dblCurrencyExchangeRate
--		FROM tblARInvoice WITH (NOLOCK)) A
--		ON ARPAC.[intInvoiceId] = A.[intInvoiceId] AND ISNULL(ARPAC.[ysnApplied],0) = 1 AND ARPAC.[dblAppliedInvoiceDetailAmount] <> @ZeroDecimal
--LEFT JOIN 
--	(SELECT [intEntityId], strCustomerNumber FROM tblARCustomer WITH (NOLOCK)) C ON A.[intEntityCustomerId] = C.[intEntityId]
--INNER JOIN 
--	(SELECT intInvoiceId FROM @PostInvoiceData ) P ON A.intInvoiceId = P.intInvoiceId
--WHERE
--	ISNULL(A.intPeriodsToAccrue,0) <= 1			
SELECT
     [dtmDate]                      = CAST(ISNULL(I.[dtmPostDate], I.[dtmDate]) AS DATE)
    ,[strBatchId]                   = I.[strBatchId]
    ,[intAccountId]                 = ARPAC.[intAccountId]
    ,[dblDebit]                     = CASE WHEN I.[strTransactionType] IN ('Invoice', 'Debit Memo', 'Cash', 'Cash Refund') THEN ARPAC.[dblBaseAppliedInvoiceDetailAmount] ELSE @ZeroDecimal END
    ,[dblCredit]                    = CASE WHEN I.[strTransactionType] IN ('Invoice', 'Debit Memo', 'Cash', 'Cash Refund') THEN @ZeroDecimal ELSE ARPAC.[dblBaseAppliedInvoiceDetailAmount] END
    ,[dblDebitUnit]                 = @ZeroDecimal
    ,[dblCreditUnit]                = @ZeroDecimal
    ,[strDescription]               = I.[strComments]
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
    ,[dblDebitForeign]              = CASE WHEN I.[strTransactionType] IN ('Invoice', 'Debit Memo', 'Cash', 'Cash Refund') THEN ARPAC.[dblAppliedInvoiceDetailAmount] ELSE @ZeroDecimal END
    ,[dblDebitReport]               = CASE WHEN I.[strTransactionType] IN ('Invoice', 'Debit Memo', 'Cash', 'Cash Refund') THEN ARPAC.[dblAppliedInvoiceDetailAmount] ELSE @ZeroDecimal END
    ,[dblCreditForeign]             = CASE WHEN I.[strTransactionType] IN ('Invoice', 'Debit Memo', 'Cash', 'Cash Refund') THEN @ZeroDecimal ELSE ARPAC.[dblAppliedInvoiceDetailAmount] END
    ,[dblCreditReport]              = CASE WHEN I.[strTransactionType] IN ('Invoice', 'Debit Memo', 'Cash', 'Cash Refund') THEN @ZeroDecimal ELSE ARPAC.[dblAppliedInvoiceDetailAmount] END
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
    @PostInvoiceData I
        ON ARPAC.[intInvoiceId] = I.[intInvoiceId]
        AND I.[ysnPost] = 1
        AND ISNULL(ARPAC.[ysnApplied],0) = 1 
        AND ARPAC.[dblAppliedInvoiceDetailAmount] <> @ZeroDecimal
WHERE
    I.[intInvoiceDetailId] IS NULL
    AND I.[intPeriodsToAccrue] <= 1

UNION ALL
--Debit Payment
--SELECT
--	 dtmDate					= CAST(ISNULL(A.dtmPostDate, A.dtmDate) AS DATE)
--	,strBatchID					= @batchIdUsed
--	,intAccountId				= SMCL.intUndepositedFundsId 
--	,dblDebit					= CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash') THEN  A.dblBasePayment - ISNULL(@ZeroDecimal, @ZeroDecimal) ELSE @ZeroDecimal END
--	,dblCredit					= CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash') THEN  @ZeroDecimal ELSE A.dblBasePayment - ISNULL(@ZeroDecimal, @ZeroDecimal) END
--	,dblDebitUnit				= @ZeroDecimal
--	,dblCreditUnit				= @ZeroDecimal					
--	,strDescription				= P.[strDescription]
--	,strCode					= @CODE
--	,strReference				= C.strCustomerNumber
--	,intCurrencyId				= A.intCurrencyId 
--	,dblExchangeRate			= A.dblCurrencyExchangeRate
--	,dtmDateEntered				= @PostDate
--	,dtmTransactionDate			= A.dtmDate
--	,strJournalLineDescription	= @POSTDESC + A.strTransactionType 
--	,intJournalLineNo			= A.intInvoiceId
--	,ysnIsUnposted				= 0
--	,intUserId					= @userId
--	,intEntityId				= @UserEntityID				
--	,strTransactionId			= A.strInvoiceNumber
--	,intTransactionId			= A.intInvoiceId
--	,strTransactionType			= A.strTransactionType
--	,strTransactionForm			= @SCREEN_NAME
--	,strModuleName				= @MODULE_NAME
--	,intConcurrencyId			= 1
--	,[dblDebitForeign]			= CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash') THEN  A.dblPayment - ISNULL(@ZeroDecimal, @ZeroDecimal) ELSE @ZeroDecimal END
--	,[dblDebitReport]			= CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash') THEN  A.dblPayment - ISNULL(@ZeroDecimal, @ZeroDecimal) ELSE @ZeroDecimal END
--	,[dblCreditForeign]			= CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash') THEN  @ZeroDecimal ELSE A.dblPayment - ISNULL(@ZeroDecimal, @ZeroDecimal) END
--	,[dblCreditReport]			= CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash') THEN  @ZeroDecimal ELSE A.dblPayment - ISNULL(@ZeroDecimal, @ZeroDecimal) END
--	,[dblReportingRate]			= A.dblCurrencyExchangeRate
--	,[dblForeignRate]			= A.dblCurrencyExchangeRate
--	,[strRateType]				= ''	  			
--FROM
--	(SELECT intInvoiceId, strInvoiceNumber, [intEntityCustomerId], intCompanyLocationId, dtmPostDate, dtmDate, strTransactionType, dblPayment, strComments, intCurrencyId, intPeriodsToAccrue, dblBasePayment, dblBaseInvoiceTotal,dblInvoiceTotal, ISNULL(dblCurrencyExchangeRate, @OneDecimal) AS dblCurrencyExchangeRate
--		FROM tblARInvoice WITH (NOLOCK)) A
--LEFT JOIN 
--	(SELECT [intEntityId], strCustomerNumber FROM tblARCustomer WITH (NOLOCK)) C ON A.[intEntityCustomerId] = C.[intEntityId]
--INNER JOIN 
--	(SELECT intInvoiceId, [strDescription] FROM @PostInvoiceData) P ON A.intInvoiceId = P.intInvoiceId
--INNER JOIN
--	(SELECT intCompanyLocationId, intUndepositedFundsId FROM tblSMCompanyLocation WITH (NOLOCK)) SMCL
--		ON A.intCompanyLocationId = SMCL.intCompanyLocationId
--WHERE
--	ISNULL(A.intPeriodsToAccrue,0) <= 1
--	AND (A.dblPayment - ISNULL(@ZeroDecimal, @ZeroDecimal)) <> @ZeroDecimal
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
    @PostInvoiceData I
WHERE
    I.intInvoiceDetailId IS NULL
    AND I.[ysnPost] = 1
    AND I.[intPeriodsToAccrue] <= 1
    AND I.[dblPayment] <> @ZeroDecimal

UNION ALL
--Credit Prepaids
--SELECT
--	 dtmDate					= CAST(ISNULL(A.dtmPostDate, A.dtmDate) AS DATE)
--	,strBatchID					= @batchIdUsed
--	,intAccountId				= CASE WHEN ARPAC.strTransactionType IN('Customer Prepayment','Credit Memo') THEN SMCL.intAPAccount ELSE ARPAC.intAccountId END
--	,dblDebit					= CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash', 'Cash Refund') THEN  @ZeroDecimal ELSE ARPAC.[dblAppliedInvoiceDetailAmount] END
--	,dblCredit					= CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash', 'Cash Refund') THEN  ARPAC.[dblAppliedInvoiceDetailAmount] ELSE @ZeroDecimal END
--	,dblDebitUnit				= @ZeroDecimal 
--	,dblCreditForeign			= @ZeroDecimal
--	,strDescription				= A.strComments
--	,strCode					= @CODE
--	,strReference				= C.strCustomerNumber
--	,intCurrencyId				= A.intCurrencyId 
--	,dblExchangeRate			= A.dblCurrencyExchangeRate
--	,dtmDateEntered				= @PostDate
--	,dtmTransactionDate			= A.dtmDate
--	,strJournalLineDescription	= 'Applied Prepaid - ' + ARPAC.[strInvoiceNumber] 
--	,intJournalLineNo			= ARPAC.[intPrepaidAndCreditId]
--	,ysnIsUnposted				= 0
--	,intUserId					= @userId
--	,intEntityId				= @UserEntityID				
--	,strTransactionId			= A.strInvoiceNumber
--	,intTransactionId			= A.intInvoiceId
--	,strTransactionType			= A.strTransactionType
--	,strTransactionForm			= @SCREEN_NAME
--	,strModuleName				= @MODULE_NAME
--	,intConcurrencyId			= 1
--	,[dblDebitForeign]			= CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash', 'Cash Refund') THEN  @ZeroDecimal ELSE ARPAC.[dblAppliedInvoiceDetailAmount] END
--	,[dblDebitReport]			= CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash', 'Cash Refund') THEN  @ZeroDecimal ELSE ARPAC.[dblAppliedInvoiceDetailAmount] END
--	,[dblCreditForeign]			= CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash', 'Cash Refund') THEN  ARPAC.[dblAppliedInvoiceDetailAmount] ELSE @ZeroDecimal END
--	,[dblCreditReport]			= CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash', 'Cash Refund') THEN  ARPAC.[dblAppliedInvoiceDetailAmount] ELSE @ZeroDecimal END
--	,[dblReportingRate]			= A.dblCurrencyExchangeRate
--	,[dblForeignRate]			= A.dblCurrencyExchangeRate
--	,[strRateType]				= ''
--FROM
--	(SELECT  I.strInvoiceNumber, PPC.[intInvoiceId],I.strTransactionType,I.intAccountId, [intPrepaidAndCreditId], [intPrepaymentId], [ysnApplied], [dblAppliedInvoiceDetailAmount], [dblBaseAppliedInvoiceDetailAmount]
--		FROM tblARPrepaidAndCredit PPC WITH (NOLOCK)
--		INNER JOIN tblARInvoice I
--		ON I.intInvoiceId = PPC.intPrepaymentId) ARPAC
--INNER JOIN
--	(SELECT [intInvoiceId],intAccountId, strInvoiceNumber, dtmPostDate, dtmDate, [intEntityCustomerId], strTransactionType, intCurrencyId, strComments, intPeriodsToAccrue, intCompanyLocationId, ISNULL(dblCurrencyExchangeRate, @OneDecimal) AS dblCurrencyExchangeRate
--		FROM tblARInvoice WITH (NOLOCK) ) A ON ARPAC.[intInvoiceId] = A.[intInvoiceId] AND  ISNULL(ARPAC.[ysnApplied],0) = 1 AND ARPAC.[dblAppliedInvoiceDetailAmount] <> @ZeroDecimal				 
--LEFT JOIN 
--	(SELECT [intEntityId], strCustomerNumber FROM tblARCustomer WITH (NOLOCK)) C ON A.[intEntityCustomerId] = C.[intEntityId]
--INNER JOIN 
--	(SELECT intInvoiceId, strTransactionType FROM @PostInvoiceData) P ON A.intInvoiceId = P.intInvoiceId
--LEFT OUTER JOIN
--	(SELECT [intCompanyLocationId], intAPAccount FROM tblSMCompanyLocation WITH (NOLOCK)) SMCL ON SMCL.[intCompanyLocationId] = A.intCompanyLocationId
--WHERE
--	ISNULL(A.intPeriodsToAccrue,0) <= 1
--	AND P.strTransactionType <> 'Cash Refund'
SELECT
     [dtmDate]                      = CAST(ISNULL(I.[dtmPostDate], I.[dtmDate]) AS DATE)
    ,[strBatchId]                   = I.[strBatchId]
    ,[intAccountId]                 = CASE WHEN ARPAC.[strTransactionType] IN('Customer Prepayment','Credit Memo') THEN I.[intAPAccount] ELSE ARPAC.[intAccountId] END
    ,[dblDebit]                     = CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN @ZeroDecimal ELSE ARPAC.[dblBaseAppliedInvoiceDetailAmount] END
    ,[dblCredit]                    = CASE WHEN I.[ysnIsInvoicePositive] = 0 THEN @ZeroDecimal ELSE ARPAC.[dblBaseAppliedInvoiceDetailAmount] END
    ,[dblDebitUnit]                 = @ZeroDecimal
    ,[dblCreditUnit]                = @ZeroDecimal
    ,[strDescription]               = I.[strComments]
    ,[strCode]                      = @CODE
    ,[strReference]                 = I.[strCustomerNumber]
    ,[intCurrencyId]                = I.[intCurrencyId]
    ,[dblExchangeRate]              = I.[dblAverageExchangeRate]
    ,[dtmDateEntered]               = I.[dtmDatePosted]
    ,[dtmTransactionDate]           = I.[dtmDate]
    ,[strJournalLineDescription]    = 'Applied Prepaid - ' + ARPAC.[strInvoiceNumber] 
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
    ,[dblDebitForeign]              = CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN @ZeroDecimal ELSE ARPAC.[dblAppliedInvoiceDetailAmount] END
    ,[dblDebitReport]               = CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN @ZeroDecimal ELSE ARPAC.[dblAppliedInvoiceDetailAmount] END
    ,[dblCreditForeign]             = CASE WHEN I.[ysnIsInvoicePositive] = 0 THEN @ZeroDecimal ELSE ARPAC.[dblAppliedInvoiceDetailAmount] END
    ,[dblCreditReport]              = CASE WHEN I.[ysnIsInvoicePositive] = 0 THEN @ZeroDecimal ELSE ARPAC.[dblAppliedInvoiceDetailAmount] END
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
    (SELECT
     I.[strInvoiceNumber]
    ,PPC.[intInvoiceId]
    ,I.[strTransactionType]
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
    @PostInvoiceData I
        ON ARPAC.[intInvoiceId] = I.[intInvoiceId]
        AND I.[ysnPost] = 1
        AND ISNULL(ARPAC.[ysnApplied],0) = 1 
        AND ARPAC.[dblAppliedInvoiceDetailAmount] <> @ZeroDecimal
WHERE
    I.intInvoiceDetailId IS NULL
    AND I.[intPeriodsToAccrue] <= 1
    AND I.[strTransactionType] <> 'Cash Refund'


UNION ALL
--CREDIT MISC			
--SELECT
--	dtmDate					= CAST(ISNULL(A.dtmPostDate, A.dtmDate) AS DATE)
--	,strBatchID					= @batchIdUsed
--	,intAccountId				= B.intAccountId
--	,dblDebit					= CASE WHEN A.strTransactionType IN ('Invoice', 'Cash') OR (A.strTransactionType = 'Debit Memo' AND A.strType IN ('CF Tran', 'CF Invoice', 'Card Fueling Transaction')) OR (A.strTransactionType = 'Credit Memo' AND A.intSourceId = 2 AND A.intOriginalInvoiceId IS NOT NULL) THEN @ZeroDecimal ELSE ISNULL(B.dblBaseTotal, @ZeroDecimal) + [dbo].fnRoundBanker(((B.dblDiscount/@OneHundredDecimal) * [dbo].fnRoundBanker((B.dblQtyShipped * B.dblBasePrice), dbo.fnARGetDefaultDecimal())), dbo.fnARGetDefaultDecimal())  END
--	,dblCredit					= CASE WHEN A.strTransactionType IN ('Invoice', 'Cash') OR (A.strTransactionType = 'Debit Memo' AND A.strType IN ('CF Tran', 'CF Invoice', 'Card Fueling Transaction')) OR (A.strTransactionType = 'Credit Memo' AND A.intSourceId = 2 AND A.intOriginalInvoiceId IS NOT NULL) THEN ISNULL(B.dblBaseTotal, @ZeroDecimal) + [dbo].fnRoundBanker(((B.dblDiscount/@OneHundredDecimal) * [dbo].fnRoundBanker((B.dblQtyShipped * B.dblBasePrice), dbo.fnARGetDefaultDecimal())), dbo.fnARGetDefaultDecimal()) ELSE @ZeroDecimal  END
--	,dblDebitUnit				= CASE WHEN A.strTransactionType IN ('Invoice', 'Cash') OR (A.strTransactionType = 'Debit Memo' AND A.strType IN ('CF Tran', 'CF Invoice', 'Card Fueling Transaction')) OR (A.strTransactionType = 'Credit Memo' AND A.intSourceId = 2 AND A.intOriginalInvoiceId IS NOT NULL) THEN @ZeroDecimal ELSE dbo.fnARCalculateQtyBetweenUOM(B.intItemUOMId, ICIS.intStockUOMId, B.dblQtyShipped, null, ICIS.strType) END
--	,dblCreditUnit				= CASE WHEN A.strTransactionType IN ('Invoice', 'Cash') OR (A.strTransactionType = 'Debit Memo' AND A.strType IN ('CF Tran', 'CF Invoice', 'Card Fueling Transaction')) OR (A.strTransactionType = 'Credit Memo' AND A.intSourceId = 2 AND A.intOriginalInvoiceId IS NOT NULL) THEN dbo.fnARCalculateQtyBetweenUOM(B.intItemUOMId, ICIS.intStockUOMId, B.dblQtyShipped, null, ICIS.strType) ELSE @ZeroDecimal END				
--	,strDescription				= P.[strDescription]
--	,strCode					= @CODE
--	,strReference				= C.strCustomerNumber
--	,intCurrencyId				= A.intCurrencyId 
--	,dblExchangeRate			= B.dblCurrencyExchangeRate
--	,dtmDateEntered				= @PostDate
--	,dtmTransactionDate			= A.dtmDate
--	,strJournalLineDescription	= B.strItemDescription 
--	,intJournalLineNo			= B.intInvoiceDetailId
--	,ysnIsUnposted				= 0
--	,intUserId					= @userId
--	,intEntityId				= @UserEntityID				
--	,strTransactionId			= A.strInvoiceNumber
--	,intTransactionId			= A.intInvoiceId
--	,strTransactionType			= A.strTransactionType
--	,strTransactionForm			= @SCREEN_NAME
--	,strModuleName				= @MODULE_NAME
--	,intConcurrencyId			= 1
--	,[dblDebitForeign]			= CASE WHEN A.strTransactionType IN ('Invoice', 'Cash') OR (A.strTransactionType = 'Debit Memo' AND A.strType IN ('CF Tran', 'CF Invoice', 'Card Fueling Transaction')) OR (A.strTransactionType = 'Credit Memo' AND A.intSourceId = 2 AND A.intOriginalInvoiceId IS NOT NULL) THEN @ZeroDecimal ELSE ISNULL(B.dblTotal, @ZeroDecimal) + [dbo].fnRoundBanker(((B.dblDiscount/@OneHundredDecimal) * [dbo].fnRoundBanker((B.dblQtyShipped * B.dblPrice), dbo.fnARGetDefaultDecimal())), dbo.fnARGetDefaultDecimal())  END
--	,[dblDebitReport]			= CASE WHEN A.strTransactionType IN ('Invoice', 'Cash') OR (A.strTransactionType = 'Debit Memo' AND A.strType IN ('CF Tran', 'CF Invoice', 'Card Fueling Transaction')) OR (A.strTransactionType = 'Credit Memo' AND A.intSourceId = 2 AND A.intOriginalInvoiceId IS NOT NULL) THEN @ZeroDecimal ELSE ISNULL(B.dblTotal, @ZeroDecimal) + [dbo].fnRoundBanker(((B.dblDiscount/@OneHundredDecimal) * [dbo].fnRoundBanker((B.dblQtyShipped * B.dblPrice), dbo.fnARGetDefaultDecimal())), dbo.fnARGetDefaultDecimal())  END
--	,[dblCreditForeign]			= CASE WHEN A.strTransactionType IN ('Invoice', 'Cash') OR (A.strTransactionType = 'Debit Memo' AND A.strType IN ('CF Tran', 'CF Invoice', 'Card Fueling Transaction')) OR (A.strTransactionType = 'Credit Memo' AND A.intSourceId = 2 AND A.intOriginalInvoiceId IS NOT NULL) THEN ISNULL(B.dblTotal, @ZeroDecimal) + [dbo].fnRoundBanker(((B.dblDiscount/@OneHundredDecimal) * [dbo].fnRoundBanker((B.dblQtyShipped * B.dblPrice), dbo.fnARGetDefaultDecimal())), dbo.fnARGetDefaultDecimal()) ELSE @ZeroDecimal  END
--	,[dblCreditReport]			= CASE WHEN A.strTransactionType IN ('Invoice', 'Cash') OR (A.strTransactionType = 'Debit Memo' AND A.strType IN ('CF Tran', 'CF Invoice', 'Card Fueling Transaction')) OR (A.strTransactionType = 'Credit Memo' AND A.intSourceId = 2 AND A.intOriginalInvoiceId IS NOT NULL) THEN ISNULL(B.dblTotal, @ZeroDecimal) + [dbo].fnRoundBanker(((B.dblDiscount/@OneHundredDecimal) * [dbo].fnRoundBanker((B.dblQtyShipped * B.dblPrice), dbo.fnARGetDefaultDecimal())), dbo.fnARGetDefaultDecimal()) ELSE @ZeroDecimal  END
--	,[dblReportingRate]			= B.dblCurrencyExchangeRate 
--	,[dblForeignRate]			= B.dblCurrencyExchangeRate 
--	,[strRateType]				= SMCERT.strCurrencyExchangeRateType 
--FROM
--	(SELECT intInvoiceId, intInvoiceDetailId, intAccountId, intItemId, strItemDescription, intItemUOMId, dblQtyShipped, dblDiscount, dblPrice, dblTotal, intCurrencyExchangeRateTypeId, dblBaseTotal, dblBasePrice, ISNULL(dblCurrencyExchangeRate, @OneDecimal) AS dblCurrencyExchangeRate
--		FROM tblARInvoiceDetail WITH (NOLOCK)) B
--INNER JOIN
--	(SELECT intInvoiceId, strInvoiceNumber, intCompanyLocationId, dtmDate, dtmPostDate, intCurrencyId, [intEntityCustomerId], strTransactionType, strComments, intPeriodsToAccrue, strType, intSourceId, intOriginalInvoiceId
--		FROM tblARInvoice WITH (NOLOCK)) A  ON B.intInvoiceId = A.intInvoiceId					
--LEFT JOIN 
--	(SELECT [intEntityId], strCustomerNumber FROM tblARCustomer WITH (NOLOCK)) C ON A.[intEntityCustomerId] = C.[intEntityId]		
--INNER JOIN 
--	(SELECT intInvoiceId, [strDescription] FROM @PostInvoiceData)	P ON A.intInvoiceId = P.intInvoiceId 	
--INNER JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = A.intCompanyLocationId
--LEFT OUTER JOIN 
--	(SELECT intItemId, intLocationId, intStockUOMId, strType FROM vyuICGetItemStock WITH (NOLOCK)) ICIS ON B.intItemId = ICIS.intItemId AND A.intCompanyLocationId = ICIS.intLocationId 
--LEFT OUTER JOIN
--	(
--		SELECT
--			intCurrencyExchangeRateTypeId 
--			,strCurrencyExchangeRateType 
--		FROM
--			tblSMCurrencyExchangeRateType
--	)	SMCERT
--		ON B.intCurrencyExchangeRateTypeId = SMCERT.intCurrencyExchangeRateTypeId
--WHERE
--	((B.intItemId IS NULL OR B.intItemId = 0)
--		OR (EXISTS(SELECT NULL FROM tblICItem WHERE intItemId = B.intItemId AND strType IN ('Non-Inventory','Service','Other Charge'))))
--	AND (A.strTransactionType <> 'Debit Memo' OR (A.strTransactionType = 'Debit Memo' AND A.strType IN ('CF Tran', 'CF Invoice', 'Card Fueling Transaction')))
--	AND ISNULL(A.intPeriodsToAccrue,0) <= 1
--	AND (B.dblTotal <> @ZeroDecimal OR B.dblQtyShipped <> @ZeroDecimal)
--	AND A.strTransactionType <> 'Cash Refund'
SELECT
     [dtmDate]                      = CAST(ISNULL(I.[dtmPostDate], I.[dtmDate]) AS DATE)
    ,[strBatchId]                   = I.[strBatchId]
    ,[intAccountId]                 = I.[intItemAccountId]
    ,[dblDebit]                     = CASE WHEN I.strTransactionType IN ('Invoice', 'Cash') OR (I.strTransactionType = 'Debit Memo' AND I.strType IN ('CF Tran', 'CF Invoice', 'Card Fueling Transaction')) OR (I.strTransactionType = 'Credit Memo' AND I.intSourceId = 2 AND I.intOriginalInvoiceId IS NOT NULL) THEN @ZeroDecimal ELSE I.[dblBaseLineItemGLAmount] END
    ,[dblCredit]                    = CASE WHEN I.strTransactionType IN ('Invoice', 'Cash') OR (I.strTransactionType = 'Debit Memo' AND I.strType IN ('CF Tran', 'CF Invoice', 'Card Fueling Transaction')) OR (I.strTransactionType = 'Credit Memo' AND I.intSourceId = 2 AND I.intOriginalInvoiceId IS NOT NULL) THEN I.[dblBaseLineItemGLAmount] ELSE @ZeroDecimal END
    ,[dblDebitUnit]                 = CASE WHEN I.strTransactionType IN ('Invoice', 'Cash') OR (I.strTransactionType = 'Debit Memo' AND I.strType IN ('CF Tran', 'CF Invoice', 'Card Fueling Transaction')) OR (I.strTransactionType = 'Credit Memo' AND I.intSourceId = 2 AND I.intOriginalInvoiceId IS NOT NULL) THEN @ZeroDecimal ELSE I.[dblUnitQtyShipped] END
    ,[dblCreditUnit]                = CASE WHEN I.strTransactionType IN ('Invoice', 'Cash') OR (I.strTransactionType = 'Debit Memo' AND I.strType IN ('CF Tran', 'CF Invoice', 'Card Fueling Transaction')) OR (I.strTransactionType = 'Credit Memo' AND I.intSourceId = 2 AND I.intOriginalInvoiceId IS NOT NULL) THEN I.[dblUnitQtyShipped] ELSE @ZeroDecimal END
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
    ,[dblDebitForeign]              = CASE WHEN I.strTransactionType IN ('Invoice', 'Cash') OR (I.strTransactionType = 'Debit Memo' AND I.strType IN ('CF Tran', 'CF Invoice', 'Card Fueling Transaction')) OR (I.strTransactionType = 'Credit Memo' AND I.intSourceId = 2 AND I.intOriginalInvoiceId IS NOT NULL) THEN @ZeroDecimal ELSE I.[dblLineItemGLAmount] END
    ,[dblDebitReport]               = CASE WHEN I.strTransactionType IN ('Invoice', 'Cash') OR (I.strTransactionType = 'Debit Memo' AND I.strType IN ('CF Tran', 'CF Invoice', 'Card Fueling Transaction')) OR (I.strTransactionType = 'Credit Memo' AND I.intSourceId = 2 AND I.intOriginalInvoiceId IS NOT NULL) THEN @ZeroDecimal ELSE I.[dblLineItemGLAmount] END
    ,[dblCreditForeign]             = CASE WHEN I.strTransactionType IN ('Invoice', 'Cash') OR (I.strTransactionType = 'Debit Memo' AND I.strType IN ('CF Tran', 'CF Invoice', 'Card Fueling Transaction')) OR (I.strTransactionType = 'Credit Memo' AND I.intSourceId = 2 AND I.intOriginalInvoiceId IS NOT NULL) THEN I.[dblLineItemGLAmount] ELSE @ZeroDecimal END
    ,[dblCreditReport]              = CASE WHEN I.strTransactionType IN ('Invoice', 'Cash') OR (I.strTransactionType = 'Debit Memo' AND I.strType IN ('CF Tran', 'CF Invoice', 'Card Fueling Transaction')) OR (I.strTransactionType = 'Credit Memo' AND I.intSourceId = 2 AND I.intOriginalInvoiceId IS NOT NULL) THEN I.[dblLineItemGLAmount] ELSE @ZeroDecimal END
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
    @PostInvoiceData I
WHERE
    I.intInvoiceDetailId IS NOT NULL
    AND I.[ysnPost] = 1
    AND I.[intPeriodsToAccrue] <= 1
    AND (
        I.[intItemId] IS NULL
        OR
        (
            I.[intItemId] IS NOT NULL
            AND
            I.[strItemType] IN ('Non-Inventory','Service','Other Charge')
        )		
        )
    AND (
        I.[dblTotal] <> @ZeroDecimal
        OR
	    I.[dblQtyShipped] <> @ZeroDecimal
        )
    AND I.[strTransactionType] <> 'Cash Refund'


UNION ALL
--CREDIT Software -- License
--SELECT
--	 dtmDate					= CAST(ISNULL(A.dtmPostDate, A.dtmDate) AS DATE)
--	,strBatchID					= @batchIdUsed
--	,intAccountId				= B.intLicenseAccountId 
--	,dblDebit					= CASE WHEN A.strTransactionType IN ('Invoice', 'Cash') THEN @ZeroDecimal 
--																						ELSE (CASE WHEN B.strMaintenanceType = 'License Only'
--																									THEN
--																										ISNULL(B.dblBaseTotal, @ZeroDecimal) + (CASE WHEN (ISNULL(A.intPeriodsToAccrue,0) > 1 AND @accrueLicense = 0) THEN @ZeroDecimal ELSE [dbo].fnRoundBanker(((B.dblDiscount/@OneHundredDecimal) * [dbo].fnRoundBanker((B.dblQtyShipped * B.dblBasePrice), dbo.fnARGetDefaultDecimal())), dbo.fnARGetDefaultDecimal()) END)
--																									ELSE
--																										(CASE WHEN ISNULL(B.dblDiscount, @ZeroDecimal) > @ZeroDecimal 
--																											THEN
--																												[dbo].fnRoundBanker(B.dblBaseTotal * ([dbo].fnRoundBanker(@OneHundredDecimal - [dbo].fnRoundBanker(((ISNULL(B.dblBaseMaintenanceAmount, @ZeroDecimal) * B.dblQtyShipped) / B.dblBaseTotal) * @OneHundredDecimal, dbo.fnARGetDefaultDecimal()), dbo.fnARGetDefaultDecimal())/ @OneHundredDecimal), dbo.fnARGetDefaultDecimal()) + + (CASE WHEN ISNULL(A.intPeriodsToAccrue,0) > 1 AND @accrueLicense = 0  THEN @ZeroDecimal ELSE [dbo].fnRoundBanker(([dbo].fnRoundBanker(((B.dblDiscount/@OneHundredDecimal) * [dbo].fnRoundBanker((B.dblQtyShipped * B.dblBasePrice), dbo.fnARGetDefaultDecimal())), dbo.fnARGetDefaultDecimal())) * ([dbo].fnRoundBanker(@OneHundredDecimal - [dbo].fnRoundBanker(((ISNULL(B.dblBaseMaintenanceAmount, @ZeroDecimal) * B.dblQtyShipped) / B.dblBaseTotal) * @OneHundredDecimal, dbo.fnARGetDefaultDecimal()), dbo.fnARGetDefaultDecimal())/ @OneHundredDecimal), dbo.fnARGetDefaultDecimal()) END) 
--																											ELSE
--																												[dbo].fnRoundBanker((ISNULL(B.dblBaseLicenseAmount, @ZeroDecimal) * B.dblQtyShipped), dbo.fnARGetDefaultDecimal())		
--																										END)
--																								END)
--									END
--	,dblCredit					= CASE WHEN A.strTransactionType IN ('Invoice', 'Cash') THEN (CASE WHEN B.strMaintenanceType = 'License Only'
--																									THEN
--																										ISNULL(B.dblBaseTotal, @ZeroDecimal) + (CASE WHEN (ISNULL(A.intPeriodsToAccrue,0) > 1 AND @accrueLicense = 0) THEN @ZeroDecimal ELSE [dbo].fnRoundBanker(((B.dblDiscount/@OneHundredDecimal) * [dbo].fnRoundBanker((B.dblQtyShipped * B.dblBasePrice), dbo.fnARGetDefaultDecimal())), dbo.fnARGetDefaultDecimal()) END)
--																									ELSE
--																										(CASE WHEN ISNULL(B.dblDiscount, @ZeroDecimal) > @ZeroDecimal 
--																											THEN
--																												[dbo].fnRoundBanker(B.dblBaseTotal * ([dbo].fnRoundBanker(@OneHundredDecimal - [dbo].fnRoundBanker(((ISNULL(B.dblMaintenanceAmount, @ZeroDecimal) * B.dblQtyShipped) / B.dblTotal) * @OneHundredDecimal, dbo.fnARGetDefaultDecimal()), dbo.fnARGetDefaultDecimal())/ @OneHundredDecimal), dbo.fnARGetDefaultDecimal()) + + (CASE WHEN ISNULL(A.intPeriodsToAccrue,0) > 1 AND @accrueLicense = 0  THEN @ZeroDecimal ELSE [dbo].fnRoundBanker(([dbo].fnRoundBanker(((B.dblDiscount/@OneHundredDecimal) * [dbo].fnRoundBanker((B.dblQtyShipped * B.dblBasePrice), dbo.fnARGetDefaultDecimal())), dbo.fnARGetDefaultDecimal())) * ([dbo].fnRoundBanker(@OneHundredDecimal - [dbo].fnRoundBanker(((ISNULL(B.dblBaseMaintenanceAmount, @ZeroDecimal) * B.dblQtyShipped) / B.dblBaseTotal) * @OneHundredDecimal, dbo.fnARGetDefaultDecimal()), dbo.fnARGetDefaultDecimal())/ @OneHundredDecimal), dbo.fnARGetDefaultDecimal()) END) 
--																											ELSE
--																												[dbo].fnRoundBanker((ISNULL(B.dblLicenseAmount, @ZeroDecimal) * B.dblQtyShipped), dbo.fnARGetDefaultDecimal())		
--																										END)
																													
--																								END)
--									ELSE @ZeroDecimal  END
--	,dblDebitUnit				= CASE WHEN A.strTransactionType IN ('Invoice', 'Cash') THEN @ZeroDecimal ELSE dbo.fnARCalculateQtyBetweenUOM(B.intItemUOMId, ICIS.intStockUOMId, B.dblQtyShipped, null, I.strType) END
--	,dblCreditUnit				= CASE WHEN A.strTransactionType IN ('Invoice', 'Cash') THEN dbo.fnARCalculateQtyBetweenUOM(B.intItemUOMId, ICIS.intStockUOMId, B.dblQtyShipped, null, I.strType) ELSE @ZeroDecimal END							
--	,strDescription				= P.[strDescription]
--	,strCode					= @CODE
--	,strReference				= C.strCustomerNumber
--	,intCurrencyId				= A.intCurrencyId 
--	,dblExchangeRate			= B.dblCurrencyExchangeRate
--	,dtmDateEntered				= @PostDate
--	,dtmTransactionDate			= A.dtmDate
--	,strJournalLineDescription	= B.strItemDescription 
--	,intJournalLineNo			= B.intInvoiceDetailId
--	,ysnIsUnposted				= 0
--	,intUserId					= @userId
--	,intEntityId				= @UserEntityID				
--	,strTransactionId			= A.strInvoiceNumber
--	,intTransactionId			= A.intInvoiceId
--	,strTransactionType			= A.strTransactionType
--	,strTransactionForm			= @SCREEN_NAME
--	,strModuleName				= @MODULE_NAME
--	,intConcurrencyId			= 1
--	,[dblDebitForeign]			= CASE WHEN A.strTransactionType IN ('Invoice', 'Cash') THEN @ZeroDecimal 
--																						ELSE (CASE WHEN B.strMaintenanceType = 'License Only'
--																									THEN
--																										ISNULL(B.dblTotal, @ZeroDecimal) + (CASE WHEN (ISNULL(A.intPeriodsToAccrue,0) > 1 AND @accrueLicense = 0) THEN @ZeroDecimal ELSE [dbo].fnRoundBanker(((B.dblDiscount/@OneHundredDecimal) * [dbo].fnRoundBanker((B.dblQtyShipped * B.dblPrice), dbo.fnARGetDefaultDecimal())), dbo.fnARGetDefaultDecimal()) END)
--																									ELSE
--																										(CASE WHEN ISNULL(B.dblDiscount, @ZeroDecimal) > @ZeroDecimal 
--																											THEN
--																												[dbo].fnRoundBanker(B.dblTotal * ([dbo].fnRoundBanker(@OneHundredDecimal - [dbo].fnRoundBanker(((ISNULL(B.dblMaintenanceAmount, @ZeroDecimal) * B.dblQtyShipped) / B.dblTotal) * @OneHundredDecimal, dbo.fnARGetDefaultDecimal()), dbo.fnARGetDefaultDecimal())/ @OneHundredDecimal), dbo.fnARGetDefaultDecimal()) + + (CASE WHEN ISNULL(A.intPeriodsToAccrue,0) > 1 AND @accrueLicense = 0  THEN @ZeroDecimal ELSE [dbo].fnRoundBanker(([dbo].fnRoundBanker(((B.dblDiscount/@OneHundredDecimal) * [dbo].fnRoundBanker((B.dblQtyShipped * B.dblPrice), dbo.fnARGetDefaultDecimal())), dbo.fnARGetDefaultDecimal())) * ([dbo].fnRoundBanker(@OneHundredDecimal - [dbo].fnRoundBanker(((ISNULL(B.dblMaintenanceAmount, @ZeroDecimal) * B.dblQtyShipped) / B.dblTotal) * @OneHundredDecimal, dbo.fnARGetDefaultDecimal()), dbo.fnARGetDefaultDecimal())/ @OneHundredDecimal), dbo.fnARGetDefaultDecimal()) END) 
--																											ELSE
--																												[dbo].fnRoundBanker((ISNULL(B.dblLicenseAmount, @ZeroDecimal) * B.dblQtyShipped), dbo.fnARGetDefaultDecimal())		
--																										END)
--																								END)
--									END
--	,[dblDebitReport]			= CASE WHEN A.strTransactionType IN ('Invoice', 'Cash') THEN @ZeroDecimal 
--																						ELSE (CASE WHEN B.strMaintenanceType = 'License Only'
--																									THEN
--																										ISNULL(B.dblTotal, @ZeroDecimal) + (CASE WHEN (ISNULL(A.intPeriodsToAccrue,0) > 1 AND @accrueLicense = 0) THEN @ZeroDecimal ELSE [dbo].fnRoundBanker(((B.dblDiscount/@OneHundredDecimal) * [dbo].fnRoundBanker((B.dblQtyShipped * B.dblPrice), dbo.fnARGetDefaultDecimal())), dbo.fnARGetDefaultDecimal()) END)
--																									ELSE
--																										(CASE WHEN ISNULL(B.dblDiscount, @ZeroDecimal) > @ZeroDecimal 
--																											THEN
--																												[dbo].fnRoundBanker(B.dblTotal * ([dbo].fnRoundBanker(@OneHundredDecimal - [dbo].fnRoundBanker(((ISNULL(B.dblMaintenanceAmount, @ZeroDecimal) * B.dblQtyShipped) / B.dblTotal) * @OneHundredDecimal, dbo.fnARGetDefaultDecimal()), dbo.fnARGetDefaultDecimal())/ @OneHundredDecimal), dbo.fnARGetDefaultDecimal()) + + (CASE WHEN ISNULL(A.intPeriodsToAccrue,0) > 1 AND @accrueLicense = 0  THEN @ZeroDecimal ELSE [dbo].fnRoundBanker(([dbo].fnRoundBanker(((B.dblDiscount/@OneHundredDecimal) * [dbo].fnRoundBanker((B.dblQtyShipped * B.dblPrice), dbo.fnARGetDefaultDecimal())), dbo.fnARGetDefaultDecimal())) * ([dbo].fnRoundBanker(@OneHundredDecimal - [dbo].fnRoundBanker(((ISNULL(B.dblMaintenanceAmount, @ZeroDecimal) * B.dblQtyShipped) / B.dblTotal) * @OneHundredDecimal, dbo.fnARGetDefaultDecimal()), dbo.fnARGetDefaultDecimal())/ @OneHundredDecimal), dbo.fnARGetDefaultDecimal()) END) 
--																											ELSE
--																												[dbo].fnRoundBanker((ISNULL(B.dblLicenseAmount, @ZeroDecimal) * B.dblQtyShipped), dbo.fnARGetDefaultDecimal())		
--																										END)
--																								END)
--									END
--	,[dblCreditForeign]			= CASE WHEN A.strTransactionType IN ('Invoice', 'Cash') THEN (CASE WHEN B.strMaintenanceType = 'License Only'
--																									THEN
--																										ISNULL(B.dblTotal, @ZeroDecimal) + (CASE WHEN (ISNULL(A.intPeriodsToAccrue,0) > 1 AND @accrueLicense = 0) THEN @ZeroDecimal ELSE [dbo].fnRoundBanker(((B.dblDiscount/@OneHundredDecimal) * [dbo].fnRoundBanker((B.dblQtyShipped * B.dblPrice), dbo.fnARGetDefaultDecimal())), dbo.fnARGetDefaultDecimal()) END)
--																									ELSE
--																										(CASE WHEN ISNULL(B.dblDiscount, @ZeroDecimal) > @ZeroDecimal 
--																											THEN
--																												[dbo].fnRoundBanker(B.dblTotal * ([dbo].fnRoundBanker(@OneHundredDecimal - [dbo].fnRoundBanker(((ISNULL(B.dblMaintenanceAmount, @ZeroDecimal) * B.dblQtyShipped) / B.dblTotal) * @OneHundredDecimal, dbo.fnARGetDefaultDecimal()), dbo.fnARGetDefaultDecimal())/ @OneHundredDecimal), dbo.fnARGetDefaultDecimal()) + + (CASE WHEN ISNULL(A.intPeriodsToAccrue,0) > 1 AND @accrueLicense = 0  THEN @ZeroDecimal ELSE [dbo].fnRoundBanker(([dbo].fnRoundBanker(((B.dblDiscount/@OneHundredDecimal) * [dbo].fnRoundBanker((B.dblQtyShipped * B.dblPrice), dbo.fnARGetDefaultDecimal())), dbo.fnARGetDefaultDecimal())) * ([dbo].fnRoundBanker(@OneHundredDecimal - [dbo].fnRoundBanker(((ISNULL(B.dblMaintenanceAmount, @ZeroDecimal) * B.dblQtyShipped) / B.dblTotal) * @OneHundredDecimal, dbo.fnARGetDefaultDecimal()), dbo.fnARGetDefaultDecimal())/ @OneHundredDecimal), dbo.fnARGetDefaultDecimal()) END) 
--																											ELSE
--																												[dbo].fnRoundBanker((ISNULL(B.dblLicenseAmount, @ZeroDecimal) * B.dblQtyShipped), dbo.fnARGetDefaultDecimal())		
--																										END)
																													
--																								END)
--									ELSE @ZeroDecimal  END
--	,[dblCreditReport]			= CASE WHEN A.strTransactionType IN ('Invoice', 'Cash') THEN (CASE WHEN B.strMaintenanceType = 'License Only'
--																									THEN
--																										ISNULL(B.dblTotal, @ZeroDecimal) + (CASE WHEN (ISNULL(A.intPeriodsToAccrue,0) > 1 AND @accrueLicense = 0) THEN @ZeroDecimal ELSE [dbo].fnRoundBanker(((B.dblDiscount/@OneHundredDecimal) * [dbo].fnRoundBanker((B.dblQtyShipped * B.dblPrice), dbo.fnARGetDefaultDecimal())), dbo.fnARGetDefaultDecimal()) END)
--																									ELSE
--																										(CASE WHEN ISNULL(B.dblDiscount, @ZeroDecimal) > @ZeroDecimal 
--																											THEN
--																												[dbo].fnRoundBanker(B.dblTotal * ([dbo].fnRoundBanker(@OneHundredDecimal - [dbo].fnRoundBanker(((ISNULL(B.dblMaintenanceAmount, @ZeroDecimal) * B.dblQtyShipped) / B.dblTotal) * @OneHundredDecimal, dbo.fnARGetDefaultDecimal()), dbo.fnARGetDefaultDecimal())/ @OneHundredDecimal), dbo.fnARGetDefaultDecimal()) + + (CASE WHEN ISNULL(A.intPeriodsToAccrue,0) > 1 AND @accrueLicense = 0  THEN @ZeroDecimal ELSE [dbo].fnRoundBanker(([dbo].fnRoundBanker(((B.dblDiscount/@OneHundredDecimal) * [dbo].fnRoundBanker((B.dblQtyShipped * B.dblPrice), dbo.fnARGetDefaultDecimal())), dbo.fnARGetDefaultDecimal())) * ([dbo].fnRoundBanker(@OneHundredDecimal - [dbo].fnRoundBanker(((ISNULL(B.dblMaintenanceAmount, @ZeroDecimal) * B.dblQtyShipped) / B.dblTotal) * @OneHundredDecimal, dbo.fnARGetDefaultDecimal()), dbo.fnARGetDefaultDecimal())/ @OneHundredDecimal), dbo.fnARGetDefaultDecimal()) END) 
--																											ELSE
--																												[dbo].fnRoundBanker((ISNULL(B.dblLicenseAmount, @ZeroDecimal) * B.dblQtyShipped), dbo.fnARGetDefaultDecimal())		
--																										END)
																													
--																								END)
--									ELSE @ZeroDecimal  END
--	,[dblReportingRate]			= B.dblCurrencyExchangeRate 
--	,[dblForeignRate]			= B.dblCurrencyExchangeRate 
--	,[strRateType]				= SMCERT.strCurrencyExchangeRateType 
--FROM
--	(SELECT intInvoiceId, intInvoiceDetailId, intItemId, strItemDescription, strMaintenanceType, dblLicenseAmount, dblTotal, intItemUOMId, dblQtyShipped, dblDiscount, intCurrencyExchangeRateTypeId, 
--		dblMaintenanceAmount, dblPrice, intLicenseAccountId, dblBasePrice, dblBaseTotal, dblBaseLicenseAmount, dblBaseMaintenanceAmount, ISNULL(dblCurrencyExchangeRate, @OneDecimal) AS dblCurrencyExchangeRate
--		FROM tblARInvoiceDetail WITH (NOLOCK)) B
--INNER JOIN
--	(SELECT intInvoiceId, [intEntityCustomerId], intCompanyLocationId, dtmDate, dtmPostDate, intCurrencyId, strTransactionType, strInvoiceNumber, strComments, intPeriodsToAccrue 
--		FROM tblARInvoice WITH (NOLOCK)) A ON B.intInvoiceId = A.intInvoiceId
--INNER JOIN
--	(SELECT intItemId, strType FROM tblICItem WITH (NOLOCK)) I ON B.intItemId = I.intItemId 				
--LEFT JOIN 
--	(SELECT [intEntityId], strCustomerNumber FROM tblARCustomer WITH (NOLOCK)) C ON A.[intEntityCustomerId] = C.[intEntityId]		
--INNER JOIN 
--	(SELECT intInvoiceId, [strDescription] FROM @PostInvoiceData)	P ON A.intInvoiceId = P.intInvoiceId 
--LEFT OUTER JOIN 
--	(SELECT intItemId, intLocationId, intStockUOMId FROM vyuICGetItemStock WITH (NOLOCK)) ICIS ON B.intItemId = ICIS.intItemId  AND A.intCompanyLocationId = ICIS.intLocationId
--LEFT OUTER JOIN
--	(
--		SELECT
--			intCurrencyExchangeRateTypeId 
--			,strCurrencyExchangeRateType 
--		FROM
--			tblSMCurrencyExchangeRateType
--	)SMCERT
--		ON B.intCurrencyExchangeRateTypeId = SMCERT.intCurrencyExchangeRateTypeId
--WHERE
--	B.dblLicenseAmount <> @ZeroDecimal
--	AND B.strMaintenanceType IN ('License/Maintenance', 'License Only')
--	AND ISNULL(I.strType,'') = 'Software'
--	AND A.strTransactionType NOT IN ('Debit Memo', 'Cash Refund')
--	AND (ISNULL(A.intPeriodsToAccrue,0) <= 1 OR ( ISNULL(A.intPeriodsToAccrue,0) > 1 AND ISNULL(@accrueLicense,0) = 0))
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
    @PostInvoiceData I
WHERE
    I.intInvoiceDetailId IS NOT NULL
    AND I.[ysnPost] = 1
    AND I.[dblLicenseAmount] <> @ZeroDecimal
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

UNION ALL
--DEBIT Software -- License
--SELECT
--		dtmDate					= CAST(ISNULL(A.dtmPostDate, A.dtmDate) AS DATE)
--	,strBatchID					= @batchIdUsed
--	,intAccountId				= @DeferredRevenueAccountId
--	,dblDebit					= CASE WHEN A.strTransactionType IN ('Invoice', 'Cash') THEN (CASE WHEN B.strMaintenanceType = 'License Only'
--																									THEN
--																										ISNULL(B.dblBaseTotal, @ZeroDecimal) + (CASE WHEN (ISNULL(A.intPeriodsToAccrue,0) > 1 AND @accrueLicense = 0) THEN 0 ELSE [dbo].fnRoundBanker(((B.dblDiscount/@OneHundredDecimal) * [dbo].fnRoundBanker((B.dblQtyShipped * B.dblBasePrice), dbo.fnARGetDefaultDecimal())), dbo.fnARGetDefaultDecimal()) END)
--																									ELSE
--																										(CASE WHEN ISNULL(B.dblDiscount, @ZeroDecimal) > @ZeroDecimal 
--																											THEN
--																												[dbo].fnRoundBanker(B.dblBaseTotal * ([dbo].fnRoundBanker(@OneHundredDecimal - [dbo].fnRoundBanker(((ISNULL(B.dblBaseMaintenanceAmount, @ZeroDecimal) * B.dblQtyShipped) / B.dblBaseTotal) * @OneHundredDecimal, dbo.fnARGetDefaultDecimal()), dbo.fnARGetDefaultDecimal())/ @OneHundredDecimal), dbo.fnARGetDefaultDecimal()) + + (CASE WHEN ISNULL(A.intPeriodsToAccrue,0) > 1 AND @accrueLicense = 0  THEN @ZeroDecimal ELSE [dbo].fnRoundBanker(([dbo].fnRoundBanker(((B.dblDiscount/@OneHundredDecimal) * [dbo].fnRoundBanker((B.dblQtyShipped * B.dblBasePrice), dbo.fnARGetDefaultDecimal())), dbo.fnARGetDefaultDecimal())) * ([dbo].fnRoundBanker(@OneHundredDecimal - [dbo].fnRoundBanker(((ISNULL(B.dblBaseMaintenanceAmount, @ZeroDecimal) * B.dblQtyShipped) / B.dblBaseTotal) * @OneHundredDecimal, dbo.fnARGetDefaultDecimal()), dbo.fnARGetDefaultDecimal())/ @OneHundredDecimal), dbo.fnARGetDefaultDecimal()) END) 
--																											ELSE
--																												[dbo].fnRoundBanker((ISNULL(B.dblBaseLicenseAmount, @ZeroDecimal) * B.dblQtyShipped), dbo.fnARGetDefaultDecimal())		
--																										END)
--																								END)
--									ELSE @ZeroDecimal  END
--	,dblCredit					= CASE WHEN A.strTransactionType IN ('Invoice', 'Cash') THEN @ZeroDecimal 
--																						ELSE (CASE WHEN B.strMaintenanceType = 'License Only'
--																									THEN
--																										ISNULL(B.dblBaseTotal, @ZeroDecimal) + (CASE WHEN (ISNULL(A.intPeriodsToAccrue,0) > 1 AND @accrueLicense = 0) THEN 0 ELSE [dbo].fnRoundBanker(((B.dblDiscount/@OneHundredDecimal) * [dbo].fnRoundBanker((B.dblQtyShipped * B.dblBasePrice), dbo.fnARGetDefaultDecimal())), dbo.fnARGetDefaultDecimal()) END)
--																									ELSE
--																										(CASE WHEN ISNULL(B.dblDiscount, @ZeroDecimal) > @ZeroDecimal 
--																											THEN
--																												[dbo].fnRoundBanker(B.dblBaseTotal * ([dbo].fnRoundBanker(@OneHundredDecimal - [dbo].fnRoundBanker(((ISNULL(B.dblBaseMaintenanceAmount, @ZeroDecimal) * B.dblQtyShipped) / B.dblBaseTotal) * @OneHundredDecimal, dbo.fnARGetDefaultDecimal()), dbo.fnARGetDefaultDecimal())/ @OneHundredDecimal), dbo.fnARGetDefaultDecimal()) + + (CASE WHEN ISNULL(A.intPeriodsToAccrue,0) > 1 AND @accrueLicense = 0  THEN @ZeroDecimal ELSE [dbo].fnRoundBanker(([dbo].fnRoundBanker(((B.dblDiscount/@OneHundredDecimal) * [dbo].fnRoundBanker((B.dblQtyShipped * B.dblBasePrice), dbo.fnARGetDefaultDecimal())), dbo.fnARGetDefaultDecimal())) * ([dbo].fnRoundBanker(@OneHundredDecimal - [dbo].fnRoundBanker(((ISNULL(B.dblBaseMaintenanceAmount, @ZeroDecimal) * B.dblQtyShipped) / B.dblBaseTotal) * @OneHundredDecimal, dbo.fnARGetDefaultDecimal()), dbo.fnARGetDefaultDecimal())/ @OneHundredDecimal), dbo.fnARGetDefaultDecimal()) END) 
--																											ELSE
--																												[dbo].fnRoundBanker((ISNULL(B.dblBaseLicenseAmount, @ZeroDecimal) * B.dblQtyShipped), dbo.fnARGetDefaultDecimal())		
--																										END)
--																								END)
--									END
--	,dblDebitUnit				= CASE WHEN A.strTransactionType IN ('Invoice', 'Cash') THEN dbo.fnARCalculateQtyBetweenUOM(B.intItemUOMId, ICIS.intStockUOMId, B.dblQtyShipped, null, I.strType)  ELSE @ZeroDecimal END				
--	,dblCreditUnit				= CASE WHEN A.strTransactionType IN ('Invoice', 'Cash') THEN @ZeroDecimal ELSE dbo.fnARCalculateQtyBetweenUOM(B.intItemUOMId, ICIS.intStockUOMId, B.dblQtyShipped, null, I.strType) END				
--	,strDescription				= P.[strDescription]
--	,strCode					= @CODE
--	,strReference				= C.strCustomerNumber
--	,intCurrencyId				= A.intCurrencyId 
--	,dblExchangeRate			= B.dblCurrencyExchangeRate
--	,dtmDateEntered				= @PostDate
--	,dtmTransactionDate			= A.dtmDate
--	,strJournalLineDescription	= B.strItemDescription 
--	,intJournalLineNo			= B.intInvoiceDetailId
--	,ysnIsUnposted				= 0
--	,intUserId					= @userId
--	,intEntityId				= @UserEntityID				
--	,strTransactionId			= A.strInvoiceNumber
--	,intTransactionId			= A.intInvoiceId
--	,strTransactionType			= A.strTransactionType
--	,strTransactionForm			= @SCREEN_NAME
--	,strModuleName				= @MODULE_NAME
--	,intConcurrencyId			= 1
--	,[dblDebitForeign]			= CASE WHEN A.strTransactionType IN ('Invoice', 'Cash') THEN (CASE WHEN B.strMaintenanceType = 'License Only'
--																									THEN
--																										ISNULL(B.dblTotal, @ZeroDecimal) + (CASE WHEN (ISNULL(A.intPeriodsToAccrue,0) > 1 AND @accrueLicense = 0) THEN 0 ELSE [dbo].fnRoundBanker(((B.dblDiscount/@OneHundredDecimal) * [dbo].fnRoundBanker((B.dblQtyShipped * B.dblPrice), dbo.fnARGetDefaultDecimal())), dbo.fnARGetDefaultDecimal()) END)
--																									ELSE
--																										(CASE WHEN ISNULL(B.dblDiscount, @ZeroDecimal) > @ZeroDecimal 
--																											THEN
--																												[dbo].fnRoundBanker(B.dblTotal * ([dbo].fnRoundBanker(@OneHundredDecimal - [dbo].fnRoundBanker(((ISNULL(B.dblMaintenanceAmount, @ZeroDecimal) * B.dblQtyShipped) / B.dblTotal) * @OneHundredDecimal, dbo.fnARGetDefaultDecimal()), dbo.fnARGetDefaultDecimal())/ @OneHundredDecimal), dbo.fnARGetDefaultDecimal()) + + (CASE WHEN ISNULL(A.intPeriodsToAccrue,0) > 1 AND @accrueLicense = 0  THEN @ZeroDecimal ELSE [dbo].fnRoundBanker(([dbo].fnRoundBanker(((B.dblDiscount/@OneHundredDecimal) * [dbo].fnRoundBanker((B.dblQtyShipped * B.dblPrice), dbo.fnARGetDefaultDecimal())), dbo.fnARGetDefaultDecimal())) * ([dbo].fnRoundBanker(@OneHundredDecimal - [dbo].fnRoundBanker(((ISNULL(B.dblMaintenanceAmount, @ZeroDecimal) * B.dblQtyShipped) / B.dblTotal) * @OneHundredDecimal, dbo.fnARGetDefaultDecimal()), dbo.fnARGetDefaultDecimal())/ @OneHundredDecimal), dbo.fnARGetDefaultDecimal()) END) 
--																											ELSE
--																												[dbo].fnRoundBanker((ISNULL(B.dblLicenseAmount, @ZeroDecimal) * B.dblQtyShipped), dbo.fnARGetDefaultDecimal())		
--																										END)
--																								END)
--									ELSE @ZeroDecimal  END
--	,[dblDebitReport]			= CASE WHEN A.strTransactionType IN ('Invoice', 'Cash') THEN (CASE WHEN B.strMaintenanceType = 'License Only'
--																									THEN
--																										ISNULL(B.dblTotal, @ZeroDecimal) + (CASE WHEN (ISNULL(A.intPeriodsToAccrue,0) > 1 AND @accrueLicense = 0) THEN 0 ELSE [dbo].fnRoundBanker(((B.dblDiscount/@OneHundredDecimal) * [dbo].fnRoundBanker((B.dblQtyShipped * B.dblPrice), dbo.fnARGetDefaultDecimal())), dbo.fnARGetDefaultDecimal()) END)
--																									ELSE
--																										(CASE WHEN ISNULL(B.dblDiscount, @ZeroDecimal) > @ZeroDecimal 
--																											THEN
--																												[dbo].fnRoundBanker(B.dblTotal * ([dbo].fnRoundBanker(@OneHundredDecimal - [dbo].fnRoundBanker(((ISNULL(B.dblMaintenanceAmount, @ZeroDecimal) * B.dblQtyShipped) / B.dblTotal) * @OneHundredDecimal, dbo.fnARGetDefaultDecimal()), dbo.fnARGetDefaultDecimal())/ @OneHundredDecimal), dbo.fnARGetDefaultDecimal()) + + (CASE WHEN ISNULL(A.intPeriodsToAccrue,0) > 1 AND @accrueLicense = 0  THEN @ZeroDecimal ELSE [dbo].fnRoundBanker(([dbo].fnRoundBanker(((B.dblDiscount/@OneHundredDecimal) * [dbo].fnRoundBanker((B.dblQtyShipped * B.dblPrice), dbo.fnARGetDefaultDecimal())), dbo.fnARGetDefaultDecimal())) * ([dbo].fnRoundBanker(@OneHundredDecimal - [dbo].fnRoundBanker(((ISNULL(B.dblMaintenanceAmount, @ZeroDecimal) * B.dblQtyShipped) / B.dblTotal) * @OneHundredDecimal, dbo.fnARGetDefaultDecimal()), dbo.fnARGetDefaultDecimal())/ @OneHundredDecimal), dbo.fnARGetDefaultDecimal()) END) 
--																											ELSE
--																												[dbo].fnRoundBanker((ISNULL(B.dblLicenseAmount, @ZeroDecimal) * B.dblQtyShipped), dbo.fnARGetDefaultDecimal())		
--																										END)
--																								END)
--									ELSE @ZeroDecimal  END
--	,[dblCreditForeign]			= CASE WHEN A.strTransactionType IN ('Invoice', 'Cash') THEN @ZeroDecimal 
--																						ELSE (CASE WHEN B.strMaintenanceType = 'License Only'
--																									THEN
--																										ISNULL(B.dblTotal, @ZeroDecimal) + (CASE WHEN (ISNULL(A.intPeriodsToAccrue,0) > 1 AND @accrueLicense = 0) THEN 0 ELSE [dbo].fnRoundBanker(((B.dblDiscount/@OneHundredDecimal) * [dbo].fnRoundBanker((B.dblQtyShipped * B.dblPrice), dbo.fnARGetDefaultDecimal())), dbo.fnARGetDefaultDecimal()) END)
--																									ELSE
--																										(CASE WHEN ISNULL(B.dblDiscount, @ZeroDecimal) > @ZeroDecimal 
--																											THEN
--																												[dbo].fnRoundBanker(B.dblTotal * ([dbo].fnRoundBanker(@OneHundredDecimal - [dbo].fnRoundBanker(((ISNULL(B.dblMaintenanceAmount, @ZeroDecimal) * B.dblQtyShipped) / B.dblTotal) * @OneHundredDecimal, dbo.fnARGetDefaultDecimal()), dbo.fnARGetDefaultDecimal())/ @OneHundredDecimal), dbo.fnARGetDefaultDecimal()) + + (CASE WHEN ISNULL(A.intPeriodsToAccrue,0) > 1 AND @accrueLicense = 0  THEN @ZeroDecimal ELSE [dbo].fnRoundBanker(([dbo].fnRoundBanker(((B.dblDiscount/@OneHundredDecimal) * [dbo].fnRoundBanker((B.dblQtyShipped * B.dblPrice), dbo.fnARGetDefaultDecimal())), dbo.fnARGetDefaultDecimal())) * ([dbo].fnRoundBanker(@OneHundredDecimal - [dbo].fnRoundBanker(((ISNULL(B.dblMaintenanceAmount, @ZeroDecimal) * B.dblQtyShipped) / B.dblTotal) * @OneHundredDecimal, dbo.fnARGetDefaultDecimal()), dbo.fnARGetDefaultDecimal())/ @OneHundredDecimal), dbo.fnARGetDefaultDecimal()) END) 
--																											ELSE
--																												[dbo].fnRoundBanker((ISNULL(B.dblLicenseAmount, @ZeroDecimal) * B.dblQtyShipped), dbo.fnARGetDefaultDecimal())		
--																										END)
--																								END)
--									END
--	,[dblCreditReport]			= CASE WHEN A.strTransactionType IN ('Invoice', 'Cash') THEN @ZeroDecimal 
--																						ELSE (CASE WHEN B.strMaintenanceType = 'License Only'
--																									THEN
--																										ISNULL(B.dblTotal, @ZeroDecimal) + (CASE WHEN (ISNULL(A.intPeriodsToAccrue,0) > 1 AND @accrueLicense = 0) THEN 0 ELSE [dbo].fnRoundBanker(((B.dblDiscount/@OneHundredDecimal) * [dbo].fnRoundBanker((B.dblQtyShipped * B.dblPrice), dbo.fnARGetDefaultDecimal())), dbo.fnARGetDefaultDecimal()) END)
--																									ELSE
--																										(CASE WHEN ISNULL(B.dblDiscount, @ZeroDecimal) > @ZeroDecimal 
--																											THEN
--																												[dbo].fnRoundBanker(B.dblTotal * ([dbo].fnRoundBanker(@OneHundredDecimal - [dbo].fnRoundBanker(((ISNULL(B.dblMaintenanceAmount, @ZeroDecimal) * B.dblQtyShipped) / B.dblTotal) * @OneHundredDecimal, dbo.fnARGetDefaultDecimal()), dbo.fnARGetDefaultDecimal())/ @OneHundredDecimal), dbo.fnARGetDefaultDecimal()) + + (CASE WHEN ISNULL(A.intPeriodsToAccrue,0) > 1 AND @accrueLicense = 0  THEN @ZeroDecimal ELSE [dbo].fnRoundBanker(([dbo].fnRoundBanker(((B.dblDiscount/@OneHundredDecimal) * [dbo].fnRoundBanker((B.dblQtyShipped * B.dblPrice), dbo.fnARGetDefaultDecimal())), dbo.fnARGetDefaultDecimal())) * ([dbo].fnRoundBanker(@OneHundredDecimal - [dbo].fnRoundBanker(((ISNULL(B.dblMaintenanceAmount, @ZeroDecimal) * B.dblQtyShipped) / B.dblTotal) * @OneHundredDecimal, dbo.fnARGetDefaultDecimal()), dbo.fnARGetDefaultDecimal())/ @OneHundredDecimal), dbo.fnARGetDefaultDecimal()) END) 
--																											ELSE
--																												[dbo].fnRoundBanker((ISNULL(B.dblLicenseAmount, @ZeroDecimal) * B.dblQtyShipped), dbo.fnARGetDefaultDecimal())		
--																										END)
--																								END)
--									END
--	,[dblReportingRate]			= B.dblCurrencyExchangeRate 
--	,[dblForeignRate]			= B.dblCurrencyExchangeRate 
--	,[strRateType]				= SMCERT.strCurrencyExchangeRateType
--FROM
--	(SELECT intInvoiceId, intInvoiceDetailId, intItemId, strItemDescription, intItemUOMId, dblDiscount, dblTotal, dblLicenseAmount, dblQtyShipped, 
--		strMaintenanceType, dblPrice, dblMaintenanceAmount, intCurrencyExchangeRateTypeId, dblBasePrice, dblBaseTotal, dblBaseLicenseAmount, dblBaseMaintenanceAmount, ISNULL(dblCurrencyExchangeRate, @OneDecimal) AS dblCurrencyExchangeRate
--		FROM tblARInvoiceDetail WITH (NOLOCK)) B
--INNER JOIN
--	(SELECT intInvoiceId, dtmPostDate, strInvoiceNumber, intCurrencyId, dtmDate, [intEntityCustomerId], intCompanyLocationId, strTransactionType, strComments, intPeriodsToAccrue 
--		FROM tblARInvoice WITH (NOLOCK))  A 
--		ON B.intInvoiceId = A.intInvoiceId
--INNER JOIN
--	(SELECT intItemId, strType FROM tblICItem WITH (NOLOCK)) I ON B.intItemId = I.intItemId 				
--LEFT JOIN 
--	(SELECT [intEntityId], strCustomerNumber FROM tblARCustomer WITH (NOLOCK)) C ON A.[intEntityCustomerId] = C.[intEntityId]		
--INNER JOIN 
--	(SELECT intInvoiceId, [strDescription] FROM @PostInvoiceData) P ON A.intInvoiceId = P.intInvoiceId
--LEFT OUTER JOIN
--	(SELECT intItemId, intLocationId FROM vyuARGetItemAccount WITH (NOLOCK)) IST ON B.intItemId = IST.intItemId AND A.intCompanyLocationId = IST.intLocationId
--LEFT OUTER JOIN 
--	(SELECT intItemId, intLocationId, intStockUOMId FROM vyuICGetItemStock WITH (NOLOCK)) ICIS ON B.intItemId = ICIS.intItemId AND A.intCompanyLocationId = ICIS.intLocationId 					
--LEFT OUTER JOIN
--	(
--		SELECT
--			intCurrencyExchangeRateTypeId 
--			,strCurrencyExchangeRateType 
--		FROM
--			tblSMCurrencyExchangeRateType
--	)	SMCERT
--		ON B.intCurrencyExchangeRateTypeId = SMCERT.intCurrencyExchangeRateTypeId	
--WHERE
--	B.dblLicenseAmount <> @ZeroDecimal
--	AND B.strMaintenanceType IN ('License/Maintenance', 'License Only')
--	AND ISNULL(I.strType,'') = 'Software'
--	AND A.strTransactionType NOT IN ('Debit Memo', 'Cash Refund')
--	AND (ISNULL(A.intPeriodsToAccrue,0) > 1 AND ISNULL(@accrueLicense,0) = 0)
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
    @PostInvoiceData I
WHERE
    I.intInvoiceDetailId IS NOT NULL
    AND I.[ysnPost] = 1
    AND I.[intPeriodsToAccrue] > 1
    AND I.[dblLicenseAmount] <> @ZeroDecimal
    AND I.[strMaintenanceType] IN ('License/Maintenance', 'License Only')
    AND I.[strItemType] = 'Software'
    AND I.[strTransactionType] NOT IN ('Cash Refund', 'Debit Memo')
    AND I.[ysnAccrueLicense] = 0

UNION ALL
--CREDIT Software -- Maintenance
--SELECT
--		dtmDate					= CAST(ISNULL(A.dtmPostDate, A.dtmDate) AS DATE)
--	,strBatchID					= @batchIdUsed
--	,intAccountId				= B.intMaintenanceAccountId 
--	,dblDebit					= CASE WHEN A.strTransactionType IN ('Invoice', 'Cash') THEN @ZeroDecimal ELSE (CASE WHEN B.strMaintenanceType IN ('Maintenance Only', 'SaaS')  THEN 
--																										ISNULL(B.dblBaseTotal, @ZeroDecimal) + [dbo].fnRoundBanker(((B.dblDiscount/@OneHundredDecimal) * [dbo].fnRoundBanker((B.dblQtyShipped * B.dblBasePrice), dbo.fnARGetDefaultDecimal())), dbo.fnARGetDefaultDecimal())
--																									ELSE
--																										(CASE WHEN ISNULL(B.dblDiscount, @ZeroDecimal) > @ZeroDecimal 
--																											THEN
--																												[dbo].fnRoundBanker(B.dblBaseTotal * ([dbo].fnRoundBanker(((ISNULL(B.dblMaintenanceAmount, @ZeroDecimal) * B.dblQtyShipped) / B.dblBaseTotal) * @OneHundredDecimal, dbo.fnARGetDefaultDecimal())/ @OneHundredDecimal), dbo.fnARGetDefaultDecimal()) + [dbo].fnRoundBanker(([dbo].fnRoundBanker(((B.dblDiscount/@OneHundredDecimal) * [dbo].fnRoundBanker((B.dblQtyShipped * B.dblBasePrice), dbo.fnARGetDefaultDecimal())), dbo.fnARGetDefaultDecimal())) * ([dbo].fnRoundBanker(((ISNULL(B.dblBaseMaintenanceAmount, @ZeroDecimal) * B.dblQtyShipped) / B.dblBaseTotal) * @OneHundredDecimal, dbo.fnARGetDefaultDecimal())/ @OneHundredDecimal), dbo.fnARGetDefaultDecimal()) 
--																											ELSE
--																												[dbo].fnRoundBanker((ISNULL(B.dblBaseMaintenanceAmount, @ZeroDecimal) * B.dblQtyShipped), dbo.fnARGetDefaultDecimal())		
--																										END)
--																									END)
--									END
--	,dblCredit					= CASE WHEN A.strTransactionType IN ('Invoice', 'Cash') THEN (CASE WHEN B.strMaintenanceType IN ('Maintenance Only', 'SaaS')  THEN 
--																										ISNULL(B.dblBaseTotal, @ZeroDecimal) + [dbo].fnRoundBanker(((B.dblDiscount/@OneHundredDecimal) * [dbo].fnRoundBanker((B.dblQtyShipped * B.dblBasePrice), dbo.fnARGetDefaultDecimal())), dbo.fnARGetDefaultDecimal())
--																									ELSE
--																										(CASE WHEN ISNULL(B.dblDiscount, @ZeroDecimal) > @ZeroDecimal 
--																											THEN
--																												[dbo].fnRoundBanker(B.dblBaseTotal * ([dbo].fnRoundBanker(((ISNULL(B.dblBaseMaintenanceAmount, @ZeroDecimal) * B.dblQtyShipped) / B.dblBaseTotal) * @OneHundredDecimal, dbo.fnARGetDefaultDecimal())/ @OneHundredDecimal), dbo.fnARGetDefaultDecimal()) + [dbo].fnRoundBanker(([dbo].fnRoundBanker(((B.dblDiscount/@OneHundredDecimal) * [dbo].fnRoundBanker((B.dblQtyShipped * B.dblBasePrice), dbo.fnARGetDefaultDecimal())), dbo.fnARGetDefaultDecimal())) * ([dbo].fnRoundBanker(((ISNULL(B.dblBaseMaintenanceAmount, @ZeroDecimal) * B.dblQtyShipped) / B.dblBaseTotal) * @OneHundredDecimal, dbo.fnARGetDefaultDecimal())/ @OneHundredDecimal), dbo.fnARGetDefaultDecimal()) 
--																											ELSE
--																												[dbo].fnRoundBanker((ISNULL(B.dblBaseMaintenanceAmount, @ZeroDecimal) * B.dblQtyShipped), dbo.fnARGetDefaultDecimal())		
--																										END)
--																									END) 
--									ELSE @ZeroDecimal  END
--	,dblDebitUnit				= CASE WHEN A.strTransactionType IN ('Invoice', 'Cash') THEN @ZeroDecimal ELSE (dbo.fnARCalculateQtyBetweenUOM(B.intItemUOMId, ICIS.intStockUOMId, B.dblQtyShipped, null, I.strType)) END
--	,dblCreditUnit				= CASE WHEN A.strTransactionType IN ('Invoice', 'Cash') THEN (dbo.fnARCalculateQtyBetweenUOM(B.intItemUOMId, ICIS.intStockUOMId, B.dblQtyShipped, null, I.strType)) ELSE @ZeroDecimal END							
--	,strDescription				= P.[strDescription]
--	,strCode					= @CODE
--	,strReference				= C.strCustomerNumber
--	,intCurrencyId				= A.intCurrencyId 
--	,dblExchangeRate			= B.dblCurrencyExchangeRate
--	,dtmDateEntered				= @PostDate
--	,dtmTransactionDate			= A.dtmDate
--	,strJournalLineDescription	= B.strItemDescription 
--	,intJournalLineNo			= B.intInvoiceDetailId
--	,ysnIsUnposted				= 0
--	,intUserId					= @userId
--	,intEntityId				= @UserEntityID				
--	,strTransactionId			= A.strInvoiceNumber
--	,intTransactionId			= A.intInvoiceId
--	,strTransactionType			= A.strTransactionType
--	,strTransactionForm			= @SCREEN_NAME
--	,strModuleName				= @MODULE_NAME
--	,intConcurrencyId			= 1
--	,[dblDebitForeign]			= CASE WHEN A.strTransactionType IN ('Invoice', 'Cash') THEN @ZeroDecimal ELSE (CASE WHEN B.strMaintenanceType IN ('Maintenance Only', 'SaaS')  THEN 
--																										ISNULL(B.dblTotal, @ZeroDecimal) + [dbo].fnRoundBanker(((B.dblDiscount/@OneHundredDecimal) * [dbo].fnRoundBanker((B.dblQtyShipped * B.dblPrice), dbo.fnARGetDefaultDecimal())), dbo.fnARGetDefaultDecimal())
--																									ELSE
--																										(CASE WHEN ISNULL(B.dblDiscount, @ZeroDecimal) > @ZeroDecimal 
--																											THEN
--																												[dbo].fnRoundBanker(B.dblTotal * ([dbo].fnRoundBanker(((ISNULL(B.dblMaintenanceAmount, @ZeroDecimal) * B.dblQtyShipped) / B.dblTotal) * @OneHundredDecimal, dbo.fnARGetDefaultDecimal())/ @OneHundredDecimal), dbo.fnARGetDefaultDecimal()) + [dbo].fnRoundBanker(([dbo].fnRoundBanker(((B.dblDiscount/@OneHundredDecimal) * [dbo].fnRoundBanker((B.dblQtyShipped * B.dblPrice), dbo.fnARGetDefaultDecimal())), dbo.fnARGetDefaultDecimal())) * ([dbo].fnRoundBanker(((ISNULL(B.dblMaintenanceAmount, @ZeroDecimal) * B.dblQtyShipped) / B.dblTotal) * @OneHundredDecimal, dbo.fnARGetDefaultDecimal())/ @OneHundredDecimal), dbo.fnARGetDefaultDecimal()) 
--																											ELSE
--																												[dbo].fnRoundBanker((ISNULL(B.dblMaintenanceAmount, @ZeroDecimal) * B.dblQtyShipped), dbo.fnARGetDefaultDecimal())		
--																										END)
--																									END)
--									END
--	,[dblDebitReport]			= CASE WHEN A.strTransactionType IN ('Invoice', 'Cash') THEN @ZeroDecimal ELSE (CASE WHEN B.strMaintenanceType IN ('Maintenance Only', 'SaaS')  THEN 
--																										ISNULL(B.dblTotal, @ZeroDecimal) + [dbo].fnRoundBanker(((B.dblDiscount/@OneHundredDecimal) * [dbo].fnRoundBanker((B.dblQtyShipped * B.dblPrice), dbo.fnARGetDefaultDecimal())), dbo.fnARGetDefaultDecimal())
--																									ELSE
--																										(CASE WHEN ISNULL(B.dblDiscount, @ZeroDecimal) > @ZeroDecimal 
--																											THEN
--																												[dbo].fnRoundBanker(B.dblTotal * ([dbo].fnRoundBanker(((ISNULL(B.dblMaintenanceAmount, @ZeroDecimal) * B.dblQtyShipped) / B.dblTotal) * @OneHundredDecimal, dbo.fnARGetDefaultDecimal())/ @OneHundredDecimal), dbo.fnARGetDefaultDecimal()) + [dbo].fnRoundBanker(([dbo].fnRoundBanker(((B.dblDiscount/@OneHundredDecimal) * [dbo].fnRoundBanker((B.dblQtyShipped * B.dblPrice), dbo.fnARGetDefaultDecimal())), dbo.fnARGetDefaultDecimal())) * ([dbo].fnRoundBanker(((ISNULL(B.dblMaintenanceAmount, @ZeroDecimal) * B.dblQtyShipped) / B.dblTotal) * @OneHundredDecimal, dbo.fnARGetDefaultDecimal())/ @OneHundredDecimal), dbo.fnARGetDefaultDecimal()) 
--																											ELSE
--																												[dbo].fnRoundBanker((ISNULL(B.dblMaintenanceAmount, @ZeroDecimal) * B.dblQtyShipped), dbo.fnARGetDefaultDecimal())		
--																										END)
--																									END)
--									END
--	,[dblCreditForeign]			= CASE WHEN A.strTransactionType IN ('Invoice', 'Cash') THEN (CASE WHEN B.strMaintenanceType IN ('Maintenance Only', 'SaaS')  THEN 
--																										ISNULL(B.dblTotal, @ZeroDecimal) + [dbo].fnRoundBanker(((B.dblDiscount/@OneHundredDecimal) * [dbo].fnRoundBanker((B.dblQtyShipped * B.dblPrice), dbo.fnARGetDefaultDecimal())), dbo.fnARGetDefaultDecimal())
--																									ELSE
--																										(CASE WHEN ISNULL(B.dblDiscount, @ZeroDecimal) > @ZeroDecimal 
--																											THEN
--																												[dbo].fnRoundBanker(B.dblTotal * ([dbo].fnRoundBanker(((ISNULL(B.dblMaintenanceAmount, @ZeroDecimal) * B.dblQtyShipped) / B.dblTotal) * @OneHundredDecimal, dbo.fnARGetDefaultDecimal())/ @OneHundredDecimal), dbo.fnARGetDefaultDecimal()) + [dbo].fnRoundBanker(([dbo].fnRoundBanker(((B.dblDiscount/@OneHundredDecimal) * [dbo].fnRoundBanker((B.dblQtyShipped * B.dblPrice), dbo.fnARGetDefaultDecimal())), dbo.fnARGetDefaultDecimal())) * ([dbo].fnRoundBanker(((ISNULL(B.dblMaintenanceAmount, @ZeroDecimal) * B.dblQtyShipped) / B.dblTotal) * @OneHundredDecimal, dbo.fnARGetDefaultDecimal())/ @OneHundredDecimal), dbo.fnARGetDefaultDecimal()) 
--																											ELSE
--																												[dbo].fnRoundBanker((ISNULL(B.dblMaintenanceAmount, @ZeroDecimal) * B.dblQtyShipped), dbo.fnARGetDefaultDecimal())		
--																										END)
--																									END) 
--									ELSE @ZeroDecimal  END
--	,[dblCreditReport]			= CASE WHEN A.strTransactionType IN ('Invoice', 'Cash') THEN (CASE WHEN B.strMaintenanceType IN ('Maintenance Only', 'SaaS')  THEN 
--																										ISNULL(B.dblTotal, @ZeroDecimal) + [dbo].fnRoundBanker(((B.dblDiscount/@OneHundredDecimal) * [dbo].fnRoundBanker((B.dblQtyShipped * B.dblPrice), dbo.fnARGetDefaultDecimal())), dbo.fnARGetDefaultDecimal())
--																									ELSE
--																										(CASE WHEN ISNULL(B.dblDiscount, @ZeroDecimal) > @ZeroDecimal 
--																											THEN
--																												[dbo].fnRoundBanker(B.dblTotal * ([dbo].fnRoundBanker(((ISNULL(B.dblMaintenanceAmount, @ZeroDecimal) * B.dblQtyShipped) / B.dblTotal) * @OneHundredDecimal, dbo.fnARGetDefaultDecimal())/ @OneHundredDecimal), dbo.fnARGetDefaultDecimal()) + [dbo].fnRoundBanker(([dbo].fnRoundBanker(((B.dblDiscount/@OneHundredDecimal) * [dbo].fnRoundBanker((B.dblQtyShipped * B.dblPrice), dbo.fnARGetDefaultDecimal())), dbo.fnARGetDefaultDecimal())) * ([dbo].fnRoundBanker(((ISNULL(B.dblMaintenanceAmount, @ZeroDecimal) * B.dblQtyShipped) / B.dblTotal) * @OneHundredDecimal, dbo.fnARGetDefaultDecimal())/ @OneHundredDecimal), dbo.fnARGetDefaultDecimal()) 
--																											ELSE
--																												[dbo].fnRoundBanker((ISNULL(B.dblMaintenanceAmount, @ZeroDecimal) * B.dblQtyShipped), dbo.fnARGetDefaultDecimal())		
--																										END)
--																									END) 
--									ELSE @ZeroDecimal END
--	,[dblReportingRate]			= B.dblCurrencyExchangeRate 
--	,[dblForeignRate]			= B.dblCurrencyExchangeRate 
--	,[strRateType]				= SMCERT.strCurrencyExchangeRateType 
--FROM
--	(SELECT intInvoiceId, intInvoiceDetailId, intItemId, strItemDescription, dblMaintenanceAmount, intMaintenanceAccountId, strMaintenanceType, intItemUOMId, dblQtyShipped, dblDiscount, 
--		dblPrice, dblTotal, intCurrencyExchangeRateTypeId, dblBasePrice, dblBaseTotal, dblBaseMaintenanceAmount, dblBaseLicenseAmount, ISNULL(dblCurrencyExchangeRate, @OneDecimal) AS dblCurrencyExchangeRate
--		FROM tblARInvoiceDetail WITH (NOLOCK)) B
--INNER JOIN
--	(SELECT intInvoiceId, strInvoiceNumber, strTransactionType, intCurrencyId, [intEntityCustomerId], strComments, dtmDate, dtmPostDate, intCompanyLocationId, intPeriodsToAccrue
--		FROM tblARInvoice WITH (NOLOCK))  A 
--		ON B.intInvoiceId = A.intInvoiceId
--INNER JOIN
--	(SELECT intItemId, strType FROM tblICItem WITH (NOLOCK)) I ON B.intItemId = I.intItemId 				
--LEFT JOIN 
--	(SELECT [intEntityId], strCustomerNumber FROM tblARCustomer WITH (NOLOCK)) C
--		ON A.[intEntityCustomerId] = C.[intEntityId]		
--INNER JOIN 
--	(SELECT intInvoiceId, [strDescription] FROM @PostInvoiceData)	P ON A.intInvoiceId = P.intInvoiceId
--LEFT OUTER JOIN
--	(SELECT intItemId, intLocationId, intStockUOMId FROM vyuICGetItemStock WITH (NOLOCK)) ICIS ON B.intItemId = ICIS.intItemId AND A.intCompanyLocationId = ICIS.intLocationId 
--LEFT OUTER JOIN
--	(
--		SELECT
--			intCurrencyExchangeRateTypeId 
--			,strCurrencyExchangeRateType 
--		FROM
--			tblSMCurrencyExchangeRateType
--	)	SMCERT
--		ON B.intCurrencyExchangeRateTypeId = SMCERT.intCurrencyExchangeRateTypeId	
--WHERE
--	B.dblMaintenanceAmount <> @ZeroDecimal
--	AND B.strMaintenanceType IN ('License/Maintenance', 'Maintenance Only', 'SaaS')
--	AND ISNULL(I.strType,'') = 'Software'
--	AND A.strTransactionType NOT IN ('Debit Memo', 'Cash Refund')
--	AND ISNULL(A.intPeriodsToAccrue,0) <= 1
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
    @PostInvoiceData I
WHERE
    I.intInvoiceDetailId IS NOT NULL
    AND I.[ysnPost] = 1
    AND I.[intPeriodsToAccrue] <= 1
    AND I.[dblMaintenanceAmount] <> @ZeroDecimal
    AND I.[strMaintenanceType] IN ('License/Maintenance', 'Maintenance Only', 'SaaS')
    AND I.[strItemType] = 'Software'
    AND I.[strTransactionType] NOT IN ('Cash Refund', 'Debit Memo')


UNION ALL
--CREDIT SALES
--SELECT			
--		dtmDate					= CAST(ISNULL(A.dtmPostDate, A.dtmDate) AS DATE)
--	,strBatchID					= @batchIdUsed
--	,intAccountId				= B.intSalesAccountId
--	,dblDebit					= CASE WHEN A.strTransactionType IN ('Invoice', 'Cash') OR (A.strTransactionType = 'Credit Memo' AND A.intSourceId = 2 AND A.intOriginalInvoiceId IS NOT NULL) THEN @ZeroDecimal ELSE ISNULL(B.dblBaseTotal, @ZeroDecimal) + [dbo].fnRoundBanker(((B.dblDiscount/@OneHundredDecimal) * [dbo].fnRoundBanker((B.dblQtyShipped * B.dblBasePrice), dbo.fnARGetDefaultDecimal())), dbo.fnARGetDefaultDecimal()) END
--	,dblCredit					= CASE WHEN A.strTransactionType IN ('Invoice', 'Cash') OR (A.strTransactionType = 'Credit Memo' AND A.intSourceId = 2 AND A.intOriginalInvoiceId IS NOT NULL) THEN ISNULL(B.dblBaseTotal, @ZeroDecimal) + [dbo].fnRoundBanker(((B.dblDiscount/@OneHundredDecimal) * [dbo].fnRoundBanker((B.dblQtyShipped * B.dblBasePrice), dbo.fnARGetDefaultDecimal())), dbo.fnARGetDefaultDecimal()) ELSE  @ZeroDecimal END
--	,dblDebitUnit				= CASE WHEN A.strTransactionType IN ('Invoice', 'Cash') OR (A.strTransactionType = 'Credit Memo' AND A.intSourceId = 2 AND A.intOriginalInvoiceId IS NOT NULL) THEN @ZeroDecimal ELSE dbo.fnARCalculateQtyBetweenUOM(B.intItemUOMId, ICIS.intStockUOMId, B.dblQtyShipped, null, I.strType)  END
--	,dblCreditUnit				= CASE WHEN A.strTransactionType IN ('Invoice', 'Cash') OR (A.strTransactionType = 'Credit Memo' AND A.intSourceId = 2 AND A.intOriginalInvoiceId IS NOT NULL) THEN dbo.fnARCalculateQtyBetweenUOM(B.intItemUOMId, ICIS.intStockUOMId, B.dblQtyShipped, null, I.strType) ELSE @ZeroDecimal END							
--	,strDescription				= P.[strDescription]
--	,strCode					= @CODE
--	,strReference				= C.strCustomerNumber
--	,intCurrencyId				= A.intCurrencyId 
--	,dblExchangeRate			= B.dblCurrencyExchangeRate
--	,dtmDateEntered				= @PostDate
--	,dtmTransactionDate			= A.dtmDate
--	,strJournalLineDescription	= B.strItemDescription 
--	,intJournalLineNo			= B.intInvoiceDetailId
--	,ysnIsUnposted				= 0
--	,intUserId					= @userId
--	,intEntityId				= @UserEntityID				
--	,strTransactionId			= A.strInvoiceNumber
--	,intTransactionId			= A.intInvoiceId
--	,strTransactionType			= A.strTransactionType
--	,strTransactionForm			= @SCREEN_NAME
--	,strModuleName				= @MODULE_NAME
--	,intConcurrencyId			= 1
--	,[dblDebitForeign]			= CASE WHEN A.strTransactionType IN ('Invoice', 'Cash') OR (A.strTransactionType = 'Credit Memo' AND A.intSourceId = 2 AND A.intOriginalInvoiceId IS NOT NULL) THEN @ZeroDecimal ELSE ISNULL(B.dblTotal, @ZeroDecimal) + [dbo].fnRoundBanker(((B.dblDiscount/@OneHundredDecimal) * [dbo].fnRoundBanker((B.dblQtyShipped * B.dblPrice), dbo.fnARGetDefaultDecimal())), dbo.fnARGetDefaultDecimal()) END
--	,[dblDebitReport]			= CASE WHEN A.strTransactionType IN ('Invoice', 'Cash') OR (A.strTransactionType = 'Credit Memo' AND A.intSourceId = 2 AND A.intOriginalInvoiceId IS NOT NULL) THEN @ZeroDecimal ELSE ISNULL(B.dblTotal, @ZeroDecimal) + [dbo].fnRoundBanker(((B.dblDiscount/@OneHundredDecimal) * [dbo].fnRoundBanker((B.dblQtyShipped * B.dblPrice), dbo.fnARGetDefaultDecimal())), dbo.fnARGetDefaultDecimal()) END
--	,[dblCreditForeign]			= CASE WHEN A.strTransactionType IN ('Invoice', 'Cash') OR (A.strTransactionType = 'Credit Memo' AND A.intSourceId = 2 AND A.intOriginalInvoiceId IS NOT NULL) THEN ISNULL(B.dblTotal, @ZeroDecimal) + [dbo].fnRoundBanker(((B.dblDiscount/@OneHundredDecimal) * [dbo].fnRoundBanker((B.dblQtyShipped * B.dblPrice), dbo.fnARGetDefaultDecimal())), dbo.fnARGetDefaultDecimal()) ELSE @ZeroDecimal END
--	,[dblCreditReport]			= CASE WHEN A.strTransactionType IN ('Invoice', 'Cash') OR (A.strTransactionType = 'Credit Memo' AND A.intSourceId = 2 AND A.intOriginalInvoiceId IS NOT NULL) THEN ISNULL(B.dblTotal, @ZeroDecimal) + [dbo].fnRoundBanker(((B.dblDiscount/@OneHundredDecimal) * [dbo].fnRoundBanker((B.dblQtyShipped * B.dblPrice), dbo.fnARGetDefaultDecimal())), dbo.fnARGetDefaultDecimal()) ELSE @ZeroDecimal END
--	,[dblReportingRate]			= B.dblCurrencyExchangeRate 
--	,[dblForeignRate]			= B.dblCurrencyExchangeRate 
--	,[strRateType]				= SMCERT.strCurrencyExchangeRateType 
--FROM
--	(SELECT intInvoiceId, intInvoiceDetailId, intItemId, strItemDescription, intItemUOMId, intSalesAccountId, dblQtyShipped, dblDiscount, dblPrice, dblTotal,
--			intCurrencyExchangeRateTypeId, dblBaseTotal, dblBasePrice, ISNULL(dblCurrencyExchangeRate, @OneDecimal) AS dblCurrencyExchangeRate
--		FROM tblARInvoiceDetail WITH (NOLOCK)
--		WHERE (intItemId IS NOT NULL OR intItemId <> 0)) B
--INNER JOIN
--	(SELECT intInvoiceId, strInvoiceNumber, intEntityCustomerId, intCompanyLocationId, strTransactionType, strComments, intCurrencyId, dtmPostDate, dtmDate, intPeriodsToAccrue, dblInvoiceTotal, intSourceId, intOriginalInvoiceId
--		FROM tblARInvoice WITH (NOLOCK)) A 
--		ON B.intInvoiceId = A.intInvoiceId					
--LEFT JOIN 
--	(SELECT [intEntityId], strCustomerNumber FROM tblARCustomer WITH (NOLOCK)) C
--		ON A.[intEntityCustomerId] = C.[intEntityId]			
--INNER JOIN 
--	(SELECT intInvoiceId, [strDescription] FROM @PostInvoiceData)	P
--		ON A.intInvoiceId = P.intInvoiceId
--INNER JOIN
--	(SELECT intItemId, strType FROM tblICItem WITH (NOLOCK)) I
--		ON B.intItemId = I.intItemId
--INNER JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = A.intCompanyLocationId
--LEFT OUTER JOIN
--	(SELECT intItemId, intLocationId, intStockUOMId FROM vyuICGetItemStock WITH (NOLOCK)) ICIS
--		ON B.intItemId = ICIS.intItemId 
--		AND A.intCompanyLocationId = ICIS.intLocationId
--LEFT OUTER JOIN
--	(
--		SELECT
--			intCurrencyExchangeRateTypeId 
--			,strCurrencyExchangeRateType 
--		FROM
--			tblSMCurrencyExchangeRateType
--	)	SMCERT
--		ON B.intCurrencyExchangeRateTypeId = SMCERT.intCurrencyExchangeRateTypeId 
--WHERE			 
--	(B.intItemId IS NOT NULL OR B.intItemId <> 0)
--	AND ISNULL(I.strType,'') NOT IN ('Non-Inventory','Service','Other Charge','Software','Comment')
--	AND A.strTransactionType NOT IN ('Debit Memo', 'Cash Refund')
--	AND ISNULL(A.intPeriodsToAccrue,0) <= 1
--	AND (
--            B.dblQtyShipped <> @ZeroDecimal
--        OR
--            (B.dblQtyShipped = @ZeroDecimal AND A.dblInvoiceTotal = @ZeroDecimal)
--        )
SELECT
     [dtmDate]                      = CAST(ISNULL(I.[dtmPostDate], I.[dtmDate]) AS DATE)
    ,[strBatchId]                   = I.[strBatchId]
    ,[intAccountId]                 = I.[intSalesAccountId]
    ,[dblDebit]                     = CASE WHEN I.[strTransactionType] IN ('Invoice', 'Cash') OR (I.[strTransactionType] = 'Credit Memo' AND I.[intSourceId] = 2 AND I.[intOriginalInvoiceId] IS NOT NULL) THEN @ZeroDecimal ELSE I.[dblBaseLineItemGLAmount] END
    ,[dblCredit]                    = CASE WHEN I.[strTransactionType] IN ('Invoice', 'Cash') OR (I.[strTransactionType] = 'Credit Memo' AND I.[intSourceId] = 2 AND I.[intOriginalInvoiceId] IS NOT NULL) THEN I.[dblBaseLineItemGLAmount] ELSE @ZeroDecimal END
    ,[dblDebitUnit]                 = CASE WHEN I.[strTransactionType] IN ('Invoice', 'Cash') OR (I.[strTransactionType] = 'Credit Memo' AND I.[intSourceId] = 2 AND I.[intOriginalInvoiceId] IS NOT NULL) THEN @ZeroDecimal ELSE I.[dblUnitQtyShipped] END
    ,[dblCreditUnit]                = CASE WHEN I.[strTransactionType] IN ('Invoice', 'Cash') OR (I.[strTransactionType] = 'Credit Memo' AND I.[intSourceId] = 2 AND I.[intOriginalInvoiceId] IS NOT NULL) THEN I.[dblUnitQtyShipped] ELSE @ZeroDecimal END
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
    ,[dblDebitForeign]              = CASE WHEN I.[strTransactionType] IN ('Invoice', 'Cash') OR (I.[strTransactionType] = 'Credit Memo' AND I.[intSourceId] = 2 AND I.[intOriginalInvoiceId] IS NOT NULL) THEN @ZeroDecimal ELSE I.[dblLineItemGLAmount] END
    ,[dblDebitReport]               = CASE WHEN I.[strTransactionType] IN ('Invoice', 'Cash') OR (I.[strTransactionType] = 'Credit Memo' AND I.[intSourceId] = 2 AND I.[intOriginalInvoiceId] IS NOT NULL) THEN @ZeroDecimal ELSE I.[dblLineItemGLAmount] END
    ,[dblCreditForeign]             = CASE WHEN I.[strTransactionType] IN ('Invoice', 'Cash') OR (I.[strTransactionType] = 'Credit Memo' AND I.[intSourceId] = 2 AND I.[intOriginalInvoiceId] IS NOT NULL) THEN I.[dblLineItemGLAmount] ELSE @ZeroDecimal END
    ,[dblCreditReport]              = CASE WHEN I.[strTransactionType] IN ('Invoice', 'Cash') OR (I.[strTransactionType] = 'Credit Memo' AND I.[intSourceId] = 2 AND I.[intOriginalInvoiceId] IS NOT NULL) THEN I.[dblLineItemGLAmount] ELSE @ZeroDecimal END
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
    @PostInvoiceData I
WHERE
    I.intInvoiceDetailId IS NOT NULL
    AND I.[ysnPost] = 1
    AND I.[intPeriodsToAccrue] <= 1
    AND I.[intItemId] IS NOT NULL
    AND I.[strItemType] NOT IN ('Non-Inventory','Service','Other Charge','Software','Comment')
    AND I.[strTransactionType] NOT IN ('Cash Refund', 'Debit Memo')
    AND (
        I.[dblQtyShipped] <> @ZeroDecimal
        OR
	    (I.[dblQtyShipped] = @ZeroDecimal AND I.[dblInvoiceTotal] = @ZeroDecimal)
        )

UNION ALL
--CREDIT SALES - Debit Memo
--SELECT			
--		dtmDate					= CAST(ISNULL(A.dtmPostDate, A.dtmDate) AS DATE)
--	,strBatchID					= @batchIdUsed
--	,intAccountId				= B.intSalesAccountId
--	,dblDebit					= CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash') THEN @ZeroDecimal ELSE ISNULL(B.dblBaseTotal, @ZeroDecimal) + [dbo].fnRoundBanker(((B.dblDiscount/@OneHundredDecimal) * [dbo].fnRoundBanker((B.dblQtyShipped * B.dblBasePrice), dbo.fnARGetDefaultDecimal())), dbo.fnARGetDefaultDecimal()) END
--	,dblCredit					= CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash') THEN ISNULL(B.dblBaseTotal, @ZeroDecimal) + [dbo].fnRoundBanker(((B.dblDiscount/@OneHundredDecimal) * [dbo].fnRoundBanker((B.dblQtyShipped * B.dblBasePrice), dbo.fnARGetDefaultDecimal())), dbo.fnARGetDefaultDecimal()) ELSE  @ZeroDecimal END
--	,dblDebitUnit				= CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash') THEN @ZeroDecimal ELSE dbo.fnARCalculateQtyBetweenUOM(B.intItemUOMId, ICIS.intStockUOMId, B.dblQtyShipped, null, I.strType)  END
--	,dblCreditUnit				= CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash') THEN dbo.fnARCalculateQtyBetweenUOM(B.intItemUOMId, ICIS.intStockUOMId, B.dblQtyShipped, null, I.strType) ELSE @ZeroDecimal END							
--	,strDescription				= P.[strDescription]
--	,strCode					= @CODE
--	,strReference				= C.strCustomerNumber
--	,intCurrencyId				= A.intCurrencyId 
--	,dblExchangeRate			= B.dblCurrencyExchangeRate
--	,dtmDateEntered				= @PostDate
--	,dtmTransactionDate			= A.dtmDate
--	,strJournalLineDescription	= B.strItemDescription 
--	,intJournalLineNo			= B.intInvoiceDetailId
--	,ysnIsUnposted				= 0
--	,intUserId					= @userId
--	,intEntityId				= @UserEntityID				
--	,strTransactionId			= A.strInvoiceNumber
--	,intTransactionId			= A.intInvoiceId
--	,strTransactionType			= A.strTransactionType
--	,strTransactionForm			= @SCREEN_NAME
--	,strModuleName				= @MODULE_NAME
--	,intConcurrencyId			= 1
--	,[dblDebitForeign]			= CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash') THEN @ZeroDecimal ELSE ISNULL(B.dblTotal, @ZeroDecimal) + [dbo].fnRoundBanker(((B.dblDiscount/@OneHundredDecimal) * [dbo].fnRoundBanker((B.dblQtyShipped * B.dblPrice), dbo.fnARGetDefaultDecimal())), dbo.fnARGetDefaultDecimal()) END
--	,[dblDebitReport]			= CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash') THEN @ZeroDecimal ELSE ISNULL(B.dblTotal, @ZeroDecimal) + [dbo].fnRoundBanker(((B.dblDiscount/@OneHundredDecimal) * [dbo].fnRoundBanker((B.dblQtyShipped * B.dblPrice), dbo.fnARGetDefaultDecimal())), dbo.fnARGetDefaultDecimal()) END
--	,[dblCreditForeign]			= CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash') THEN ISNULL(B.dblTotal, @ZeroDecimal) + [dbo].fnRoundBanker(((B.dblDiscount/@OneHundredDecimal) * [dbo].fnRoundBanker((B.dblQtyShipped * B.dblPrice), dbo.fnARGetDefaultDecimal())), dbo.fnARGetDefaultDecimal()) ELSE  @ZeroDecimal END
--	,[dblCreditReport]			= CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash') THEN ISNULL(B.dblTotal, @ZeroDecimal) + [dbo].fnRoundBanker(((B.dblDiscount/@OneHundredDecimal) * [dbo].fnRoundBanker((B.dblQtyShipped * B.dblPrice), dbo.fnARGetDefaultDecimal())), dbo.fnARGetDefaultDecimal()) ELSE  @ZeroDecimal END
--	,[dblReportingRate]			= B.dblCurrencyExchangeRate 
--	,[dblForeignRate]			= B.dblCurrencyExchangeRate 
--	,[strRateType]				= SMCERT.strCurrencyExchangeRateType
--FROM
--	(SELECT intInvoiceId, intInvoiceDetailId, intItemId, strItemDescription, intSalesAccountId, dblTotal, intItemUOMId, dblQtyShipped, dblDiscount, dblPrice,
--			intCurrencyExchangeRateTypeId, dblBaseTotal, dblBasePrice, ISNULL(dblCurrencyExchangeRate, @OneDecimal) AS dblCurrencyExchangeRate
--		FROM tblARInvoiceDetail WITH (NOLOCK)) B
--INNER JOIN
--	(SELECT intInvoiceId, strInvoiceNumber, [intEntityCustomerId], dtmPostDate, dtmDate, strTransactionType, strComments, intCurrencyId, intCompanyLocationId, intPeriodsToAccrue, strType
--		FROM tblARInvoice WITH (NOLOCK)) A 
--		ON B.intInvoiceId = A.intInvoiceId					
--LEFT JOIN 
--	(SELECT [intEntityId], strCustomerNumber FROM tblARCustomer WITH (NOLOCK)) C
--		ON A.[intEntityCustomerId] = C.[intEntityId]			
--INNER JOIN 
--	(SELECT intInvoiceId, [strDescription] FROM @PostInvoiceData)	P
--		ON A.intInvoiceId = P.intInvoiceId
--LEFT OUTER JOIN
--	(SELECT intItemId, strType FROM tblICItem WITH (NOLOCK)) I
--		ON B.intItemId = I.intItemId
--LEFT OUTER JOIN
--	(SELECT intItemId, intLocationId, intStockUOMId FROM vyuICGetItemStock WITH (NOLOCK)) ICIS
--		ON B.intItemId = ICIS.intItemId 
--		AND A.intCompanyLocationId = ICIS.intLocationId
--LEFT OUTER JOIN
--	(
--		SELECT
--			intCurrencyExchangeRateTypeId 
--			,strCurrencyExchangeRateType 
--		FROM
--			tblSMCurrencyExchangeRateType
--	)	SMCERT
--		ON B.intCurrencyExchangeRateTypeId = SMCERT.intCurrencyExchangeRateTypeId 
--WHERE
--	B.dblQtyShipped <> @ZeroDecimal  
--	AND A.strTransactionType = 'Debit Memo'
--	AND A.strType NOT IN ('CF Tran', 'CF Invoice', 'Card Fueling Transaction')
--	AND ISNULL(A.intPeriodsToAccrue,0) <= 1
--	AND ISNULL(I.strType,'') <> 'Comment'
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
    @PostInvoiceData I
WHERE
    I.intInvoiceDetailId IS NOT NULL
    AND I.[ysnPost] = 1
    AND I.[intPeriodsToAccrue] <= 1
    AND I.[dblQtyShipped] <> @ZeroDecimal
    AND I.[strType] NOT IN ('CF Tran', 'CF Invoice', 'Card Fueling Transaction')
    AND I.[strTransactionType] = 'Debit Memo'
    AND I.[strItemType] <> 'Comment'

UNION ALL
--CREDIT Shipping
--SELECT
--	 dtmDate					= CAST(ISNULL(A.dtmPostDate, A.dtmDate) AS DATE)
--	,strBatchID					= @batchIdUsed
--	,intAccountId				= L.intFreightIncome
--	,dblDebit					= CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash') THEN @ZeroDecimal ELSE A.dblBaseShipping END
--	,dblCredit					= CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash') THEN A.dblBaseShipping ELSE @ZeroDecimal  END
--	,dblDebitUnit				= @ZeroDecimal
--	,dblCreditUnit				= @ZeroDecimal							
--	,strDescription				= P.[strDescription]
--	,strCode					= @CODE
--	,strReference				= C.strCustomerNumber
--	,intCurrencyId				= A.intCurrencyId 
--	,dblExchangeRate			= A.dblCurrencyExchangeRate
--	,dtmDateEntered				= @PostDate
--	,dtmTransactionDate			= A.dtmDate
--	,strJournalLineDescription	= @POSTDESC + A.strTransactionType 
--	,intJournalLineNo			= A.intInvoiceId
--	,ysnIsUnposted				= 0
--	,intUserId					= @userId
--	,intEntityId				= @UserEntityID				
--	,strTransactionId			= A.strInvoiceNumber
--	,intTransactionId			= A.intInvoiceId
--	,strTransactionType			= A.strTransactionType
--	,strTransactionForm			= @SCREEN_NAME
--	,strModuleName				= @MODULE_NAME
--	,intConcurrencyId			= 1
--	,[dblDebitForeign]			= CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash') THEN @ZeroDecimal ELSE A.dblShipping END
--	,[dblDebitReport]			= CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash') THEN @ZeroDecimal ELSE A.dblShipping END
--	,[dblCreditForeign]			= CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash') THEN A.dblShipping ELSE @ZeroDecimal  END
--	,[dblCreditReport]			= CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash') THEN A.dblShipping ELSE @ZeroDecimal  END
--	,[dblReportingRate]			= A.dblCurrencyExchangeRate
--	,[dblForeignRate]			= A.dblCurrencyExchangeRate
--	,[strRateType]				= ''
--FROM
--	(SELECT intInvoiceId, strInvoiceNumber, [intEntityCustomerId], intCompanyLocationId, dtmPostDate, dtmDate, dblShipping, strTransactionType, strComments, intCurrencyId, dblBaseShipping, dblBaseInvoiceTotal, dblInvoiceTotal, ISNULL(dblCurrencyExchangeRate, @OneDecimal) AS dblCurrencyExchangeRate
--		FROM tblARInvoice WITH (NOLOCK)) A 
--LEFT JOIN 
--	(SELECT [intEntityId], strCustomerNumber FROM tblARCustomer WITH (NOLOCK)) C
--		ON A.[intEntityCustomerId] = C.[intEntityId]	
--INNER JOIN
--	(SELECT intCompanyLocationId, intFreightIncome FROM tblSMCompanyLocation WITH (NOLOCK)) L
--		ON A.intCompanyLocationId = L.intCompanyLocationId	
--INNER JOIN 
--	(SELECT intInvoiceId, [strDescription] FROM @PostInvoiceData)	P
--		ON A.intInvoiceId = P.intInvoiceId	
--WHERE
--	A.dblShipping <> @ZeroDecimal
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
    @PostInvoiceData I
WHERE
    I.intInvoiceDetailId IS NULL
    AND I.[ysnPost] = 1
    AND I.[dblShipping] <> @ZeroDecimal

UNION ALL
--CREDIT Tax
--SELECT			
--	 dtmDate					= CAST(ISNULL(A.dtmPostDate, A.dtmDate) AS DATE)
--	,strBatchID					= @batchIdUsed
--	,intAccountId				= ISNULL([dbo].[fnGetGLAccountIdFromProfitCenter](ISNULL(DT.intSalesTaxAccountId,TC.intSalesTaxAccountId), SMCL.intProfitCenter),ISNULL(DT.intSalesTaxAccountId,TC.intSalesTaxAccountId))
--	,dblDebit					= CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash') THEN 
--										CASE WHEN DT.dblBaseAdjustedTax < @ZeroDecimal THEN ABS(DT.dblBaseAdjustedTax) ELSE @ZeroDecimal END 
--									ELSE 
--										CASE WHEN DT.dblBaseAdjustedTax < @ZeroDecimal THEN @ZeroDecimal ELSE DT.dblBaseAdjustedTax END
--									END
--	,dblCredit					= CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash') THEN 
--										CASE WHEN DT.dblBaseAdjustedTax < @ZeroDecimal THEN @ZeroDecimal ELSE DT.dblBaseAdjustedTax END 
--									ELSE 
--										CASE WHEN DT.dblBaseAdjustedTax < @ZeroDecimal THEN ABS(DT.dblBaseAdjustedTax) ELSE @ZeroDecimal END 
--									END
--	,dblDebitUnit				= @ZeroDecimal
--	,dblCreditUnit				= @ZeroDecimal								
--	,strDescription				= P.[strDescription]
--	,strCode					= @CODE
--	,strReference				= C.strCustomerNumber
--	,intCurrencyId				= A.intCurrencyId 
--	,dblExchangeRate			= A.dblCurrencyExchangeRate
--	,dtmDateEntered				= @PostDate
--	,dtmTransactionDate			= A.dtmDate
--	,strJournalLineDescription	= @POSTDESC + A.strTransactionType 
--	,intJournalLineNo			= DT.intInvoiceDetailTaxId
--	,ysnIsUnposted				= 0
--	,intUserId					= @userId
--	,intEntityId				= @UserEntityID				
--	,strTransactionId			= A.strInvoiceNumber
--	,intTransactionId			= A.intInvoiceId
--	,strTransactionType			= A.strTransactionType
--	,strTransactionForm			= @SCREEN_NAME
--	,strModuleName				= @MODULE_NAME
--	,intConcurrencyId			= 1
--	,[dblDebitForeign]			= CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash') THEN 
--										CASE WHEN DT.dblAdjustedTax < @ZeroDecimal THEN ABS(DT.dblAdjustedTax) ELSE @ZeroDecimal END 
--									ELSE 
--										CASE WHEN DT.dblAdjustedTax < @ZeroDecimal THEN @ZeroDecimal ELSE DT.dblAdjustedTax END
--									END
--	,[dblDebitReport]			= CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash') THEN 
--										CASE WHEN DT.dblAdjustedTax < @ZeroDecimal THEN ABS(DT.dblAdjustedTax) ELSE @ZeroDecimal END 
--									ELSE 
--										CASE WHEN DT.dblAdjustedTax < @ZeroDecimal THEN @ZeroDecimal ELSE DT.dblAdjustedTax END
--									END
--	,[dblCreditForeign]			= CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash') THEN 
--										CASE WHEN DT.dblAdjustedTax < @ZeroDecimal THEN @ZeroDecimal ELSE DT.dblAdjustedTax END 
--									ELSE 
--										CASE WHEN DT.dblAdjustedTax < @ZeroDecimal THEN ABS(DT.dblAdjustedTax) ELSE @ZeroDecimal END 
--									END
--	,[dblCreditReport]			= CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash') THEN 
--										CASE WHEN DT.dblAdjustedTax < @ZeroDecimal THEN @ZeroDecimal ELSE DT.dblAdjustedTax END 
--									ELSE 
--										CASE WHEN DT.dblAdjustedTax < @ZeroDecimal THEN ABS(DT.dblAdjustedTax) ELSE @ZeroDecimal END 
--									END
--	,[dblReportingRate]			= A.dblCurrencyExchangeRate
--	,[dblForeignRate]			= A.dblCurrencyExchangeRate
--	,[strRateType]				= SMCERT.strCurrencyExchangeRateType 
--FROM
--	(SELECT intTaxCodeId, intInvoiceDetailId, intInvoiceDetailTaxId, intSalesTaxAccountId, dblAdjustedTax, dblBaseAdjustedTax
--		FROM tblARInvoiceDetailTax WITH (NOLOCK)) DT
--INNER JOIN
--	(SELECT intInvoiceId, intInvoiceDetailId, intCurrencyExchangeRateTypeId FROM tblARInvoiceDetail WITH (NOLOCK)) D
--		ON DT.intInvoiceDetailId = D.intInvoiceDetailId
--INNER JOIN			
--	(SELECT intInvoiceId, dtmPostDate, dtmDate, intEntityCustomerId, strComments, strTransactionType, intCurrencyId, strInvoiceNumber, intPeriodsToAccrue, intCompanyLocationId, dblBaseInvoiceTotal, dblInvoiceTotal, ISNULL(dblCurrencyExchangeRate, @OneDecimal) AS dblCurrencyExchangeRate
--		FROM tblARInvoice WITH (NOLOCK)) A 
--		ON D.intInvoiceId = A.intInvoiceId
--INNER JOIN
--	(SELECT [intEntityId], strCustomerNumber FROM tblARCustomer WITH (NOLOCK)) C
--		ON A.intEntityCustomerId = C.[intEntityId]
--INNER JOIN
--	tblSMCompanyLocation SMCL
--		ON A.intCompanyLocationId = SMCL.intCompanyLocationId 
--INNER JOIN 
--	(SELECT intInvoiceId, [strDescription] FROM @PostInvoiceData )	P
--		ON A.intInvoiceId = P.intInvoiceId				
--LEFT OUTER JOIN
--	(SELECT intTaxCodeId, intSalesTaxAccountId FROM tblSMTaxCode WITH (NOLOCK)) TC
--		ON DT.intTaxCodeId = TC.intTaxCodeId
--LEFT OUTER JOIN
--	(
--		SELECT
--			intCurrencyExchangeRateTypeId 
--			,strCurrencyExchangeRateType 
--		FROM
--			tblSMCurrencyExchangeRateType
--	)	SMCERT
--		ON D.intCurrencyExchangeRateTypeId = SMCERT.intCurrencyExchangeRateTypeId	
--WHERE
--	DT.dblAdjustedTax <> @ZeroDecimal
--	AND ISNULL(A.intPeriodsToAccrue,0) <= 1
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
    @PostInvoiceData I
        ON ARIDT.[intInvoiceDetailId] = I.[intInvoiceDetailId]
WHERE
    I.intInvoiceDetailId IS NOT NULL
    AND I.[ysnPost] = 1
    AND I.[intPeriodsToAccrue] <= 1
    AND ARIDT.[dblAdjustedTax] <> @ZeroDecimal

UNION ALL
--DEBIT Discount
--SELECT			
--		dtmDate					= CAST(ISNULL(A.dtmPostDate, A.dtmDate) AS DATE)
--	,strBatchID					= @batchIdUsed
--	,intAccountId				= ISNULL(IST.intDiscountAccountId, @DiscountAccountId)
--	,dblDebit					= CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash') THEN [dbo].fnRoundBanker(((D.dblDiscount/@OneHundredDecimal) * [dbo].fnRoundBanker((D.dblQtyShipped * D.dblBasePrice), dbo.fnARGetDefaultDecimal())), dbo.fnARGetDefaultDecimal()) ELSE @ZeroDecimal END
--	,dblCredit					= CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash') THEN @ZeroDecimal ELSE [dbo].fnRoundBanker(((D.dblDiscount/@OneHundredDecimal) * [dbo].fnRoundBanker((D.dblQtyShipped * D.dblBasePrice), dbo.fnARGetDefaultDecimal())), dbo.fnARGetDefaultDecimal()) END
--	,dblDebitUnit				= @ZeroDecimal
--	,dblCreditUnit				= @ZeroDecimal								
--	,strDescription				= P.[strDescription]
--	,strCode					= @CODE
--	,strReference				= C.strCustomerNumber
--	,intCurrencyId				= A.intCurrencyId 
--	,dblExchangeRate			= D.dblCurrencyExchangeRate
--	,dtmDateEntered				= @PostDate
--	,dtmTransactionDate			= A.dtmDate
--	,strJournalLineDescription	= @POSTDESC + A.strTransactionType 
--	,intJournalLineNo			= D.intInvoiceDetailId
--	,ysnIsUnposted				= 0
--	,intUserId					= @userId
--	,intEntityId				= @UserEntityID				
--	,strTransactionId			= A.strInvoiceNumber
--	,intTransactionId			= A.intInvoiceId
--	,strTransactionType			= A.strTransactionType
--	,strTransactionForm			= @SCREEN_NAME
--	,strModuleName				= @MODULE_NAME
--	,intConcurrencyId			= 1
--	,[dblDebitForeign]			= CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash') THEN [dbo].fnRoundBanker(((D.dblDiscount/@OneHundredDecimal) * [dbo].fnRoundBanker((D.dblQtyShipped * D.dblPrice), dbo.fnARGetDefaultDecimal())), dbo.fnARGetDefaultDecimal()) ELSE @ZeroDecimal END
--	,[dblDebitReport]			= CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash') THEN [dbo].fnRoundBanker(((D.dblDiscount/@OneHundredDecimal) * [dbo].fnRoundBanker((D.dblQtyShipped * D.dblPrice), dbo.fnARGetDefaultDecimal())), dbo.fnARGetDefaultDecimal()) ELSE @ZeroDecimal END
--	,[dblCreditForeign]			= CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash') THEN @ZeroDecimal ELSE [dbo].fnRoundBanker(((D.dblDiscount/@OneHundredDecimal) * [dbo].fnRoundBanker((D.dblQtyShipped * D.dblPrice), dbo.fnARGetDefaultDecimal())), dbo.fnARGetDefaultDecimal()) END
--	,[dblCreditReport]			= CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash') THEN @ZeroDecimal ELSE [dbo].fnRoundBanker(((D.dblDiscount/@OneHundredDecimal) * [dbo].fnRoundBanker((D.dblQtyShipped * D.dblPrice), dbo.fnARGetDefaultDecimal())), dbo.fnARGetDefaultDecimal()) END
--	,[dblReportingRate]			= D.dblCurrencyExchangeRate
--	,[dblForeignRate]			= D.dblCurrencyExchangeRate
--	,[strRateType]				= SMCERT.strCurrencyExchangeRateType 
--FROM
--	(SELECT intInvoiceId, intItemId, intInvoiceDetailId, dblQtyShipped, dblDiscount, dblPrice, intCurrencyExchangeRateTypeId, dblBasePrice, ISNULL(dblCurrencyExchangeRate, @OneDecimal) AS dblCurrencyExchangeRate FROM tblARInvoiceDetail WITH (NOLOCK)) D
--INNER JOIN			
--	(SELECT intInvoiceId, strInvoiceNumber, intEntityCustomerId, strTransactionType, intCurrencyId, intCompanyLocationId, dtmPostDate, dtmDate, strComments 
--		FROM tblARInvoice WITH (NOLOCK)) A 
--		ON D.intInvoiceId = A.intInvoiceId
--LEFT OUTER JOIN
--	(SELECT intItemId, intLocationId, intDiscountAccountId FROM vyuARGetItemAccount WITH (NOLOCK)) IST
--		ON D.intItemId = IST.intItemId 
--		AND A.intCompanyLocationId = IST.intLocationId 
--INNER JOIN
--	(SELECT [intEntityId], strCustomerNumber FROM tblARCustomer WITH (NOLOCK)) C
--		ON A.intEntityCustomerId = C.[intEntityId]
--INNER JOIN 
--	(SELECT intInvoiceId, [strDescription] FROM @PostInvoiceData) P
--		ON A.intInvoiceId = P.intInvoiceId
--LEFT OUTER JOIN
--	(
--		SELECT
--			intCurrencyExchangeRateTypeId 
--			,strCurrencyExchangeRateType 
--		FROM
--			tblSMCurrencyExchangeRateType
--	)	SMCERT
--		ON D.intCurrencyExchangeRateTypeId = SMCERT.intCurrencyExchangeRateTypeId	
--WHERE
--	((D.dblDiscount/@OneHundredDecimal) * (D.dblQtyShipped * D.dblPrice)) <> @ZeroDecimal
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
    @PostInvoiceData I
LEFT OUTER JOIN
    @ItemAccounts IA
       ON I.[intItemId] = IA.[intItemId]
       AND I.[intCompanyLocationId] = IA.[intLocationId]
WHERE
    I.[intInvoiceDetailId] IS NOT NULL
    AND I.[ysnPost] = 1
    AND I.[dblBaseDiscountAmount] <> @ZeroDecimal
    

RETURN
END