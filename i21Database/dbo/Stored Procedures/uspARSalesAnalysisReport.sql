CREATE PROCEDURE [dbo].[uspARSalesAnalysisReport]
      @tblTransactionIds	InvoiceId READONLY
	, @ysnInvoice			BIT = 1
    , @ysnRebuild           BIT = 0
    , @ysnPost              BIT = 1
AS

DECLARE @strRequestId NVARCHAR(200) = NEWID()

IF(OBJECT_ID('tempdb..#INVOICES') IS NOT NULL)
BEGIN
    DROP TABLE #INVOICES
END
IF(OBJECT_ID('tempdb..#ORDERS') IS NOT NULL)
BEGIN
    DROP TABLE #ORDERS
END
IF(OBJECT_ID('tempdb..#CUSTOMERS') IS NOT NULL)
BEGIN
    DROP TABLE #CUSTOMERS
END
IF(OBJECT_ID('tempdb..#TRANSACTIONS') IS NOT NULL)
BEGIN
    DROP TABLE #TRANSACTIONS
END

DECLARE @intNewPerformanceLogId	INT = NULL

IF ISNULL(@ysnRebuild, 0) = 1
	BEGIN
		EXEC dbo.uspARLogPerformanceRuntime @strScreenName			= 'Rebuild Sales Analysis Report'
										  , @strProcedureName       = 'uspARSalesAnalysisReport'
										  , @strRequestId			= @strRequestId
										  , @ysnStart		        = 1
										  , @intUserId	            = 1
										  , @intPerformanceLogId    = NULL
										  , @intNewPerformanceLogId = @intNewPerformanceLogId OUT
	END

IF ISNULL(@ysnPost, 0) = 0
    BEGIN
        DELETE SAS 
        FROM tblARSalesAnalysisStagingReport SAS
        INNER JOIN @tblTransactionIds II ON SAS.intTransactionId = II.intHeaderId
        WHERE (@ysnInvoice = 1 AND SAS.strTransactionType <> 'Order')
           OR (@ysnInvoice = 0 AND SAS.strTransactionType = 'Order')

        RETURN
    END

CREATE TABLE #INVOICES (intInvoiceId	INT);
CREATE TABLE #ORDERS (intSalesOrderId	INT);
CREATE TABLE #CUSTOMERS (
	[intEntityCustomerId]		INT PRIMARY KEY,
	[strCustomerName]			NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[strCustomerNumber]			NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[strAccountStatusCode]		NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
);
CREATE TABLE #TRANSACTIONS (
	[strRecordNumber]			NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
	[strInvoiceOriginId]		NVARCHAR (100)  COLLATE Latin1_General_CI_AS NULL,
	[intSourceId]				INT NULL,
	[intTransactionId]			INT NULL,
	[intEntityCustomerId]		INT NULL,
	[intAccountId]				INT NULL,
	[intItemId]					INT NULL,
	[intItemUOMId]				INT NULL,
	[dtmDate]					DATETIME NULL,
	[intCompanyLocationId]		INT NULL,
	[intEntitySalespersonId]	INT NULL,
	[strTransactionType]		NVARCHAR (100)  COLLATE Latin1_General_CI_AS NULL,
	[strType]					NVARCHAR (100)  COLLATE Latin1_General_CI_AS NULL,
	[strItemDescription]		NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
	[intItemAccountId]			INT NULL,
	[dblQtyOrdered]				NUMERIC(18, 6) NULL,
	[dblQtyShipped]				NUMERIC(18, 6) NULL,
	[dblStandardCost]			NUMERIC(18, 6) NULL,
	[dblPrice]					NUMERIC(18, 6) NULL,
	[dblTax]					NUMERIC(18, 6) NULL,
	[dblLineTotal]				NUMERIC(18, 6) NULL,
	[dblTotal]					NUMERIC(18, 6) NULL,
	[strBillToLocationName]		NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
	[strShipToLocationName]		NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
	[intSiteId]					INT NULL,
	[intTicketId]				INT NULL,
	[strShipToCity]				NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
	[strShipToState]			NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
	[strShipToCountry]			NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
	[strShipToZipCode]			NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
	[intCurrencyId]				INT NULL,
	[intInvoiceDetailId]		INT NULL,
	[dblRebateAmount]			NUMERIC(18, 6) NULL,
	[dblBuybackAmount]			NUMERIC(18, 6) NULL,
	[strAccountingPeriod]		NVARCHAR (100)  COLLATE Latin1_General_CI_AS NULL
);

--INVOICES
IF ISNULL(@ysnInvoice, 1) = 1 OR ISNULL(@ysnRebuild, 0) = 1
	BEGIN
        IF ISNULL(@ysnRebuild, 0) = 1
			BEGIN
				INSERT INTO #INVOICES
				SELECT ARI.intInvoiceId
				FROM tblARInvoice ARI
				WHERE ARI.ysnPosted = 1 
				  AND ARI.strTransactionType IN ('Invoice', 'Credit Memo', 'Debit Memo', 'Cash', 'Cash Refund', 'Service Charge')
			END
		ELSE 
			BEGIN
				INSERT INTO #INVOICES
				SELECT ARI.intInvoiceId
				FROM tblARInvoice ARI
				INNER JOIN @tblTransactionIds II ON ARI.intInvoiceId = II.intHeaderId
				WHERE ARI.ysnPosted = 1 
				  AND ARI.strTransactionType IN ('Invoice', 'Credit Memo', 'Debit Memo', 'Cash', 'Cash Refund', 'Service Charge')
			END

		INSERT INTO #TRANSACTIONS (
			  [strRecordNumber]
			, [strInvoiceOriginId]
			, [intSourceId]
			, [intTransactionId]
			, [intEntityCustomerId]
			, [intAccountId]
			, [intItemId]
			, [intItemUOMId]
			, [dtmDate]
			, [intCompanyLocationId]
			, [intEntitySalespersonId]
			, [strTransactionType]
			, [strType]
			, [strItemDescription]
			, [intItemAccountId]
			, [dblQtyOrdered]
			, [dblQtyShipped]
			, [dblStandardCost]
			, [dblPrice]
			, [dblTax]
			, [dblLineTotal]
			, [dblTotal]
			, [strBillToLocationName]
			, [strShipToLocationName]
			, [intSiteId]
			, [intTicketId]
			, [strShipToCity]
			, [strShipToState]
			, [strShipToCountry]
			, [strShipToZipCode]
			, [intCurrencyId]
			, [intInvoiceDetailId]
			, [dblRebateAmount]
			, [dblBuybackAmount]
			, [strAccountingPeriod]
		)
		SELECT strRecordNumber			= ARI.strInvoiceNumber
			, strInvoiceOriginId		= ARI.strInvoiceOriginId
			, intSourceId				= ARI.intSourceId
			, intTransactionId			= ARI.intInvoiceId		
			, intEntityCustomerId		= ARI.intEntityCustomerId
			, intAccountId				= ARI.intAccountId
			, intItemId					= ARID.intItemId
			, intItemUOMId				= ARID.intItemUOMId
			, dtmDate					= ARI.dtmDate
			, intCompanyLocationId		= ARI.intCompanyLocationId
			, intEntitySalespersonId	= ARI.intEntitySalespersonId
			, strTransactionType		= ARI.strTransactionType
			, strType					= ARI.strType
			, strItemDescription		= ARID.strItemDescription	  
			, intItemAccountId			= CASE WHEN ICI.strType IN ('Non-Inventory','Service','Other Charge') 
													THEN ISNULL(ARID.intAccountId, ARID.intSalesAccountId)
											WHEN ICI.strType = 'Software' AND ISNULL(ARID.strMaintenanceType, '') <> ''
													THEN CASE WHEN ARID.strMaintenanceType IN ('License/Maintenance', 'License Only') 
																THEN ARID.intLicenseAccountId
															WHEN ARID.strMaintenanceType IN ('Maintenance Only', 'SaaS') 
																THEN ARID.intMaintenanceAccountId
														END
											ELSE ISNULL(ARID.intSalesAccountId, ARID.intAccountId) 
										END
			, dblQtyOrdered				= ARID.dblQtyOrdered
			, dblQtyShipped				= ARID.dblQtyShipped
			, dblStandardCost			= (CASE WHEN ARI.strType = 'CF Tran' AND CFTRAN.strTransactionType IN ('Remote', 'Extended Remote')
													THEN ISNULL(CFTRAN.dblNetTransferCost, 0)											
												WHEN ISNULL(ICI.strLotTracking, 'No') = 'No' AND ISNULL(ARID.intInventoryShipmentItemId, 0) <> 0
													THEN --dbo.fnCalculateCostBetweenUOM(NONLOTTED.intItemUOMId, ARID.intItemUOMId, ISNULL(NONLOTTED.dblCost, 0))
													 CASE WHEN ISNULL(NONLOTTED.dblUnitQty, 0) = 0 OR ISNULL(ARIDUOM.dblUnitQty, 0) = 0 THEN NULL 			
														  WHEN NONLOTTED.dblUnitQty = ARIDUOM.dblUnitQty THEN ISNULL(NONLOTTED.dblCost, 0)
														  WHEN NONLOTTED.dblUnitQty = 1 THEN ISNULL(NONLOTTED.dblCost, 0) * ARIDUOM.dblUnitQty
														  WHEN ARIDUOM.dblUnitQty = 1 THEN ISNULL(NONLOTTED.dblCost, 0) / NONLOTTED.dblUnitQty
														  WHEN NONLOTTED.dblUnitQty < 1 AND NONLOTTED.dblUnitQty < ARIDUOM.dblUnitQty THEN (ISNULL(NONLOTTED.dblCost, 0) / NONLOTTED.dblUnitQty) * ARIDUOM.dblUnitQty
														  WHEN NONLOTTED.dblUnitQty < ARIDUOM.dblUnitQty THEN (ISNULL(NONLOTTED.dblCost, 0) * NONLOTTED.dblUnitQty) / ARIDUOM.dblUnitQty 
														  WHEN NONLOTTED.dblUnitQty > ARIDUOM.dblUnitQty THEN (ISNULL(NONLOTTED.dblCost, 0) / NONLOTTED.dblUnitQty) * ARIDUOM.dblUnitQty 
														  ELSE (ISNULL(NONLOTTED.dblCost, 0) * NONLOTTED.dblUnitQty) / ARIDUOM.dblUnitQty				
													END
												WHEN ISNULL(ICI.strLotTracking, 'No') <> 'No' AND ISNULL(ARID.intInventoryShipmentItemId, 0) <> 0 AND ISNULL(ARID.intSalesOrderDetailId, 0) <> 0
													THEN --dbo.fnCalculateCostBetweenUOM(LOTTED.intItemUOMId, ARID.intItemUOMId, ISNULL(LOTTED.dblCost, 0))
													 CASE WHEN ISNULL(LOTTED.dblUnitQty, 0) = 0 OR ISNULL(ARIDUOM.dblUnitQty, 0) = 0 THEN NULL 			
														  WHEN LOTTED.dblUnitQty = ARIDUOM.dblUnitQty THEN ISNULL(LOTTED.dblCost, 0)
														  WHEN LOTTED.dblUnitQty = 1 THEN ISNULL(LOTTED.dblCost, 0) * ARIDUOM.dblUnitQty
														  WHEN ARIDUOM.dblUnitQty = 1 THEN ISNULL(LOTTED.dblCost, 0) / LOTTED.dblUnitQty
														  WHEN LOTTED.dblUnitQty < 1 AND LOTTED.dblUnitQty < ARIDUOM.dblUnitQty THEN (ISNULL(LOTTED.dblCost, 0) / LOTTED.dblUnitQty) * ARIDUOM.dblUnitQty
														  WHEN LOTTED.dblUnitQty < ARIDUOM.dblUnitQty THEN (ISNULL(LOTTED.dblCost, 0) * LOTTED.dblUnitQty) / ARIDUOM.dblUnitQty 
														  WHEN LOTTED.dblUnitQty > ARIDUOM.dblUnitQty THEN (ISNULL(LOTTED.dblCost, 0) / LOTTED.dblUnitQty) * ARIDUOM.dblUnitQty 
														  ELSE (ISNULL(LOTTED.dblCost, 0) * LOTTED.dblUnitQty) / ARIDUOM.dblUnitQty				
													END 
												ELSE --dbo.fnCalculateCostBetweenUOM(NONSO.intItemUOMId, ARID.intItemUOMId, ISNULL(NONSO.dblCost, 0))
													 CASE WHEN ISNULL(NONSO.dblUnitQty, 0) = 0 OR ISNULL(ARIDUOM.dblUnitQty, 0) = 0 THEN NULL 			
														  WHEN NONSO.dblUnitQty = ARIDUOM.dblUnitQty THEN ISNULL(NONSO.dblCost, 0)
														  WHEN NONSO.dblUnitQty = 1 THEN ISNULL(NONSO.dblCost, 0) * ARIDUOM.dblUnitQty
														  WHEN ARIDUOM.dblUnitQty = 1 THEN ISNULL(NONSO.dblCost, 0) / NONSO.dblUnitQty
														  WHEN NONSO.dblUnitQty < 1 AND NONSO.dblUnitQty < ARIDUOM.dblUnitQty THEN (ISNULL(NONSO.dblCost, 0) / NONSO.dblUnitQty) * ARIDUOM.dblUnitQty
														  WHEN NONSO.dblUnitQty < ARIDUOM.dblUnitQty THEN (ISNULL(NONSO.dblCost, 0) * NONSO.dblUnitQty) / ARIDUOM.dblUnitQty 
														  WHEN NONSO.dblUnitQty > ARIDUOM.dblUnitQty THEN (ISNULL(NONSO.dblCost, 0) / NONSO.dblUnitQty) * ARIDUOM.dblUnitQty 
														  ELSE (ISNULL(NONSO.dblCost, 0) * NONSO.dblUnitQty) / ARIDUOM.dblUnitQty				
													END 
											END)
			, dblPrice					= CASE WHEN ICI.strType = 'Software' AND ISNULL(ARID.strMaintenanceType, '') <> ''
													THEN CASE WHEN ARID.strMaintenanceType IN ('License/Maintenance', 'License Only') 
																THEN ARID.dblLicenseAmount
															WHEN ARID.strMaintenanceType IN ('Maintenance Only', 'SaaS') 
																THEN ARID.dblMaintenanceAmount
														END
											ELSE ARID.dblPrice
										END
			, dblTax					= ARID.dblTotalTax
			, dblLineTotal				= CASE WHEN ICI.strType = 'Software' AND ISNULL(ARID.strMaintenanceType, '') <> ''
													THEN CASE WHEN ARID.strMaintenanceType IN ('License/Maintenance', 'License Only') 
																THEN ARID.dblQtyShipped * ARID.dblLicenseAmount
															WHEN ARID.strMaintenanceType IN ('Maintenance Only', 'SaaS') 
																THEN ARID.dblQtyShipped * ARID.dblMaintenanceAmount
														END
											ELSE ARID.dblTotal
										END
			, dblTotal					= ARI.dblInvoiceTotal			
			, strBillToLocationName		= ARI.strBillToLocationName
			, strShipToLocationName		=  CASE WHEN ARI.strType = 'Tank Delivery' AND TMSITE.intSiteID IS NOT NULL 
											THEN TMSITE.strSiteAddress ELSE ARI.strShipToLocationName END
			, intSiteId					= ARID.intSiteId
			, intTicketId				= ARID.intTicketId
			, strShipToCity				= CASE WHEN ARI.strType = 'Tank Delivery' AND TMSITE.intSiteID IS NOT NULL 
											THEN TMSITE.strCity ELSE ARI.strShipToCity END
			, strShipToState			= CASE WHEN ARI.strType = 'Tank Delivery' AND TMSITE.intSiteID IS NOT NULL 
											THEN TMSITE.strState ELSE ARI.strShipToState END
			, strShipToCountry			= CASE WHEN ARI.strType = 'Tank Delivery' AND TMSITE.intSiteID IS NOT NULL 
											THEN TMSITE.strCountry ELSE ARI.strShipToCountry END
			, strShipToZipCode			= CASE WHEN ARI.strType = 'Tank Delivery' AND TMSITE.intSiteID IS NOT NULL 
											THEN TMSITE.strZipCode ELSE ARI.strShipToZipCode END 
			, intCurrencyId				= ARI.intCurrencyId		
			, intInvoiceDetailId		= ARID.intInvoiceDetailId
			, dblRebateAmount			= ARID.dblRebateAmount
			, dblBuybackAmount			= ARID.dblBuybackAmount
			, strAccountingPeriod	    = AccPeriod.strPeriod
		FROM tblARInvoiceDetail ARID 
		INNER JOIN tblARInvoice ARI ON ARID.intInvoiceId = ARI.intInvoiceId	
		INNER JOIN #INVOICES II ON ARI.intInvoiceId = II.intInvoiceId
		LEFT JOIN tblICItem ICI ON ARID.intItemId = ICI.intItemId
		LEFT JOIN tblTMSite TMSITE ON TMSITE.intSiteID = ARID.intSiteId
		LEFT JOIN tblGLFiscalYearPeriod AccPeriod ON ARI.intPeriodId = AccPeriod.intGLFiscalYearPeriodId
		LEFT JOIN tblICItemUOM ARIDUOM ON ARID.intItemUOMId = ARIDUOM.intItemUOMId
		LEFT OUTER JOIN (
			SELECT intTransactionId		= ICIT.intTransactionId
				 , strTransactionId		= ICIT.strTransactionId
				 , intItemId			= ICIT.intItemId
				 , intItemUOMId			= ICIT.intItemUOMId
				 , dblCost				= CASE WHEN SUM(ICIT.dblQty) <> 0 THEN SUM(ICIT.dblQty * ICIT.dblCost + ICIT.dblValue) / SUM(ICIT.dblQty) ELSE 0 END
				 , dblUnitQty			= AVG(UOM.dblUnitQty)
			FROM tblICInventoryTransaction ICIT
			INNER JOIN tblICItemUOM UOM ON ICIT.intItemUOMId = UOM.intItemUOMId
			WHERE ICIT.ysnIsUnposted = 0
			  AND ICIT.intItemUOMId IS NOT NULL
			  AND ICIT.intTransactionTypeId <> 1
			GROUP BY ICIT.intTransactionId, ICIT.strTransactionId, ICIT.intItemId, ICIT.intItemUOMId
		) AS NONSO ON ARI.intInvoiceId		= NONSO.intTransactionId
				  AND ARI.strInvoiceNumber	= NONSO.strTransactionId
				  AND ARID.intItemId		= NONSO.intItemId
		LEFT OUTER JOIN (
			SELECT intInventoryShipmentItemId	= ICISI.intInventoryShipmentItemId
				 , intLineNo					= ICISI.intLineNo
				 , intItemId					= ICISI.intItemId
				 , intItemUOMId					= ICISI.intItemUOMId
				 , dblCost						= ICIT.dblCost
				 , dblUnitQty					= UOM.dblUnitQty
			FROM tblICInventoryShipmentItem ICISI	
			INNER JOIN tblICInventoryShipment ICIS ON ICISI.intInventoryShipmentId = ICIS.intInventoryShipmentId
			INNER JOIN tblICItem ICI ON ICISI.intItemId = ICI.intItemId
									AND ISNULL(ICI.strLotTracking, 'No') = 'No'
			INNER JOIN tblICInventoryTransaction ICIT ON ICIT.ysnIsUnposted					= 0
													 AND ISNULL(ICIT.intLotId, 0)			= 0
													 AND ICIS.intInventoryShipmentId		= ICIT.intTransactionId
													 AND ICIS.strShipmentNumber				= ICIT.strTransactionId
													 AND ICISI.intInventoryShipmentItemId	= ICIT.intTransactionDetailId
													 AND ICISI.intItemId					= ICIT.intItemId
													 AND ICIT.intInTransitSourceLocationId 	IS NULL
													 AND ICIT.intItemUOMId 					IS NOT NULL
													 AND ICIT.intTransactionTypeId 			<> 1
			INNER JOIN tblICItemUOM UOM ON ICIT.intItemUOMId = UOM.intItemUOMId	
		) AS NONLOTTED ON ARID.intInventoryShipmentItemId = NONLOTTED.intInventoryShipmentItemId
					  AND ARID.intItemId = NONLOTTED.intItemId
					  AND ((ARID.intSalesOrderDetailId IS NOT NULL AND ARID.intSalesOrderDetailId = NONLOTTED.intLineNo) OR ARID.intSalesOrderDetailId IS NULL)
		LEFT OUTER JOIN (
			SELECT intInventoryShipmentItemId	= ICISI.intInventoryShipmentItemId
				 , intLineNo					= ICISI.intLineNo
				 , intItemId					= ICISI.intItemId
				 , intItemUOMId					= ICISI.intItemUOMId
				 , dblCost 						= ABS(AVG(ICIT.dblQty * ICIT.dblCost))
				 , dblUnitQty					= AVG(UOM.dblUnitQty)
			FROM tblICInventoryShipmentItem ICISI
			INNER JOIN tblICInventoryShipment ICIS ON ICISI.intInventoryShipmentId = ICIS.intInventoryShipmentId
			INNER JOIN tblICItem ICI ON ICISI.intItemId = ICI.intItemId
									AND ISNULL(ICI.strLotTracking, 'No') <> 'No'
			INNER JOIN tblICInventoryTransaction ICIT ON ICIT.ysnIsUnposted 				= 0
													 AND ISNULL(ICIT.intLotId, 0)			<> 0
													 AND ICIS.intInventoryShipmentId		= ICIT.intTransactionId
													 AND ICIS.strShipmentNumber				= ICIT.strTransactionId
													 AND ICISI.intInventoryShipmentItemId	= ICIT.intTransactionDetailId
													 AND ICISI.intItemId					= ICIT.intItemId		
													 AND ISNULL(ICI.strLotTracking, 'No')	<> 'No'
													 AND ICIT.intItemUOMId 					IS NOT NULL
													 AND ICIT.intTransactionTypeId 			<> 1
			INNER JOIN tblICItemUOM UOM ON ICISI.intItemUOMId = UOM.intItemUOMId	
			INNER JOIN tblICLot ICL ON ICIT.intLotId = ICL.intLotId
								   AND ICISI.intItemUOMId = (CASE WHEN (ICI.strType = 'Finished Good' OR ICI.ysnAutoBlend = 1) THEN ICISI.intItemUOMId ELSE ICL.intItemUOMId END)
			GROUP BY ICISI.intInventoryShipmentItemId, ICISI.intLineNo, ICISI.intItemId, ICISI.intItemUOMId
		) AS LOTTED ON ARID.intInventoryShipmentItemId	= LOTTED.intInventoryShipmentItemId
					AND ARID.intItemId					= LOTTED.intItemId				
					AND ARID.intSalesOrderDetailId		= LOTTED.intLineNo
		LEFT OUTER JOIN (
			SELECT intInvoiceId
					, dblNetTransferCost
					, strTransactionType
			FROM tblCFTransaction CF
			WHERE ISNULL(CF.intInvoiceId, 0) <> 0
		) AS CFTRAN ON ARI.intInvoiceId = CFTRAN.intInvoiceId 
					AND ARI.strType = 'CF Tran'	
		WHERE ARI.ysnPosted = 1 
		  AND ARI.strTransactionType IN ('Invoice', 'Credit Memo', 'Debit Memo', 'Cash', 'Cash Refund', 'Service Charge')	  
		  AND ISNULL(ARID.intStorageScheduleTypeId, 0) = 0
		  AND ISNULL(ICI.strType, '') <> 'Bundle'

		UNION ALL

		--INVOICE ITEMS = BUNDLE
		SELECT strRecordNumber			= ARI.strInvoiceNumber
			, strInvoiceOriginId		= ARI.strInvoiceOriginId
			, intSourceId				= ARI.intSourceId
			, intTransactionId			= ARI.intInvoiceId
			, intEntityCustomerId		= ARI.intEntityCustomerId
			, intAccountId				= ARI.intAccountId
			, intItemId					= ARID.intItemId
			, intItemUOMId				= ARID.intItemUOMId
			, dtmDate					= ARI.dtmDate
			, intCompanyLocationId		= ARI.intCompanyLocationId
			, intEntitySalespersonId	= ARI.intEntitySalespersonId
			, strTransactionType		= ARI.strTransactionType
			, strType					= ARI.strType
			, strItemDescription		= ARID.strItemDescription	  
			, intItemAccountId			= CASE WHEN ICI.strType IN ('Non-Inventory','Service','Other Charge') THEN ISNULL(ARID.intAccountId, ARID.intSalesAccountId) ELSE ISNULL(ARID.intSalesAccountId, ARID.intAccountId) END
			, dblQtyOrdered				= ARID.dblQtyOrdered
			, dblQtyShipped				= ARID.dblQtyShipped
			, dblStandardCost			= (CASE WHEN ISNULL(ICI.strLotTracking, 'No') = 'No' AND ISNULL(ARID.intInventoryShipmentItemId, 0) <> 0 AND ISNULL(ARID.intSalesOrderDetailId, 0) <> 0
													THEN CASE WHEN ISNULL(NONLOTTED.dblCost, 0) > 0 THEN ISNULL(NONLOTTED.dblCost, 0) / ARID.dblQtyShipped ELSE ISNULL(NONLOTTED.dblCost, 0) END
												WHEN ISNULL(ICI.strLotTracking, 'No') <> 'No' AND ISNULL(ARID.intInventoryShipmentItemId, 0) <> 0 AND ISNULL(ARID.intSalesOrderDetailId, 0) <> 0
													THEN CASE WHEN ISNULL(LOTTED.dblCost, 0) > 0 THEN ISNULL(LOTTED.dblCost, 0) / ARID.dblQtyShipped ELSE ISNULL(LOTTED.dblCost, 0) END 
												ELSE CASE WHEN ISNULL(NONSO.dblCost, 0) > 0 THEN ISNULL(NONSO.dblCost, 0) / ARID.dblQtyShipped ELSE ISNULL(NONSO.dblCost, 0) END
											END)
			, dblPrice					= ARID.dblPrice
			, dblTax					= ARID.dblTotalTax
			, dblLineTotal				= ARID.dblTotal
			, dblTotal					= ARI.dblInvoiceTotal			
			, strBillToLocationName		= ARI.strBillToLocationName
			, strShipToLocationName		=  CASE WHEN ARI.strType = 'Tank Delivery' AND TMSITE.intSiteID IS NOT NULL 
	 										THEN TMSITE.strSiteAddress ELSE ARI.strShipToLocationName END
			, intSiteId					= ARID.intSiteId
			, intTicketId				= ARID.intTicketId
			, strShipToCity				= CASE WHEN ARI.strType = 'Tank Delivery' AND TMSITE.intSiteID IS NOT NULL 
	 										THEN TMSITE.strCity ELSE ARI.strShipToCity END
			, strShipToState			= CASE WHEN ARI.strType = 'Tank Delivery' AND TMSITE.intSiteID IS NOT NULL 
	 										THEN TMSITE.strState ELSE ARI.strShipToState END
			, strShipToCountry			= CASE WHEN ARI.strType = 'Tank Delivery' AND TMSITE.intSiteID IS NOT NULL 
	 										THEN TMSITE.strCountry ELSE ARI.strShipToCountry END
			, strShipToZipCode			= CASE WHEN ARI.strType = 'Tank Delivery' AND TMSITE.intSiteID IS NOT NULL 
	 										THEN TMSITE.strZipCode ELSE ARI.strShipToZipCode END 
			, intCurrencyId				= ARI.intCurrencyId
			, intInvoiceDetailId		= ARID.intInvoiceDetailId
			, dblRebateAmount			= ARID.dblRebateAmount
			, dblBuybackAmount			= ARID.dblBuybackAmount
			, strAccountingPeriod	    = AccPeriod.strPeriod
		FROM tblARInvoiceDetail ARID 
		INNER JOIN tblARInvoice ARI ON ARID.intInvoiceId = ARI.intInvoiceId
		INNER JOIN #INVOICES II ON ARI.intInvoiceId = II.intInvoiceId
		INNER JOIN tblICItem ICI ON ARID.intItemId = ICI.intItemId
		LEFT JOIN tblGLFiscalYearPeriod AccPeriod ON ARI.intPeriodId = AccPeriod.intGLFiscalYearPeriodId
		LEFT OUTER JOIN (
			SELECT intTransactionId
				 , strTransactionId
				 , intTransactionDetailId
				 , dblCost	= SUM(ICIT.dblCost * (ABS(ICIT.dblQty) * ICIT.dblUOMQty))
			FROM tblICInventoryTransaction ICIT
			INNER JOIN tblARInvoiceDetailComponent ARIDC ON ICIT.intTransactionDetailId = ARIDC.intInvoiceDetailId
														AND ICIT.intItemId = ARIDC.intComponentItemId
			WHERE ICIT.ysnIsUnposted = 0
			  AND ICIT.intItemUOMId IS NOT NULL
			  AND ICIT.intTransactionTypeId <> 1
			GROUP BY ICIT.intTransactionDetailId, ICIT.intTransactionId, ICIT.strTransactionId
		) AS NONSO ON ARI.intInvoiceId			= NONSO.intTransactionId
				  AND ARI.strInvoiceNumber		= NONSO.strTransactionId
				  AND ARID.intInvoiceDetailId 	= NONSO.intTransactionDetailId
		LEFT OUTER JOIN (
			SELECT ICISI.intInventoryShipmentItemId
				 , ICISI.intLineNo
				 , ICISI.intItemId
				 , ICISI.intItemUOMId
				 , ICIT.dblCost		 
			FROM tblICInventoryShipmentItem ICISI	
			INNER JOIN tblICInventoryShipment ICIS ON ICISI.intInventoryShipmentId = ICIS.intInventoryShipmentId
			INNER JOIN tblICItem ICI ON ICISI.intItemId = ICI.intItemId
									AND ISNULL(ICI.strLotTracking, 'No') = 'No'
			INNER JOIN tblICInventoryTransaction ICIT ON ICIT.ysnIsUnposted					= 0
													 AND ISNULL(ICIT.intLotId, 0)			= 0
													 AND ICIS.intInventoryShipmentId		= ICIT.intTransactionId
													 AND ICIS.strShipmentNumber				= ICIT.strTransactionId
													 AND ICISI.intInventoryShipmentItemId	= ICIT.intTransactionDetailId
													 AND ICISI.intItemId					= ICIT.intItemId												 
													 AND ICIT.intInTransitSourceLocationId 	IS NULL
													 AND ICIT.intItemUOMId 					IS NOT NULL
													 AND ICIT.intTransactionTypeId 			<> 1
		) AS NONLOTTED ON ARID.intInventoryShipmentItemId	= NONLOTTED.intInventoryShipmentItemId
					  AND ARID.intItemId					= NONLOTTED.intItemId				  
					  AND ARID.intSalesOrderDetailId		= NONLOTTED.intLineNo
		LEFT OUTER JOIN (
			SELECT ICISI.intInventoryShipmentItemId
					, ICISI.intLineNo
					, ICISI.intItemId
					, ICISI.intItemUOMId
					, dblCost = ABS(AVG(ICIT.dblQty * ICIT.dblCost))
			FROM tblICInventoryShipmentItem ICISI
			INNER JOIN tblICInventoryShipment ICIS ON ICISI.intInventoryShipmentId = ICIS.intInventoryShipmentId
			INNER JOIN tblICItem ICI ON ICISI.intItemId = ICI.intItemId
									AND ISNULL(ICI.strLotTracking, 'No') <> 'No'
			INNER JOIN tblICInventoryTransaction ICIT ON ICIT.ysnIsUnposted					= 0
													 AND ISNULL(ICIT.intLotId, 0)			<> 0
													 AND ICIS.intInventoryShipmentId		= ICIT.intTransactionId
													 AND ICIS.strShipmentNumber				= ICIT.strTransactionId
													 AND ICISI.intInventoryShipmentItemId	= ICIT.intTransactionDetailId
													 AND ICISI.intItemId					= ICIT.intItemId		
													 AND ISNULL(ICI.strLotTracking, 'No')	<> 'No'
													 AND ICIT.intItemUOMId 					IS NOT NULL
													 AND ICIT.intTransactionTypeId 			<> 1
			INNER JOIN tblICLot ICL ON ICIT.intLotId = ICL.intLotId
								   AND ICISI.intItemUOMId = (CASE WHEN (ICI.strType = 'Finished Good' OR ICI.ysnAutoBlend = 1) THEN ICISI.intItemUOMId ELSE ICL.intItemUOMId END)
			GROUP BY ICISI.intInventoryShipmentItemId, ICISI.intLineNo, ICISI.intItemId, ICISI.intItemUOMId
		) AS LOTTED ON ARID.intInventoryShipmentItemId	= LOTTED.intInventoryShipmentItemId
				   AND ARID.intItemId					= LOTTED.intItemId
				   AND ARID.intSalesOrderDetailId		= LOTTED.intLineNo
		LEFT OUTER JOIN tblTMSite TMSITE ON TMSITE.intSiteID = ARID.intSiteId	
		WHERE ARI.ysnPosted = 1 
		  AND ARI.strTransactionType IN ('Invoice', 'Credit Memo', 'Debit Memo', 'Cash', 'Cash Refund', 'Service Charge')
		  AND ISNULL(ARID.intStorageScheduleTypeId, 0) = 0
		  AND ISNULL(ICI.strType, '') = 'Bundle'

	END

-- --SALES ORDERS
-- IF ISNULL(@ysnInvoice, 1) = 0 OR ISNULL(@ysnRebuild, 0) = 1
-- 	BEGIN	
-- 		IF ISNULL(@ysnRebuild, 0) = 1
-- 			BEGIN
-- 				INSERT INTO #ORDERS
-- 				SELECT SO.intSalesOrderId
-- 				FROM tblSOSalesOrder SO
-- 				WHERE SO.ysnProcessed = 1
-- 		          AND SO.strTransactionType = 'Order'
-- 			END
-- 		ELSE 
-- 			BEGIN
-- 				INSERT INTO #ORDERS
-- 				SELECT SO.intSalesOrderId
-- 				FROM tblSOSalesOrder SO
--                 INNER JOIN @tblTransactionIds II ON SO.intSalesOrderId = II.intHeaderId
-- 				WHERE SO.ysnProcessed = 1
-- 		          AND SO.strTransactionType = 'Order'
-- 			END

-- 		INSERT INTO #TRANSACTIONS (
-- 			  [strRecordNumber]
-- 			, [strInvoiceOriginId]
-- 			, [intSourceId]
-- 			, [intTransactionId]
-- 			, [intEntityCustomerId]
-- 			, [intAccountId]
-- 			, [intItemId]
-- 			, [intItemUOMId]
-- 			, [dtmDate]
-- 			, [intCompanyLocationId]
-- 			, [intEntitySalespersonId]
-- 			, [strTransactionType]
-- 			, [strType]
-- 			, [strItemDescription]
-- 			, [intItemAccountId]
-- 			, [dblQtyOrdered]
-- 			, [dblQtyShipped]
-- 			, [dblStandardCost]
-- 			, [dblPrice]
-- 			, [dblTax]
-- 			, [dblLineTotal]
-- 			, [dblTotal]
-- 			, [strBillToLocationName]
-- 			, [strShipToLocationName]
-- 			, [intSiteId]
-- 			, [intTicketId]
-- 			, [strShipToCity]
-- 			, [strShipToState]
-- 			, [strShipToCountry]
-- 			, [strShipToZipCode]
-- 			, [intCurrencyId]
-- 			, [intInvoiceDetailId]
-- 			, [dblRebateAmount]
-- 			, [dblBuybackAmount]
-- 			, [strAccountingPeriod]
-- 		)
-- 		SELECT strRecordNumber				= SO.strSalesOrderNumber
-- 			, strInvoiceOriginId			= NULL
-- 			, intSourceId					= NULL
-- 			, intTransactionId				= SO.intSalesOrderId
-- 			, intEntityCustomerId			= SO.intEntityCustomerId
-- 			, intAccountId					= SO.intAccountId
-- 			, intItemId						= SOD.intItemId
-- 			, intItemUOMId					= SOD.intItemUOMId
-- 			, dtmDate						= SO.dtmDate
-- 			, intCompanyLocationId			= SO.intCompanyLocationId
-- 			, intEntitySalespersonId		= SO.intEntitySalespersonId
-- 			, strTransactionType			= SO.strTransactionType
-- 			, strType						= SO.strType
-- 			, strItemDescription			= SOD.strItemDescription
-- 			, intItemAccountId				= CASE WHEN ICI.strType = 'Software' 
-- 														THEN CASE WHEN SOD.strMaintenanceType IN ('License/Maintenance', 'License Only')
-- 																	THEN ISNULL(INV.intLicenseAccountId, SOD.intLicenseAccountId)
-- 																  WHEN SOD.strMaintenanceType IN ('License/Maintenance', 'License Only')
-- 																	THEN ISNULL(INV.intMaintenanceAccountId, SOD.intMaintenanceAccountId)
-- 															 END
-- 												   ELSE ISNULL(ISNULL(INV.intSalesAccountId, SOD.intSalesAccountId), SOD.intAccountId)  
-- 											  END
-- 			, dblQtyOrdered					= SOD.dblQtyOrdered
-- 			, dblQtyShipped					= SOD.dblQtyShipped
-- 			, dblStandardCost				= (CASE WHEN ISNULL(ICI.strLotTracking, 'No') = 'No' AND ISNULL(INV.intSalesOrderDetailId, 0) <> 0
-- 														THEN --dbo.fnCalculateCostBetweenUOM(INV.intOrderUOMId, SOD.intItemUOMId, ISNULL(INV.dblCost, 0))
-- 															 CASE WHEN ISNULL(INV.dblUnitQty, 0) = 0 OR ISNULL(SU.dblUnitQty, 0) = 0 THEN NULL 			
-- 																  WHEN INV.dblUnitQty = SU.dblUnitQty THEN ISNULL(INV.dblCost, 0)
-- 																  WHEN INV.dblUnitQty = 1 THEN ISNULL(INV.dblCost, 0) * SU.dblUnitQty
-- 																  WHEN SU.dblUnitQty = 1 THEN ISNULL(INV.dblCost, 0) / INV.dblUnitQty
-- 																  WHEN INV.dblUnitQty < 1 AND INV.dblUnitQty < SU.dblUnitQty THEN (ISNULL(INV.dblCost, 0) / INV.dblUnitQty) * SU.dblUnitQty
-- 																  WHEN INV.dblUnitQty < SU.dblUnitQty THEN (ISNULL(INV.dblCost, 0) * INV.dblUnitQty) / SU.dblUnitQty 
-- 																  WHEN INV.dblUnitQty > SU.dblUnitQty THEN (ISNULL(INV.dblCost, 0) / INV.dblUnitQty) * SU.dblUnitQty 
-- 																  ELSE (ISNULL(INV.dblCost, 0) * INV.dblUnitQty) / SU.dblUnitQty				
-- 															END
-- 													WHEN ISNULL(ICI.strLotTracking, 'No') = 'No' AND ISNULL(NONLOTTED.intInventoryShipmentItemId, 0) <> 0
-- 														THEN --dbo.fnCalculateCostBetweenUOM(NONLOTTED.intItemUOMId, SOD.intItemUOMId, ISNULL(NONLOTTED.dblCost, 0))
-- 															 CASE WHEN ISNULL(NONLOTTED.dblUnitQty, 0) = 0 OR ISNULL(SU.dblUnitQty, 0) = 0 THEN NULL 			
-- 																  WHEN NONLOTTED.dblUnitQty = SU.dblUnitQty THEN ISNULL(NONLOTTED.dblCost, 0)
-- 																  WHEN NONLOTTED.dblUnitQty = 1 THEN ISNULL(NONLOTTED.dblCost, 0) * SU.dblUnitQty
-- 																  WHEN SU.dblUnitQty = 1 THEN ISNULL(NONLOTTED.dblCost, 0) / NONLOTTED.dblUnitQty
-- 																  WHEN NONLOTTED.dblUnitQty < 1 AND NONLOTTED.dblUnitQty < SU.dblUnitQty THEN (ISNULL(NONLOTTED.dblCost, 0) / NONLOTTED.dblUnitQty) * SU.dblUnitQty
-- 																  WHEN NONLOTTED.dblUnitQty < SU.dblUnitQty THEN (ISNULL(NONLOTTED.dblCost, 0) * NONLOTTED.dblUnitQty) / SU.dblUnitQty 
-- 																  WHEN NONLOTTED.dblUnitQty > SU.dblUnitQty THEN (ISNULL(NONLOTTED.dblCost, 0) / NONLOTTED.dblUnitQty) * SU.dblUnitQty 
-- 																  ELSE (ISNULL(NONLOTTED.dblCost, 0) * NONLOTTED.dblUnitQty) / SU.dblUnitQty				
-- 															END
-- 													WHEN ISNULL(ICI.strLotTracking, 'No') <> 'No' AND ISNULL(LOTTED.intInventoryShipmentItemId, 0) <> 0
-- 														THEN --dbo.fnCalculateCostBetweenUOM(LOTTED.intItemUOMId, SOD.intItemUOMId, ISNULL(LOTTED.dblCost, 0))
-- 															 CASE WHEN ISNULL(LOTTED.dblUnitQty, 0) = 0 OR ISNULL(SU.dblUnitQty, 0) = 0 THEN NULL 			
-- 																  WHEN LOTTED.dblUnitQty = SU.dblUnitQty THEN ISNULL(LOTTED.dblCost, 0)
-- 																  WHEN LOTTED.dblUnitQty = 1 THEN ISNULL(LOTTED.dblCost, 0) * SU.dblUnitQty
-- 																  WHEN SU.dblUnitQty = 1 THEN ISNULL(LOTTED.dblCost, 0) / LOTTED.dblUnitQty
-- 																  WHEN LOTTED.dblUnitQty < 1 AND LOTTED.dblUnitQty < SU.dblUnitQty THEN (ISNULL(LOTTED.dblCost, 0) / LOTTED.dblUnitQty) * SU.dblUnitQty
-- 																  WHEN LOTTED.dblUnitQty < SU.dblUnitQty THEN (ISNULL(LOTTED.dblCost, 0) * LOTTED.dblUnitQty) / SU.dblUnitQty 
-- 																  WHEN LOTTED.dblUnitQty > SU.dblUnitQty THEN (ISNULL(LOTTED.dblCost, 0) / LOTTED.dblUnitQty) * SU.dblUnitQty 
-- 																  ELSE (ISNULL(LOTTED.dblCost, 0) * LOTTED.dblUnitQty) / SU.dblUnitQty				
-- 															END 
-- 													ELSE 0.000000
-- 												END)
-- 			, dblPrice						= CASE WHEN ICI.strType = 'Software' 
-- 														THEN CASE WHEN SOD.strMaintenanceType IN ('License/Maintenance', 'License Only')
-- 																	THEN SOD.dblLicenseAmount
-- 																  WHEN SOD.strMaintenanceType IN ('License/Maintenance', 'License Only')
-- 																	THEN SOD.dblMaintenanceAmount
-- 															 END
-- 												   ELSE SOD.dblPrice
-- 											  END
-- 			, dblTax						= SOD.dblTotalTax
-- 			, dblLineTotal					= CASE WHEN ICI.strType = 'Software' 
-- 														THEN CASE WHEN SOD.strMaintenanceType IN ('License/Maintenance', 'License Only')
-- 																	THEN SOD.dblQtyOrdered * SOD.dblLicenseAmount
-- 																  WHEN SOD.strMaintenanceType IN ('License/Maintenance', 'License Only')
-- 																	THEN SOD.dblQtyOrdered * SOD.dblMaintenanceAmount
-- 															 END
-- 												   ELSE SOD.dblTotal
-- 											  END
-- 			, dblTotal						= SO.dblSalesOrderTotal
-- 			, strBillToLocationName			= SO.strBillToLocationName
-- 			, strShipToLocationName			= SO.strShipToLocationName
-- 			, intSiteId						= NULL
-- 			, intTicketId					= NULL
-- 			, strShipToCity					= SO.strShipToCity
-- 			, strShipToState				= SO.strShipToState
-- 			, strShipToCountry				= SO.strShipToCountry
-- 			, strShipToZipCode				= SO.strShipToZipCode
-- 			, intCurrencyId					= SO.intCurrencyId
-- 			, intInvoiceDetailId			= NULL
-- 			, dblRebateAmount				= 0.000000
-- 			, dblBuybackAmount				= 0.000000
-- 			, strAccountingPeriod		    = NULL
-- 		FROM tblSOSalesOrder SO 
-- 		INNER JOIN #ORDERS SS ON SO.intSalesOrderId = SS.intSalesOrderId
-- 		INNER JOIN tblSOSalesOrderDetail SOD ON SO.intSalesOrderId = SOD.intSalesOrderId
-- 		LEFT JOIN tblICItem ICI ON SOD.intItemId = ICI.intItemId			
-- 		LEFT JOIN tblICItemUOM SU ON SOD.intItemUOMId = SU.intItemUOMId
-- 		LEFT OUTER JOIN (
-- 			SELECT ID.intSalesOrderDetailId
-- 				 , ID.intItemId
-- 				 , ID.intOrderUOMId
-- 				 , ICIT.dblCost
-- 				 , ID.intAccountId
-- 				 , ID.intSalesAccountId
-- 				 , ID.intLicenseAccountId
-- 				 , ID.intMaintenanceAccountId
-- 				 , UOM.dblUnitQty
-- 			FROM tblARInvoiceDetail ID
-- 			INNER JOIN tblARInvoice I ON ID.intInvoiceId = I.intInvoiceId
-- 			INNER JOIN tblICItem ICI ON ID.intItemId = ICI.intItemId
-- 									AND ISNULL(ICI.strLotTracking, 'No') = 'No'
-- 			INNER JOIN tblICItemUOM UOM ON ID.intOrderUOMId = UOM.intItemUOMId
-- 			INNER JOIN tblICInventoryTransaction ICIT ON ICIT.ysnIsUnposted			= 0
-- 													 AND ISNULL(ICIT.intLotId, 0)	= 0
-- 													 AND I.intInvoiceId				= ICIT.intTransactionId
-- 													 AND I.strInvoiceNumber			= ICIT.strTransactionId
-- 													 AND ID.intInvoiceDetailId		= ICIT.intTransactionDetailId
-- 													 AND ID.intItemId				= ICIT.intItemId
-- 													 AND ICIT.intItemUOMId 			IS NOT NULL
-- 													 AND ICIT.intTransactionTypeId 	<> 1
-- 			WHERE ID.intSalesOrderDetailId IS NOT NULL
-- 		) AS INV ON SOD.intSalesOrderDetailId = INV.intSalesOrderDetailId
-- 				AND SOD.intItemId			 = INV.intItemId
-- 		LEFT OUTER JOIN (
-- 			SELECT intInventoryShipmentItemId	= ICISI.intInventoryShipmentItemId
-- 				 , intLineNo					= ICISI.intLineNo
-- 				 , intItemId					= ICISI.intItemId
-- 				 , intItemUOMId					= ICISI.intItemUOMId
-- 				 , dblCost						= ICIT.dblCost
-- 				 , dblUnitQty					= UOM.dblUnitQty		 
-- 			FROM tblICInventoryShipmentItem ICISI	
-- 			INNER JOIN tblICInventoryShipment ICIS ON ICISI.intInventoryShipmentId = ICIS.intInventoryShipmentId
-- 			INNER JOIN tblICItem ICI ON ICISI.intItemId = ICI.intItemId
-- 									AND ISNULL(ICI.strLotTracking, 'No') = 'No'
-- 			INNER JOIN tblICInventoryTransaction ICIT ON ICIT.ysnIsUnposted					= 0
-- 													 AND ISNULL(ICIT.intLotId, 0)			= 0
-- 													 AND ICIS.intInventoryShipmentId		= ICIT.intTransactionId
-- 													 AND ICIS.strShipmentNumber				= ICIT.strTransactionId
-- 													 AND ICISI.intInventoryShipmentItemId	= ICIT.intTransactionDetailId
-- 													 AND ICISI.intItemId					= ICIT.intItemId
-- 													 AND ICIT.intInTransitSourceLocationId 	IS NULL
-- 													 AND ICIT.intItemUOMId 					IS NOT NULL
-- 													 AND ICIT.intTransactionTypeId 			<> 1
-- 			INNER JOIN tblICItemUOM UOM ON ICIT.intItemUOMId = UOM.intItemUOMId
-- 		) AS NONLOTTED ON SOD.intItemId	= NONLOTTED.intItemId
-- 					  AND SOD.intSalesOrderDetailId	= NONLOTTED.intLineNo
-- 		LEFT OUTER JOIN (
-- 			SELECT intInventoryShipmentItemId	= ICISI.intInventoryShipmentItemId
-- 				 , intLineNo					= ICISI.intLineNo
-- 				 , intItemId					= ICISI.intItemId
-- 				 , intItemUOMId					= ICISI.intItemUOMId
-- 				 , dblCost						= ABS(AVG(ICIT.dblQty * ICIT.dblCost))
-- 				 , dblUnitQty					= AVG(UOM.dblUnitQty)
-- 			FROM tblICInventoryShipmentItem ICISI
-- 			INNER JOIN tblICInventoryShipment ICIS ON ICISI.intInventoryShipmentId = ICIS.intInventoryShipmentId
-- 			INNER JOIN tblICItem ICI ON ICISI.intItemId = ICI.intItemId
-- 									AND ISNULL(ICI.strLotTracking, 'No') <> 'No'
-- 			INNER JOIN tblICInventoryTransaction ICIT ON ICIT.ysnIsUnposted					= 0
-- 													 AND ISNULL(ICIT.intLotId, 0)			<> 0
-- 													 AND ICIS.intInventoryShipmentId		= ICIT.intTransactionId
-- 													 AND ICIS.strShipmentNumber				= ICIT.strTransactionId
-- 													 AND ICISI.intInventoryShipmentItemId	= ICIT.intTransactionDetailId
-- 													 AND ICISI.intItemId					= ICIT.intItemId
-- 													 AND ICIT.intItemUOMId 					IS NOT NULL
-- 													 AND ICIT.intTransactionTypeId 			<> 1
-- 			INNER JOIN tblICItemUOM UOM ON ICIT.intItemUOMId = UOM.intItemUOMId
-- 			INNER JOIN tblICLot ICL ON ICIT.intLotId = ICL.intLotId
-- 								   AND ICISI.intItemUOMId = (CASE WHEN ICI.strType = 'Finished Good' OR ICI.ysnAutoBlend = 1 THEN ICISI.intItemUOMId ELSE ICL.intItemUOMId END)
-- 			GROUP BY ICISI.intInventoryShipmentItemId, ICISI.intLineNo, ICISI.intItemId, ICISI.intItemUOMId
-- 		) AS LOTTED ON SOD.intItemId				= LOTTED.intItemId
-- 				   AND SOD.intSalesOrderDetailId	= LOTTED.intLineNo
-- 		WHERE SO.ysnProcessed = 1
-- 		  AND SO.strTransactionType = 'Order'
-- 	END	

--CUSTOMERS
INSERT INTO #CUSTOMERS (
	  intEntityCustomerId
	, strCustomerName
	, strCustomerNumber
	, strAccountStatusCode
)
SELECT intEntityCustomerId		= CC.intEntityId
	, strCustomerName			= E.strName
	, strCustomerNumber			= CC.strCustomerNumber
	, strAccountStatusCode		= SC.strAccountStatusCode
FROM (
	SELECT DISTINCT intEntityCustomerId 
	FROM #TRANSACTIONS
	WHERE intEntityCustomerId IS NOT NULL 
) C
INNER JOIN tblARCustomer CC ON C.intEntityCustomerId = CC.intEntityId
INNER JOIN tblEMEntity E ON E.intEntityId = CC.intEntityId
OUTER APPLY (
	 SELECT strAccountStatusCode = LEFT(strAccountStatusCode, LEN(strAccountStatusCode) - 1) COLLATE Latin1_General_CI_AS
	 FROM (
	  SELECT CAST(ARAS.strAccountStatusCode AS VARCHAR(200))  + ', '
	  FROM dbo.tblARCustomerAccountStatus CAS WITH(NOLOCK)
	  INNER JOIN (
	   SELECT intAccountStatusId
		 , strAccountStatusCode
	   FROM dbo.tblARAccountStatus WITH (NOLOCK)
	  ) ARAS ON CAS.intAccountStatusId = ARAS.intAccountStatusId
	  WHERE CAS.intEntityCustomerId = C.intEntityCustomerId
	  FOR XML PATH ('')
	 ) SC (strAccountStatusCode)
) SC

IF ISNULL(@ysnRebuild, 0) = 1
	TRUNCATE TABLE tblARSalesAnalysisStagingReport

INSERT INTO tblARSalesAnalysisStagingReport (
	  strRecordNumber
	, strInvoiceOriginId
	, intSourceId
	, intTransactionId
	, intAccountId
	, dtmDate
	, intCompanyLocationId
	, intEntityCustomerId
	, intItemId
	, intUnitMeasureId
	, intManufacturerId
	, intBrandId
	, intCommodityId
	, intCategoryId
	, intEntitySalespersonId
	, intTicketId
	, strTransactionType
	, strType
	, dblQtyOrdered
	, dblQtyShipped
	, dblUnitCost
	, dblTotalCost
	, dblMargin
	, dblMarginPercentage
	, dblMarginPerUnit
	, dblMarginPerUnitPercentage
	, dblPrice
	, dblTax
	, dblLineTotal
	, dblTotal
	, strCustomerNumber
	, intItemAccountId
	, strAccountId
	, strAccountName
	, strLocationName
	, strItemName
	, strItemDesc
	, strLineDesc
	, strUOM
	, strManufacturer
	, strBrandName
	, strCommodityName
	, strCategoryName
	, strCategoryDescription
    , strCustomerName
	, strSalespersonName
	, strBillTo
	, strShipTo
	, strSiteNumber
	, strSiteDescription
	, strTicketNumber
	, strCustomerReference
	, strShipToCity
	, strShipToState
	, strShipToCountry
	, strShipToZipCode
	, intCurrencyId
	, strCurrency
	, strCurrencyDescription
	, intInvoiceDetailId
	, dblRebateAmount
	, dblBuybackAmount
	, strAccountStatusCode
    , strAccountingPeriod
)
SELECT strRecordNumber			= SAR.strRecordNumber
	  , strInvoiceOriginId		= SAR.strInvoiceOriginId
      , intSourceId				= SAR.intSourceId
	  , intTransactionId		= SAR.intTransactionId
	  , intAccountId			= SAR.intAccountId
	  , dtmDate					= DATEADD(dd, DATEDIFF(dd, 0, dtmDate), 0)
	  , intCompanyLocationId	= SAR.intCompanyLocationId
	  , intEntityCustomerId		= SAR.intEntityCustomerId
	  , intItemId				= IC.intItemId
	  , intUnitMeasureId		= UOM.intUnitMeasureId
	  , intManufacturerId		= IC.intManufacturerId
	  , intBrandId				= IC.intBrandId
	  , intCommodityId			= IC.intCommodityId
	  , intCategoryId			= IC.intCategoryId	  
	  , intEntitySalespersonId	= SAR.intEntitySalespersonId
	  , intTicketId				= SAR.intTicketId
	  , strTransactionType		= SAR.strTransactionType
	  , strType					= SAR.strType
	  , dblQtyOrdered			= CASE WHEN SAR.strTransactionType IN ('Credit Memo', 'Overpayment', 'Credit', 'Customer Prepayment', 'Cash Refund') THEN -ISNULL(SAR.dblQtyOrdered, 0) ELSE ISNULL(SAR.dblQtyOrdered, 0) END
	  , dblQtyShipped			= CASE WHEN SAR.strTransactionType IN ('Credit Memo', 'Overpayment', 'Credit', 'Customer Prepayment', 'Cash Refund') THEN -ISNULL(SAR.dblQtyShipped, 0) ELSE ISNULL(SAR.dblQtyShipped, 0) END
	  , dblUnitCost				= ISNULL(SAR.dblStandardCost, 0)
	  , dblTotalCost			= ROUND(ISNULL(SAR.dblStandardCost, 0) *
									CASE WHEN SAR.strTransactionType IN ('Invoice', 'Credit Memo', 'Debit Memo', 'Cash', 'Cash Refund') 
										THEN CASE WHEN SAR.strTransactionType IN ('Credit Memo', 'Overpayment', 'Credit', 'Customer Prepayment', 'Cash Refund') THEN -ISNULL(SAR.dblQtyShipped, 0) ELSE ISNULL(SAR.dblQtyShipped, 0) END
										ELSE ISNULL(SAR.dblQtyOrdered, 0)
									END,2)
	 , dblMargin				= ((ISNULL(SAR.dblPrice, 0) - ISNULL(SAR.dblStandardCost, 0)) * 
									CASE WHEN SAR.strTransactionType IN ('Invoice', 'Credit Memo', 'Debit Memo', 'Cash', 'Cash Refund') 
										THEN CASE WHEN SAR.strTransactionType IN ('Credit Memo', 'Overpayment', 'Credit', 'Customer Prepayment', 'Cash Refund') 
											THEN -ISNULL(SAR.dblQtyShipped, 0) ELSE ISNULL(SAR.dblQtyShipped, 0) END
										ELSE ISNULL(SAR.dblQtyOrdered, 0)
									END) + ISNULL(SAR.dblRebateAmount, 0)
	 , dblMarginPercentage		= CASE WHEN (ISNULL(SAR.dblPrice, 0) - ISNULL(SAR.dblStandardCost, 0)) * 
											CASE WHEN SAR.strTransactionType IN ('Invoice', 'Credit Memo', 'Debit Memo', 'Cash', 'Cash Refund') 
												THEN ISNULL(SAR.dblQtyShipped, 0)
												ELSE ISNULL(SAR.dblQtyOrdered, 0)
											END <> 0 --AND ISNULL(SAR.dblLineTotal, 0) > 0
									THEN 
										CASE WHEN ISNULL(SAR.dblLineTotal, 0) = 0
											 THEN 
												CASE WHEN ISNULL(SAR.dblBuybackAmount, 0) <> 0
												     THEN ((ISNULL(SAR.dblBuybackAmount, 0) - (ISNULL(SAR.dblStandardCost, 0) * ISNULL(SAR.dblQtyShipped, 0))) / ISNULL(SAR.dblBuybackAmount, 0)) * 100
													 ELSE -100
												END
											 ELSE
												(((ISNULL(SAR.dblPrice, 0) - ISNULL(SAR.dblStandardCost, 0)) * 
												CASE WHEN SAR.strTransactionType IN ('Invoice', 'Credit Memo', 'Debit Memo', 'Cash', 'Cash Refund') 
													THEN CASE WHEN SAR.strTransactionType IN ('Credit Memo', 'Overpayment', 'Credit', 'Customer Prepayment', 'Cash Refund') THEN -ISNULL(SAR.dblQtyShipped, 0) ELSE ISNULL(SAR.dblQtyShipped, 0) END
													ELSE ISNULL(SAR.dblQtyOrdered, 0)
												END + ISNULL(SAR.dblRebateAmount, 0))/ ISNULL(SAR.dblLineTotal, 0)) * 100
											 END
									ELSE 0 
								  END
	 , dblMarginPerUnit 		= ISNULL(
									CASE WHEN dblQtyShipped != 0 THEN 
										((ISNULL(SAR.dblPrice, 0) - ISNULL(SAR.dblStandardCost, 0)) * 
											CASE WHEN SAR.strTransactionType IN ('Invoice', 'Credit Memo', 'Debit Memo', 'Cash', 'Cash Refund') 
												THEN CASE WHEN SAR.strTransactionType IN ('Credit Memo', 'Overpayment', 'Credit', 'Customer Prepayment', 'Cash Refund') 
													THEN -ISNULL(SAR.dblQtyShipped, 0) ELSE ISNULL(SAR.dblQtyShipped, 0) END
												ELSE ISNULL(SAR.dblQtyOrdered, 0)
											END) / ISNULL(SAR.dblQtyShipped, 0) + (ISNULL(SAR.dblRebateAmount, 0) / ISNULL(SAR.dblQtyShipped, 0))
									END
								,0)
	 , dblMarginPerUnitPercentage = ISNULL(
									CASE WHEN SAR.strTransactionType IN ('Invoice', 'Credit Memo', 'Debit Memo', 'Cash', 'Cash Refund') AND ISNULL(SAR.dblQtyShipped, 0) <> 0
										 THEN (((ISNULL(SAR.dblPrice, 0) - ISNULL(SAR.dblStandardCost, 0) + (ISNULL(SAR.dblRebateAmount, 0) / ABS(SAR.dblQtyShipped) )) *
											CASE WHEN SAR.strTransactionType IN ('Credit Memo', 'Overpayment', 'Credit', 'Customer Prepayment', 'Cash Refund') 
													THEN -SAR.dblQtyShipped
													ELSE SAR.dblQtyShipped 
											END) / 100) / SAR.dblQtyShipped
										 WHEN SAR.strTransactionType = 'Order' AND ISNULL(SAR.dblQtyOrdered, 0) <> 0
										 THEN (((ISNULL(SAR.dblPrice, 0) - ISNULL(SAR.dblStandardCost, 0)) * SAR.dblQtyOrdered) / 100) / SAR.dblQtyOrdered
										 ELSE 0
									END
								, 0)
	 , dblPrice					= ISNULL(SAR.dblPrice, 0)
	 , dblTax					= CASE WHEN SAR.strTransactionType IN ('Credit Memo', 'Overpayment', 'Credit', 'Customer Prepayment', 'Cash Refund') THEN -ISNULL(SAR.dblTax, 0) ELSE ISNULL(SAR.dblTax, 0) END
	 , dblLineTotal				= CASE WHEN SAR.strTransactionType IN ('Credit Memo', 'Overpayment', 'Credit', 'Customer Prepayment', 'Cash Refund') THEN -ISNULL(SAR.dblLineTotal, 0) ELSE ISNULL(SAR.dblLineTotal, 0) END
	 , dblTotal					= CASE WHEN SAR.strTransactionType IN ('Credit Memo', 'Overpayment', 'Credit', 'Customer Prepayment', 'Cash Refund') THEN -ISNULL(SAR.dblTotal, 0) ELSE ISNULL(SAR.dblTotal, 0) END
	 , strCustomerNumber		= C.strCustomerNumber
	 , intItemAccountId			= SAR.intItemAccountId
	 , strAccountId				= GA.strAccountId
	 , strAccountName			= GA.strDescription
	 , strLocationName			= L.strLocationName
	 , strItemName				= IC.strItemNo
	 , strItemDesc				= IC.strDescription
	 , strLineDesc				= SAR.strItemDescription
	 , strUOM					= UOM.strUnitMeasure
	 , strManufacturer			= ICM.strManufacturer
	 , strBrandName				= ICB.strBrandName
	 , strCommodityName			= ICC.strCommodityCode
	 , strCategoryName			= CAT.strCategoryCode
	 , strCategoryDescription	= CAT.strDescription
     , strCustomerName			= C.strCustomerName
	 , strSalespersonName		= ESP.strName
	 , strBillTo				= RTRIM(SAR.strBillToLocationName)
	 , strShipTo				= RTRIM(SAR.strShipToLocationName)
	 , strSiteNumber			= REPLACE(STR(TMS.intSiteNumber, 4), SPACE(1), '0') COLLATE Latin1_General_CI_AS
	 , strSiteDescription		= TMS.strDescription
	 , strTicketNumber			= SCT.strTicketNumber
	 , strCustomerReference		= SCT.strCustomerReference
	 , strShipToCity			= RTRIM(strShipToCity)
	 , strShipToState			= RTRIM(strShipToState)
	 , strShipToCountry			= RTRIM(strShipToCountry)
	 , strShipToZipCode			= RTRIM(strShipToZipCode)
	 , intCurrencyId			= SAR.intCurrencyId
	 , strCurrency				= SMC.strCurrency
	 , strCurrencyDescription	= SMC.strDescription
	 , intInvoiceDetailId 		= SAR.intInvoiceDetailId
	 , dblRebateAmount			= SAR.dblRebateAmount
	 , dblBuybackAmount			= SAR.dblBuybackAmount
	 , strAccountStatusCode 	= C.strAccountStatusCode
     , strAccountingPeriod	    = SAR.strAccountingPeriod
FROM #TRANSACTIONS SAR
LEFT JOIN tblGLAccount GA ON SAR.intItemAccountId = GA.intAccountId
INNER JOIN tblSMCompanyLocation L ON SAR.intCompanyLocationId = L.intCompanyLocationId
INNER JOIN #CUSTOMERS C ON SAR.intEntityCustomerId = C.intEntityCustomerId
INNER JOIN tblSMCurrency SMC ON SAR.intCurrencyId = SMC.intCurrencyID
LEFT JOIN tblARSalesperson SP ON SAR.intEntitySalespersonId = SP.intEntityId
LEFT JOIN tblEMEntity ESP ON SP.intEntityId = ESP.intEntityId
LEFT JOIN tblICItem IC ON SAR.intItemId = IC.intItemId
LEFT JOIN tblICManufacturer ICM ON IC.intManufacturerId = ICM.intManufacturerId
LEFT JOIN tblICCommodity ICC ON IC.intCommodityId = ICC.intCommodityId
LEFT JOIN tblICCategory CAT ON IC.intCategoryId = CAT.intCategoryId		
LEFT JOIN tblICBrand ICB ON IC.intBrandId = ICB.intBrandId
LEFT JOIN tblICItemUOM IUOM ON SAR.intItemUOMId = IUOM.intItemUOMId
LEFT JOIN tblICUnitMeasure UOM ON IUOM.intUnitMeasureId = UOM.intUnitMeasureId
LEFT JOIN tblTMSite TMS ON SAR.intSiteId = TMS.intSiteID
LEFT JOIN tblSCTicket SCT ON SAR.intTicketId = SCT.intTicketId
GROUP BY 
	  SAR.strRecordNumber
	, SAR.strInvoiceOriginId
	, SAR.intSourceId
	, SAR.intTransactionId
	, SAR.intAccountId
	, SAR.dtmDate
	, SAR.intCompanyLocationId
	, SAR.intEntityCustomerId
	, IC.intItemId
	, UOM.intUnitMeasureId
	, IC.intManufacturerId
	, IC.intBrandId
	, IC.intCommodityId
	, IC.intCategoryId
	, SAR.intEntitySalespersonId
	, SAR.intTicketId
	, SAR.strTransactionType
	, SAR.strType
	, SAR.dblQtyOrdered
	, SAR.dblQtyShipped
	, SAR.dblStandardCost
	, SAR.dblPrice
	, SAR.dblRebateAmount
	, SAR.dblBuybackAmount
	, SAR.dblLineTotal
	, SAR.dblTax
	, SAR.dblTotal
	, C.strCustomerNumber
	, SAR.intItemAccountId
	, GA.strAccountId
	, GA.strDescription
	, L.strLocationName
	, IC.strItemNo
	, IC.strDescription
	, SAR.strItemDescription
	, UOM.strUnitMeasure
	, ICM.strManufacturer
	, ICB.strBrandName
	, ICC.strCommodityCode
	, CAT.strCategoryCode
	, CAT.strDescription
	, C.strCustomerName
	, ESP.strName
	, SAR.strBillToLocationName
	, SAR.strShipToLocationName
	, TMS.intSiteNumber
	, TMS.strDescription
	, SCT.strTicketNumber
	, SCT.strCustomerReference
	, strShipToCity
	, strShipToState
	, strShipToCountry
	, SAR.strShipToZipCode
	, SAR.intCurrencyId
	, SMC.strCurrency
	, SMC.strDescription
	, SAR.intInvoiceDetailId
	, C.strAccountStatusCode
	, SAR.strAccountingPeriod

IF ISNULL(@intNewPerformanceLogId, 0) <> 0 AND ISNULL(@ysnRebuild, 0) = 1
	BEGIN
		EXEC dbo.uspARLogPerformanceRuntime @strScreenName			= 'Rebuild Sales Analysis Report'
										  , @strProcedureName       = 'uspARSalesAnalysisReport'
										  , @strRequestId			= @strRequestId
										  , @ysnStart		        = 0
										  , @intUserId	            = 1
										  , @intPerformanceLogId    = @intNewPerformanceLogId
	END