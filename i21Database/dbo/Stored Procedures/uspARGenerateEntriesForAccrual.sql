CREATE PROCEDURE [dbo].[uspARGenerateEntriesForAccrual]
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

WHILE EXISTS(SELECT NULL FROM @Invoices I LEFT OUTER JOIN @GLEntries G ON I.intId = G.intTransactionId WHERE ISNULL(G.intTransactionId,0) = 0)
BEGIN
	DECLARE  @InvoiceId		INT
			,@AccrualPeriod	INT
			,@LoopCounter	INT
			,@Remainder		DECIMAL(18,6)
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
		 dtmDate					= DATEADD(dd, DATEDIFF(dd, 0, A.dtmDate), 0)
		,strBatchID					= @BatchId
		,intAccountId				= A.intAccountId
		,dblDebit					= CASE WHEN A.strTransactionType = 'Invoice' THEN  A.dblInvoiceTotal ELSE 0 END
		,dblCredit					= CASE WHEN A.strTransactionType = 'Invoice' THEN  0 ELSE A.dblInvoiceTotal END
		,dblDebitUnit				= CASE WHEN A.strTransactionType = 'Invoice'	THEN  
																						(
																						SELECT
																							SUM([dbo].[fnCalculateQtyBetweenUOM](ARID.intItemUOMId, ICIS.intStockUOMId, ARID.dblQtyShipped))
																						FROM
																							tblARInvoice ARI 
																						LEFT JOIN
																							tblARInvoiceDetail ARID
																								ON ARI.intInvoiceId = ARID.intInvoiceId	
																						INNER JOIN
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
																							AND (ARID.intItemId IS NOT NULL OR ARID.intItemId <> 0)
																							AND I.strType NOT IN ('Non-Inventory','Service','Other Charge','Software')
																						)
																					ELSE 
																						0
																					END
		,dblCreditUnit				=  CASE WHEN A.strTransactionType = 'Invoice'	THEN  
																						0
																					ELSE 
																						(
																						SELECT
																							SUM([dbo].[fnCalculateQtyBetweenUOM](ARID.intItemUOMId, ICIS.intStockUOMId, ARID.dblQtyShipped))
																						FROM
																							tblARInvoice ARI 
																						LEFT JOIN
																							tblARInvoiceDetail ARID
																								ON ARI.intInvoiceId = ARID.intInvoiceId	
																						INNER JOIN
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
																							AND (ARID.intItemId IS NOT NULL OR ARID.intItemId <> 0)
																							AND I.strType NOT IN ('Non-Inventory','Service','Other Charge','Software')
																						)
																					END				
		,strDescription				= A.strComments
		,strCode					= @Code
		,strReference				= C.strCustomerNumber
		,intCurrencyId				= A.intCurrencyId 
		,dblExchangeRate			= 1
		,dtmDateEntered				= GETDATE()
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
		 dtmDate					= DATEADD(dd, DATEDIFF(dd, 0, A.dtmDate), 0)
		,strBatchID					= @BatchId
		,intAccountId				= @DeferredRevenueAccountId
		,dblDebit					= CASE WHEN A.strTransactionType = 'Invoice' THEN  0 ELSE A.dblInvoiceTotal END
		,dblCredit					= CASE WHEN A.strTransactionType = 'Invoice' THEN  A.dblInvoiceTotal ELSE 0 END
		,dblDebitUnit				= CASE WHEN A.strTransactionType = 'Invoice'	THEN  
																						0
																					ELSE
																						(
																						SELECT
																							SUM([dbo].[fnCalculateQtyBetweenUOM](ARID.intItemUOMId, ICIS.intStockUOMId, ARID.dblQtyShipped))
																						FROM
																							tblARInvoice ARI 
																						LEFT JOIN
																							tblARInvoiceDetail ARID
																								ON ARI.intInvoiceId = ARID.intInvoiceId	
																						INNER JOIN
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
																							AND (ARID.intItemId IS NOT NULL OR ARID.intItemId <> 0)
																							AND I.strType NOT IN ('Non-Inventory','Service','Other Charge','Software')
																						)
																					END
		,dblCreditUnit				=  CASE WHEN A.strTransactionType = 'Invoice'	THEN   
																						(
																						SELECT
																							SUM([dbo].[fnCalculateQtyBetweenUOM](ARID.intItemUOMId, ICIS.intStockUOMId, ARID.dblQtyShipped))
																						FROM
																							tblARInvoice ARI 
																						LEFT JOIN
																							tblARInvoiceDetail ARID
																								ON ARI.intInvoiceId = ARID.intInvoiceId	
																						INNER JOIN
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
																							AND (ARID.intItemId IS NOT NULL OR ARID.intItemId <> 0)
																							AND I.strType NOT IN ('Non-Inventory','Service','Other Charge','Software')
																						)																						
																					ELSE
																						0
																					END				
		,strDescription				= A.strComments
		,strCode					= @Code
		,strReference				= C.strCustomerNumber
		,intCurrencyId				= A.intCurrencyId 
		,dblExchangeRate			= 1
		,dtmDateEntered				= GETDATE()
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
 

	-- MISC
	DECLARE	 @MiscTotal		DECIMAL(18,6)
			,@MiscPerPeriod	DECIMAL(18,6)

	SELECT
		@MiscTotal = ISNULL(B.dblTotal, 0.00) + ((ISNULL(B.dblDiscount, 0.00)/100.00) * (ISNULL(B.dblQtyShipped, 0.00) * ISNULL(B.dblPrice, 0.00)))
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
	WHERE
		A.intInvoiceId = @InvoiceId 
		AND B.dblTotal <> @ZeroDecimal 
		AND ((B.intItemId IS NULL OR B.intItemId = 0)
			OR (EXISTS(SELECT NULL FROM tblICItem WHERE intItemId = B.intItemId AND strType IN ('Non-Inventory','Service','Other Charge','Software'))))
		AND A.strType <> 'Debit Memo'

	SET @MiscPerPeriod = ROUND((@MiscTotal/@AccrualPeriod),2)
	SET @Remainder = ROUND(@MiscTotal,2) - ROUND((@MiscPerPeriod * @AccrualPeriod),2)
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
			 dtmDate					= DATEADD(mm, @LoopCounter, DATEADD(dd, DATEDIFF(dd, 0, A.dtmDate), 0))
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
			,dblDebit					= CASE WHEN A.strTransactionType = 'Invoice' THEN 0 ELSE @MiscPerPeriod + (CASE WHEN @LoopCounter + 1 = @AccrualPeriod THEN @Remainder ELSE 0 END) END
			,dblCredit					= CASE WHEN A.strTransactionType = 'Invoice' THEN @MiscPerPeriod + (CASE WHEN @LoopCounter + 1 = @AccrualPeriod THEN @Remainder ELSE 0 END) ELSE 0  END
			,dblDebitUnit				= CASE WHEN A.strTransactionType = 'Invoice' THEN 0 ELSE ISNULL(B.dblQtyShipped, 0.00) END
			,dblCreditUnit				= CASE WHEN A.strTransactionType = 'Invoice' THEN ISNULL(B.dblQtyShipped, 0.00) ELSE 0 END				
			,strDescription				= A.strComments
			,strCode					= @Code
			,strReference				= C.strCustomerNumber
			,intCurrencyId				= A.intCurrencyId 
			,dblExchangeRate			= 1
			,dtmDateEntered				= GETDATE()
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
		WHERE
			A.intInvoiceId = @InvoiceId 
			AND B.dblTotal <> @ZeroDecimal 
			AND ((B.intItemId IS NULL OR B.intItemId = 0)
				OR (EXISTS(SELECT NULL FROM tblICItem WHERE intItemId = B.intItemId AND strType IN ('Non-Inventory','Service','Other Charge','Software'))))
			AND A.strType <> 'Debit Memo'

		UNION ALL
		--DEBIT Deffered Revenue	
		SELECT
			 dtmDate					= DATEADD(mm, @LoopCounter, DATEADD(dd, DATEDIFF(dd, 0, A.dtmDate), 0))
			,strBatchID					= @BatchId
			,intAccountId				= @DeferredRevenueAccountId
			,dblDebit					= CASE WHEN A.strTransactionType = 'Invoice' THEN @MiscPerPeriod + (CASE WHEN @LoopCounter + 1 = @AccrualPeriod THEN @Remainder ELSE 0 END) ELSE 0 END
			,dblCredit					= CASE WHEN A.strTransactionType = 'Invoice' THEN 0 ELSE @MiscPerPeriod + (CASE WHEN @LoopCounter + 1 = @AccrualPeriod THEN @Remainder ELSE 0 END) END
			,dblDebitUnit				= CASE WHEN A.strTransactionType = 'Invoice' THEN ISNULL(B.dblQtyShipped, 0.00) ELSE 0 END
			,dblCreditUnit				= CASE WHEN A.strTransactionType = 'Invoice' THEN 0 ELSE ISNULL(B.dblQtyShipped, 0.00) END				
			,strDescription				= A.strComments
			,strCode					= @Code
			,strReference				= C.strCustomerNumber
			,intCurrencyId				= A.intCurrencyId 
			,dblExchangeRate			= 1
			,dtmDateEntered				= GETDATE()
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
		WHERE
			A.intInvoiceId = @InvoiceId 
			AND B.dblTotal <> @ZeroDecimal 
			AND ((B.intItemId IS NULL OR B.intItemId = 0)
				OR (EXISTS(SELECT NULL FROM tblICItem WHERE intItemId = B.intItemId AND strType IN ('Non-Inventory','Service','Other Charge','Software'))))
			AND A.strType <> 'Debit Memo'

		SET @LoopCounter = @LoopCounter + 1

	END
END


SELECT * FROM @GLEntries
