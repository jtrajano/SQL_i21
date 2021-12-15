CREATE PROCEDURE [dbo].[uspARGenerateEntriesForAccrual]

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

WHILE EXISTS(SELECT NULL FROM ##ARPostInvoiceHeader I LEFT OUTER JOIN @GLEntries G ON I.[intInvoiceId] = G.[intTransactionId] WHERE I.[intPeriodsToAccrue] > 1 AND ISNULL(G.[intTransactionId],0) = 0)
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

    SELECT TOP 1 @InvoiceId = I.[intInvoiceId] FROM ##ARPostInvoiceHeader I LEFT OUTER JOIN @GLEntries G ON I.[intInvoiceId] = G.[intTransactionId] WHERE I.[intPeriodsToAccrue] > 1 AND ISNULL(G.intTransactionId,0) = 0

    SELECT
        @AccrualPeriod = [intPeriodsToAccrue]
    FROM
        ##ARPostInvoiceHeader
    WHERE
        [intInvoiceId] = @InvoiceId 

    --DEBIT AR
	INSERT INTO ##ARInvoiceGLEntries
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
        ,[ysnRebuild]
	)	
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
        ##ARPostInvoiceHeader I
    LEFT OUTER JOIN
        (
        SELECT
             [dblUnitQtyShipped]    = SUM([dblUnitQtyShipped])
            ,[intInvoiceId]         = [intInvoiceId]
        FROM
            ##ARPostInvoiceDetail
        GROUP BY
            [intInvoiceId]
        ) ARID
            ON I.[intInvoiceId] = ARID.[intInvoiceId]
    WHERE
        I.[intInvoiceId] = @InvoiceId

	UNION ALL
	 
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
        ##ARPostInvoiceHeader I
    LEFT OUTER JOIN
        (
        SELECT
             [dblUnitQtyShipped]        = SUM([dblUnitQtyShipped])
            ,[dblDiscountAmount]        = SUM([dblDiscountAmount])
            ,[dblBaseDiscountAmount]    = SUM([dblBaseDiscountAmount])
            ,[intInvoiceId]             = [intInvoiceId]
        FROM
            ##ARPostInvoiceDetail
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
        ##ARPostInvoiceDetail ARID
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
        ##ARPostInvoiceDetail ARID
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
        ##ARPostInvoiceDetail ARID
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
        ##ARPostInvoiceDetail ARID
    WHERE
        ARID.[intInvoiceId] = @InvoiceId 
        AND ARID.[dblMaintenanceAmount] <> @ZeroDecimal
        AND ARID.strMaintenanceType  IN ('Maintenance Only', 'SaaS')
        -- AND ARID.[ysnAccrueLicense] = 1
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
            ##ARPostInvoiceDetail I
        INNER JOIN
            tblARInvoiceAccrual ARIA
                ON I.[intInvoiceDetailId] = ARIA.[intInvoiceDetailId]
        WHERE
            I.[intInvoiceDetailId] = @InvoiceDetailId
            AND I.[dblTotal] <> @ZeroDecimal
            AND (
                I.[intItemId] IS NULL
                OR
                I.[strItemType] IN ('Non-Inventory','Service','Other Charge')
                )
            AND I.[strTransactionType] <> 'Debit Memo'

		UNION ALL

		--CREDIT	
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
																	      THEN (CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN ARIA.[dblAmount] ELSE @ZeroDecimal END)
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
																	      THEN (CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN ARIA.[dblAmount] ELSE @ZeroDecimal END)
																		  ELSE (CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN @ZeroDecimal ELSE ARIA.[dblAmount] END)
																	END)
                                                                  ), [dbo].[fnARGetDefaultDecimal]())
            ,[dblCreditReport]              = [dbo].fnRoundBanker((
                                                                    (CASE WHEN I.[intPeriodsToAccrue] > 1
																	      THEN (CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN ARIA.[dblAmount] ELSE @ZeroDecimal END)
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
            ##ARPostInvoiceDetail I
        INNER JOIN
            tblARInvoiceAccrual ARIA
                ON I.[intInvoiceDetailId] = ARIA.[intInvoiceDetailId]
        LEFT OUTER JOIN
            ##ARInvoiceItemAccount IA
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
		
		UNION ALL 

		--DEBIT Software -- License		
        SELECT
             [dtmDate]                      = ARIA.[dtmAccrualDate]
            ,[strBatchId]                   = I.[strBatchId]
            ,[intAccountId]                 = I.[intDeferredRevenueAccountId]
            ,[dblDebit]                     = [dbo].fnRoundBanker((
                                                                    (CASE WHEN I.[intPeriodsToAccrue] > 1
																	      THEN (CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN ARIA.[dblAmount] ELSE @ZeroDecimal END) 
																		  ELSE (CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN @ZeroDecimal ELSE ARIA.[dblAmount] END)
																	END)
                                                                    * I.[dblCurrencyExchangeRate]
                                                                  ), [dbo].[fnARGetDefaultDecimal]())
            ,[dblCredit]                    = [dbo].fnRoundBanker((
                                                                    (CASE WHEN I.[intPeriodsToAccrue] > 1
																	      THEN (CASE WHEN I.[ysnIsInvoicePositive] = 0 THEN ARIA.[dblAmount] ELSE @ZeroDecimal END) 
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
																	      THEN (CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN ARIA.[dblAmount] ELSE @ZeroDecimal END) 
																		  ELSE (CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN @ZeroDecimal ELSE ARIA.[dblAmount] END)
																	END)
                                                                  ), [dbo].[fnARGetDefaultDecimal]())
            ,[dblDebitReport]               = [dbo].fnRoundBanker((
                                                                    (CASE WHEN I.[intPeriodsToAccrue] > 1
																	      THEN (CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN ARIA.[dblAmount] ELSE @ZeroDecimal END) 
																		  ELSE (CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN @ZeroDecimal ELSE ARIA.[dblAmount] END)
																	END)
                                                                  ), [dbo].[fnARGetDefaultDecimal]())
            ,[dblCreditForeign]             = [dbo].fnRoundBanker((
                                                                    (CASE WHEN I.[intPeriodsToAccrue] > 1
																	      THEN (CASE WHEN I.[ysnIsInvoicePositive] = 0 THEN ARIA.[dblAmount] ELSE @ZeroDecimal END) 
																		  ELSE (CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN @ZeroDecimal ELSE ARIA.[dblAmount] END)
																	END)
                                                                  ), [dbo].[fnARGetDefaultDecimal]())
            ,[dblCreditReport]              = [dbo].fnRoundBanker((
                                                                    (CASE WHEN I.[intPeriodsToAccrue] > 1
																	      THEN (CASE WHEN I.[ysnIsInvoicePositive] = 0 THEN ARIA.[dblAmount] ELSE @ZeroDecimal END) 
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
            ##ARPostInvoiceDetail I
        INNER JOIN
            tblARInvoiceAccrual ARIA
                ON I.[intInvoiceDetailId] = ARIA.[intInvoiceDetailId]
        LEFT OUTER JOIN
            ##ARInvoiceItemAccount IA
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
		
		UNION ALL 

		--CREDIT Software -- License		
        SELECT
             [dtmDate]                      = ARIA.[dtmAccrualDate]
            ,[strBatchId]                   = I.[strBatchId]
            ,[intAccountId]                 = IA.[intGeneralAccountId]
            ,[dblDebit]                     = [dbo].fnRoundBanker((
                                                                    (CASE WHEN I.[intPeriodsToAccrue] > 1
																	      THEN (CASE WHEN I.[ysnIsInvoicePositive] = 0 THEN ARIA.[dblAmount] ELSE @ZeroDecimal END) 
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
																	      THEN (CASE WHEN I.[ysnIsInvoicePositive] = 0 THEN ARIA.[dblAmount] ELSE @ZeroDecimal END) 
																		  ELSE (CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN @ZeroDecimal ELSE ARIA.[dblAmount] END)
																	END)
                                                                  ), [dbo].[fnARGetDefaultDecimal]())
            ,[dblDebitReport]               = [dbo].fnRoundBanker((
                                                                    (CASE WHEN I.[intPeriodsToAccrue] > 1
																	      THEN (CASE WHEN I.[ysnIsInvoicePositive] = 0 THEN ARIA.[dblAmount] ELSE @ZeroDecimal END) 
																		  ELSE (CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN @ZeroDecimal ELSE ARIA.[dblAmount] END)
																	END)
                                                                  ), [dbo].[fnARGetDefaultDecimal]())
            ,[dblCreditForeign]             = [dbo].fnRoundBanker((
                                                                    (CASE WHEN I.[intPeriodsToAccrue] > 1
																	      THEN (CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN ARIA.[dblAmount] ELSE @ZeroDecimal END) 
																		  ELSE (CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN @ZeroDecimal ELSE ARIA.[dblAmount] END)
																	END)
                                                                  ), [dbo].[fnARGetDefaultDecimal]())
            ,[dblCreditReport]              = [dbo].fnRoundBanker((
                                                                    (CASE WHEN I.[intPeriodsToAccrue] > 1
																	      THEN (CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN ARIA.[dblAmount] ELSE @ZeroDecimal END) 
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
            ##ARPostInvoiceDetail I
        INNER JOIN
            tblARInvoiceAccrual ARIA
                ON I.[intInvoiceDetailId] = ARIA.[intInvoiceDetailId]
        LEFT OUTER JOIN
            ##ARInvoiceItemAccount IA
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
		
		UNION ALL 

		--DEBIT Software -- Maintenance		
        SELECT
             [dtmDate]                      = ARIA.[dtmAccrualDate]
            ,[strBatchId]                   = I.[strBatchId]
            ,[intAccountId]                 = I.[intDeferredRevenueAccountId]
            ,[dblDebit]                     = [dbo].fnRoundBanker((
                                                                    (CASE WHEN I.[intPeriodsToAccrue] > 1
																	      THEN (CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN ARIA.[dblAmount] ELSE @ZeroDecimal END) 
																		  ELSE (CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN @ZeroDecimal ELSE ARIA.[dblAmount] END)
																	END)
                                                                    * I.[dblCurrencyExchangeRate]
                                                                  ), [dbo].[fnARGetDefaultDecimal]())
            ,[dblCredit]                    = [dbo].fnRoundBanker((
                                                                    (CASE WHEN I.[intPeriodsToAccrue] > 1
																	      THEN (CASE WHEN I.[ysnIsInvoicePositive] = 0 THEN ARIA.[dblAmount] ELSE @ZeroDecimal END) 
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
																	      THEN (CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN ARIA.[dblAmount] ELSE @ZeroDecimal END) 
																		  ELSE (CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN @ZeroDecimal ELSE ARIA.[dblAmount] END)
																	END)
                                                                  ), [dbo].[fnARGetDefaultDecimal]())
            ,[dblDebitReport]               = [dbo].fnRoundBanker((
                                                                    (CASE WHEN I.[intPeriodsToAccrue] > 1
																	      THEN (CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN ARIA.[dblAmount] ELSE @ZeroDecimal END) 
																		  ELSE (CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN @ZeroDecimal ELSE ARIA.[dblAmount] END)
																	END)
                                                                  ), [dbo].[fnARGetDefaultDecimal]())
            ,[dblCreditForeign]             = [dbo].fnRoundBanker((
                                                                    (CASE WHEN I.[intPeriodsToAccrue] > 1
																	      THEN (CASE WHEN I.[ysnIsInvoicePositive] = 0 THEN ARIA.[dblAmount] ELSE @ZeroDecimal END) 
																		  ELSE (CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN @ZeroDecimal ELSE ARIA.[dblAmount] END)
																	END)
                                                                  ), [dbo].[fnARGetDefaultDecimal]())
            ,[dblCreditReport]              = [dbo].fnRoundBanker((
                                                                    (CASE WHEN I.[intPeriodsToAccrue] > 1
																	      THEN (CASE WHEN I.[ysnIsInvoicePositive] = 0 THEN ARIA.[dblAmount] ELSE @ZeroDecimal END) 
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
            ##ARPostInvoiceDetail I
        INNER JOIN
            tblARInvoiceAccrual ARIA
                ON I.[intInvoiceDetailId] = ARIA.[intInvoiceDetailId]
        LEFT OUTER JOIN
            ##ARInvoiceItemAccount IA
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
		
		UNION ALL 

		--CREDIT Software -- Maintenance		
        SELECT
             [dtmDate]                      = ARIA.[dtmAccrualDate]
            ,[strBatchId]                   = I.[strBatchId]
            ,[intAccountId]                 = IA.[intMaintenanceSalesAccountId]
            ,[dblDebit]                     = [dbo].fnRoundBanker((
                                                                    (CASE WHEN I.[intPeriodsToAccrue] > 1
																	      THEN (CASE WHEN I.[ysnIsInvoicePositive] = 0 THEN ARIA.[dblAmount] ELSE @ZeroDecimal END) 
																		  ELSE (CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN @ZeroDecimal ELSE ARIA.[dblAmount] END)
																	END)
                                                                    * I.[dblCurrencyExchangeRate]
                                                                  ), [dbo].[fnARGetDefaultDecimal]())
            ,[dblCredit]                    = [dbo].fnRoundBanker((
                                                                    (CASE WHEN I.[intPeriodsToAccrue] > 1
																	      THEN (CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN ARIA.[dblAmount] ELSE @ZeroDecimal END) 
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
																	      THEN (CASE WHEN I.[ysnIsInvoicePositive] = 0 THEN ARIA.[dblAmount] ELSE @ZeroDecimal END)
																		  ELSE (CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN @ZeroDecimal ELSE ARIA.[dblAmount] END)
																	END)
                                                                  ), [dbo].[fnARGetDefaultDecimal]())
            ,[dblDebitReport]               = [dbo].fnRoundBanker((
                                                                    (CASE WHEN I.[intPeriodsToAccrue] > 1
																	      THEN (CASE WHEN I.[ysnIsInvoicePositive] = 0 THEN ARIA.[dblAmount] ELSE @ZeroDecimal END)
																		  ELSE (CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN @ZeroDecimal ELSE ARIA.[dblAmount] END)
																	END)
                                                                  ), [dbo].[fnARGetDefaultDecimal]())
            ,[dblCreditForeign]             = [dbo].fnRoundBanker((
                                                                    (CASE WHEN I.[intPeriodsToAccrue] > 1
																	      THEN (CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN ARIA.[dblAmount] ELSE @ZeroDecimal END) 
																		  ELSE (CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN @ZeroDecimal ELSE ARIA.[dblAmount] END)
																	END)
                                                                  ), [dbo].[fnARGetDefaultDecimal]())
            ,[dblCreditReport]              = [dbo].fnRoundBanker((
                                                                    (CASE WHEN I.[intPeriodsToAccrue] > 1
																	      THEN (CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN ARIA.[dblAmount] ELSE @ZeroDecimal END) 
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
            ##ARPostInvoiceDetail I
        INNER JOIN
            tblARInvoiceAccrual ARIA
                ON I.[intInvoiceDetailId] = ARIA.[intInvoiceDetailId]
        LEFT OUTER JOIN
            ##ARInvoiceItemAccount IA
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
SELECT
     [dtmDate]                      = CAST(ISNULL(I.[dtmPostDate], I.[dtmDate]) AS DATE)
    ,[strBatchId]                   = I.[strBatchId]
    ,[intAccountId]                 = I.[intDeferredRevenueAccountId]    
	,dblDebit						= CASE WHEN I.[ysnIsInvoicePositive] = 1  THEN ARITD.dblBaseAdjustedTax ELSE @ZeroDecimal END
	,dblCredit						= CASE WHEN I.[ysnIsInvoicePositive] = 1  THEN @ZeroDecimal ELSE ARITD.dblBaseAdjustedTax END		
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
	,[dblDebitForeign]              = CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN (ARITD.[dblAdjustedTax]) ELSE @ZeroDecimal END
    ,[dblDebitReport]               = CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN (ARITD.[dblAdjustedTax]) ELSE @ZeroDecimal END 
    ,[dblCreditForeign]             = CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN @ZeroDecimal ELSE ARITD.[dblAdjustedTax] END
    ,[dblCreditReport]              = CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN @ZeroDecimal ELSE ARITD.[dblAdjustedTax] END
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
    ##ARPostInvoiceDetail I
        ON ARITD.[intInvoiceDetailId] = I.[intInvoiceDetailId]
WHERE
    I.[intInvoiceId] = @InvoiceId
    AND ARITD.[dblBaseAdjustedTax] <> @ZeroDecimal
		
UNION ALL
	
SELECT
     [dtmDate]                      = CAST(ISNULL(I.[dtmPostDate], I.[dtmDate]) AS DATE)
    ,[strBatchId]                   = I.[strBatchId]
    ,[intAccountId]                 = ARITD.[intSalesTaxAccountId]
    ,dblDebit						= CASE WHEN I.[ysnIsInvoicePositive] = 1  THEN @ZeroDecimal ELSE ARITD.dblBaseAdjustedTax END
	,dblCredit						= CASE WHEN I.[ysnIsInvoicePositive] = 1  THEN ARITD.dblBaseAdjustedTax ELSE @ZeroDecimal END		
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
	,[dblDebitForeign]              = CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN @ZeroDecimal ELSE ARITD.[dblAdjustedTax] END
    ,[dblDebitReport]               = CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN @ZeroDecimal ELSE ARITD.[dblAdjustedTax] END
    ,[dblCreditForeign]             = CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN (ARITD.[dblAdjustedTax]) ELSE @ZeroDecimal END
    ,[dblCreditReport]              = CASE WHEN I.[ysnIsInvoicePositive] = 1 THEN (ARITD.[dblAdjustedTax]) ELSE @ZeroDecimal END 
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
    ##ARPostInvoiceDetail I
        ON ARITD.[intInvoiceDetailId] = I.[intInvoiceDetailId]
WHERE
    I.[intInvoiceId] = @InvoiceId
    AND ARITD.[dblBaseAdjustedTax] <> @ZeroDecimal

    IF NOT EXISTS(SELECT TOP 1 NULL FROM @GLEntries)
	BEGIN
		BREAK;
	END
END

INSERT INTO ##ARInvoiceGLEntries
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
    [dtmDate]                      = GLEntries.[dtmDate]
   ,[strBatchId]                   = GLEntries.[strBatchId]
   ,[intAccountId]                 = GLEntries.[intAccountId]
   ,[dblDebit]                     = GLEntries.[dblDebit]
   ,[dblCredit]                    = GLEntries.[dblCredit]
   ,[dblDebitUnit]                 = DebitUnit.Value
   ,[dblCreditUnit]                = CreditUnit.Value
   ,[strDescription]               = GLEntries.[strDescription]
   ,[strCode]                      = GLEntries.[strCode]
   ,[strReference]                 = GLEntries.[strReference]
   ,[intCurrencyId]                = GLEntries.[intCurrencyId]
   ,[dblExchangeRate]              = GLEntries.[dblExchangeRate]
   ,[dtmDateEntered]               = GLEntries.[dtmDateEntered]
   ,[dtmTransactionDate]           = GLEntries.[dtmTransactionDate]
   ,[strJournalLineDescription]    = GLEntries.[strJournalLineDescription]
   ,[intJournalLineNo]             = GLEntries.[intJournalLineNo]
   ,[ysnIsUnposted]                = GLEntries.[ysnIsUnposted]
   ,[intUserId]                    = GLEntries.[intUserId]
   ,[intEntityId]                  = GLEntries.[intEntityId]
   ,[strTransactionId]             = GLEntries.[strTransactionId]
   ,[intTransactionId]             = GLEntries.[intTransactionId]
   ,[strTransactionType]           = GLEntries.[strTransactionType]
   ,[strTransactionForm]           = GLEntries.[strTransactionForm]
   ,[strModuleName]                = GLEntries.[strModuleName]
   ,[intConcurrencyId]             = GLEntries.[intConcurrencyId]
   ,[dblDebitForeign]              = GLEntries.[dblDebitForeign]
   ,[dblDebitReport]               = GLEntries.[dblDebitReport]
   ,[dblCreditForeign]             = GLEntries.[dblCreditForeign]
   ,[dblCreditReport]              = GLEntries.[dblCreditReport]
   ,[dblReportingRate]             = GLEntries.[dblReportingRate]
   ,[dblForeignRate]               = GLEntries.[dblForeignRate]
   ,[strRateType]                  = GLEntries.[strRateType]
   ,[strDocument]                  = GLEntries.[strDocument]
   ,[strComments]                  = GLEntries.[strComments]
   ,[strSourceDocumentId]          = GLEntries.[strSourceDocumentId]
   ,[intSourceLocationId]          = GLEntries.[intSourceLocationId]
   ,[intSourceUOMId]               = GLEntries.[intSourceUOMId]
   ,[dblSourceUnitDebit]           = GLEntries.[dblSourceUnitDebit]
   ,[dblSourceUnitCredit]          = GLEntries.[dblSourceUnitCredit]
   ,[intCommodityId]               = GLEntries.[intCommodityId]
   ,[intSourceEntityId]            = GLEntries.[intSourceEntityId]
   ,[ysnRebuild]                   = GLEntries.[ysnRebuild]
FROM
	@GLEntries GLEntries
CROSS APPLY dbo.fnGetDebitUnit(ISNULL(GLEntries.dblDebitUnit, 0.000000) - ISNULL(GLEntries.dblCreditUnit, 0.000000)) DebitUnit
CROSS APPLY dbo.fnGetCreditUnit(ISNULL(GLEntries.dblDebitUnit, 0.000000) - ISNULL(GLEntries.dblCreditUnit, 0.000000)) CreditUnit

GO