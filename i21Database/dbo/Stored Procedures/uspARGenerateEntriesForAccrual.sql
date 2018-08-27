CREATE PROCEDURE [dbo].[uspARGenerateEntriesForAccrual]
     --@Invoices      [InvoicePostingTable]   READONLY
    --,@ItemAccounts  [InvoiceItemAccount]    READONLY
    --,@PostDate      DATETIME                = NULL
AS

DECLARE @MODULE_NAME NVARCHAR(25) = 'Accounts Receivable'
DECLARE @SCREEN_NAME NVARCHAR(25) = 'Invoice'
DECLARE @CODE NVARCHAR(25) = 'AR'
DECLARE @POSTDESC NVARCHAR(10) = 'Posted '

DECLARE @GLEntries AS RecapTableType
DECLARE @ZeroDecimal DECIMAL(18,6)
SET @ZeroDecimal = 0.000000
DECLARE @OneDecimal DECIMAL(18,6)
SET @OneDecimal = 1.000000
DECLARE @OneHundredDecimal DECIMAL(18,6)
SET @OneHundredDecimal = 100.000000

EXEC dbo.[uspARInsertDefaultAccrual]  

WHILE EXISTS(SELECT NULL FROM #ARPostInvoiceHeader I LEFT OUTER JOIN @GLEntries G ON I.[intInvoiceId] = G.[intTransactionId] WHERE I.[intPeriodsToAccrue] > 1 AND I.[ysnPost] = 1 AND ISNULL(G.[intTransactionId],0) = 0)
BEGIN
    DECLARE  @InvoiceId							INT
            ,@AccrualPeriod						INT
            ,@LoopCounter						INT
            ,@TaxLoopCounter					INT
            ,@Remainder							DECIMAL(18,6)
            ,@RemainderWODiscount				DECIMAL(18,6)
            ,@LicenseRemainder					DECIMAL(18,6)
            ,@LicenseRemainderWODiscount		DECIMAL(18,6)
            ,@MaintenanceRemainder				DECIMAL(18,6)
            ,@MaintenanceRemainderWODiscount	DECIMAL(18,6)
            ,@UnitsRemainder					DECIMAL(18,6)
            ,@TaxRemainder						DECIMAL(18,6)

    SELECT TOP 1 @InvoiceId = I.[intInvoiceId] FROM #ARPostInvoiceHeader I LEFT OUTER JOIN @GLEntries G ON I.[intInvoiceId] = G.[intTransactionId] WHERE I.[intPeriodsToAccrue] > 1 AND I.[ysnPost] = 1 AND ISNULL(G.intTransactionId,0) = 0

    SELECT
        @AccrualPeriod = [intPeriodsToAccrue]
    FROM
        #ARPostInvoiceHeader
    WHERE
        [intInvoiceId] = @InvoiceId 

    --DEBIT AR
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
	--SELECT
	--	 dtmDate					= CAST(ISNULL(A.dtmPostDate, A.dtmDate) AS DATE)
	--	,strBatchID					= @BatchId
	--	,intAccountId				= A.intAccountId
	--	,dblDebit					= CASE WHEN A.strTransactionType  IN ('Invoice', 'Cash') THEN  A.dblBaseInvoiceTotal ELSE @ZeroDecimal END
	--	,dblCredit					= CASE WHEN A.strTransactionType  IN ('Invoice', 'Cash') THEN  @ZeroDecimal ELSE A.dblBaseInvoiceTotal END
	--	,dblDebitUnit				= CASE WHEN A.strTransactionType  IN ('Invoice', 'Cash')	THEN  
	--																					(
	--																					SELECT
	--																						SUM(ISNULL([dbo].[fnCalculateQtyBetweenUOM](ARID.intItemUOMId, ICIS.intStockUOMId, ARID.dblQtyShipped),ISNULL(ARID.dblQtyShipped, @ZeroDecimal)))
	--																					FROM
	--																						tblARInvoiceDetail ARID 
	--																					INNER JOIN
	--																						tblARInvoice ARI
	--																							ON ARID.intInvoiceId = ARI.intInvoiceId	
	--																					LEFT OUTER JOIN
	--																						tblICItem I
	--																							ON ARID.intItemId = I.intItemId
	--																					LEFT OUTER JOIN
	--																						@ItemAccounts IST
	--																							ON ARID.intItemId = IST.intItemId 
	--																							AND ARI.intCompanyLocationId = IST.intLocationId 
	--																					LEFT OUTER JOIN
	--																						vyuICGetItemStock ICIS
	--																							ON ARID.intItemId = ICIS.intItemId 
	--																							AND ARI.intCompanyLocationId = ICIS.intLocationId 
	--																					WHERE
	--																						ARI.intInvoiceId = A.intInvoiceId
	--																						AND ARID.dblTotal <> @ZeroDecimal  
	--																					)
	--																				ELSE 
	--																					@ZeroDecimal
	--																				END
	--	,dblCreditUnit				=  CASE WHEN A.strTransactionType  IN ('Invoice', 'Cash')	THEN  
	--																					@ZeroDecimal
	--																				ELSE 
	--																					(
	--																					SELECT
	--																						SUM(ISNULL([dbo].[fnCalculateQtyBetweenUOM](ARID.intItemUOMId, ICIS.intStockUOMId, ARID.dblQtyShipped),ISNULL(ARID.dblQtyShipped, @ZeroDecimal)))
	--																					FROM
	--																						tblARInvoiceDetail ARID 
	--																					INNER JOIN
	--																						tblARInvoice ARI
	--																							ON ARID.intInvoiceId = ARI.intInvoiceId	
	--																					LEFT OUTER JOIN
	--																						tblICItem I
	--																							ON ARID.intItemId = I.intItemId
	--																					LEFT OUTER JOIN
	--																						@ItemAccounts IST
	--																							ON ARID.intItemId = IST.intItemId 
	--																							AND ARI.intCompanyLocationId = IST.intLocationId 
	--																					LEFT OUTER JOIN
	--																						vyuICGetItemStock ICIS
	--																							ON ARID.intItemId = ICIS.intItemId 
	--																							AND ARI.intCompanyLocationId = ICIS.intLocationId 
	--																					WHERE
	--																						ARI.intInvoiceId = A.intInvoiceId
	--																						AND ARID.dblTotal <> @ZeroDecimal  
	--																					)
	--																				END				
	--	,strDescription				= A.strComments
	--	,strCode					= @CODE
	--	,strReference				= C.strCustomerNumber
	--	,intCurrencyId				= A.intCurrencyId 
	--	,dblExchangeRate			= A.dblCurrencyExchangeRate
	--	,dtmDateEntered				= @PostDate 
	--	,dtmTransactionDate			= A.dtmDate
	--	,strJournalLineDescription	= 'Posted ' + A.strTransactionType 
	--	,intJournalLineNo			= A.intInvoiceId
	--	,ysnIsUnposted				= 0
	--	,intUserId					= @UserId
	--	,intEntityId				= @UserEntityId 				
	--	,strTransactionId			= A.strInvoiceNumber
	--	,intTransactionId			= A.intInvoiceId
	--	,strTransactionType			= A.strTransactionType
	--	,strTransactionForm			= @SCREEN_NAME 
	--	,strModuleName				= @MODULE_NAME 
	--	,intConcurrencyId			= 1
	--	,[dblDebitForeign]			= CASE WHEN A.strTransactionType  IN ('Invoice', 'Cash') THEN  A.dblInvoiceTotal ELSE @ZeroDecimal END
	--	,[dblDebitReport]			= CASE WHEN A.strTransactionType  IN ('Invoice', 'Cash') THEN  A.dblInvoiceTotal ELSE @ZeroDecimal END	
	--	,[dblCreditForeign]			= CASE WHEN A.strTransactionType  IN ('Invoice', 'Cash') THEN  @ZeroDecimal ELSE A.dblInvoiceTotal END
	--	,[dblCreditReport]			= CASE WHEN A.strTransactionType  IN ('Invoice', 'Cash') THEN  @ZeroDecimal ELSE A.dblInvoiceTotal END
	--	,[dblReportingRate]			= A.dblCurrencyExchangeRate
	--	,[dblForeignRate]			= A.dblCurrencyExchangeRate
	--	,[strRateType]				= ''			 
	--FROM
	--	tblARInvoice A
	--LEFT JOIN 
	--	tblARCustomer C
	--		ON A.[intEntityCustomerId] = C.[intEntityId] 			
	--WHERE
	--	A.intInvoiceId = @InvoiceId
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
        ,[dtmDateEntered]               = I.[dtmPostDate]
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
        I.[intInvoiceId] = @InvoiceId


	UNION ALL
	----CREDIT Deferred Revenue
	--SELECT
	--	 dtmDate					= CAST(ISNULL(A.dtmPostDate, A.dtmDate) AS DATE)
	--	,strBatchID					= @BatchId
	--	,intAccountId				= @DeferredRevenueAccountId
	--	,dblDebit					= CASE WHEN A.strTransactionType  IN ('Invoice', 'Cash') THEN  @ZeroDecimal ELSE A.dblBaseInvoiceTotal + BASEDT.dblDiscountTotal END
	--	,dblCredit					= CASE WHEN A.strTransactionType  IN ('Invoice', 'Cash') THEN  A.dblBaseInvoiceTotal + BASEDT.dblDiscountTotal ELSE @ZeroDecimal END
	--	,dblDebitUnit				= CASE WHEN A.strTransactionType  IN ('Invoice', 'Cash') THEN  @ZeroDecimal
	--																				ELSE
	--																					(
	--																					SELECT
	--																						SUM(ISNULL([dbo].[fnCalculateQtyBetweenUOM](ARID.intItemUOMId, ICIS.intStockUOMId, ARID.dblQtyShipped),ISNULL(ARID.dblQtyShipped, @ZeroDecimal)))
	--																					FROM
	--																						tblARInvoiceDetail ARID 
	--																					INNER JOIN
	--																						tblARInvoice ARI
	--																							ON ARID.intInvoiceId = ARI.intInvoiceId	
	--																					LEFT OUTER JOIN
	--																						tblICItem I
	--																							ON ARID.intItemId = I.intItemId
	--																					LEFT OUTER JOIN
	--																						@ItemAccounts IST
	--																							ON ARID.intItemId = IST.intItemId 
	--																							AND ARI.intCompanyLocationId = IST.intLocationId 
	--																					LEFT OUTER JOIN
	--																						vyuICGetItemStock ICIS
	--																							ON ARID.intItemId = ICIS.intItemId 
	--																							AND ARI.intCompanyLocationId = ICIS.intLocationId 
	--																					WHERE
	--																						ARI.intInvoiceId = A.intInvoiceId
	--																						AND ARID.dblTotal <> @ZeroDecimal  
	--																					)
	--																				END
	--	,dblCreditUnit				=  CASE WHEN A.strTransactionType  IN ('Invoice', 'Cash') THEN (
	--																					SELECT
	--																						SUM(ISNULL([dbo].[fnCalculateQtyBetweenUOM](ARID.intItemUOMId, ICIS.intStockUOMId, ARID.dblQtyShipped),ISNULL(ARID.dblQtyShipped, @ZeroDecimal)))
	--																					FROM
	--																						tblARInvoiceDetail ARID
	--																					INNER JOIN
	--																						tblARInvoice ARI 
	--																							ON ARID.intInvoiceId = ARI.intInvoiceId	
	--																					LEFT OUTER JOIN
	--																						tblICItem I
	--																							ON ARID.intItemId = I.intItemId
	--																					LEFT OUTER JOIN
	--																						@ItemAccounts IST
	--																							ON ARID.intItemId = IST.intItemId 
	--																							AND ARI.intCompanyLocationId = IST.intLocationId 
	--																					LEFT OUTER JOIN
	--																						vyuICGetItemStock ICIS
	--																							ON ARID.intItemId = ICIS.intItemId 
	--																							AND ARI.intCompanyLocationId = ICIS.intLocationId 
	--																					WHERE
	--																						ARI.intInvoiceId = A.intInvoiceId 
	--																						AND ARID.dblTotal <> @ZeroDecimal
	--																					)																						
	--																				ELSE
	--																					@ZeroDecimal
	--																				END				
	--	,strDescription				= A.strComments
	--	,strCode					= @CODE
	--	,strReference				= C.strCustomerNumber
	--	,intCurrencyId				= A.intCurrencyId 
	--	,dblExchangeRate			= A.dblCurrencyExchangeRate
	--	,dtmDateEntered				= @PostDate 
	--	,dtmTransactionDate			= A.dtmDate
	--	,strJournalLineDescription	= 'Posted ' + A.strTransactionType 
	--	,intJournalLineNo			= A.intInvoiceId
	--	,ysnIsUnposted				= 0
	--	,intUserId					= @UserId
	--	,intEntityId				= @UserEntityId 				
	--	,strTransactionId			= A.strInvoiceNumber
	--	,intTransactionId			= A.intInvoiceId
	--	,strTransactionType			= A.strTransactionType
	--	,strTransactionForm			= @SCREEN_NAME 
	--	,strModuleName				= @MODULE_NAME 
	--	,intConcurrencyId			= 1
	--	,[dblDebitForeign]			= CASE WHEN A.strTransactionType  IN ('Invoice', 'Cash') THEN  @ZeroDecimal ELSE A.dblInvoiceTotal + DT.dblDiscountTotal END
	--	,[dblDebitReport]			= CASE WHEN A.strTransactionType  IN ('Invoice', 'Cash') THEN  @ZeroDecimal ELSE A.dblInvoiceTotal + DT.dblDiscountTotal END	
	--	,[dblCreditForeign]			= CASE WHEN A.strTransactionType  IN ('Invoice', 'Cash') THEN  A.dblInvoiceTotal + DT.dblDiscountTotal ELSE @ZeroDecimal END
	--	,[dblCreditReport]			= CASE WHEN A.strTransactionType  IN ('Invoice', 'Cash') THEN  A.dblInvoiceTotal + DT.dblDiscountTotal ELSE @ZeroDecimal END
	--	,[dblReportingRate]			= A.dblCurrencyExchangeRate
	--	,[dblForeignRate]			= A.dblCurrencyExchangeRate
	--	,[strRateType]				= ''				 
	--FROM
	--	tblARInvoice A
	--LEFT JOIN 
	--	tblARCustomer C
	--		ON A.[intEntityCustomerId] = C.[intEntityId] 		
	--LEFT OUTER	JOIN
	--	(
	--		SELECT 
	--			 intInvoiceId		= intInvoiceId
	--			,dblDiscountTotal	= SUM(ISNULL([dbo].fnRoundBanker(((dblDiscount/100.00) * [dbo].fnRoundBanker((dblQtyShipped * dblPrice), dbo.fnARGetDefaultDecimal())), dbo.fnARGetDefaultDecimal()), @ZeroDecimal))
	--		FROM
	--			tblARInvoiceDetail
	--		GROUP BY
	--			intInvoiceId 
	--	)  DT
	--		ON A.intInvoiceId = DT.intInvoiceId
	--LEFT OUTER	JOIN
	--	(
	--		SELECT 
	--			 intInvoiceId		= intInvoiceId
	--			,dblDiscountTotal	= SUM(ISNULL([dbo].fnRoundBanker(((dblDiscount/100.00) * [dbo].fnRoundBanker((dblQtyShipped * dblBasePrice), dbo.fnARGetDefaultDecimal())), dbo.fnARGetDefaultDecimal()), @ZeroDecimal))
	--		FROM
	--			tblARInvoiceDetail
	--		GROUP BY
	--			intInvoiceId 
	--	)  BASEDT
	--		ON A.intInvoiceId = BASEDT.intInvoiceId
	--WHERE
	--	A.intInvoiceId = @InvoiceId
    SELECT
         [dtmDate]                      = CAST(ISNULL(I.[dtmPostDate], I.[dtmDate]) AS DATE)
        ,[strBatchId]                   = I.[strBatchId]
        ,[intAccountId]                 = I.[intDeferredRevenueAccountId]
        ,[dblDebit]                     = CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN @ZeroDecimal ELSE I.[dblBaseInvoiceTotal] + ARID.[dblBaseDiscountAmount] END
        ,[dblCredit]                    = CASE WHEN I.[ysnIsInvoicePositive] = 0 THEN @ZeroDecimal ELSE I.[dblBaseInvoiceTotal] + ARID.[dblBaseDiscountAmount] END
        ,[dblDebitUnit]                 = CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN @ZeroDecimal ELSE ARID.[dblUnitQtyShipped] END
        ,[dblCreditUnit]                = CASE WHEN I.[ysnIsInvoicePositive] = 0 THEN @ZeroDecimal ELSE ARID.[dblUnitQtyShipped] END
        ,[strDescription]               = I.[strDescription]
        ,[strCode]                      = @CODE
        ,[strReference]                 = I.[strCustomerNumber]
        ,[intCurrencyId]                = I.[intCurrencyId]
        ,[dblExchangeRate]              = I.[dblAverageExchangeRate]
        ,[dtmDateEntered]               = I.[dtmPostDate]
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
        ,[dblDebitForeign]              = CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN @ZeroDecimal ELSE I.[dblInvoiceTotal] + ARID.[dblDiscountAmount] END
        ,[dblDebitReport]               = CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN @ZeroDecimal ELSE I.[dblInvoiceTotal] + ARID.[dblDiscountAmount] END
        ,[dblCreditForeign]             = CASE WHEN I.[ysnIsInvoicePositive] = 0 THEN @ZeroDecimal ELSE I.[dblInvoiceTotal] + ARID.[dblDiscountAmount] END
        ,[dblCreditReport]              = CASE WHEN I.[ysnIsInvoicePositive] = 0 THEN @ZeroDecimal ELSE I.[dblInvoiceTotal] + ARID.[dblDiscountAmount] END
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
             [dblUnitQtyShipped]        = SUM([dblUnitQtyShipped])
            ,[dblDiscountAmount]        = SUM([dblDiscountAmount])
            ,[dblBaseDiscountAmount]    = SUM([dblBaseDiscountAmount])
            ,[intInvoiceId]             = [intInvoiceId]
        FROM
            #ARPostInvoiceDetail
        GROUP BY
            [intInvoiceId]
        ) ARID
            ON I.[intInvoiceId] = ARID.[intInvoiceId]
    WHERE
        I.[intInvoiceId] = @InvoiceId
		
		
		 
    DECLARE @InvoiceDetail AS TABLE(intInvoiceId INT, intInvoiceDetailId INT, dblTotal DECIMAL(18,6), dblDiscount DECIMAL(18,6), dblQtyShipped DECIMAL(18,6), dblPrice DECIMAL(18,6), dblUnits DECIMAL(18,6), dblMaintenanceAmount DECIMAL(18,6), dblLicenseAmount DECIMAL(18,6), strMaintenanceType NVARCHAR(25))
    DELETE FROM @InvoiceDetail
    INSERT INTO @InvoiceDetail
        (intInvoiceId
        ,intInvoiceDetailId
        ,dblTotal
        ,dblUnits
        ,dblDiscount
        ,dblQtyShipped
        ,dblPrice
        ,dblMaintenanceAmount
        ,dblLicenseAmount
        ,strMaintenanceType)
    --SELECT
    --	 intInvoiceId			= ARI.intInvoiceId
    --	,intInvoiceDetailId		= ARID.intInvoiceDetailId
    --	,dblTotal				= ARID.dblTotal
    --	,dblUnits				= ISNULL([dbo].[fnCalculateQtyBetweenUOM](ARID.intItemUOMId, ICIS.intStockUOMId, ARID.dblQtyShipped),ISNULL(ARID.dblQtyShipped, @ZeroDecimal))
    --	,dblDiscount			= ARID.dblDiscount 
    --	,dblQtyShipped			= ARID.dblQtyShipped
    --	,dblPrice				= ARID.dblPrice
    --	,dblMaintenanceAmount	= @ZeroDecimal
    --	,dblLicenseAmount		= @ZeroDecimal
    --	,strMaintenanceType		= ARID.strMaintenanceType
    --FROM
    --	tblARInvoiceDetail ARID
    --INNER JOIN
    --	 tblARInvoice ARI
    --		ON ARI.intInvoiceId = ARID.intInvoiceId	
    --LEFT OUTER JOIN
    --	vyuICGetItemStock ICIS
    --		ON ARID.intItemId = ICIS.intItemId 
    --		AND ARI.intCompanyLocationId = ICIS.intLocationId 	
    --WHERE
    --	ARI.intInvoiceId = @InvoiceId 
    --	AND ARID.dblTotal <> @ZeroDecimal 
    --	AND ((ARID.intItemId IS NULL OR ARID.intItemId = 0)
    --		OR (EXISTS(SELECT NULL FROM tblICItem WHERE intItemId = ARID.intItemId AND strType IN ('Non-Inventory','Service','Other Charge'))))
    --	AND ARI.strType <> 'Debit Memo'
    --ORDER BY
    --	ARI.intInvoiceId
    --	,ARID.intInvoiceDetailId
    SELECT
         [intInvoiceId]         = ARID.[intInvoiceId]
        ,[intInvoiceDetailId]   = ARID.[intInvoiceDetailId]
        ,[dblTotal]             = ARID.[dblTotal]
        ,[dblUnits]             = ISNULL(ARID.[dblUnitQtyShipped], ISNULL(ARID.[dblQtyShipped], @ZeroDecimal))
        ,[dblDiscount]          = ARID.[dblDiscount] 
        ,[dblQtyShipped]        = ARID.[dblQtyShipped]
        ,[dblPrice]             = ARID.[dblPrice]
        ,[dblMaintenanceAmount] = @ZeroDecimal
        ,[dblLicenseAmount]     = @ZeroDecimal
        ,[strMaintenanceType]   = ARID.[strMaintenanceType]
    FROM
        #ARPostInvoiceDetail ARID
    WHERE
        ARID.[intInvoiceId] = @InvoiceId
        AND ARID.[dblTotal] <> @ZeroDecimal 
        AND (
            ARID.[intItemId] IS NULL
            OR
            ARID.[strItemType] IN ('Non-Inventory','Service','Other Charge')
            )
        AND ARID.[strTransactionType] <> 'Debit Memo'
    ORDER BY
        ARID.[intInvoiceDetailId]


    --License/Maintenance
    INSERT INTO @InvoiceDetail
        ([intInvoiceId]
        ,[intInvoiceDetailId]
        ,[dblTotal]
        ,[dblUnits]
        ,[dblDiscount]
        ,[dblQtyShipped]
        ,[dblPrice]
        ,[dblMaintenanceAmount]
        ,[dblLicenseAmount]
        ,[strMaintenanceType])
    --SELECT
    --	 intInvoiceId			= ARI.intInvoiceId
    --	,intInvoiceDetailId		= ARID.intInvoiceDetailId
    --	,dblTotal				= ARID.dblTotal
    --	,dblUnits				= ISNULL([dbo].[fnCalculateQtyBetweenUOM](ARID.intItemUOMId, ICIS.intStockUOMId, ARID.dblQtyShipped),ISNULL(ARID.dblQtyShipped, @ZeroDecimal))
    --	,dblDiscount			= ARID.dblDiscount 
    --	,dblQtyShipped			= ARID.dblQtyShipped
    --	,dblPrice				= ARID.dblPrice
    --	,dblMaintenanceAmount	= ARID.dblMaintenanceAmount
    --	,dblLicenseAmount		= CASE WHEN @AccrueLicense = 1 THEN ARID.dblLicenseAmount ELSE @ZeroDecimal END
    --	,strMaintenanceType		= ARID.strMaintenanceType
    --FROM
    --	tblARInvoiceDetail ARID
    --INNER JOIN
    --	 tblARInvoice ARI
    --		ON ARI.intInvoiceId = ARID.intInvoiceId
    --INNER JOIN
    --	tblICItem ICI
    --		ON ARID.intItemId = ICI.intItemId 	
    --LEFT OUTER JOIN
    --	vyuICGetItemStock ICIS
    --		ON ARID.intItemId = ICIS.intItemId 
    --		AND ARI.intCompanyLocationId = ICIS.intLocationId 	
    --WHERE
    --	ARI.intInvoiceId = @InvoiceId 
    --	AND (ARID.dblLicenseAmount <> @ZeroDecimal OR ARID.dblMaintenanceAmount <> @ZeroDecimal)
    --	AND ARID.strMaintenanceType = 'License/Maintenance'
    --	AND ICI.strType = 'Software'
    --	AND ARI.strType <> 'Debit Memo'
    --	--AND @AccrueLicense = 1
    --ORDER BY
    --	ARI.intInvoiceId
    --	,ARID.intInvoiceDetailId
    SELECT
         [intInvoiceId]         = ARID.[intInvoiceId]
        ,[intInvoiceDetailId]   = ARID.[intInvoiceDetailId]
        ,[dblTotal]             = ARID.[dblTotal]
        ,[dblUnits]             = ISNULL(ARID.[dblUnitQtyShipped], ISNULL(ARID.[dblQtyShipped], @ZeroDecimal))
        ,[dblDiscount]          = ARID.[dblDiscount] 
        ,[dblQtyShipped]        = ARID.[dblQtyShipped]
        ,[dblPrice]             = ARID.[dblPrice]
        ,[dblMaintenanceAmount] = ARID.[dblMaintenanceAmount]
        ,[dblLicenseAmount]     = CASE WHEN ARID.[ysnAccrueLicense] = 1 THEN ARID.[dblLicenseAmount] ELSE @ZeroDecimal END
        ,[strMaintenanceType]   = ARID.[strMaintenanceType]
    FROM
        #ARPostInvoiceDetail ARID
    WHERE
        ARID.[intInvoiceId] = @InvoiceId 
        AND (ARID.[dblLicenseAmount] <> @ZeroDecimal OR ARID.[dblMaintenanceAmount] <> @ZeroDecimal) 
        AND ARID.strMaintenanceType = 'License/Maintenance'
        AND ARID.[intItemId] IS NOT NULL
        AND ARID.[strItemType] = 'Software'
        AND ARID.[strTransactionType] <> 'Debit Memo'
    ORDER BY
    ARID.[intInvoiceDetailId]


    --License
    INSERT INTO @InvoiceDetail
        ([intInvoiceId]
        ,[intInvoiceDetailId]
        ,[dblTotal]
        ,[dblUnits]
        ,[dblDiscount]
        ,[dblQtyShipped]
        ,[dblPrice]
        ,[dblMaintenanceAmount]
        ,[dblLicenseAmount]
        ,[strMaintenanceType])
    --SELECT
    --	 intInvoiceId			= ARI.intInvoiceId
    --	,intInvoiceDetailId		= ARID.intInvoiceDetailId
    --	,dblTotal				= ARID.dblTotal
    --	,dblUnits				= ISNULL([dbo].[fnCalculateQtyBetweenUOM](ARID.intItemUOMId, ICIS.intStockUOMId, ARID.dblQtyShipped),ISNULL(ARID.dblQtyShipped, @ZeroDecimal))
    --	,dblDiscount			= ARID.dblDiscount 
    --	,dblQtyShipped			= ARID.dblQtyShipped
    --	,dblPrice				= ARID.dblPrice
    --	,dblMaintenanceAmount	= @ZeroDecimal
    --	,dblLicenseAmount		= ARID.dblLicenseAmount
    --	,strMaintenanceType		= ARID.strMaintenanceType
    --FROM
    --	tblARInvoiceDetail ARID
    --INNER JOIN
    --	 tblARInvoice ARI
    --		ON ARI.intInvoiceId = ARID.intInvoiceId
    --INNER JOIN
    --	tblICItem ICI
    --		ON ARID.intItemId = ICI.intItemId 	
    --LEFT OUTER JOIN
    --	vyuICGetItemStock ICIS
    --		ON ARID.intItemId = ICIS.intItemId 
    --		AND ARI.intCompanyLocationId = ICIS.intLocationId 	
    --WHERE
    --	ARI.intInvoiceId = @InvoiceId 
    --	AND ARID.dblLicenseAmount <> @ZeroDecimal 
    --	AND ARID.strMaintenanceType = 'License Only'
    --	AND ICI.strType = 'Software'
    --	AND ARI.strType <> 'Debit Memo'
    --	AND @AccrueLicense = 1
    --ORDER BY
    --	ARI.intInvoiceId
    --	,ARID.intInvoiceDetailId
    SELECT
         [intInvoiceId]         = ARID.[intInvoiceId]
        ,[intInvoiceDetailId]   = ARID.[intInvoiceDetailId]
        ,[dblTotal]             = ARID.[dblTotal]
        ,[dblUnits]             = ISNULL(ARID.[dblUnitQtyShipped], ISNULL(ARID.[dblQtyShipped], @ZeroDecimal))
        ,[dblDiscount]          = ARID.[dblDiscount] 
        ,[dblQtyShipped]        = ARID.[dblQtyShipped]
        ,[dblPrice]             = ARID.[dblPrice]
        ,[dblMaintenanceAmount] = @ZeroDecimal
        ,[dblLicenseAmount]     = ARID.[dblLicenseAmount]
        ,[strMaintenanceType]   = ARID.[strMaintenanceType]
    FROM
        #ARPostInvoiceDetail ARID
    WHERE
        ARID.[intInvoiceId] = @InvoiceId 
        AND ARID.[dblLicenseAmount] <> @ZeroDecimal
        AND ARID.strMaintenanceType = 'License Only'
        AND ARID.[ysnAccrueLicense] = 1
        AND ARID.[intItemId] IS NOT NULL
        AND ARID.[strItemType] = 'Software'
        AND ARID.[strTransactionType] <> 'Debit Memo'
    ORDER BY
        ARID.[intInvoiceDetailId]

    -- Maintenance Only/SaaS
    INSERT INTO @InvoiceDetail
        ([intInvoiceId]
        ,[intInvoiceDetailId]
        ,[dblTotal]
        ,[dblUnits]
        ,[dblDiscount]
        ,[dblQtyShipped]
        ,[dblPrice]
        ,[dblMaintenanceAmount]
        ,[dblLicenseAmount]
        ,[strMaintenanceType])
    --SELECT
    --	 intInvoiceId			= ARI.intInvoiceId
    --	,intInvoiceDetailId		= ARID.intInvoiceDetailId
    --	,dblTotal				= ARID.dblTotal
    --	,dblUnits				= ISNULL([dbo].[fnCalculateQtyBetweenUOM](ARID.intItemUOMId, ICIS.intStockUOMId, ARID.dblQtyShipped),ISNULL(ARID.dblQtyShipped, @ZeroDecimal))
    --	,dblDiscount			= ARID.dblDiscount 
    --	,dblQtyShipped			= ARID.dblQtyShipped
    --	,dblPrice				= ARID.dblPrice
    --	,dblMaintenanceAmount	= ARID.dblMaintenanceAmount
    --	,dblLicenseAmount		= @ZeroDecimal
    --	,strMaintenanceType		= ARID.strMaintenanceType
    --FROM
    --	tblARInvoiceDetail ARID
    --INNER JOIN
    --	 tblARInvoice ARI
    --		ON ARI.intInvoiceId = ARID.intInvoiceId
    --INNER JOIN
    --	tblICItem ICI
    --		ON ARID.intItemId = ICI.intItemId 	
    --LEFT OUTER JOIN
    --	vyuICGetItemStock ICIS
    --		ON ARID.intItemId = ICIS.intItemId 
    --		AND ARI.intCompanyLocationId = ICIS.intLocationId 	
    --WHERE
    --	ARI.intInvoiceId = @InvoiceId 
    --	AND ARID.dblMaintenanceAmount <> @ZeroDecimal 
    --	AND ARID.strMaintenanceType IN ('Maintenance Only', 'SaaS')
    --	AND ICI.strType = 'Software'
    --	AND ARI.strType <> 'Debit Memo'
    --ORDER BY
    --	ARI.intInvoiceId
    --	,ARID.intInvoiceDetailId
    SELECT
         [intInvoiceId]         = ARID.[intInvoiceId]
        ,[intInvoiceDetailId]   = ARID.[intInvoiceDetailId]
        ,[dblTotal]             = ARID.[dblTotal]
        ,[dblUnits]             = ISNULL(ARID.[dblUnitQtyShipped], ISNULL(ARID.[dblQtyShipped], @ZeroDecimal))
        ,[dblDiscount]          = ARID.[dblDiscount] 
        ,[dblQtyShipped]        = ARID.[dblQtyShipped]
        ,[dblPrice]             = ARID.[dblPrice]
        ,[dblMaintenanceAmount] = ARID.[dblMaintenanceAmount]
        ,[dblLicenseAmount]     = @ZeroDecimal
        ,[strMaintenanceType]   = ARID.[strMaintenanceType]
    FROM
        #ARPostInvoiceDetail ARID
    WHERE
        ARID.[intInvoiceId] = @InvoiceId 
        AND ARID.[dblMaintenanceAmount] <> @ZeroDecimal
        AND ARID.strMaintenanceType  IN ('Maintenance Only', 'SaaS')
        AND ARID.[ysnAccrueLicense] = 1
        AND ARID.[intItemId] IS NOT NULL
        AND ARID.[strItemType] = 'Software'
        AND ARID.[strTransactionType] <> 'Debit Memo'
    ORDER BY
        ARID.[intInvoiceDetailId]


WHILE EXISTS(SELECT TOP 1 NULL FROM @InvoiceDetail)
BEGIN
	DECLARE @InvoiceDetailId					INT
			,@Total								DECIMAL(18,6)
			,@TotalPerPeriod					DECIMAL(18,6)			
			,@TotalWODiscount					DECIMAL(18,6)
			,@TotalPerPeriodWODiscount			DECIMAL(18,6)
			,@LicenseTotal						DECIMAL(18,6)
			,@LicenseTotalPerPeriod				DECIMAL(18,6)			
			,@LicenseTotalWODiscount			DECIMAL(18,6)
			,@LicenseTotalPeriodWODiscount		DECIMAL(18,6)
			,@MaintenanceTotal					DECIMAL(18,6)
			,@MaintenanceTotalPerPeriod			DECIMAL(18,6)			
			,@MaintenanceTotalWODiscount		DECIMAL(18,6)
			,@MaintenanceTotalPeriodWODiscount	DECIMAL(18,6)
			,@UnitsTotal						DECIMAL(18,6)
			,@UnitsPerPeriod					DECIMAL(18,6)
			,@MaintenanceType					NVARCHAR(25)

	SET @Remainder = @ZeroDecimal
	SET @RemainderWODiscount = @ZeroDecimal
	SET @LicenseRemainder = @ZeroDecimal
	SET @LicenseRemainderWODiscount = @ZeroDecimal
	SET @MaintenanceRemainder = @ZeroDecimal
	SET @MaintenanceRemainderWODiscount = @ZeroDecimal
	SET @UnitsRemainder = @ZeroDecimal

	SELECT TOP 1 
		 @InvoiceDetailId				= intInvoiceDetailId
		,@Total							= ISNULL(dblTotal, @ZeroDecimal) + [dbo].fnRoundBanker(((dblDiscount/100.00) * [dbo].fnRoundBanker((dblQtyShipped * dblPrice), dbo.fnARGetDefaultDecimal())), dbo.fnARGetDefaultDecimal())
		,@TotalWODiscount				= dblTotal
		,@LicenseTotal					= CASE WHEN strMaintenanceType IN ('Maintenance Only', 'SaaS', 'License Only') THEN ISNULL(dblTotal, @ZeroDecimal) + [dbo].fnRoundBanker(((dblDiscount/100.00) * [dbo].fnRoundBanker((dblQtyShipped * dblPrice), dbo.fnARGetDefaultDecimal())), dbo.fnARGetDefaultDecimal()) ELSE [dbo].fnRoundBanker(dblTotal * ([dbo].fnRoundBanker(100.000000 - [dbo].fnRoundBanker(((ISNULL(dblMaintenanceAmount, @ZeroDecimal) * dblQtyShipped) / dblTotal) * 100.000000, dbo.fnARGetDefaultDecimal()), dbo.fnARGetDefaultDecimal())/ 100.000000), dbo.fnARGetDefaultDecimal()) END
		,@LicenseTotalWODiscount		= CASE WHEN strMaintenanceType IN ('Maintenance Only', 'SaaS', 'License Only') THEN dblTotal ELSE [dbo].fnRoundBanker(dblTotal * ([dbo].fnRoundBanker(100.000000 - [dbo].fnRoundBanker(((ISNULL(dblMaintenanceAmount, @ZeroDecimal) * dblQtyShipped) / dblTotal) * 100.000000, dbo.fnARGetDefaultDecimal()), dbo.fnARGetDefaultDecimal())/ 100.000000), dbo.fnARGetDefaultDecimal()) END --+ [dbo].fnRoundBanker(([dbo].fnRoundBanker(((dblDiscount/100.00) * [dbo].fnRoundBanker((dblQtyShipped * dblPrice), dbo.fnARGetDefaultDecimal())), dbo.fnARGetDefaultDecimal())) * ([dbo].fnRoundBanker(100.000000 - [dbo].fnRoundBanker(((ISNULL(dblMaintenanceAmount, @ZeroDecimal) * dblQtyShipped) / dblTotal) * 100.000000, dbo.fnARGetDefaultDecimal()), dbo.fnARGetDefaultDecimal())/ 100.000000), dbo.fnARGetDefaultDecimal())
		,@MaintenanceTotal				= CASE WHEN strMaintenanceType IN ('Maintenance Only', 'SaaS', 'License Only') THEN ISNULL(dblTotal, @ZeroDecimal) + [dbo].fnRoundBanker(((dblDiscount/100.00) * [dbo].fnRoundBanker((dblQtyShipped * dblPrice), dbo.fnARGetDefaultDecimal())), dbo.fnARGetDefaultDecimal()) ELSE [dbo].fnRoundBanker(dblTotal * ([dbo].fnRoundBanker(((ISNULL(dblMaintenanceAmount, @ZeroDecimal) * dblQtyShipped) / dblTotal) * 100.000000, dbo.fnARGetDefaultDecimal())/ 100.000000), dbo.fnARGetDefaultDecimal()) END
		,@MaintenanceTotalWODiscount	= CASE WHEN strMaintenanceType IN ('Maintenance Only', 'SaaS', 'License Only') THEN dblTotal ELSE [dbo].fnRoundBanker(dblTotal * ([dbo].fnRoundBanker(((ISNULL(dblMaintenanceAmount, @ZeroDecimal) * dblQtyShipped) / dblTotal) * 100.000000, dbo.fnARGetDefaultDecimal())/ 100.000000), dbo.fnARGetDefaultDecimal()) END --+ [dbo].fnRoundBanker(([dbo].fnRoundBanker(((dblDiscount/100.00) * [dbo].fnRoundBanker((dblQtyShipped * dblPrice), dbo.fnARGetDefaultDecimal())), dbo.fnARGetDefaultDecimal())) * ([dbo].fnRoundBanker(((ISNULL(dblMaintenanceAmount, @ZeroDecimal) * dblQtyShipped) / dblTotal) * 100.000000, dbo.fnARGetDefaultDecimal())/ 100.000000), dbo.fnARGetDefaultDecimal())
		,@UnitsTotal					= dblUnits
		--,@MaintenanceType				= strMaintenanceType
	FROM 
		@InvoiceDetail
		
	SET @Remainder = @ZeroDecimal
	SET @RemainderWODiscount = @ZeroDecimal
	SET @LicenseRemainder = @ZeroDecimal
	SET @LicenseRemainderWODiscount = @ZeroDecimal
	SET @MaintenanceRemainder = @ZeroDecimal
	SET @MaintenanceRemainderWODiscount = @ZeroDecimal
	SET @UnitsRemainder = @ZeroDecimal
	
	SET @TotalPerPeriod = [dbo].fnRoundBanker((@Total/@AccrualPeriod), dbo.fnARGetDefaultDecimal())
	SET @Remainder = [dbo].fnRoundBanker(@Total, dbo.fnARGetDefaultDecimal()) - [dbo].fnRoundBanker((@TotalPerPeriod * @AccrualPeriod), dbo.fnARGetDefaultDecimal())
	SET @TotalPerPeriodWODiscount = [dbo].fnRoundBanker((@TotalWODiscount/@AccrualPeriod), dbo.fnARGetDefaultDecimal())
	SET @RemainderWODiscount = [dbo].fnRoundBanker(@TotalWODiscount, dbo.fnARGetDefaultDecimal()) - [dbo].fnRoundBanker((@TotalPerPeriodWODiscount * @AccrualPeriod), dbo.fnARGetDefaultDecimal())

	SET @LicenseTotalPerPeriod = [dbo].fnRoundBanker((@LicenseTotal/@AccrualPeriod), dbo.fnARGetDefaultDecimal())
	SET @LicenseRemainder = [dbo].fnRoundBanker(@LicenseTotal, dbo.fnARGetDefaultDecimal()) - [dbo].fnRoundBanker((@LicenseTotalPerPeriod * @AccrualPeriod), dbo.fnARGetDefaultDecimal())
	SET @LicenseTotalPeriodWODiscount = [dbo].fnRoundBanker((@LicenseTotalWODiscount/@AccrualPeriod), dbo.fnARGetDefaultDecimal())
	SET @LicenseRemainderWODiscount = [dbo].fnRoundBanker(@LicenseTotalWODiscount, dbo.fnARGetDefaultDecimal()) - [dbo].fnRoundBanker((@LicenseTotalPeriodWODiscount * @AccrualPeriod), dbo.fnARGetDefaultDecimal())


	SET @MaintenanceTotalPerPeriod = [dbo].fnRoundBanker((@MaintenanceTotal/@AccrualPeriod), dbo.fnARGetDefaultDecimal())
	SET @MaintenanceRemainder = [dbo].fnRoundBanker(@MaintenanceTotal, dbo.fnARGetDefaultDecimal()) - [dbo].fnRoundBanker((@MaintenanceTotalPerPeriod * @AccrualPeriod), dbo.fnARGetDefaultDecimal())
	SET @MaintenanceTotalPeriodWODiscount = [dbo].fnRoundBanker((@MaintenanceTotalWODiscount/@AccrualPeriod), dbo.fnARGetDefaultDecimal())
	SET @MaintenanceRemainderWODiscount = [dbo].fnRoundBanker(@MaintenanceTotalWODiscount, dbo.fnARGetDefaultDecimal()) - [dbo].fnRoundBanker((@MaintenanceTotalPeriodWODiscount * @AccrualPeriod), dbo.fnARGetDefaultDecimal())

	SET @UnitsPerPeriod = [dbo].fnRoundBanker((@UnitsTotal/@AccrualPeriod),6)
	SET @UnitsRemainder = [dbo].fnRoundBanker(@UnitsTotal,6) - [dbo].fnRoundBanker((@UnitsPerPeriod * @AccrualPeriod),6)
	SET @LoopCounter = 0		

	------WHILE @LoopCounter < @AccrualPeriod
	------BEGIN
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
		--DEBIT Deffered Revenue	
		--SELECT
		--	 dtmDate					= Accrual.dtmAccrualDate
		--	,strBatchID					= @BatchId
		--	,intAccountId				= @DeferredRevenueAccountId
		--	,dblDebit					= [dbo].fnRoundBanker(((CASE WHEN A.strTransactionType  IN ('Invoice', 'Cash') THEN Accrual.dblAmount ELSE @ZeroDecimal END)
		--									* B.dblCurrencyExchangeRate), [dbo].[fnARGetDefaultDecimal]())
		--	,dblCredit					= [dbo].fnRoundBanker(((CASE WHEN A.strTransactionType  IN ('Invoice', 'Cash') THEN @ZeroDecimal ELSE Accrual.dblAmount END)
		--									* B.dblCurrencyExchangeRate), [dbo].[fnARGetDefaultDecimal]())
		--	,dblDebitUnit				= @ZeroDecimal
		--	,dblCreditUnit				= @ZeroDecimal
		--	,strDescription				= A.strComments
		--	,strCode					= @CODE
		--	,strReference				= C.strCustomerNumber
		--	,intCurrencyId				= A.intCurrencyId 
		--	,dblExchangeRate			= B.dblCurrencyExchangeRate
		--	,dtmDateEntered				= @PostDate
		--	,dtmTransactionDate			= A.dtmDate
		--	,strJournalLineDescription	= B.strItemDescription 
		--	,intJournalLineNo			= B.intInvoiceDetailId
		--	,ysnIsUnposted				= 0
		--	,intUserId					= @UserId
		--	,intEntityId				= @UserEntityId 			
		--	,strTransactionId			= A.strInvoiceNumber
		--	,intTransactionId			= A.intInvoiceId
		--	,strTransactionType			= A.strTransactionType
		--	,strTransactionForm			= @SCREEN_NAME 
		--	,strModuleName				= @MODULE_NAME 
		--	,intConcurrencyId			= 1
		--	,[dblDebitForeign]			= CASE WHEN A.strTransactionType  IN ('Invoice', 'Cash') THEN Accrual.dblAmount ELSE @ZeroDecimal END
		--	,[dblDebitReport]			= CASE WHEN A.strTransactionType  IN ('Invoice', 'Cash') THEN Accrual.dblAmount ELSE @ZeroDecimal END
		--	,[dblCreditForeign]			= CASE WHEN A.strTransactionType  IN ('Invoice', 'Cash') THEN @ZeroDecimal ELSE Accrual.dblAmount END
		--	,[dblCreditReport]			= CASE WHEN A.strTransactionType  IN ('Invoice', 'Cash') THEN @ZeroDecimal ELSE Accrual.dblAmount END
		--	,[dblReportingRate]			= B.dblCurrencyExchangeRate
		--	,[dblForeignRate]			= B.dblCurrencyExchangeRate
		--	,[strRateType]				= SMCERT.strCurrencyExchangeRateType 
		--FROM
		--	tblARInvoice A 
		--LEFT JOIN
		--	tblARInvoiceDetail B
		--		ON A.intInvoiceId = B.intInvoiceId
		--LEFT JOIN 
		--	tblARCustomer C
		--		ON A.[intEntityCustomerId] = C.[intEntityId]		
		--LEFT OUTER JOIN
		--	@ItemAccounts IST
		--		ON B.intItemId = IST.intItemId 
		--		AND A.intCompanyLocationId = IST.intLocationId
		--LEFT OUTER JOIN
		--	vyuICGetItemStock ICIS
		--		ON B.intItemId = ICIS.intItemId 
		--		AND B.intItemUOMId = ICIS.intStockUOMId
		--		AND A.intCompanyLocationId = ICIS.intLocationId
		--LEFT OUTER JOIN
		--	tblSMCurrencyExchangeRateType SMCERT
		--		ON B.intCurrencyExchangeRateTypeId = SMCERT.intCurrencyExchangeRateTypeId
		--LEFT OUTER JOIN 
		--	tblARInvoiceAccrual Accrual
		--		ON Accrual.intInvoiceDetailId = B.intInvoiceDetailId
		--WHERE
		--	A.intInvoiceId = @InvoiceId 
		--	AND B.intInvoiceDetailId = @InvoiceDetailId
		--	AND B.dblTotal <> @ZeroDecimal 
		--	AND ((B.intItemId IS NULL OR B.intItemId = 0)
		--		OR (EXISTS(SELECT NULL FROM tblICItem WHERE intItemId = B.intItemId AND strType IN ('Non-Inventory','Service','Other Charge'))))
		--	AND A.strType <> 'Debit Memo'
        SELECT
             [dtmDate]                      = ARIA.[dtmAccrualDate]
            ,[strBatchId]                   = I.[strBatchId]
            ,[intAccountId]                 = I.[intDeferredRevenueAccountId]
            ,[dblDebit]                     = [dbo].fnRoundBanker(((CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN ARIA.[dblAmount] ELSE @ZeroDecimal END) * I.[dblCurrencyExchangeRate]), [dbo].[fnARGetDefaultDecimal]())
            ,[dblCredit]                    = [dbo].fnRoundBanker(((CASE WHEN I.[ysnIsInvoicePositive] = 0 THEN ARIA.[dblAmount] ELSE @ZeroDecimal END) * I.[dblCurrencyExchangeRate]), [dbo].[fnARGetDefaultDecimal]())
            ,[dblDebitUnit]                 = @ZeroDecimal
            ,[dblCreditUnit]                = @ZeroDecimal
            ,[strDescription]               = I.[strComments]
            ,[strCode]                      = @CODE
            ,[strReference]                 = I.[strCustomerNumber]
            ,[intCurrencyId]                = I.[intCurrencyId]
            ,[dblExchangeRate]              = I.[dblCurrencyExchangeRate]
            ,[dtmDateEntered]               = I.[dtmPostDate]
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
            ,[dblDebitForeign]              = [dbo].fnRoundBanker((CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN ARIA.[dblAmount] ELSE @ZeroDecimal END), [dbo].[fnARGetDefaultDecimal]())
            ,[dblDebitReport]               = [dbo].fnRoundBanker((CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN ARIA.[dblAmount] ELSE @ZeroDecimal END), [dbo].[fnARGetDefaultDecimal]())
            ,[dblCreditForeign]             = [dbo].fnRoundBanker((CASE WHEN I.[ysnIsInvoicePositive] = 0 THEN ARIA.[dblAmount] ELSE @ZeroDecimal END), [dbo].[fnARGetDefaultDecimal]())
            ,[dblCreditReport]              = [dbo].fnRoundBanker((CASE WHEN I.[ysnIsInvoicePositive] = 0 THEN ARIA.[dblAmount] ELSE @ZeroDecimal END), [dbo].[fnARGetDefaultDecimal]())
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
            tblARInvoiceAccrual ARIA
                ON I.[intInvoiceDetailId] = ARIA.[intInvoiceDetailId]
        WHERE
            I.[intInvoiceDetailId] = @InvoiceDetailId
            --AND I.[intInvoiceId] = @InvoiceId
            --AND I.[intInvoiceDetailId] IS NOT NULL
            AND I.[dblTotal] <> @ZeroDecimal
            AND (
                I.[intItemId] IS NULL
                OR
                I.[strItemType] IN ('Non-Inventory','Service','Other Charge')
                )
            AND I.[strTransactionType] <> 'Debit Memo'

		UNION ALL
		--CREDIT	
		--SELECT
		--	 dtmDate					= Accrual.dtmAccrualDate
		--	,strBatchID					= @BatchId
		--	,intAccountId				= (CASE WHEN (EXISTS(SELECT NULL FROM tblICItem WHERE intItemId = B.intItemId AND strType IN ('Non-Inventory','Service'))) 
		--										THEN
		--											IST.intGeneralAccountId												
		--										WHEN (EXISTS(SELECT NULL FROM tblICItem WHERE intItemId = B.intItemId AND strType = 'Other Charge')) 
		--										THEN
		--											IST.intOtherChargeIncomeAccountId
		--										ELSE
		--											ISNULL(ISNULL(B.intServiceChargeAccountId, B.intSalesAccountId), SMCL.intSalesAccount)
		--									END)
		--	,dblDebit					= [dbo].fnRoundBanker(((CASE WHEN @AccrualPeriod > 1 
		--									THEN 
		--										CASE WHEN A.strTransactionType IN ('Invoice', 'Cash') THEN @ZeroDecimal ELSE Accrual.dblAmount END 
		--									ELSE
		--										CASE WHEN A.strTransactionType IN ('Invoice', 'Cash') THEN @ZeroDecimal ELSE Accrual.dblAmount END 
		--								  END) * B.dblCurrencyExchangeRate), [dbo].[fnARGetDefaultDecimal]())
		--	,dblCredit					= [dbo].fnRoundBanker(((CASE WHEN @AccrualPeriod > 1 
		--									THEN 
		--										CASE WHEN A.strTransactionType  IN ('Invoice', 'Cash') THEN Accrual.dblAmount END
		--									ELSE
		--										CASE WHEN A.strTransactionType  IN ('Invoice', 'Cash') THEN @ZeroDecimal ELSE Accrual.dblAmount  END 
		--								  END) * B.dblCurrencyExchangeRate), [dbo].[fnARGetDefaultDecimal]())
		--	,dblDebitUnit				= 0
		--	,dblCreditUnit				= 0
		--	,strDescription				= A.strComments
		--	,strCode					= @CODE
		--	,strReference				= C.strCustomerNumber
		--	,intCurrencyId				= A.intCurrencyId 
		--	,dblExchangeRate			= B.dblCurrencyExchangeRate
		--	,dtmDateEntered				= @PostDate
		--	,dtmTransactionDate			= A.dtmDate
		--	,strJournalLineDescription	= B.strItemDescription 
		--	,intJournalLineNo			= B.intInvoiceDetailId
		--	,ysnIsUnposted				= 0
		--	,intUserId					= @UserId
		--	,intEntityId				= @UserEntityId 			
		--	,strTransactionId			= A.strInvoiceNumber
		--	,intTransactionId			= A.intInvoiceId
		--	,strTransactionType			= A.strTransactionType
		--	,strTransactionForm			= @SCREEN_NAME 
		--	,strModuleName				= @MODULE_NAME 
		--	,intConcurrencyId			= 1
		--	,[dblDebitForeign]			= CASE WHEN @AccrualPeriod > 1 
		--									THEN 
		--										CASE WHEN A.strTransactionType IN ('Invoice', 'Cash') THEN @ZeroDecimal ELSE Accrual.dblAmount END 
		--									ELSE
		--										CASE WHEN A.strTransactionType IN ('Invoice', 'Cash') THEN @ZeroDecimal ELSE Accrual.dblAmount END 
		--								  END
		--	,[dblDebitReport]			= CASE WHEN @AccrualPeriod > 1 
		--									THEN 
		--										CASE WHEN A.strTransactionType IN ('Invoice', 'Cash') THEN @ZeroDecimal ELSE Accrual.dblAmount END 
		--									ELSE
		--										CASE WHEN A.strTransactionType IN ('Invoice', 'Cash') THEN @ZeroDecimal ELSE Accrual.dblAmount END 
		--								  END
		--	,[dblCreditForeign]			= CASE WHEN @AccrualPeriod > 1 
		--									THEN 
		--										CASE WHEN A.strTransactionType  IN ('Invoice', 'Cash') THEN Accrual.dblAmount END
		--									ELSE
		--										CASE WHEN A.strTransactionType  IN ('Invoice', 'Cash') THEN @ZeroDecimal ELSE Accrual.dblAmount  END 
		--								  END
		--	,[dblCreditReport]			= CASE WHEN @AccrualPeriod > 1 
		--									THEN 
		--										CASE WHEN A.strTransactionType  IN ('Invoice', 'Cash') THEN Accrual.dblAmount END
		--									ELSE
		--										CASE WHEN A.strTransactionType  IN ('Invoice', 'Cash') THEN @ZeroDecimal ELSE Accrual.dblAmount  END 
		--								  END
		--	,[dblReportingRate]			= B.dblCurrencyExchangeRate
		--	,[dblForeignRate]			= B.dblCurrencyExchangeRate
		--	,[strRateType]				= SMCERT.strCurrencyExchangeRateType 
		--FROM
		--	tblARInvoice A 
		--LEFT JOIN
		--	tblARInvoiceDetail B
		--		ON A.intInvoiceId = B.intInvoiceId
		--LEFT JOIN 
		--	tblARCustomer C
		--		ON A.[intEntityCustomerId] = C.[intEntityId]		
		--LEFT OUTER JOIN
		--	@ItemAccounts IST
		--		ON B.intItemId = IST.intItemId 
		--		AND A.intCompanyLocationId = IST.intLocationId
		--LEFT OUTER JOIN
		--	vyuICGetItemStock ICIS
		--		ON B.intItemId = ICIS.intItemId 
		--		AND B.intItemUOMId = ICIS.intStockUOMId
		--		AND A.intCompanyLocationId = ICIS.intLocationId
		--LEFT OUTER JOIN
		--	tblSMCompanyLocation SMCL
		--		ON A.intCompanyLocationId = SMCL.intCompanyLocationId
		--LEFT OUTER JOIN
		--	tblSMCurrencyExchangeRateType SMCERT
		--		ON B.intCurrencyExchangeRateTypeId = SMCERT.intCurrencyExchangeRateTypeId
		--LEFT OUTER JOIN
		--	tblARInvoiceAccrual Accrual
		--		ON Accrual.intInvoiceDetailId = B.intInvoiceDetailId
		--WHERE
		--	A.intInvoiceId = @InvoiceId
		--	AND B.intInvoiceDetailId = @InvoiceDetailId 
		--	AND B.dblTotal <> @ZeroDecimal 
		--	AND ((B.intItemId IS NULL OR B.intItemId = 0)
		--		OR (EXISTS(SELECT NULL FROM tblICItem WHERE intItemId = B.intItemId AND strType IN ('Non-Inventory','Service','Other Charge'))))
		--	AND A.strType <> 'Debit Memo'
        SELECT
             [dtmDate]                      = ARIA.[dtmAccrualDate]
            ,[strBatchId]                   = I.[strBatchId]
            ,[intAccountId]                 = (CASE WHEN I.[strItemType] IN ('Non-Inventory','Service') THEN IA.[intGeneralAccountId]
                                                    WHEN I.[strItemType] = 'Other Charge' THEN IA.intOtherChargeIncomeAccountId
                                                    ELSE ISNULL(I.[intServiceChargeAccountId], I.[intSalesAccountId])
                                              END)
            ,[dblDebit]                     = [dbo].fnRoundBanker((
                                                                    (CASE WHEN I.[intPeriodsToAccrue] > 1
																	      THEN (CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN @ZeroDecimal ELSE ARIA.[dblAmount] END)
																		  ELSE (CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN @ZeroDecimal ELSE ARIA.[dblAmount] END)
																	END)
                                                                    * I.[dblCurrencyExchangeRate]
                                                                  ), [dbo].[fnARGetDefaultDecimal]())
            ,[dblCredit]                    = [dbo].fnRoundBanker((
                                                                    (CASE WHEN I.[intPeriodsToAccrue] > 1
																	      THEN ARIA.[dblAmount]
																		  ELSE (CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN @ZeroDecimal ELSE ARIA.[dblAmount] END)
																	END)
                                                                    * I.[dblCurrencyExchangeRate]
                                                                  ), [dbo].[fnARGetDefaultDecimal]())
            ,[dblDebitUnit]                 = @ZeroDecimal
            ,[dblCreditUnit]                = @ZeroDecimal
            ,[strDescription]               = I.[strComments]
            ,[strCode]                      = @CODE
            ,[strReference]                 = I.[strCustomerNumber]
            ,[intCurrencyId]                = I.[intCurrencyId]
            ,[dblExchangeRate]              = I.[dblCurrencyExchangeRate]
            ,[dtmDateEntered]               = I.[dtmPostDate]
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
            ,[dblDebitForeign]              = [dbo].fnRoundBanker((
                                                                    (CASE WHEN I.[intPeriodsToAccrue] > 1
																	      THEN (CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN @ZeroDecimal ELSE ARIA.[dblAmount] END)
																		  ELSE (CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN @ZeroDecimal ELSE ARIA.[dblAmount] END)
																	END)
                                                                  ), [dbo].[fnARGetDefaultDecimal]())
            ,[dblDebitReport]               = [dbo].fnRoundBanker((
                                                                    (CASE WHEN I.[intPeriodsToAccrue] > 1
																	      THEN (CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN @ZeroDecimal ELSE ARIA.[dblAmount] END)
																		  ELSE (CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN @ZeroDecimal ELSE ARIA.[dblAmount] END)
																	END)
                                                                  ), [dbo].[fnARGetDefaultDecimal]())
            ,[dblCreditForeign]             = [dbo].fnRoundBanker((
                                                                    (CASE WHEN I.[intPeriodsToAccrue] > 1
																	      THEN ARIA.[dblAmount]
																		  ELSE (CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN @ZeroDecimal ELSE ARIA.[dblAmount] END)
																	END)
                                                                  ), [dbo].[fnARGetDefaultDecimal]())
            ,[dblCreditReport]              = [dbo].fnRoundBanker((
                                                                    (CASE WHEN I.[intPeriodsToAccrue] > 1
																	      THEN ARIA.[dblAmount]
																		  ELSE (CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN @ZeroDecimal ELSE ARIA.[dblAmount] END)
																	END)
                                                                  ), [dbo].[fnARGetDefaultDecimal]())
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
            tblARInvoiceAccrual ARIA
                ON I.[intInvoiceDetailId] = ARIA.[intInvoiceDetailId]
        LEFT OUTER JOIN
            #ARInvoiceItemAccount IA
                ON I.[intItemId] = IA.[intItemId] 
                AND I.[intCompanyLocationId] = IA.[intLocationId]
        WHERE
            I.[intInvoiceDetailId] = @InvoiceDetailId
            --AND I.[intInvoiceId] = @InvoiceId
            --AND I.[intInvoiceDetailId] IS NOT NULL
            AND I.[dblTotal] <> @ZeroDecimal
            AND (
                I.[intItemId] IS NULL
                OR
                I.[strItemType] IN ('Non-Inventory','Service','Other Charge')
                )
            AND I.[strTransactionType] <> 'Debit Memo'

		--DEBIT Software -- License
		UNION ALL 
		--SELECT
		--		dtmDate					= Accrual.dtmAccrualDate
		--	,strBatchID					= @BatchId
		--	,intAccountId				= @DeferredRevenueAccountId
		--	,dblDebit					= [dbo].fnRoundBanker(((CASE WHEN @AccrualPeriod > 1 
		--									THEN 
		--										CASE WHEN A.strTransactionType  IN ('Invoice', 'Cash') THEN Accrual.dblAmount END
		--									ELSE
		--										CASE WHEN A.strTransactionType  IN ('Invoice', 'Cash') THEN @ZeroDecimal ELSE Accrual.dblAmount  END 
		--									END) * B.dblCurrencyExchangeRate), [dbo].[fnARGetDefaultDecimal]())
		--	,dblCredit					= [dbo].fnRoundBanker(((CASE WHEN @AccrualPeriod > 1 
		--									THEN 
		--										CASE WHEN A.strTransactionType  IN ('Invoice', 'Cash') THEN @ZeroDecimal ELSE Accrual.dblAmount END 
		--									ELSE 
		--										CASE WHEN A.strTransactionType  IN ('Invoice', 'Cash') THEN @ZeroDecimal ELSE Accrual.dblAmount END 
		--									END) * B.dblCurrencyExchangeRate), [dbo].[fnARGetDefaultDecimal]())
		--	,dblDebitUnit				= @ZeroDecimal
		--	,dblCreditUnit				= @ZeroDecimal
		--	,strDescription				= A.strComments
		--	,strCode					= @CODE
		--	,strReference				= C.strCustomerNumber
		--	,intCurrencyId				= A.intCurrencyId 
		--	,dblExchangeRate			= B.dblCurrencyExchangeRate
		--	,dtmDateEntered				= @PostDate
		--	,dtmTransactionDate			= A.dtmDate
		--	,strJournalLineDescription	= B.strItemDescription 
		--	,intJournalLineNo			= B.intInvoiceDetailId
		--	,ysnIsUnposted				= 0
		--	,intUserId					= @UserId
		--	,intEntityId				= @UserEntityId				
		--	,strTransactionId			= A.strInvoiceNumber
		--	,intTransactionId			= A.intInvoiceId
		--	,strTransactionType			= A.strTransactionType
		--	,strTransactionForm			= @SCREEN_NAME
		--	,strModuleName				= @MODULE_NAME
		--	,intConcurrencyId			= 1
		--	,[dblDebitForeign]			= CASE WHEN @AccrualPeriod > 1 
		--									THEN 
		--										CASE WHEN A.strTransactionType  IN ('Invoice', 'Cash') THEN Accrual.dblAmount END
		--									ELSE
		--										CASE WHEN A.strTransactionType  IN ('Invoice', 'Cash') THEN @ZeroDecimal ELSE Accrual.dblAmount  END 
		--									END
		--	,[dblDebitReport]			= CASE WHEN @AccrualPeriod > 1 
		--									THEN 
		--										CASE WHEN A.strTransactionType  IN ('Invoice', 'Cash') THEN Accrual.dblAmount END
		--									ELSE
		--										CASE WHEN A.strTransactionType  IN ('Invoice', 'Cash') THEN @ZeroDecimal ELSE Accrual.dblAmount  END 
		--									END
		--	,[dblCreditForeign]			= CASE WHEN @AccrualPeriod > 1 
		--									THEN 
		--										CASE WHEN A.strTransactionType  IN ('Invoice', 'Cash') THEN @ZeroDecimal ELSE Accrual.dblAmount END 
		--									ELSE 
		--										CASE WHEN A.strTransactionType  IN ('Invoice', 'Cash') THEN @ZeroDecimal ELSE Accrual.dblAmount END 
		--									END
		--	,[dblCreditReport]			= CASE WHEN @AccrualPeriod > 1 
		--									THEN 
		--										CASE WHEN A.strTransactionType  IN ('Invoice', 'Cash') THEN @ZeroDecimal ELSE Accrual.dblAmount END 
		--									ELSE 
		--										CASE WHEN A.strTransactionType  IN ('Invoice', 'Cash') THEN @ZeroDecimal ELSE Accrual.dblAmount END 
		--									END
		--	,[dblReportingRate]			= B.dblCurrencyExchangeRate
		--	,[dblForeignRate]			= B.dblCurrencyExchangeRate
		--	,[strRateType]				= SMCERT.strCurrencyExchangeRateType
		--FROM
		--	tblARInvoiceDetail B
		--INNER JOIN
		--	tblARInvoice A 
		--		ON B.intInvoiceId = A.intInvoiceId
		--INNER JOIN
		--	tblICItem I
		--		ON B.intItemId = I.intItemId 				
		--LEFT JOIN 
		--	tblARCustomer C
		--		ON A.[intEntityCustomerId] = C.[intEntityId]		
		--LEFT OUTER JOIN
		--	@ItemAccounts IST
		--		ON B.intItemId = IST.intItemId 
		--		AND A.intCompanyLocationId = IST.intLocationId
		--LEFT OUTER JOIN
		--	vyuICGetItemStock ICIS
		--		ON B.intItemId = ICIS.intItemId 
		--		AND B.intItemUOMId = ICIS.intStockUOMId
		--		AND A.intCompanyLocationId = ICIS.intLocationId
		--LEFT OUTER JOIN
		--	tblSMCurrencyExchangeRateType SMCERT
		--		ON B.intCurrencyExchangeRateTypeId = SMCERT.intCurrencyExchangeRateTypeId	
		--LEFT OUTER JOIN
		--	tblARInvoiceAccrual Accrual
		--		ON Accrual.intInvoiceDetailId = B.intInvoiceDetailId
		--WHERE
		--	B.dblLicenseAmount <> @ZeroDecimal
		--	AND B.intInvoiceDetailId = @InvoiceDetailId 
		--	AND B.strMaintenanceType IN ('License/Maintenance', 'License Only')
		--	AND I.strType = 'Software'
		--	AND A.strTransactionType <> 'Debit Memo'
		--	AND @AccrueLicense = 1
        SELECT
             [dtmDate]                      = ARIA.[dtmAccrualDate]
            ,[strBatchId]                   = I.[strBatchId]
            ,[intAccountId]                 = I.[intDeferredRevenueAccountId]
            ,[dblDebit]                     = [dbo].fnRoundBanker((
                                                                    (CASE WHEN I.[intPeriodsToAccrue] > 1
																	      THEN ARIA.[dblAmount]
																		  ELSE (CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN @ZeroDecimal ELSE ARIA.[dblAmount] END)
																	END)
                                                                    * I.[dblCurrencyExchangeRate]
                                                                  ), [dbo].[fnARGetDefaultDecimal]())
            ,[dblCredit]                    = [dbo].fnRoundBanker((
                                                                    (CASE WHEN I.[intPeriodsToAccrue] > 1
																	      THEN (CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN @ZeroDecimal ELSE ARIA.[dblAmount] END)
																		  ELSE (CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN @ZeroDecimal ELSE ARIA.[dblAmount] END)
																	END)
                                                                    * I.[dblCurrencyExchangeRate]
                                                                  ), [dbo].[fnARGetDefaultDecimal]())
            ,[dblDebitUnit]                 = @ZeroDecimal
            ,[dblCreditUnit]                = @ZeroDecimal
            ,[strDescription]               = I.[strComments]
            ,[strCode]                      = @CODE
            ,[strReference]                 = I.[strCustomerNumber]
            ,[intCurrencyId]                = I.[intCurrencyId]
            ,[dblExchangeRate]              = I.[dblCurrencyExchangeRate]
            ,[dtmDateEntered]               = I.[dtmPostDate]
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
            ,[dblDebitForeign]              = [dbo].fnRoundBanker((
                                                                    (CASE WHEN I.[intPeriodsToAccrue] > 1
																	      THEN ARIA.[dblAmount]
																		  ELSE (CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN @ZeroDecimal ELSE ARIA.[dblAmount] END)
																	END)
                                                                  ), [dbo].[fnARGetDefaultDecimal]())
            ,[dblDebitReport]               = [dbo].fnRoundBanker((
                                                                    (CASE WHEN I.[intPeriodsToAccrue] > 1
																	      THEN ARIA.[dblAmount]
																		  ELSE (CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN @ZeroDecimal ELSE ARIA.[dblAmount] END)
																	END)
                                                                  ), [dbo].[fnARGetDefaultDecimal]())
            ,[dblCreditForeign]             = [dbo].fnRoundBanker((
                                                                    (CASE WHEN I.[intPeriodsToAccrue] > 1
																	      THEN (CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN @ZeroDecimal ELSE ARIA.[dblAmount] END)
																		  ELSE (CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN @ZeroDecimal ELSE ARIA.[dblAmount] END)
																	END)
                                                                  ), [dbo].[fnARGetDefaultDecimal]())
            ,[dblCreditReport]              = [dbo].fnRoundBanker((
                                                                    (CASE WHEN I.[intPeriodsToAccrue] > 1
																	      THEN (CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN @ZeroDecimal ELSE ARIA.[dblAmount] END)
																		  ELSE (CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN @ZeroDecimal ELSE ARIA.[dblAmount] END)
																	END)
                                                                  ), [dbo].[fnARGetDefaultDecimal]())
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
            tblARInvoiceAccrual ARIA
                ON I.[intInvoiceDetailId] = ARIA.[intInvoiceDetailId]
        LEFT OUTER JOIN
            #ARInvoiceItemAccount IA
                ON I.[intItemId] = IA.[intItemId] 
                AND I.[intCompanyLocationId] = IA.[intLocationId]
        WHERE
            I.[intInvoiceDetailId] = @InvoiceDetailId
            --AND I.[intInvoiceId] = @InvoiceId
            --AND I.[intInvoiceDetailId] IS NOT NULL
            AND I.[dblLicenseAmount] <> @ZeroDecimal
            AND I.[ysnAccrueLicense] = 1
            AND I.[strMaintenanceType] IN ('License/Maintenance', 'License Only')
            AND I.[strItemType] = 'Software'
            AND I.[strTransactionType] <> 'Debit Memo'

		

		--CREDIT Software -- License
		UNION ALL 
		--SELECT
		--		dtmDate					= Accrual.dtmAccrualDate
		--	,strBatchID					= @BatchId
		--	,intAccountId				= IST.intGeneralAccountId
		--	,dblDebit					= [dbo].fnRoundBanker(((CASE WHEN @AccrualPeriod > 1 
		--									THEN 
		--										CASE WHEN A.strTransactionType  IN ('Invoice', 'Cash') THEN @ZeroDecimal ELSE Accrual.dblAmount END 
		--									ELSE
		--										CASE WHEN A.strTransactionType  IN ('Invoice', 'Cash') THEN @ZeroDecimal ELSE Accrual.dblAmount END 
		--									END) * B.dblCurrencyExchangeRate), [dbo].[fnARGetDefaultDecimal]())
		--	,dblCredit					= [dbo].fnRoundBanker(((CASE WHEN @AccrualPeriod > 1 
		--									THEN 
		--										CASE WHEN A.strTransactionType  IN ('Invoice', 'Cash') THEN Accrual.dblAmount END
		--									ELSE 
		--										CASE WHEN A.strTransactionType  IN ('Invoice', 'Cash') THEN @ZeroDecimal ELSE Accrual.dblAmount  END 
		--									END) * B.dblCurrencyExchangeRate), [dbo].[fnARGetDefaultDecimal]())
		--	,dblDebitUnit				= 0
		--	,dblCreditUnit				= 0
		--	,strDescription				= A.strComments
		--	,strCode					= @CODE
		--	,strReference				= C.strCustomerNumber
		--	,intCurrencyId				= A.intCurrencyId 
		--	,dblExchangeRate			= B.dblCurrencyExchangeRate
		--	,dtmDateEntered				= @PostDate
		--	,dtmTransactionDate			= A.dtmDate
		--	,strJournalLineDescription	= B.strItemDescription 
		--	,intJournalLineNo			= B.intInvoiceDetailId
		--	,ysnIsUnposted				= 0
		--	,intUserId					= @UserId
		--	,intEntityId				= @UserEntityId				
		--	,strTransactionId			= A.strInvoiceNumber
		--	,intTransactionId			= A.intInvoiceId
		--	,strTransactionType			= A.strTransactionType
		--	,strTransactionForm			= @SCREEN_NAME
		--	,strModuleName				= @MODULE_NAME
		--	,intConcurrencyId			= 1
		--	,[dblDebitForeign]			= CASE WHEN @AccrualPeriod > 1 
		--									THEN 
		--										CASE WHEN A.strTransactionType  IN ('Invoice', 'Cash') THEN @ZeroDecimal ELSE Accrual.dblAmount END 
		--									ELSE
		--										CASE WHEN A.strTransactionType  IN ('Invoice', 'Cash') THEN @ZeroDecimal ELSE Accrual.dblAmount END 
		--									END
		--	,[dblDebitReport]			= CASE WHEN @AccrualPeriod > 1 
		--									THEN 
		--										CASE WHEN A.strTransactionType  IN ('Invoice', 'Cash') THEN @ZeroDecimal ELSE Accrual.dblAmount END 
		--									ELSE
		--										CASE WHEN A.strTransactionType  IN ('Invoice', 'Cash') THEN @ZeroDecimal ELSE Accrual.dblAmount END 
		--									END
		--	,[dblCreditForeign]			= CASE WHEN @AccrualPeriod > 1 
		--									THEN 
		--										CASE WHEN A.strTransactionType  IN ('Invoice', 'Cash') THEN Accrual.dblAmount END
		--									ELSE 
		--										CASE WHEN A.strTransactionType  IN ('Invoice', 'Cash') THEN @ZeroDecimal ELSE Accrual.dblAmount END 
		--									END
		--	,[dblCreditReport]			= CASE WHEN @AccrualPeriod > 1 
		--									THEN 
		--										CASE WHEN A.strTransactionType  IN ('Invoice', 'Cash') THEN Accrual.dblAmount END
		--									ELSE 
		--										CASE WHEN A.strTransactionType  IN ('Invoice', 'Cash') THEN @ZeroDecimal ELSE Accrual.dblAmount  END 
		--									END
		--	,[dblReportingRate]			= B.dblCurrencyExchangeRate
		--	,[dblForeignRate]			= B.dblCurrencyExchangeRate
		--	,[strRateType]				= SMCERT.strCurrencyExchangeRateType
		--FROM
		--	tblARInvoiceDetail B
		--INNER JOIN
		--	tblARInvoice A 
		--		ON B.intInvoiceId = A.intInvoiceId
		--INNER JOIN
		--	tblICItem I
		--		ON B.intItemId = I.intItemId 				
		--LEFT JOIN 
		--	tblARCustomer C
		--		ON A.[intEntityCustomerId] = C.[intEntityId]		
		--LEFT OUTER JOIN
		--	@ItemAccounts IST
		--		ON B.intItemId = IST.intItemId 
		--		AND A.intCompanyLocationId = IST.intLocationId
		--LEFT OUTER JOIN
		--	vyuICGetItemStock ICIS
		--		ON B.intItemId = ICIS.intItemId 
		--		AND B.intItemUOMId = ICIS.intStockUOMId
		--		AND A.intCompanyLocationId = ICIS.intLocationId
		--LEFT OUTER JOIN
		--	tblSMCurrencyExchangeRateType SMCERT
		--		ON B.intCurrencyExchangeRateTypeId = SMCERT.intCurrencyExchangeRateTypeId		
		--LEFT OUTER JOIN
		--	tblARInvoiceAccrual Accrual
		--		ON Accrual.intInvoiceDetailId = B.intInvoiceDetailId			
		--WHERE
		--	B.dblLicenseAmount <> @ZeroDecimal
		--	AND B.intInvoiceDetailId = @InvoiceDetailId 
		--	AND B.strMaintenanceType IN ('License/Maintenance', 'License Only')
		--	AND I.strType = 'Software'
		--	AND A.strTransactionType <> 'Debit Memo'
		--	AND @AccrueLicense = 1
        SELECT
             [dtmDate]                      = ARIA.[dtmAccrualDate]
            ,[strBatchId]                   = I.[strBatchId]
            ,[intAccountId]                 = IA.[intGeneralAccountId]
            ,[dblDebit]                     = [dbo].fnRoundBanker((
                                                                    (CASE WHEN I.[intPeriodsToAccrue] > 1
																	      THEN (CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN @ZeroDecimal ELSE ARIA.[dblAmount] END)
																		  ELSE (CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN @ZeroDecimal ELSE ARIA.[dblAmount] END)
																	END)
                                                                    * I.[dblCurrencyExchangeRate]
                                                                  ), [dbo].[fnARGetDefaultDecimal]())
            ,[dblCredit]                    = [dbo].fnRoundBanker((
                                                                    (CASE WHEN I.[intPeriodsToAccrue] > 1
																	      THEN ARIA.[dblAmount]
																		  ELSE (CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN @ZeroDecimal ELSE ARIA.[dblAmount] END)
																	END)
                                                                    * I.[dblCurrencyExchangeRate]
                                                                  ), [dbo].[fnARGetDefaultDecimal]())
            ,[dblDebitUnit]                 = @ZeroDecimal
            ,[dblCreditUnit]                = @ZeroDecimal
            ,[strDescription]               = I.[strComments]
            ,[strCode]                      = @CODE
            ,[strReference]                 = I.[strCustomerNumber]
            ,[intCurrencyId]                = I.[intCurrencyId]
            ,[dblExchangeRate]              = I.[dblCurrencyExchangeRate]
            ,[dtmDateEntered]               = I.[dtmPostDate]
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
            ,[dblDebitForeign]              = [dbo].fnRoundBanker((
                                                                    (CASE WHEN I.[intPeriodsToAccrue] > 1
																	      THEN (CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN @ZeroDecimal ELSE ARIA.[dblAmount] END)
																		  ELSE (CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN @ZeroDecimal ELSE ARIA.[dblAmount] END)
																	END)
                                                                  ), [dbo].[fnARGetDefaultDecimal]())
            ,[dblDebitReport]               = [dbo].fnRoundBanker((
                                                                    (CASE WHEN I.[intPeriodsToAccrue] > 1
																	      THEN (CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN @ZeroDecimal ELSE ARIA.[dblAmount] END)
																		  ELSE (CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN @ZeroDecimal ELSE ARIA.[dblAmount] END)
																	END)
                                                                  ), [dbo].[fnARGetDefaultDecimal]())
            ,[dblCreditForeign]             = [dbo].fnRoundBanker((
                                                                    (CASE WHEN I.[intPeriodsToAccrue] > 1
																	      THEN ARIA.[dblAmount]
																		  ELSE (CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN @ZeroDecimal ELSE ARIA.[dblAmount] END)
																	END)
                                                                  ), [dbo].[fnARGetDefaultDecimal]())
            ,[dblCreditReport]              = [dbo].fnRoundBanker((
                                                                    (CASE WHEN I.[intPeriodsToAccrue] > 1
																	      THEN ARIA.[dblAmount]
																		  ELSE (CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN @ZeroDecimal ELSE ARIA.[dblAmount] END)
																	END)
                                                                  ), [dbo].[fnARGetDefaultDecimal]())
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
            tblARInvoiceAccrual ARIA
                ON I.[intInvoiceDetailId] = ARIA.[intInvoiceDetailId]
        LEFT OUTER JOIN
            #ARInvoiceItemAccount IA
                ON I.[intItemId] = IA.[intItemId] 
                AND I.[intCompanyLocationId] = IA.[intLocationId]
        WHERE
            I.[intInvoiceDetailId] = @InvoiceDetailId
            --AND I.[intInvoiceId] = @InvoiceId
            --AND I.[intInvoiceDetailId] IS NOT NULL
            AND I.[dblLicenseAmount] <> @ZeroDecimal
            AND I.[ysnAccrueLicense] = 1
            AND I.[strMaintenanceType] IN ('License/Maintenance', 'License Only')
            AND I.[strItemType] = 'Software'
            AND I.[strTransactionType] <> 'Debit Memo'

						

		--DEBIT Software -- Maintenance
		UNION ALL 
		--SELECT
		--		dtmDate					= Accrual.dtmAccrualDate
		--	,strBatchID					= @BatchId
		--	,intAccountId				= @DeferredRevenueAccountId
		--	,dblDebit					= [dbo].fnRoundBanker(((CASE WHEN @AccrualPeriod > 1 
		--									THEN
		--										CASE WHEN A.strTransactionType  IN ('Invoice', 'Cash') THEN Accrual.dblAmount END
		--									ELSE
		--										CASE WHEN A.strTransactionType  IN ('Invoice', 'Cash') THEN @ZeroDecimal ELSE Accrual.dblAmount  END 
		--									END) * B.dblCurrencyExchangeRate), [dbo].[fnARGetDefaultDecimal]())
		--	,dblCredit					= [dbo].fnRoundBanker(((CASE WHEN @AccrualPeriod > 1 
		--									THEN 
		--										CASE WHEN A.strTransactionType  IN ('Invoice', 'Cash') THEN @ZeroDecimal ELSE Accrual.dblAmount END 
		--									ELSE
		--										CASE WHEN A.strTransactionType  IN ('Invoice', 'Cash') THEN @ZeroDecimal ELSE Accrual.dblAmount END 
		--									END) * B.dblCurrencyExchangeRate), [dbo].[fnARGetDefaultDecimal]())
		--	,dblDebitUnit				= 0
		--	,dblCreditUnit				= 0
		--	,strDescription				= A.strComments
		--	,strCode					= @CODE
		--	,strReference				= C.strCustomerNumber
		--	,intCurrencyId				= A.intCurrencyId 
		--	,dblExchangeRate			= B.dblCurrencyExchangeRate
		--	,dtmDateEntered				= @PostDate
		--	,dtmTransactionDate			= A.dtmDate
		--	,strJournalLineDescription	= B.strItemDescription 
		--	,intJournalLineNo			= B.intInvoiceDetailId
		--	,ysnIsUnposted				= 0
		--	,intUserId					= @UserId
		--	,intEntityId				= @UserEntityId				
		--	,strTransactionId			= A.strInvoiceNumber
		--	,intTransactionId			= A.intInvoiceId
		--	,strTransactionType			= A.strTransactionType
		--	,strTransactionForm			= @SCREEN_NAME
		--	,strModuleName				= @MODULE_NAME
		--	,intConcurrencyId			= 1
		--	,[dblDebitForeign]			= CASE WHEN @AccrualPeriod > 1 
		--									THEN
		--										CASE WHEN A.strTransactionType  IN ('Invoice', 'Cash') THEN Accrual.dblAmount END
		--									ELSE
		--										CASE WHEN A.strTransactionType  IN ('Invoice', 'Cash') THEN @ZeroDecimal ELSE Accrual.dblAmount  END 
		--									END
		--	,[dblDebitReport]			= CASE WHEN @AccrualPeriod > 1 
		--									THEN
		--										CASE WHEN A.strTransactionType  IN ('Invoice', 'Cash') THEN Accrual.dblAmount END
		--									ELSE
		--										CASE WHEN A.strTransactionType  IN ('Invoice', 'Cash') THEN @ZeroDecimal ELSE Accrual.dblAmount  END 
		--									END
		--	,[dblCreditForeign]			= CASE WHEN @AccrualPeriod > 1 
		--									THEN 
		--										CASE WHEN A.strTransactionType  IN ('Invoice', 'Cash') THEN @ZeroDecimal ELSE Accrual.dblAmount END 
		--									ELSE
		--										CASE WHEN A.strTransactionType  IN ('Invoice', 'Cash') THEN @ZeroDecimal ELSE Accrual.dblAmount END 
		--									END
		--	,[dblCreditReport]			= CASE WHEN @AccrualPeriod > 1 
		--									THEN 
		--										CASE WHEN A.strTransactionType  IN ('Invoice', 'Cash') THEN @ZeroDecimal ELSE Accrual.dblAmount END 
		--									ELSE
		--										CASE WHEN A.strTransactionType  IN ('Invoice', 'Cash') THEN @ZeroDecimal ELSE Accrual.dblAmount END 
		--									END
		--	,[dblReportingRate]			= B.dblCurrencyExchangeRate
		--	,[dblForeignRate]			= B.dblCurrencyExchangeRate
		--	,[strRateType]				= SMCERT.strCurrencyExchangeRateType
		--FROM
		--	tblARInvoiceDetail B
		--INNER JOIN
		--	tblARInvoice A 
		--		ON B.intInvoiceId = A.intInvoiceId
		--INNER JOIN
		--	tblICItem I
		--		ON B.intItemId = I.intItemId 				
		--LEFT JOIN 
		--	tblARCustomer C
		--		ON A.[intEntityCustomerId] = C.[intEntityId]		
		--LEFT OUTER JOIN
		--	@ItemAccounts IST
		--		ON B.intItemId = IST.intItemId 
		--		AND A.intCompanyLocationId = IST.intLocationId
		--LEFT OUTER JOIN
		--	vyuICGetItemStock ICIS
		--		ON B.intItemId = ICIS.intItemId 
		--		AND B.intItemUOMId = ICIS.intStockUOMId
		--		AND A.intCompanyLocationId = ICIS.intLocationId
		--LEFT OUTER JOIN
		--	tblSMCurrencyExchangeRateType SMCERT
		--		ON B.intCurrencyExchangeRateTypeId = SMCERT.intCurrencyExchangeRateTypeId	
		--LEFT OUTER JOIN 
		--	tblARInvoiceAccrual Accrual
		--		ON Accrual.intInvoiceDetailId = B.intInvoiceDetailId					
		--WHERE
		--	B.dblMaintenanceAmount <> @ZeroDecimal
		--	AND B.intInvoiceDetailId = @InvoiceDetailId 
		--	AND B.strMaintenanceType IN ('License/Maintenance', 'Maintenance Only', 'SaaS')
		--	AND I.strType = 'Software'
		--	AND A.strTransactionType <> 'Debit Memo'
        SELECT
             [dtmDate]                      = ARIA.[dtmAccrualDate]
            ,[strBatchId]                   = I.[strBatchId]
            ,[intAccountId]                 = I.[intDeferredRevenueAccountId]
            ,[dblDebit]                     = [dbo].fnRoundBanker((
                                                                    (CASE WHEN I.[intPeriodsToAccrue] > 1
																	      THEN ARIA.[dblAmount]
																		  ELSE (CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN @ZeroDecimal ELSE ARIA.[dblAmount] END)
																	END)
                                                                    * I.[dblCurrencyExchangeRate]
                                                                  ), [dbo].[fnARGetDefaultDecimal]())
            ,[dblCredit]                    = [dbo].fnRoundBanker((
                                                                    (CASE WHEN I.[intPeriodsToAccrue] > 1
																	      THEN (CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN @ZeroDecimal ELSE ARIA.[dblAmount] END)
																		  ELSE (CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN @ZeroDecimal ELSE ARIA.[dblAmount] END)
																	END)
                                                                    * I.[dblCurrencyExchangeRate]
                                                                  ), [dbo].[fnARGetDefaultDecimal]())
            ,[dblDebitUnit]                 = @ZeroDecimal
            ,[dblCreditUnit]                = @ZeroDecimal
            ,[strDescription]               = I.[strComments]
            ,[strCode]                      = @CODE
            ,[strReference]                 = I.[strCustomerNumber]
            ,[intCurrencyId]                = I.[intCurrencyId]
            ,[dblExchangeRate]              = I.[dblCurrencyExchangeRate]
            ,[dtmDateEntered]               = I.[dtmPostDate]
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
            ,[dblDebitForeign]              = [dbo].fnRoundBanker((
                                                                    (CASE WHEN I.[intPeriodsToAccrue] > 1
																	      THEN ARIA.[dblAmount]
																		  ELSE (CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN @ZeroDecimal ELSE ARIA.[dblAmount] END)
																	END)
                                                                  ), [dbo].[fnARGetDefaultDecimal]())
            ,[dblDebitReport]               = [dbo].fnRoundBanker((
                                                                    (CASE WHEN I.[intPeriodsToAccrue] > 1
																	      THEN ARIA.[dblAmount]
																		  ELSE (CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN @ZeroDecimal ELSE ARIA.[dblAmount] END)
																	END)
                                                                  ), [dbo].[fnARGetDefaultDecimal]())
            ,[dblCreditForeign]             = [dbo].fnRoundBanker((
                                                                    (CASE WHEN I.[intPeriodsToAccrue] > 1
																	      THEN (CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN @ZeroDecimal ELSE ARIA.[dblAmount] END)
																		  ELSE (CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN @ZeroDecimal ELSE ARIA.[dblAmount] END)
																	END)
                                                                  ), [dbo].[fnARGetDefaultDecimal]())
            ,[dblCreditReport]              = [dbo].fnRoundBanker((
                                                                    (CASE WHEN I.[intPeriodsToAccrue] > 1
																	      THEN (CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN @ZeroDecimal ELSE ARIA.[dblAmount] END)
																		  ELSE (CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN @ZeroDecimal ELSE ARIA.[dblAmount] END)
																	END)
                                                                  ), [dbo].[fnARGetDefaultDecimal]())
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
            tblARInvoiceAccrual ARIA
                ON I.[intInvoiceDetailId] = ARIA.[intInvoiceDetailId]
        LEFT OUTER JOIN
            #ARInvoiceItemAccount IA
                ON I.[intItemId] = IA.[intItemId] 
                AND I.[intCompanyLocationId] = IA.[intLocationId]
        WHERE
            I.[intInvoiceDetailId] = @InvoiceDetailId
            --AND I.[intInvoiceId] = @InvoiceId
            --AND I.[intInvoiceDetailId] IS NOT NULL
            AND I.[dblMaintenanceAmount] <> @ZeroDecimal
            AND I.[strMaintenanceType] IN ('License/Maintenance', 'Maintenance Only', 'SaaS')
            AND I.[strItemType] = 'Software'
            AND I.[strTransactionType] <> 'Debit Memo'

		--CREDIT Software -- Maintenance
		UNION ALL 
		--SELECT
		--		dtmDate					= Accrual.dtmAccrualDate
		--	,strBatchID					= @BatchId
		--	,intAccountId				= IST.intMaintenanceSalesAccountId
		--	,dblDebit					= [dbo].fnRoundBanker(((CASE WHEN @AccrualPeriod > 1 
		--									THEN
		--										CASE WHEN A.strTransactionType  IN ('Invoice', 'Cash') THEN @ZeroDecimal ELSE Accrual.dblAmount END 
		--									ELSE
		--										CASE WHEN A.strTransactionType  IN ('Invoice', 'Cash') THEN @ZeroDecimal ELSE Accrual.dblAmount END 
		--									END) * B.dblCurrencyExchangeRate), [dbo].[fnARGetDefaultDecimal]())
		--	,dblCredit					= [dbo].fnRoundBanker(((CASE WHEN @AccrualPeriod > 1 
		--									THEN 
		--										CASE WHEN A.strTransactionType  IN ('Invoice', 'Cash') THEN Accrual.dblAmount END
		--									ELSE
		--										CASE WHEN A.strTransactionType  IN ('Invoice', 'Cash') THEN @ZeroDecimal ELSE Accrual.dblAmount  END 
		--									END) * B.dblCurrencyExchangeRate), [dbo].[fnARGetDefaultDecimal]())
		--	,dblDebitUnit				= 0
		--	,dblCreditUnit				= 0
		--	,strDescription				= A.strComments
		--	,strCode					= @CODE
		--	,strReference				= C.strCustomerNumber
		--	,intCurrencyId				= A.intCurrencyId 
		--	,dblExchangeRate			= B.dblCurrencyExchangeRate
		--	,dtmDateEntered				= @PostDate
		--	,dtmTransactionDate			= A.dtmDate
		--	,strJournalLineDescription	= B.strItemDescription 
		--	,intJournalLineNo			= B.intInvoiceDetailId
		--	,ysnIsUnposted				= 0
		--	,intUserId					= @UserId
		--	,intEntityId				= @UserEntityId				
		--	,strTransactionId			= A.strInvoiceNumber
		--	,intTransactionId			= A.intInvoiceId
		--	,strTransactionType			= A.strTransactionType
		--	,strTransactionForm			= @SCREEN_NAME
		--	,strModuleName				= @MODULE_NAME
		--	,intConcurrencyId			= 1
		--	,[dblDebitForeign]			= CASE WHEN @AccrualPeriod > 1 
		--									THEN
		--										CASE WHEN A.strTransactionType  IN ('Invoice', 'Cash') THEN @ZeroDecimal ELSE Accrual.dblAmount END 
		--									ELSE
		--										CASE WHEN A.strTransactionType  IN ('Invoice', 'Cash') THEN @ZeroDecimal ELSE Accrual.dblAmount END 
		--									END
		--	,[dblDebitReport]			= CASE WHEN @AccrualPeriod > 1 
		--									THEN
		--										CASE WHEN A.strTransactionType  IN ('Invoice', 'Cash') THEN @ZeroDecimal ELSE Accrual.dblAmount END 
		--									ELSE
		--										CASE WHEN A.strTransactionType  IN ('Invoice', 'Cash') THEN @ZeroDecimal ELSE Accrual.dblAmount END 
		--									END
		--	,[dblCreditForeign]			= CASE WHEN @AccrualPeriod > 1 
		--									THEN 
		--										CASE WHEN A.strTransactionType  IN ('Invoice', 'Cash') THEN Accrual.dblAmount END
		--									ELSE
		--										CASE WHEN A.strTransactionType  IN ('Invoice', 'Cash') THEN @ZeroDecimal ELSE Accrual.dblAmount  END 
		--									END
		--	,[dblCreditReport]			= CASE WHEN @AccrualPeriod > 1 
		--									THEN 
		--										CASE WHEN A.strTransactionType  IN ('Invoice', 'Cash') THEN Accrual.dblAmount END
		--									ELSE
		--										CASE WHEN A.strTransactionType  IN ('Invoice', 'Cash') THEN @ZeroDecimal ELSE Accrual.dblAmount  END 
		--									END
		--	,[dblReportingRate]			= B.dblCurrencyExchangeRate
		--	,[dblForeignRate]			= B.dblCurrencyExchangeRate
		--	,[strRateType]				= SMCERT.strCurrencyExchangeRateType
		--FROM
		--	tblARInvoiceDetail B
		--INNER JOIN
		--	tblARInvoice A 
		--		ON B.intInvoiceId = A.intInvoiceId
		--INNER JOIN
		--	tblICItem I
		--		ON B.intItemId = I.intItemId 				
		--LEFT JOIN 
		--	tblARCustomer C
		--		ON A.[intEntityCustomerId] = C.[intEntityId]		
		--LEFT OUTER JOIN
		--	@ItemAccounts IST
		--		ON B.intItemId = IST.intItemId 
		--		AND A.intCompanyLocationId = IST.intLocationId
		--LEFT OUTER JOIN
		--	vyuICGetItemStock ICIS
		--		ON B.intItemId = ICIS.intItemId 
		--		AND B.intItemUOMId = ICIS.intStockUOMId
		--		AND A.intCompanyLocationId = ICIS.intLocationId
		--LEFT OUTER JOIN
		--	tblSMCurrencyExchangeRateType SMCERT
		--		ON B.intCurrencyExchangeRateTypeId = SMCERT.intCurrencyExchangeRateTypeId		
		--LEFT OUTER JOIN
		--	tblARInvoiceAccrual Accrual
		--		ON Accrual.intInvoiceDetailId = B.intInvoiceDetailId				
		--WHERE
		--	B.dblMaintenanceAmount <> @ZeroDecimal
		--	AND B.intInvoiceDetailId = @InvoiceDetailId 
		--	AND B.strMaintenanceType IN ('License/Maintenance', 'Maintenance Only', 'SaaS')
		--	AND I.strType = 'Software'
		--	AND A.strTransactionType <> 'Debit Memo'
        SELECT
             [dtmDate]                      = ARIA.[dtmAccrualDate]
            ,[strBatchId]                   = I.[strBatchId]
            ,[intAccountId]                 = IA.[intMaintenanceSalesAccountId]
            ,[dblDebit]                     = [dbo].fnRoundBanker((
                                                                    (CASE WHEN I.[intPeriodsToAccrue] > 1
																	      THEN (CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN @ZeroDecimal ELSE ARIA.[dblAmount] END)
																		  ELSE (CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN @ZeroDecimal ELSE ARIA.[dblAmount] END)
																	END)
                                                                    * I.[dblCurrencyExchangeRate]
                                                                  ), [dbo].[fnARGetDefaultDecimal]())
            ,[dblCredit]                    = [dbo].fnRoundBanker((
                                                                    (CASE WHEN I.[intPeriodsToAccrue] > 1
																	      THEN ARIA.[dblAmount]
																		  ELSE (CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN @ZeroDecimal ELSE ARIA.[dblAmount] END)
																	END)
                                                                    * I.[dblCurrencyExchangeRate]
                                                                  ), [dbo].[fnARGetDefaultDecimal]())
            ,[dblDebitUnit]                 = @ZeroDecimal
            ,[dblCreditUnit]                = @ZeroDecimal
            ,[strDescription]               = I.[strComments]
            ,[strCode]                      = @CODE
            ,[strReference]                 = I.[strCustomerNumber]
            ,[intCurrencyId]                = I.[intCurrencyId]
            ,[dblExchangeRate]              = I.[dblCurrencyExchangeRate]
            ,[dtmDateEntered]               = I.[dtmPostDate]
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
            ,[dblDebitForeign]              = [dbo].fnRoundBanker((
                                                                    (CASE WHEN I.[intPeriodsToAccrue] > 1
																	      THEN (CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN @ZeroDecimal ELSE ARIA.[dblAmount] END)
																		  ELSE (CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN @ZeroDecimal ELSE ARIA.[dblAmount] END)
																	END)
                                                                  ), [dbo].[fnARGetDefaultDecimal]())
            ,[dblDebitReport]               = [dbo].fnRoundBanker((
                                                                    (CASE WHEN I.[intPeriodsToAccrue] > 1
																	      THEN (CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN @ZeroDecimal ELSE ARIA.[dblAmount] END)
																		  ELSE (CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN @ZeroDecimal ELSE ARIA.[dblAmount] END)
																	END)
                                                                  ), [dbo].[fnARGetDefaultDecimal]())
            ,[dblCreditForeign]             = [dbo].fnRoundBanker((
                                                                    (CASE WHEN I.[intPeriodsToAccrue] > 1
																	      THEN ARIA.[dblAmount]
																		  ELSE (CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN @ZeroDecimal ELSE ARIA.[dblAmount] END)
																	END)
                                                                  ), [dbo].[fnARGetDefaultDecimal]())
            ,[dblCreditReport]              = [dbo].fnRoundBanker((
                                                                    (CASE WHEN I.[intPeriodsToAccrue] > 1
																	      THEN ARIA.[dblAmount]
																		  ELSE (CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN @ZeroDecimal ELSE ARIA.[dblAmount] END)
																	END)
                                                                  ), [dbo].[fnARGetDefaultDecimal]())
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
            tblARInvoiceAccrual ARIA
                ON I.[intInvoiceDetailId] = ARIA.[intInvoiceDetailId]
        LEFT OUTER JOIN
            #ARInvoiceItemAccount IA
                ON I.[intItemId] = IA.[intItemId] 
                AND I.[intCompanyLocationId] = IA.[intLocationId]
        WHERE
            I.[intInvoiceDetailId] = @InvoiceDetailId
            --AND I.[intInvoiceId] = @InvoiceId
            --AND I.[intInvoiceDetailId] IS NOT NULL
            AND I.[dblMaintenanceAmount] <> @ZeroDecimal
            AND I.[strMaintenanceType] IN ('License/Maintenance', 'Maintenance Only', 'SaaS')
            AND I.[strItemType] = 'Software'
            AND I.[strTransactionType] <> 'Debit Memo'

		SET @LoopCounter = @LoopCounter + 1

	---END

	--DECLARE @InvoiceDetailTax AS TABLE(intInvoiceDetailId INT, intInvoiceDetailTaxId INT, dblAdjustedTax DECIMAL(18,6))
	--DELETE FROM @InvoiceDetailTax
	--INSERT INTO @InvoiceDetailTax
	--	(intInvoiceDetailId
	--	,intInvoiceDetailTaxId
	--	,dblAdjustedTax)
	--SELECT
	--	 intInvoiceDetailId			= ARID.intInvoiceDetailId
	--	,intInvoiceDetailTaxId		= ARIDT.intInvoiceDetailTaxId
	--	,dblAdjustedTax				= ARIDT.dblAdjustedTax
	--FROM
	--	tblARInvoiceDetailTax ARIDT
	--INNER JOIN
	--	tblARInvoiceDetail ARID
	--	ON ARIDT.intInvoiceDetailId = ARID.intInvoiceDetailId	
	--WHERE
	--	ARID.intInvoiceDetailId = @InvoiceDetailId 
	--	AND ARIDT.dblAdjustedTax <> @ZeroDecimal 	
	--ORDER BY
	--	ARID.intInvoiceDetailId
	--	,ARIDT.intInvoiceDetailTaxId
	


	--WHILE EXISTS(SELECT TOP 1 NULL FROM @InvoiceDetailTax)
	--BEGIN
	--DECLARE @InvoiceDetailTaxId			INT
	--		,@TaxTotal					DECIMAL(18,6)
	--		,@TaxTotalPerPeriod			DECIMAL(18,6)
	
	--SELECT TOP 1 
	--	@InvoiceDetailTaxId	= intInvoiceDetailTaxId
	--	,@TaxTotal				= dblAdjustedTax
	--	,@TaxTotalPerPeriod		= [dbo].fnRoundBanker((dblAdjustedTax/@AccrualPeriod),2)
	--FROM 
	--	@InvoiceDetailTax
		
	--SET @TaxRemainder = @ZeroDecimal
	--SET @TaxRemainder = [dbo].fnRoundBanker(@TaxTotal,2) - [dbo].fnRoundBanker((@TaxTotalPerPeriod * @AccrualPeriod),2)
	--SET @TaxLoopCounter = 0		

	--WHILE @TaxLoopCounter < @AccrualPeriod
	--BEGIN

	--	--DEBIT AR
	--	INSERT INTO @GLEntries (
	--				[dtmDate] 
	--				,[strBatchId]
	--				,[intAccountId]
	--				,[dblDebit]
	--				,[dblCredit]
	--				,[dblDebitUnit]
	--				,[dblCreditUnit]
	--				,[strDescription]
	--				,[strCode]
	--				,[strReference]
	--				,[intCurrencyId]
	--				,[dblExchangeRate]
	--				,[dtmDateEntered]
	--				,[dtmTransactionDate]
	--				,[strJournalLineDescription]
	--				,[intJournalLineNo]
	--				,[ysnIsUnposted]
	--				,[intUserId]
	--				,[intEntityId]
	--				,[strTransactionId]
	--				,[intTransactionId]
	--				,[strTransactionType]
	--				,[strTransactionForm]
	--				,[strModuleName]
	--				,[intConcurrencyId]
	--			)
	--	--CREDIT Tax
	--	SELECT
	--			dtmDate					= DATEADD(mm, @TaxLoopCounter, CAST(ISNULL(A.dtmPostDate, A.dtmDate) AS DATE))
	--		,strBatchID					= @BatchId
	--		,intAccountId				= ISNULL(DT.intSalesTaxAccountId,TC.intSalesTaxAccountId)
	--		,dblDebit					= CASE WHEN A.strTransactionType  IN ('Invoice', 'Cash') THEN 0 ELSE @TaxTotalPerPeriod + (CASE WHEN @TaxLoopCounter + 1 = @AccrualPeriod THEN @TaxRemainder ELSE 0 END) END
	--		,dblCredit					= CASE WHEN A.strTransactionType  IN ('Invoice', 'Cash') THEN @TaxTotalPerPeriod + (CASE WHEN @TaxLoopCounter + 1 = @AccrualPeriod THEN @TaxRemainder ELSE 0 END) ELSE 0 END
	--		,dblDebitUnit				= 0
	--		,dblCreditUnit				= 0				
	--		,strDescription				= A.strComments
	--		,strCode					= @CODE
	--		,strReference				= C.strCustomerNumber
	--		,intCurrencyId				= A.intCurrencyId 
	--		,dblExchangeRate			= 1
	--		,dtmDateEntered				= @PostDate 
	--		,dtmTransactionDate			= A.dtmDate
	--		,strJournalLineDescription	= 'Posted ' + A.strTransactionType 
	--		,intJournalLineNo			= A.intInvoiceId
	--		,ysnIsUnposted				= 0
	--		,intUserId					= @UserId
	--		,intEntityId				= @UserEntityId 				
	--		,strTransactionId			= A.strInvoiceNumber
	--		,intTransactionId			= A.intInvoiceId
	--		,strTransactionType			= A.strTransactionType
	--		,strTransactionForm			= @SCREEN_NAME 
	--		,strModuleName				= @MODULE_NAME 
	--		,intConcurrencyId			= 1				 
	--	FROM
	--		tblARInvoiceDetailTax DT
	--	INNER JOIN
	--		tblARInvoiceDetail D
	--			ON DT.intInvoiceDetailId = D.intInvoiceDetailId
	--	INNER JOIN			
	--		tblARInvoice A 
	--			ON D.intInvoiceId = A.intInvoiceId
	--	INNER JOIN
	--		tblARCustomer C
	--			ON A.intEntityCustomerId = C.intEntityCustomerId			
	--	LEFT OUTER JOIN
	--		tblSMTaxCode TC
	--			ON DT.intTaxCodeId = TC.intTaxCodeId	
	--	WHERE
	--		DT.intInvoiceDetailTaxId = @InvoiceDetailTaxId
	--		AND DT.dblAdjustedTax <> @ZeroDecimal
			
	--	UNION ALL
	--	--Debit Tax
	--	SELECT
	--		 dtmDate					= DATEADD(mm, @TaxLoopCounter, CAST(ISNULL(A.dtmPostDate, A.dtmDate) AS DATE))
	--		,strBatchID					= @BatchId
	--		,intAccountId				= @DeferredRevenueAccountId
	--		,dblDebit					= CASE WHEN A.strTransactionType  IN ('Invoice', 'Cash') THEN @TaxTotalPerPeriod + (CASE WHEN @TaxLoopCounter + 1 = @AccrualPeriod THEN @TaxRemainder ELSE 0 END) ELSE 0 END
	--		,dblCredit					= CASE WHEN A.strTransactionType  IN ('Invoice', 'Cash') THEN 0 ELSE @TaxTotalPerPeriod + (CASE WHEN @TaxLoopCounter + 1 = @AccrualPeriod THEN @TaxRemainder ELSE 0 END) END
	--		,dblDebitUnit				= 0
	--		,dblCreditUnit				= 0				
	--		,strDescription				= A.strComments
	--		,strCode					= @CODE
	--		,strReference				= C.strCustomerNumber
	--		,intCurrencyId				= A.intCurrencyId 
	--		,dblExchangeRate			= 1
	--		,dtmDateEntered				= @PostDate 
	--		,dtmTransactionDate			= A.dtmDate
	--		,strJournalLineDescription	= 'Posted ' + A.strTransactionType 
	--		,intJournalLineNo			= A.intInvoiceId
	--		,ysnIsUnposted				= 0
	--		,intUserId					= @UserId
	--		,intEntityId				= @UserEntityId 				
	--		,strTransactionId			= A.strInvoiceNumber
	--		,intTransactionId			= A.intInvoiceId
	--		,strTransactionType			= A.strTransactionType
	--		,strTransactionForm			= @SCREEN_NAME 
	--		,strModuleName				= @MODULE_NAME 
	--		,intConcurrencyId			= 1				 
	--	FROM
	--		tblARInvoiceDetailTax DT
	--	INNER JOIN
	--		tblARInvoiceDetail D
	--			ON DT.intInvoiceDetailId = D.intInvoiceDetailId
	--	INNER JOIN			
	--		tblARInvoice A 
	--			ON D.intInvoiceId = A.intInvoiceId
	--	INNER JOIN
	--		tblARCustomer C
	--			ON A.intEntityCustomerId = C.intEntityCustomerId			
	--	LEFT OUTER JOIN
	--		tblSMTaxCode TC
	--			ON DT.intTaxCodeId = TC.intTaxCodeId	
	--	WHERE
	--		DT.intInvoiceDetailTaxId = @InvoiceDetailTaxId
	--		AND DT.dblAdjustedTax <> @ZeroDecimal	
		
	--	SET @TaxLoopCounter = @TaxLoopCounter + 1

	--END

	--DELETE FROM @InvoiceDetailTax WHERE intInvoiceDetailTaxId = @InvoiceDetailTaxId
	--END

	DELETE FROM @InvoiceDetail WHERE intInvoiceDetailId = @InvoiceDetailId
END

--DEBIT AR
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
	--Debit Tax
	--SELECT
	--	 dtmDate					= CAST(ISNULL(A.dtmPostDate, A.dtmDate) AS DATE)
	--	,strBatchID					= @BatchId
	--	,intAccountId				= @DeferredRevenueAccountId
	--	,dblDebit					= CASE WHEN A.strTransactionType  IN ('Invoice', 'Cash') THEN DT.dblBaseAdjustedTax ELSE @ZeroDecimal END
	--	,dblCredit					= CASE WHEN A.strTransactionType  IN ('Invoice', 'Cash') THEN @ZeroDecimal ELSE DT.dblBaseAdjustedTax END
	--	,dblDebitUnit				= @ZeroDecimal
	--	,dblCreditUnit				= @ZeroDecimal				
	--	,strDescription				= A.strComments
	--	,strCode					= @CODE
	--	,strReference				= C.strCustomerNumber
	--	,intCurrencyId				= A.intCurrencyId 
	--	,dblExchangeRate			= ISNULL(D.dblCurrencyExchangeRate, 1.000000)
	--	,dtmDateEntered				= @PostDate 
	--	,dtmTransactionDate			= A.dtmDate
	--	,strJournalLineDescription	= 'Posted ' + A.strTransactionType 
	--	,intJournalLineNo			= A.intInvoiceId
	--	,ysnIsUnposted				= 0
	--	,intUserId					= @UserId
	--	,intEntityId				= @UserEntityId 				
	--	,strTransactionId			= A.strInvoiceNumber
	--	,intTransactionId			= A.intInvoiceId
	--	,strTransactionType			= A.strTransactionType
	--	,strTransactionForm			= @SCREEN_NAME 
	--	,strModuleName				= @MODULE_NAME 
	--	,intConcurrencyId			= 1
	--	,[dblDebitForeign]			= CASE WHEN A.strTransactionType  IN ('Invoice', 'Cash') THEN DT.dblAdjustedTax ELSE @ZeroDecimal END
	--	,[dblDebitReport]			= CASE WHEN A.strTransactionType  IN ('Invoice', 'Cash') THEN DT.dblAdjustedTax ELSE @ZeroDecimal END
	--	,[dblCreditForeign]			= CASE WHEN A.strTransactionType  IN ('Invoice', 'Cash') THEN 0 ELSE DT.dblAdjustedTax END
	--	,[dblCreditReport]			= CASE WHEN A.strTransactionType  IN ('Invoice', 'Cash') THEN 0 ELSE DT.dblAdjustedTax END
	--	,[dblReportingRate]			= ISNULL(D.dblCurrencyExchangeRate, 1.000000)
	--	,[dblForeignRate]			= ISNULL(D.dblCurrencyExchangeRate, 1.000000)
	--	,[strRateType]				= SMCERT.strCurrencyExchangeRateType			 
	--FROM
	--	tblARInvoiceDetailTax DT
	--INNER JOIN
	--	tblARInvoiceDetail D
	--		ON DT.intInvoiceDetailId = D.intInvoiceDetailId
	--INNER JOIN			
	--	tblARInvoice A 
	--		ON D.intInvoiceId = A.intInvoiceId
	--INNER JOIN
	--	tblARCustomer C
	--		ON A.intEntityCustomerId = C.[intEntityId]			
	--LEFT OUTER JOIN
	--	tblSMTaxCode TC
	--		ON DT.intTaxCodeId = TC.intTaxCodeId
	--LEFT OUTER JOIN
	--		tblSMCurrencyExchangeRateType SMCERT
	--			ON D.intCurrencyExchangeRateTypeId = SMCERT.intCurrencyExchangeRateTypeId	
	--WHERE
	--	A.intInvoiceId = @InvoiceId
	--	AND DT.dblAdjustedTax <> @ZeroDecimal	
SELECT
     [dtmDate]                      = CAST(ISNULL(I.[dtmPostDate], I.[dtmDate]) AS DATE)
    ,[strBatchId]                   = I.[strBatchId]
    ,[intAccountId]                 = I.[intDeferredRevenueAccountId]
    ,[dblDebit]                     = CASE WHEN I.[ysnIsInvoicePositive] = 1 
                                           THEN (CASE WHEN ARITD.[dblBaseAdjustedTax] < @ZeroDecimal THEN ABS(ARITD.[dblBaseAdjustedTax]) ELSE @ZeroDecimal END )
                                           ELSE (CASE WHEN ARITD.[dblBaseAdjustedTax] < @ZeroDecimal THEN @ZeroDecimal ELSE ARITD.[dblBaseAdjustedTax] END)
                                      END
    ,[dblCredit]                    = CASE WHEN I.[ysnIsInvoicePositive] = 0 
                                           THEN (CASE WHEN ARITD.[dblBaseAdjustedTax] < @ZeroDecimal THEN ABS(ARITD.[dblBaseAdjustedTax]) ELSE @ZeroDecimal END )
                                           ELSE (CASE WHEN ARITD.[dblBaseAdjustedTax] < @ZeroDecimal THEN @ZeroDecimal ELSE ARITD.[dblBaseAdjustedTax] END)
                                      END
    ,[dblDebitUnit]                 = @ZeroDecimal
    ,[dblCreditUnit]                = @ZeroDecimal
    ,[strDescription]               = I.[strDescription]
    ,[strCode]                      = @CODE
    ,[strReference]                 = I.[strComments]
    ,[intCurrencyId]                = I.[intCurrencyId]
    ,[dblExchangeRate]              = I.[dblCurrencyExchangeRate]
    ,[dtmDateEntered]               = I.[dtmPostDate]
    ,[dtmTransactionDate]           = I.[dtmDate]
    ,[strJournalLineDescription]    = @POSTDESC + I.[strTransactionType]
    ,[intJournalLineNo]             = ARITD.[intInvoiceDetailTaxId]
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
                                           THEN (CASE WHEN ARITD.[dblAdjustedTax] < @ZeroDecimal THEN ABS(ARITD.[dblAdjustedTax]) ELSE @ZeroDecimal END )
                                           ELSE (CASE WHEN ARITD.[dblAdjustedTax] < @ZeroDecimal THEN @ZeroDecimal ELSE ARITD.[dblAdjustedTax] END)
                                      END
    ,[dblDebitReport]               = CASE WHEN I.[ysnIsInvoicePositive] = 1 
                                           THEN (CASE WHEN ARITD.[dblAdjustedTax] < @ZeroDecimal THEN ABS(ARITD.[dblAdjustedTax]) ELSE @ZeroDecimal END )
                                           ELSE (CASE WHEN ARITD.[dblAdjustedTax] < @ZeroDecimal THEN @ZeroDecimal ELSE ARITD.[dblAdjustedTax] END)
                                      END
    ,[dblCreditForeign]             = CASE WHEN I.[ysnIsInvoicePositive] = 0 
                                           THEN (CASE WHEN ARITD.[dblAdjustedTax] < @ZeroDecimal THEN ABS(ARITD.[dblAdjustedTax]) ELSE @ZeroDecimal END )
                                           ELSE (CASE WHEN ARITD.[dblAdjustedTax] < @ZeroDecimal THEN @ZeroDecimal ELSE ARITD.[dblAdjustedTax] END)
                                      END
    ,[dblCreditReport]              = CASE WHEN I.[ysnIsInvoicePositive] = 0 
                                           THEN (CASE WHEN ARITD.[dblAdjustedTax] < @ZeroDecimal THEN ABS(ARITD.[dblAdjustedTax]) ELSE @ZeroDecimal END )
                                           ELSE (CASE WHEN ARITD.[dblAdjustedTax] < @ZeroDecimal THEN @ZeroDecimal ELSE ARITD.[dblAdjustedTax] END)
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
	) ARITD
INNER JOIN
    #ARPostInvoiceDetail I
        ON ARITD.[intInvoiceDetailId] = I.[intInvoiceDetailId]
WHERE
    I.[intInvoiceId] = @InvoiceId
    AND ARITD.[dblBaseAdjustedTax] <> @ZeroDecimal
		
UNION ALL
	
	--CREDIT Tax
	--SELECT
	--	 dtmDate					= CAST(ISNULL(A.dtmPostDate, A.dtmDate) AS DATE)
	--	,strBatchID					= @BatchId
	--	,intAccountId				= ISNULL(DT.intSalesTaxAccountId,TC.intSalesTaxAccountId)
	--	,dblDebit					= CASE WHEN A.strTransactionType  IN ('Invoice', 'Cash') THEN @ZeroDecimal ELSE DT.dblBaseAdjustedTax END
	--	,dblCredit					= CASE WHEN A.strTransactionType  IN ('Invoice', 'Cash') THEN DT.dblBaseAdjustedTax ELSE @ZeroDecimal END
	--	,dblDebitUnit				= @ZeroDecimal
	--	,dblCreditUnit				= @ZeroDecimal				
	--	,strDescription				= A.strComments
	--	,strCode					= @CODE
	--	,strReference				= C.strCustomerNumber
	--	,intCurrencyId				= A.intCurrencyId 
	--	,dblExchangeRate			= ISNULL(D.dblCurrencyExchangeRate, 1.000000)
	--	,dtmDateEntered				= @PostDate 
	--	,dtmTransactionDate			= A.dtmDate
	--	,strJournalLineDescription	= 'Posted ' + A.strTransactionType 
	--	,intJournalLineNo			= A.intInvoiceId
	--	,ysnIsUnposted				= 0
	--	,intUserId					= @UserId
	--	,intEntityId				= @UserEntityId 				
	--	,strTransactionId			= A.strInvoiceNumber
	--	,intTransactionId			= A.intInvoiceId
	--	,strTransactionType			= A.strTransactionType
	--	,strTransactionForm			= @SCREEN_NAME 
	--	,strModuleName				= @MODULE_NAME 
	--	,intConcurrencyId			= 1
	--	,[dblDebitForeign]			= CASE WHEN A.strTransactionType  IN ('Invoice', 'Cash') THEN 0 ELSE DT.dblAdjustedTax END
	--	,[dblDebitReport]			= CASE WHEN A.strTransactionType  IN ('Invoice', 'Cash') THEN 0 ELSE DT.dblAdjustedTax END
	--	,[dblCreditForeign]			= CASE WHEN A.strTransactionType  IN ('Invoice', 'Cash') THEN DT.dblAdjustedTax ELSE 0 END
	--	,[dblCreditReport]			= CASE WHEN A.strTransactionType  IN ('Invoice', 'Cash') THEN DT.dblAdjustedTax ELSE 0 END
	--	,[dblReportingRate]			= ISNULL(D.dblCurrencyExchangeRate, 1.000000)
	--	,[dblForeignRate]			= ISNULL(D.dblCurrencyExchangeRate, 1.000000)
	--	,[strRateType]				= SMCERT.strCurrencyExchangeRateType			 
	--FROM
	--	tblARInvoiceDetailTax DT
	--INNER JOIN
	--	tblARInvoiceDetail D
	--		ON DT.intInvoiceDetailId = D.intInvoiceDetailId
	--INNER JOIN			
	--	tblARInvoice A 
	--		ON D.intInvoiceId = A.intInvoiceId
	--INNER JOIN
	--	tblARCustomer C
	--		ON A.intEntityCustomerId = C.[intEntityId]			
	--LEFT OUTER JOIN
	--	tblSMTaxCode TC
	--		ON DT.intTaxCodeId = TC.intTaxCodeId
	--LEFT OUTER JOIN
	--		tblSMCurrencyExchangeRateType SMCERT
	--			ON D.intCurrencyExchangeRateTypeId = SMCERT.intCurrencyExchangeRateTypeId	
	--WHERE
	--	A.intInvoiceId = @InvoiceId
	--	AND DT.dblAdjustedTax <> @ZeroDecimal
SELECT
     [dtmDate]                      = CAST(ISNULL(I.[dtmPostDate], I.[dtmDate]) AS DATE)
    ,[strBatchId]                   = I.[strBatchId]
    ,[intAccountId]                 = ARITD.[intSalesTaxAccountId]
    ,[dblDebit]                     = CASE WHEN I.[ysnIsInvoicePositive] = 0 
                                           THEN (CASE WHEN ARITD.[dblBaseAdjustedTax] < @ZeroDecimal THEN ABS(ARITD.[dblBaseAdjustedTax]) ELSE @ZeroDecimal END )
                                           ELSE (CASE WHEN ARITD.[dblBaseAdjustedTax] < @ZeroDecimal THEN @ZeroDecimal ELSE ARITD.[dblBaseAdjustedTax] END)
                                      END
    ,[dblCredit]                    = CASE WHEN I.[ysnIsInvoicePositive] = 1 
                                           THEN (CASE WHEN ARITD.[dblBaseAdjustedTax] < @ZeroDecimal THEN ABS(ARITD.[dblBaseAdjustedTax]) ELSE @ZeroDecimal END )
                                           ELSE (CASE WHEN ARITD.[dblBaseAdjustedTax] < @ZeroDecimal THEN @ZeroDecimal ELSE ARITD.[dblBaseAdjustedTax] END)
                                      END
    ,[dblDebitUnit]                 = @ZeroDecimal
    ,[dblCreditUnit]                = @ZeroDecimal
    ,[strDescription]               = I.[strDescription]
    ,[strCode]                      = @CODE
    ,[strReference]                 = I.[strComments]
    ,[intCurrencyId]                = I.[intCurrencyId]
    ,[dblExchangeRate]              = I.[dblCurrencyExchangeRate]
    ,[dtmDateEntered]               = I.[dtmPostDate]
    ,[dtmTransactionDate]           = I.[dtmDate]
    ,[strJournalLineDescription]    = @POSTDESC + I.[strTransactionType]
    ,[intJournalLineNo]             = ARITD.[intInvoiceDetailTaxId]
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
                                           THEN (CASE WHEN ARITD.[dblAdjustedTax] < @ZeroDecimal THEN ABS(ARITD.[dblAdjustedTax]) ELSE @ZeroDecimal END )
                                           ELSE (CASE WHEN ARITD.[dblAdjustedTax] < @ZeroDecimal THEN @ZeroDecimal ELSE ARITD.[dblAdjustedTax] END)
                                      END
    ,[dblDebitReport]               = CASE WHEN I.[ysnIsInvoicePositive] = 0 
                                           THEN (CASE WHEN ARITD.[dblAdjustedTax] < @ZeroDecimal THEN ABS(ARITD.[dblAdjustedTax]) ELSE @ZeroDecimal END )
                                           ELSE (CASE WHEN ARITD.[dblAdjustedTax] < @ZeroDecimal THEN @ZeroDecimal ELSE ARITD.[dblAdjustedTax] END)
                                      END
    ,[dblCreditForeign]             = CASE WHEN I.[ysnIsInvoicePositive] = 1 
                                           THEN (CASE WHEN ARITD.[dblAdjustedTax] < @ZeroDecimal THEN ABS(ARITD.[dblAdjustedTax]) ELSE @ZeroDecimal END )
                                           ELSE (CASE WHEN ARITD.[dblAdjustedTax] < @ZeroDecimal THEN @ZeroDecimal ELSE ARITD.[dblAdjustedTax] END)
                                      END
    ,[dblCreditReport]              = CASE WHEN I.[ysnIsInvoicePositive] = 1 
                                           THEN (CASE WHEN ARITD.[dblAdjustedTax] < @ZeroDecimal THEN ABS(ARITD.[dblAdjustedTax]) ELSE @ZeroDecimal END )
                                           ELSE (CASE WHEN ARITD.[dblAdjustedTax] < @ZeroDecimal THEN @ZeroDecimal ELSE ARITD.[dblAdjustedTax] END)
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
	) ARITD
INNER JOIN
    #ARPostInvoiceDetail I
        ON ARITD.[intInvoiceDetailId] = I.[intInvoiceDetailId]
WHERE
    I.[intInvoiceId] = @InvoiceId
    AND ARITD.[dblBaseAdjustedTax] <> @ZeroDecimal

END


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
FROM
	@GLEntries
GO


