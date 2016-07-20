﻿CREATE PROCEDURE [dbo].[uspARGenerateEntriesForAccrual]
	 @Invoices					Id READONLY
	,@DeferredRevenueAccountId	INT
	,@ServiceChargesAccountId	INT
	,@BatchId					NVARCHAR(40)
	,@Code						NVARCHAR(25)
	,@UserId					INT
	,@UserEntityId				INT
	,@ScreenName				NVARCHAR(25)
	,@ModuleName				NVARCHAR(25)
AS

DECLARE @GLEntries AS RecapTableType
DECLARE @ZeroDecimal decimal(18,6)
SET @ZeroDecimal = 0.000000	

DECLARE @PostDate AS DATETIME
SET @PostDate = CAST(GETDATE() AS DATE)

WHILE EXISTS(SELECT NULL FROM @Invoices I LEFT OUTER JOIN @GLEntries G ON I.intId = G.intTransactionId WHERE ISNULL(G.intTransactionId,0) = 0)
BEGIN
	DECLARE  @InvoiceId				INT
			,@AccrualPeriod			INT
			,@LoopCounter			INT
			,@TaxLoopCounter		INT
			,@Remainder				DECIMAL(18,6)
			,@RemainderWODiscount	DECIMAL(18,6)
			,@UnitsRemainder		DECIMAL(18,6)
			,@TaxRemainder			DECIMAL(18,6)
	SELECT TOP 1 @InvoiceId = I.intId FROM @Invoices I LEFT OUTER JOIN @GLEntries G ON I.intId = G.intTransactionId WHERE ISNULL(G.intTransactionId,0) = 0

	SELECT
		@AccrualPeriod = intPeriodsToAccrue
	FROM
		tblARInvoice
	WHERE
		intInvoiceId = @InvoiceId 

	--DEBIT AR
	INSERT INTO @GLEntries (
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
			)
	SELECT
		 dtmDate					= CAST(ISNULL(A.dtmPostDate, A.dtmDate) AS DATE)
		,strBatchID					= @BatchId
		,intAccountId				= A.intAccountId
		,dblDebit					= CASE WHEN A.strTransactionType = 'Invoice' THEN  A.dblInvoiceTotal ELSE 0 END
		,dblCredit					= CASE WHEN A.strTransactionType = 'Invoice' THEN  0 ELSE A.dblInvoiceTotal END
		,dblDebitUnit				= CASE WHEN A.strTransactionType = 'Invoice'	THEN  
																						(
																						SELECT
																							SUM(ISNULL([dbo].[fnCalculateQtyBetweenUOM](ARID.intItemUOMId, ICIS.intStockUOMId, ARID.dblQtyShipped),ISNULL(ARID.dblQtyShipped, 0.00)))
																						FROM
																							tblARInvoiceDetail ARID 
																						INNER JOIN
																							tblARInvoice ARI
																								ON ARID.intInvoiceId = ARI.intInvoiceId	
																						LEFT OUTER JOIN
																							tblICItem I
																								ON ARID.intItemId = I.intItemId
																						LEFT OUTER JOIN
																							vyuARGetItemAccount IST
																								ON ARID.intItemId = IST.intItemId 
																								AND ARI.intCompanyLocationId = IST.intLocationId 
																						LEFT OUTER JOIN
																							vyuICGetItemStock ICIS
																								ON ARID.intItemId = ICIS.intItemId 
																								AND ARI.intCompanyLocationId = ICIS.intLocationId 
																						WHERE
																							ARI.intInvoiceId = A.intInvoiceId
																							AND ARID.dblTotal <> @ZeroDecimal  
																						)
																					ELSE 
																						0
																					END
		,dblCreditUnit				=  CASE WHEN A.strTransactionType = 'Invoice'	THEN  
																						0
																					ELSE 
																						(
																						SELECT
																							SUM(ISNULL([dbo].[fnCalculateQtyBetweenUOM](ARID.intItemUOMId, ICIS.intStockUOMId, ARID.dblQtyShipped),ISNULL(ARID.dblQtyShipped, 0.00)))
																						FROM
																							tblARInvoiceDetail ARID 
																						INNER JOIN
																							tblARInvoice ARI
																								ON ARID.intInvoiceId = ARI.intInvoiceId	
																						LEFT OUTER JOIN
																							tblICItem I
																								ON ARID.intItemId = I.intItemId
																						LEFT OUTER JOIN
																							vyuARGetItemAccount IST
																								ON ARID.intItemId = IST.intItemId 
																								AND ARI.intCompanyLocationId = IST.intLocationId 
																						LEFT OUTER JOIN
																							vyuICGetItemStock ICIS
																								ON ARID.intItemId = ICIS.intItemId 
																								AND ARI.intCompanyLocationId = ICIS.intLocationId 
																						WHERE
																							ARI.intInvoiceId = A.intInvoiceId
																							AND ARID.dblTotal <> @ZeroDecimal  
																						)
																					END				
		,strDescription				= A.strComments
		,strCode					= @Code
		,strReference				= C.strCustomerNumber
		,intCurrencyId				= A.intCurrencyId 
		,dblExchangeRate			= 1
		,dtmDateEntered				= @PostDate 
		,dtmTransactionDate			= A.dtmDate
		,strJournalLineDescription	= 'Posted ' + A.strTransactionType 
		,intJournalLineNo			= A.intInvoiceId
		,ysnIsUnposted				= 0
		,intUserId					= @UserId
		,intEntityId				= @UserEntityId 				
		,strTransactionId			= A.strInvoiceNumber
		,intTransactionId			= A.intInvoiceId
		,strTransactionType			= A.strTransactionType
		,strTransactionForm			= @ScreenName 
		,strModuleName				= @ModuleName 
		,intConcurrencyId			= 1				 
	FROM
		tblARInvoice A
	LEFT JOIN 
		tblARCustomer C
			ON A.[intEntityCustomerId] = C.intEntityCustomerId 			
	WHERE
		A.intInvoiceId = @InvoiceId 

	UNION ALL
	--CREDIT Deferred Revenue
	SELECT
		 dtmDate					= CAST(ISNULL(A.dtmPostDate, A.dtmDate) AS DATE)
		,strBatchID					= @BatchId
		,intAccountId				= @DeferredRevenueAccountId
		,dblDebit					= CASE WHEN A.strTransactionType = 'Invoice' THEN  0 ELSE A.dblInvoiceTotal END
		,dblCredit					= CASE WHEN A.strTransactionType = 'Invoice' THEN  A.dblInvoiceTotal ELSE 0 END
		,dblDebitUnit				= CASE WHEN A.strTransactionType = 'Invoice' THEN  0
																					ELSE
																						(
																						SELECT
																							SUM(ISNULL([dbo].[fnCalculateQtyBetweenUOM](ARID.intItemUOMId, ICIS.intStockUOMId, ARID.dblQtyShipped),ISNULL(ARID.dblQtyShipped, 0.00)))
																						FROM
																							tblARInvoiceDetail ARID 
																						INNER JOIN
																							tblARInvoice ARI
																								ON ARID.intInvoiceId = ARI.intInvoiceId	
																						LEFT OUTER JOIN
																							tblICItem I
																								ON ARID.intItemId = I.intItemId
																						LEFT OUTER JOIN
																							vyuARGetItemAccount IST
																								ON ARID.intItemId = IST.intItemId 
																								AND ARI.intCompanyLocationId = IST.intLocationId 
																						LEFT OUTER JOIN
																							vyuICGetItemStock ICIS
																								ON ARID.intItemId = ICIS.intItemId 
																								AND ARI.intCompanyLocationId = ICIS.intLocationId 
																						WHERE
																							ARI.intInvoiceId = A.intInvoiceId
																							AND ARID.dblTotal <> @ZeroDecimal  
																						)
																					END
		,dblCreditUnit				=  CASE WHEN A.strTransactionType = 'Invoice' THEN (
																						SELECT
																							SUM(ISNULL([dbo].[fnCalculateQtyBetweenUOM](ARID.intItemUOMId, ICIS.intStockUOMId, ARID.dblQtyShipped),ISNULL(ARID.dblQtyShipped, 0.00)))
																						FROM
																							tblARInvoiceDetail ARID
																						INNER JOIN
																							tblARInvoice ARI 
																								ON ARID.intInvoiceId = ARI.intInvoiceId	
																						LEFT OUTER JOIN
																							tblICItem I
																								ON ARID.intItemId = I.intItemId
																						LEFT OUTER JOIN
																							vyuARGetItemAccount IST
																								ON ARID.intItemId = IST.intItemId 
																								AND ARI.intCompanyLocationId = IST.intLocationId 
																						LEFT OUTER JOIN
																							vyuICGetItemStock ICIS
																								ON ARID.intItemId = ICIS.intItemId 
																								AND ARI.intCompanyLocationId = ICIS.intLocationId 
																						WHERE
																							ARI.intInvoiceId = A.intInvoiceId 
																							AND ARID.dblTotal <> @ZeroDecimal
																						)																						
																					ELSE
																						0
																					END				
		,strDescription				= A.strComments
		,strCode					= @Code
		,strReference				= C.strCustomerNumber
		,intCurrencyId				= A.intCurrencyId 
		,dblExchangeRate			= 1
		,dtmDateEntered				= @PostDate 
		,dtmTransactionDate			= A.dtmDate
		,strJournalLineDescription	= 'Posted ' + A.strTransactionType 
		,intJournalLineNo			= A.intInvoiceId
		,ysnIsUnposted				= 0
		,intUserId					= @UserId
		,intEntityId				= @UserEntityId 				
		,strTransactionId			= A.strInvoiceNumber
		,intTransactionId			= A.intInvoiceId
		,strTransactionType			= A.strTransactionType
		,strTransactionForm			= @ScreenName 
		,strModuleName				= @ModuleName 
		,intConcurrencyId			= 1				 
	FROM
		tblARInvoice A
	LEFT JOIN 
		tblARCustomer C
			ON A.[intEntityCustomerId] = C.intEntityCustomerId 			
	WHERE
		A.intInvoiceId = @InvoiceId
		
		
		 
 DECLARE @InvoiceDetail AS TABLE(intInvoiceId INT, intInvoiceDetailId INT, dblTotal DECIMAL(18,6), dblDiscount DECIMAL(18,6), dblQtyShipped DECIMAL(18,6), dblPrice DECIMAL(18,6), dblUnits DECIMAL(18,6))
 DELETE FROM @InvoiceDetail
 INSERT INTO @InvoiceDetail
	(intInvoiceId
	,intInvoiceDetailId
	,dblTotal
	,dblUnits
	,dblDiscount
	,dblQtyShipped
	,dblPrice)
SELECT
	 intInvoiceId			= ARI.intInvoiceId
	,intInvoiceDetailId		= ARID.intInvoiceDetailId
	,dblTotal				= ARID.dblTotal
	,dblUnits				= ISNULL([dbo].[fnCalculateQtyBetweenUOM](ARID.intItemUOMId, ICIS.intStockUOMId, ARID.dblQtyShipped),ISNULL(ARID.dblQtyShipped, 0.000000))
	,dblDiscount			= ARID.dblDiscount 
	,dblQtyShipped			= ARID.dblQtyShipped
	,dblPrice				= ARID.dblPrice 
FROM
	tblARInvoiceDetail ARID
INNER JOIN
	 tblARInvoice ARI
		ON ARI.intInvoiceId = ARID.intInvoiceId	
LEFT OUTER JOIN
	vyuICGetItemStock ICIS
		ON ARID.intItemId = ICIS.intItemId 
		AND ARI.intCompanyLocationId = ICIS.intLocationId 	
WHERE
	ARI.intInvoiceId = @InvoiceId 
	AND ARID.dblTotal <> @ZeroDecimal 
	AND ((ARID.intItemId IS NULL OR ARID.intItemId = 0)
		OR (EXISTS(SELECT NULL FROM tblICItem WHERE intItemId = ARID.intItemId AND strType IN ('Non-Inventory','Service','Other Charge','Software'))))
	AND ARI.strType <> 'Debit Memo'
ORDER BY
	ARI.intInvoiceId
	,ARID.intInvoiceDetailId


WHILE EXISTS(SELECT TOP 1 NULL FROM @InvoiceDetail)
BEGIN
	DECLARE @InvoiceDetailId			INT
			,@Total						DECIMAL(18,6)
			,@TotalPerPeriod			DECIMAL(18,6)
			,@UnitsTotal				DECIMAL(18,6)
			,@TotalWODiscount			DECIMAL(18,6)
			,@TotalPerPeriodWODiscount	DECIMAL(18,6)
			,@UnitsPerPeriod			DECIMAL(18,6)

	SET @Remainder = @ZeroDecimal
	SET @RemainderWODiscount = @ZeroDecimal
	SET @UnitsRemainder = @ZeroDecimal

	SELECT TOP 1 
		 @InvoiceDetailId			= intInvoiceDetailId
		,@Total						= ISNULL(dblTotal, 0.00) + ((ISNULL(dblDiscount, 0.00)/100.00) * (ISNULL(dblQtyShipped, 0.00) * ISNULL(dblPrice, 0.00)))
		,@TotalWODiscount			= dblTotal
		,@UnitsTotal				= dblUnits
	FROM 
		@InvoiceDetail
		
	SET @Remainder = @ZeroDecimal
	SET @RemainderWODiscount = @ZeroDecimal
	SET @UnitsRemainder = @ZeroDecimal
	
	SET @TotalPerPeriod = ROUND((@Total/@AccrualPeriod),2)
	SET @Remainder = ROUND(@Total,2) - ROUND((@TotalPerPeriod * @AccrualPeriod),2)
	SET @TotalPerPeriodWODiscount = ROUND((@TotalWODiscount/@AccrualPeriod),2)
	SET @RemainderWODiscount = ROUND(@TotalWODiscount,2) - ROUND((@TotalPerPeriodWODiscount * @AccrualPeriod),2)
	SET @UnitsPerPeriod = ROUND((@UnitsTotal/@AccrualPeriod),6)
	SET @UnitsRemainder = ROUND(@UnitsTotal,6) - ROUND((@UnitsPerPeriod * @AccrualPeriod),6)
	SET @LoopCounter = 0		

	WHILE @LoopCounter < @AccrualPeriod
	BEGIN
		INSERT INTO @GLEntries (
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
				)
		--CREDIT	
		SELECT
			 dtmDate					= DATEADD(mm, @LoopCounter, CAST(ISNULL(A.dtmPostDate, A.dtmDate) AS DATE))
			,strBatchID					= @BatchId
			,intAccountId				= (CASE WHEN (EXISTS(SELECT NULL FROM tblICItem WHERE intItemId = B.intItemId AND strType IN ('Non-Inventory','Service'))) 
												THEN
													IST.intGeneralAccountId
												WHEN (EXISTS(SELECT NULL FROM tblICItem WHERE intItemId = B.intItemId AND strType = 'Software')) 
												THEN
													ISNULL(IST.intMaintenanceSalesAccountId, IST.intGeneralAccountId)
												WHEN (EXISTS(SELECT NULL FROM tblICItem WHERE intItemId = B.intItemId AND strType = 'Other Charge')) 
												THEN
													IST.intOtherChargeIncomeAccountId
												ELSE
													(CASE WHEN B.intServiceChargeAccountId IS NOT NULL AND B.intServiceChargeAccountId <> 0 THEN B.intServiceChargeAccountId ELSE @ServiceChargesAccountId END)
											END)
			,dblDebit					= CASE WHEN @AccrualPeriod > 1 THEN CASE WHEN A.strTransactionType = 'Invoice' THEN 0 ELSE @TotalPerPeriodWODiscount + (CASE WHEN @LoopCounter + 1 = @AccrualPeriod THEN @RemainderWODiscount ELSE 0 END) END 
											ELSE CASE WHEN A.strTransactionType = 'Invoice' THEN 0 ELSE @TotalPerPeriod + (CASE WHEN @LoopCounter + 1 = @AccrualPeriod THEN @Remainder ELSE 0 END) END END
			,dblCredit					= CASE WHEN @AccrualPeriod > 1 THEN CASE WHEN A.strTransactionType = 'Invoice' THEN @TotalPerPeriodWODiscount + (CASE WHEN @LoopCounter + 1 = @AccrualPeriod THEN @RemainderWODiscount ELSE 0 END) END
											ELSE CASE WHEN A.strTransactionType = 'Invoice' THEN 0 ELSE @TotalPerPeriod + (CASE WHEN @LoopCounter + 1 = @AccrualPeriod THEN @Remainder ELSE 0 END)  END END

			,dblDebitUnit				= CASE WHEN A.strTransactionType = 'Invoice' THEN 0 ELSE @UnitsPerPeriod + (CASE WHEN @LoopCounter + 1 = @AccrualPeriod THEN @UnitsRemainder ELSE 0 END) END
			,dblCreditUnit				= CASE WHEN A.strTransactionType = 'Invoice' THEN @UnitsPerPeriod + (CASE WHEN @LoopCounter + 1 = @AccrualPeriod THEN @UnitsRemainder ELSE 0 END) ELSE 0 END				
			,strDescription				= A.strComments
			,strCode					= @Code
			,strReference				= C.strCustomerNumber
			,intCurrencyId				= A.intCurrencyId 
			,dblExchangeRate			= 1
			,dtmDateEntered				= @PostDate
			,dtmTransactionDate			= A.dtmDate
			,strJournalLineDescription	= B.strItemDescription 
			,intJournalLineNo			= B.intInvoiceDetailId
			,ysnIsUnposted				= 0
			,intUserId					= @UserId
			,intEntityId				= @UserEntityId 			
			,strTransactionId			= A.strInvoiceNumber
			,intTransactionId			= A.intInvoiceId
			,strTransactionType			= A.strTransactionType
			,strTransactionForm			= @ScreenName 
			,strModuleName				= @ModuleName 
			,intConcurrencyId			= 1	
		FROM
			tblARInvoice A 
		LEFT JOIN
			tblARInvoiceDetail B
				ON A.intInvoiceId = B.intInvoiceId
		LEFT JOIN 
			tblARCustomer C
				ON A.[intEntityCustomerId] = C.intEntityCustomerId		
		LEFT OUTER JOIN
			vyuARGetItemAccount IST
				ON B.intItemId = IST.intItemId 
				AND A.intCompanyLocationId = IST.intLocationId
		LEFT OUTER JOIN
			vyuICGetItemStock ICIS
				ON B.intItemId = ICIS.intItemId 
				AND A.intCompanyLocationId = ICIS.intLocationId 	
		WHERE
			A.intInvoiceId = @InvoiceId
			AND B.intInvoiceDetailId = @InvoiceDetailId 
			AND B.dblTotal <> @ZeroDecimal 
			AND ((B.intItemId IS NULL OR B.intItemId = 0)
				OR (EXISTS(SELECT NULL FROM tblICItem WHERE intItemId = B.intItemId AND strType IN ('Non-Inventory','Service','Other Charge','Software'))))
			AND A.strType <> 'Debit Memo'

		UNION ALL
		--DEBIT Deffered Revenue	
		SELECT
			 dtmDate					= DATEADD(mm, @LoopCounter, CAST(ISNULL(A.dtmPostDate, A.dtmDate) AS DATE))
			,strBatchID					= @BatchId
			,intAccountId				= @DeferredRevenueAccountId
			,dblDebit					= CASE WHEN A.strTransactionType = 'Invoice' THEN @TotalPerPeriodWODiscount + (CASE WHEN @LoopCounter + 1 = @AccrualPeriod THEN @RemainderWODiscount ELSE 0 END) ELSE 0 END
			,dblCredit					= CASE WHEN A.strTransactionType = 'Invoice' THEN 0 ELSE @TotalPerPeriodWODiscount + (CASE WHEN @LoopCounter + 1 = @AccrualPeriod THEN @RemainderWODiscount ELSE 0 END) END
			,dblDebitUnit				= CASE WHEN A.strTransactionType = 'Invoice' THEN @UnitsPerPeriod + (CASE WHEN @LoopCounter + 1 = @AccrualPeriod THEN @UnitsRemainder ELSE 0 END) ELSE 0 END
			,dblCreditUnit				= CASE WHEN A.strTransactionType = 'Invoice' THEN 0 ELSE @UnitsPerPeriod + (CASE WHEN @LoopCounter + 1 = @AccrualPeriod THEN @UnitsRemainder ELSE 0 END) END				
			,strDescription				= A.strComments
			,strCode					= @Code
			,strReference				= C.strCustomerNumber
			,intCurrencyId				= A.intCurrencyId 
			,dblExchangeRate			= 1
			,dtmDateEntered				= @PostDate
			,dtmTransactionDate			= A.dtmDate
			,strJournalLineDescription	= B.strItemDescription 
			,intJournalLineNo			= B.intInvoiceDetailId
			,ysnIsUnposted				= 0
			,intUserId					= @UserId
			,intEntityId				= @UserEntityId 			
			,strTransactionId			= A.strInvoiceNumber
			,intTransactionId			= A.intInvoiceId
			,strTransactionType			= A.strTransactionType
			,strTransactionForm			= @ScreenName 
			,strModuleName				= @ModuleName 
			,intConcurrencyId			= 1	
		FROM
			tblARInvoice A 
		LEFT JOIN
			tblARInvoiceDetail B
				ON A.intInvoiceId = B.intInvoiceId
		LEFT JOIN 
			tblARCustomer C
				ON A.[intEntityCustomerId] = C.intEntityCustomerId		
		LEFT OUTER JOIN
			vyuARGetItemAccount IST
				ON B.intItemId = IST.intItemId 
				AND A.intCompanyLocationId = IST.intLocationId
		LEFT OUTER JOIN
			vyuICGetItemStock ICIS
				ON B.intItemId = ICIS.intItemId 
				AND A.intCompanyLocationId = ICIS.intLocationId					
		WHERE
			A.intInvoiceId = @InvoiceId 
			AND B.intInvoiceDetailId = @InvoiceDetailId
			AND B.dblTotal <> @ZeroDecimal 
			AND ((B.intItemId IS NULL OR B.intItemId = 0)
				OR (EXISTS(SELECT NULL FROM tblICItem WHERE intItemId = B.intItemId AND strType IN ('Non-Inventory','Service','Other Charge','Software'))))
			AND A.strType <> 'Debit Memo'

		SET @LoopCounter = @LoopCounter + 1

	END

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
	--	,@TaxTotalPerPeriod		= ROUND((dblAdjustedTax/@AccrualPeriod),2)
	--FROM 
	--	@InvoiceDetailTax
		
	--SET @TaxRemainder = @ZeroDecimal
	--SET @TaxRemainder = ROUND(@TaxTotal,2) - ROUND((@TaxTotalPerPeriod * @AccrualPeriod),2)
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
	--		,dblDebit					= CASE WHEN A.strTransactionType = 'Invoice' THEN 0 ELSE @TaxTotalPerPeriod + (CASE WHEN @TaxLoopCounter + 1 = @AccrualPeriod THEN @TaxRemainder ELSE 0 END) END
	--		,dblCredit					= CASE WHEN A.strTransactionType = 'Invoice' THEN @TaxTotalPerPeriod + (CASE WHEN @TaxLoopCounter + 1 = @AccrualPeriod THEN @TaxRemainder ELSE 0 END) ELSE 0 END
	--		,dblDebitUnit				= 0
	--		,dblCreditUnit				= 0				
	--		,strDescription				= A.strComments
	--		,strCode					= @Code
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
	--		,strTransactionForm			= @ScreenName 
	--		,strModuleName				= @ModuleName 
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
	--		,dblDebit					= CASE WHEN A.strTransactionType = 'Invoice' THEN @TaxTotalPerPeriod + (CASE WHEN @TaxLoopCounter + 1 = @AccrualPeriod THEN @TaxRemainder ELSE 0 END) ELSE 0 END
	--		,dblCredit					= CASE WHEN A.strTransactionType = 'Invoice' THEN 0 ELSE @TaxTotalPerPeriod + (CASE WHEN @TaxLoopCounter + 1 = @AccrualPeriod THEN @TaxRemainder ELSE 0 END) END
	--		,dblDebitUnit				= 0
	--		,dblCreditUnit				= 0				
	--		,strDescription				= A.strComments
	--		,strCode					= @Code
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
	--		,strTransactionForm			= @ScreenName 
	--		,strModuleName				= @ModuleName 
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
	INSERT INTO @GLEntries (
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
			)
	--CREDIT Tax
	SELECT
		 dtmDate					= CAST(ISNULL(A.dtmPostDate, A.dtmDate) AS DATE)
		,strBatchID					= @BatchId
		,intAccountId				= ISNULL(DT.intSalesTaxAccountId,TC.intSalesTaxAccountId)
		,dblDebit					= CASE WHEN A.strTransactionType = 'Invoice' THEN 0 ELSE DT.dblAdjustedTax END
		,dblCredit					= CASE WHEN A.strTransactionType = 'Invoice' THEN DT.dblAdjustedTax ELSE 0 END
		,dblDebitUnit				= 0
		,dblCreditUnit				= 0				
		,strDescription				= A.strComments
		,strCode					= @Code
		,strReference				= C.strCustomerNumber
		,intCurrencyId				= A.intCurrencyId 
		,dblExchangeRate			= 1
		,dtmDateEntered				= @PostDate 
		,dtmTransactionDate			= A.dtmDate
		,strJournalLineDescription	= 'Posted ' + A.strTransactionType 
		,intJournalLineNo			= A.intInvoiceId
		,ysnIsUnposted				= 0
		,intUserId					= @UserId
		,intEntityId				= @UserEntityId 				
		,strTransactionId			= A.strInvoiceNumber
		,intTransactionId			= A.intInvoiceId
		,strTransactionType			= A.strTransactionType
		,strTransactionForm			= @ScreenName 
		,strModuleName				= @ModuleName 
		,intConcurrencyId			= 1				 
	FROM
		tblARInvoiceDetailTax DT
	INNER JOIN
		tblARInvoiceDetail D
			ON DT.intInvoiceDetailId = D.intInvoiceDetailId
	INNER JOIN			
		tblARInvoice A 
			ON D.intInvoiceId = A.intInvoiceId
	INNER JOIN
		tblARCustomer C
			ON A.intEntityCustomerId = C.intEntityCustomerId			
	LEFT OUTER JOIN
		tblSMTaxCode TC
			ON DT.intTaxCodeId = TC.intTaxCodeId	
	WHERE
		A.intInvoiceId = @InvoiceId
		AND DT.dblAdjustedTax <> @ZeroDecimal
		
	UNION ALL
	--Debit Tax
	SELECT
		 dtmDate					= CAST(ISNULL(A.dtmPostDate, A.dtmDate) AS DATE)
		,strBatchID					= @BatchId
		,intAccountId				= @DeferredRevenueAccountId
		,dblDebit					= CASE WHEN A.strTransactionType = 'Invoice' THEN DT.dblAdjustedTax ELSE 0 END
		,dblCredit					= CASE WHEN A.strTransactionType = 'Invoice' THEN 0 ELSE DT.dblAdjustedTax END
		,dblDebitUnit				= 0
		,dblCreditUnit				= 0				
		,strDescription				= A.strComments
		,strCode					= @Code
		,strReference				= C.strCustomerNumber
		,intCurrencyId				= A.intCurrencyId 
		,dblExchangeRate			= 1
		,dtmDateEntered				= @PostDate 
		,dtmTransactionDate			= A.dtmDate
		,strJournalLineDescription	= 'Posted ' + A.strTransactionType 
		,intJournalLineNo			= A.intInvoiceId
		,ysnIsUnposted				= 0
		,intUserId					= @UserId
		,intEntityId				= @UserEntityId 				
		,strTransactionId			= A.strInvoiceNumber
		,intTransactionId			= A.intInvoiceId
		,strTransactionType			= A.strTransactionType
		,strTransactionForm			= @ScreenName 
		,strModuleName				= @ModuleName 
		,intConcurrencyId			= 1				 
	FROM
		tblARInvoiceDetailTax DT
	INNER JOIN
		tblARInvoiceDetail D
			ON DT.intInvoiceDetailId = D.intInvoiceDetailId
	INNER JOIN			
		tblARInvoice A 
			ON D.intInvoiceId = A.intInvoiceId
	INNER JOIN
		tblARCustomer C
			ON A.intEntityCustomerId = C.intEntityCustomerId			
	LEFT OUTER JOIN
		tblSMTaxCode TC
			ON DT.intTaxCodeId = TC.intTaxCodeId	
	WHERE
		A.intInvoiceId = @InvoiceId
		AND DT.dblAdjustedTax <> @ZeroDecimal	
END


SELECT * FROM @GLEntries
