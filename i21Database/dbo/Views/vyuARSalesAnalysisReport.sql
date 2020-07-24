CREATE VIEW [dbo].[vyuARSalesAnalysisReport]
AS
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
	  , dblTotalCost			= ISNULL(SAR.dblStandardCost, 0) *
									CASE WHEN SAR.strTransactionType IN ('Invoice', 'Credit Memo', 'Debit Memo', 'Cash', 'Cash Refund') 
										THEN CASE WHEN SAR.strTransactionType IN ('Credit Memo', 'Overpayment', 'Credit', 'Customer Prepayment', 'Cash Refund') THEN -ISNULL(SAR.dblQtyShipped, 0) ELSE ISNULL(SAR.dblQtyShipped, 0) END
										ELSE ISNULL(SAR.dblQtyOrdered, 0)
									END
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
     , strCustomerName			= E.strName
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
	 , strCurrency				= SAR.strCurrency
	 , strCurrencyDescription	= SAR.strCurrencyDescription
	 , intInvoiceDetailId 		= SAR.intInvoiceDetailId
	 , dblRebateAmount			= SAR.dblRebateAmount
	 , dblBuybackAmount			= SAR.dblBuybackAmount
	 , strAccountStatusCode 	= STATUSCODES.strAccountStatusCode
     , strAccountingPeriod	    = SAR.strAccountingPeriod
FROM
(
	--INVOICE/NORMAL ITEMS
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
		, dblStandardCost			= (CASE WHEN ARI.strType = 'CF Tran' AND CFTRAN.strTransactionType IN ('Remote', 'Extended Remote')
												THEN ISNULL(CFTRAN.dblNetTransferCost, 0)
											WHEN ISNULL(ARID.intInventoryShipmentItemId, 0) = 0
												THEN dbo.fnCalculateCostBetweenUOM(NONSO.intItemUOMId, ARID.intItemUOMId, ISNULL(NONSO.dblCost, 0))
											WHEN ISNULL(ICI.strLotTracking, 'No') = 'No' AND ISNULL(ARID.intInventoryShipmentItemId, 0) <> 0
												THEN dbo.fnCalculateCostBetweenUOM(NONLOTTED.intItemUOMId, ARID.intItemUOMId, ISNULL(NONLOTTED.dblCost, 0))
											WHEN ISNULL(ICI.strLotTracking, 'No') <> 'No' AND ISNULL(ARID.intInventoryShipmentItemId, 0) <> 0 AND ISNULL(ARID.intSalesOrderDetailId, 0) <> 0
												THEN dbo.fnCalculateCostBetweenUOM(LOTTED.intItemUOMId, ARID.intItemUOMId, ISNULL(LOTTED.dblCost, 0))
											ELSE dbo.fnCalculateCostBetweenUOM(NONSO.intItemUOMId, ARID.intItemUOMId, ISNULL(NONSO.dblCost, 0))
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
		, strCurrency				= SMC.strCurrency
		, strCurrencyDescription	= SMC.strDescription
		, intInvoiceDetailId		= ARID.intInvoiceDetailId
		, dblRebateAmount			= ARID.dblRebateAmount
		, dblBuybackAmount			= ARID.dblBuybackAmount
		, strAccountingPeriod	    = AccPeriod.strAccountingPeriod
	FROM tblARInvoiceDetail ARID 
	INNER JOIN tblARInvoice ARI ON ARID.intInvoiceId = ARI.intInvoiceId
	LEFT OUTER JOIN (
		SELECT intCurrencyID
			 , strCurrency
			 , strDescription 
		FROM tblSMCurrency
	) SMC ON ARI.intCurrencyId = SMC.intCurrencyID	
	LEFT JOIN tblICItem ICI ON ARID.intItemId = ICI.intItemId
	LEFT OUTER JOIN (
		SELECT intTransactionId
			 , strTransactionId
			 , intItemId
			 , intItemUOMId
			 , dblCost				= CASE WHEN SUM(dblQty) <> 0 THEN SUM(dblQty * dblCost + dblValue) / SUM(dblQty) ELSE 0 END
		FROM tblICInventoryTransaction 
		WHERE ysnIsUnposted = 0
		  AND intItemUOMId IS NOT NULL
		  AND intTransactionTypeId <> 1
		GROUP BY intTransactionId, strTransactionId, intItemId, intItemUOMId
	) AS NONSO ON ARI.intInvoiceId		= NONSO.intTransactionId
			  AND ARI.strInvoiceNumber	= NONSO.strTransactionId
			  AND ARID.intItemId		= NONSO.intItemId
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
				  AND ((ARID.intSalesOrderDetailId IS NOT NULL AND ARID.intSalesOrderDetailId	= NONLOTTED.intLineNo) OR ARID.intSalesOrderDetailId IS NULL)
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
		INNER JOIN tblICInventoryTransaction ICIT ON ICIT.ysnIsUnposted 				= 0
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
	LEFT OUTER JOIN (
		SELECT intInvoiceId
			 , dblNetTransferCost
			 , strTransactionType
		FROM tblCFTransaction CF
		WHERE ISNULL(CF.intInvoiceId, 0) <> 0
	) AS CFTRAN ON ARI.intInvoiceId = CFTRAN.intInvoiceId 
	           AND ARI.strType = 'CF Tran'
	LEFT OUTER JOIN tblTMSite TMSITE
	ON TMSITE.intSiteID = ARID.intSiteId
	OUTER APPLY(
	    SELECT  strAccountingPeriod =  FORMAT( dtmEndDate, 'MMM yyyy') from tblGLFiscalYearPeriod P
		WHERE ARI.intPeriodId = P.intGLFiscalYearPeriodId
	) AccPeriod
	WHERE ARI.ysnPosted = 1 
		AND ARI.strTransactionType IN ('Invoice', 'Credit Memo', 'Debit Memo', 'Cash', 'Cash Refund', 'Service Charge')
		AND ISNULL(ICI.strType, '') NOT IN ('Software', 'Bundle')
		AND ISNULL(ARID.intStorageScheduleTypeId, 0) = 0

	--start-- workaround for AR-6909 might changed once AR-6843 has been coded
	UNION ALL

	--INVOICE/BUNDLE ITEM TYPE
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
		, dblStandardCost			= (CASE WHEN ISNULL(ARID.intInventoryShipmentItemId, 0) = 0
												THEN CASE WHEN ISNULL(NONSO.dblCost, 0) > 0 THEN ISNULL(NONSO.dblCost, 0) / ARID.dblQtyShipped ELSE ISNULL(NONSO.dblCost, 0) END
											WHEN ISNULL(ICI.strLotTracking, 'No') = 'No' AND ISNULL(ARID.intInventoryShipmentItemId, 0) <> 0 AND ISNULL(ARID.intSalesOrderDetailId, 0) <> 0
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
		, strCurrency				= SMC.strCurrency
		, strCurrencyDescription	= SMC.strDescription
		, intInvoiceDetailId		= ARID.intInvoiceDetailId
		, dblRebateAmount			= ARID.dblRebateAmount
		, dblBuybackAmount			= ARID.dblBuybackAmount
		, strAccountingPeriod	    = AccPeriod.strAccountingPeriod
	FROM tblARInvoiceDetail ARID 
	INNER JOIN tblARInvoice ARI ON ARID.intInvoiceId = ARI.intInvoiceId
	LEFT OUTER JOIN (
		SELECT intCurrencyID
			 , strCurrency
			 , strDescription 
		FROM tblSMCurrency
	) SMC ON ARI.intCurrencyId = SMC.intCurrencyID	
	LEFT JOIN tblICItem ICI ON ARID.intItemId = ICI.intItemId
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
	LEFT OUTER JOIN tblTMSite TMSITE
	ON TMSITE.intSiteID = ARID.intSiteId
	OUTER APPLY(
	    SELECT strAccountingPeriod =  FORMAT( dtmEndDate, 'MMM yyyy') from tblGLFiscalYearPeriod P
		WHERE ARI.intPeriodId = P.intGLFiscalYearPeriodId
	) AccPeriod
	WHERE ARI.ysnPosted = 1 
	  AND ARI.strTransactionType IN ('Invoice', 'Credit Memo', 'Debit Memo', 'Cash', 'Cash Refund', 'Service Charge')
	  AND ISNULL(ARID.intStorageScheduleTypeId, 0) = 0
	  AND ISNULL(ICI.strType, '') = 'Bundle' 
	--end-- workaround for AR-6909 might changed once AR-6843 has been coded

	UNION ALL

	--SALES ORDER/NON-SOFTWARE ITEMS
	SELECT strRecordNumber				= SO.strSalesOrderNumber
	    , strInvoiceOriginId			= NULL
		, intSourceId					= NULL
		, intTransactionId				= SO.intSalesOrderId
		, intEntityCustomerId			= SO.intEntityCustomerId
		, intAccountId					= SO.intAccountId
		, intItemId						= SOD.intItemId
		, intItemUOMId					= SOD.intItemUOMId
		, dtmDate						= SO.dtmDate
		, intCompanyLocationId			= SO.intCompanyLocationId
		, intEntitySalespersonId		= SO.intEntitySalespersonId
		, strTransactionType			= SO.strTransactionType
		, strType						= SO.strType
		, strItemDescription			= SOD.strItemDescription
		, intItemAccountId				=  ISNULL(ISNULL(INV.intSalesAccountId, SOD.intSalesAccountId), SOD.intAccountId)  
		, dblQtyOrdered					= SOD.dblQtyOrdered
		, dblQtyShipped					= SOD.dblQtyShipped
		, dblStandardCost				= (CASE WHEN ISNULL(ICI.strLotTracking, 'No') = 'No' AND ISNULL(INV.intSalesOrderDetailId, 0) <> 0
													THEN dbo.fnCalculateCostBetweenUOM(INV.intOrderUOMId, SOD.intItemUOMId, ISNULL(INV.dblCost, 0))
												WHEN ISNULL(ICI.strLotTracking, 'No') = 'No' AND ISNULL(NONLOTTED.intInventoryShipmentItemId, 0) <> 0
													THEN dbo.fnCalculateCostBetweenUOM(NONLOTTED.intItemUOMId, SOD.intItemUOMId, ISNULL(NONLOTTED.dblCost, 0))
												WHEN ISNULL(ICI.strLotTracking, 'No') <> 'No' AND ISNULL(LOTTED.intInventoryShipmentItemId, 0) <> 0
													THEN dbo.fnCalculateCostBetweenUOM(LOTTED.intItemUOMId, SOD.intItemUOMId, ISNULL(LOTTED.dblCost, 0))
												ELSE 0.000000
											END)
		, dblPrice						= SOD.dblPrice
		, dblTax						= SOD.dblTotalTax
		, dblLineTotal					= SOD.dblTotal
		, dblTotal						= SO.dblSalesOrderTotal
		, strBillToLocationName			= SO.strBillToLocationName
		, strShipToLocationName			= SO.strShipToLocationName
		, intSiteId						= NULL
		, intTicketId					= NULL
		, strShipToCity					= SO.strShipToCity
		, strShipToState				= SO.strShipToState
		, strShipToCountry				= SO.strShipToCountry
		, strShipToZipCode				= SO.strShipToZipCode
		, intCurrencyId					= SO.intCurrencyId
		, strCurrency					= SMC.strCurrency
		, strCurrencyDescription		= SMC.strDescription
		, intInvoiceDetailId			= NULL
		, dblRebateAmount				= 0.000000
		, dblBuybackAmount				= 0.000000
		, strAccountingPeriod		    = NULL
	FROM tblSOSalesOrder SO 
	LEFT OUTER JOIN (
		SELECT intCurrencyID
			 , strCurrency
			 , strDescription 
		FROM tblSMCurrency
	) SMC ON SO.intCurrencyId = SMC.intCurrencyID	
	INNER JOIN tblSOSalesOrderDetail SOD ON SO.intSalesOrderId = SOD.intSalesOrderId
	LEFT JOIN tblICItem ICI ON SOD.intItemId = ICI.intItemId			
	LEFT JOIN tblICItemUOM SU ON SOD.intItemId = SU.intItemId AND SU.ysnStockUnit = 1
	LEFT JOIN (
		tblICItemLocation ICL 
		INNER JOIN tblICItemPricing ICP ON ICL.intItemLocationId = ICP.intItemLocationId
	) ON SO.intCompanyLocationId = ICL.intLocationId 
	 AND SOD.intItemId = ICL.intItemId 
	 AND SOD.intItemId = ICP.intItemId	
	LEFT OUTER JOIN (
		SELECT ID.intSalesOrderDetailId
			 , ID.intItemId
			 , ID.intOrderUOMId
			 , ICIT.dblCost
			 , ID.intAccountId
			 , ID.intSalesAccountId
		FROM tblARInvoiceDetail ID
		INNER JOIN tblARInvoice I ON ID.intInvoiceId = I.intInvoiceId
		INNER JOIN tblICItem ICI ON ID.intItemId = ICI.intItemId
							    AND ISNULL(ICI.strLotTracking, 'No') = 'No'
		INNER JOIN tblICInventoryTransaction ICIT ON ICIT.ysnIsUnposted			= 0
												 AND ISNULL(ICIT.intLotId, 0)	= 0
												 AND I.intInvoiceId				= ICIT.intTransactionId
												 AND I.strInvoiceNumber			= ICIT.strTransactionId
												 AND ID.intInvoiceDetailId		= ICIT.intTransactionDetailId
												 AND ID.intItemId				= ICIT.intItemId
												 AND ICIT.intItemUOMId 			IS NOT NULL
												 AND ICIT.intTransactionTypeId 	<> 1
	) AS INV ON SOD.intSalesOrderDetailId = INV.intSalesOrderDetailId
			AND SOD.intItemId			 = INV.intItemId
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
	) AS NONLOTTED ON SOD.intItemId					= NONLOTTED.intItemId
				  AND SOD.intSalesOrderDetailId		= NONLOTTED.intLineNo
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
												 AND ICIT.intItemUOMId 					IS NOT NULL
												 AND ICIT.intTransactionTypeId 			<> 1
		INNER JOIN tblICLot ICL ON ICIT.intLotId = ICL.intLotId
							   AND ICISI.intItemUOMId = (CASE WHEN ICI.strType = 'Finished Good' OR ICI.ysnAutoBlend = 1 THEN ICISI.intItemUOMId ELSE ICL.intItemUOMId END)
		GROUP BY ICISI.intInventoryShipmentItemId, ICISI.intLineNo, ICISI.intItemId, ICISI.intItemUOMId
	) AS LOTTED ON SOD.intItemId				= LOTTED.intItemId
			   AND SOD.intSalesOrderDetailId	= LOTTED.intLineNo
	WHERE SO.ysnProcessed = 1
	  AND SO.strTransactionType = 'Order'
	  AND ICI.strType <> 'Software'

	UNION ALL

	--INVOICE/SOFTWARE ITEMS/LICENSE MAINTENANCE TYPE
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
		, intItemAccountId			= ARID.intLicenseAccountId 
		, dblQtyOrdered				= ARID.dblQtyOrdered
		, dblQtyShipped				= ARID.dblQtyShipped
		, dblStandardCost			= (CASE WHEN ISNULL(ARID.intInventoryShipmentItemId, 0) = 0
												THEN dbo.fnCalculateCostBetweenUOM(NONSO.intItemUOMId, ARID.intItemUOMId, ISNULL(NONSO.dblCost, 0))
											WHEN ISNULL(ICI.strLotTracking, 'No') = 'No' AND ISNULL(ARID.intInventoryShipmentItemId, 0) <> 0 AND ISNULL(ARID.intSalesOrderDetailId, 0) <> 0
												THEN dbo.fnCalculateCostBetweenUOM(NONLOTTED.intItemUOMId, ARID.intItemUOMId, ISNULL(NONLOTTED.dblCost, 0))
											WHEN ISNULL(ICI.strLotTracking, 'No') <> 'No' AND ISNULL(ARID.intInventoryShipmentItemId, 0) <> 0 AND ISNULL(ARID.intSalesOrderDetailId, 0) <> 0
												THEN dbo.fnCalculateCostBetweenUOM(LOTTED.intItemUOMId, ARID.intItemUOMId, ISNULL(LOTTED.dblCost, 0))
											ELSE 0.000000
										END)
		, dblPrice					= ARID.dblLicenseAmount 
		, dblTax					= ARID.dblTotalTax
		, dblLineTotal				= ARID.dblQtyShipped * ARID.dblLicenseAmount
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
		, strCurrency				= SMC.strCurrency
		, strCurrencyDescription	= SMC.strDescription
		, intInvoiceDetailId		= ARID.intInvoiceDetailId
		, dblRebateAmount			= ARID.dblRebateAmount
		, dblBuybackAmount			= ARID.dblBuybackAmount
		, strAccountingPeriod		= AccPeriod.strAccountingPeriod
	FROM tblARInvoiceDetail ARID 
	INNER JOIN tblARInvoice ARI ON ARID.intInvoiceId = ARI.intInvoiceId
	LEFT OUTER JOIN (
		SELECT intCurrencyID
			 , strCurrency
			 , strDescription 
		FROM tblSMCurrency
	) SMC ON ARI.intCurrencyId = SMC.intCurrencyID	
	LEFT JOIN tblICItem ICI ON ARID.intItemId = ICI.intItemId
	LEFT OUTER JOIN (
		SELECT intTransactionId
			 , strTransactionId
			 , intItemId
			 , intItemUOMId
			 , dblCost			= CASE WHEN SUM(dblQty) <> 0 THEN SUM(dblQty * dblCost + dblValue) / SUM(dblQty) ELSE 0 END
		FROM tblICInventoryTransaction 
		WHERE ysnIsUnposted = 0
		  AND intItemUOMId IS NOT NULL
		  AND intTransactionTypeId <> 1
		GROUP BY intTransactionId, strTransactionId, intItemId, intItemUOMId
	) AS NONSO ON ARI.intInvoiceId		= NONSO.intTransactionId
			  AND ARI.strInvoiceNumber	= NONSO.strTransactionId
			  AND ARID.intItemId		= NONSO.intItemId
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
												AND ICIS.intInventoryShipmentId			= ICIT.intTransactionId
												AND ICIS.strShipmentNumber				= ICIT.strTransactionId
												AND ICISI.intInventoryShipmentItemId	= ICIT.intTransactionDetailId
												AND ICISI.intItemId						= ICIT.intItemId												
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
		INNER JOIN tblICInventoryTransaction ICIT
			ON ICIT.ysnIsUnposted					= 0
			AND ISNULL(ICIT.intLotId, 0)			<> 0
			AND ICIS.intInventoryShipmentId			= ICIT.intTransactionId
			AND ICIS.strShipmentNumber				= ICIT.strTransactionId
			AND ICISI.intInventoryShipmentItemId	= ICIT.intTransactionDetailId
			AND ICISI.intItemId						= ICIT.intItemId		
			AND ISNULL(ICI.strLotTracking, 'No')	<> 'No'
			AND ICIT.intItemUOMId 					IS NOT NULL
			AND ICIT.intTransactionTypeId 			<> 1
		INNER JOIN tblICLot ICL ON ICIT.intLotId = ICL.intLotId
							   AND ICISI.intItemUOMId = (CASE WHEN ICI.strType = 'Finished Good' OR ICI.ysnAutoBlend = 1 THEN ICISI.intItemUOMId ELSE ICL.intItemUOMId END)
		GROUP BY ICISI.intInventoryShipmentItemId, ICISI.intLineNo, ICISI.intItemId, ICISI.intItemUOMId
	) AS LOTTED ON ARID.intInventoryShipmentItemId	= LOTTED.intInventoryShipmentItemId
			   AND ARID.intItemId					= LOTTED.intItemId
			   AND ARID.intSalesOrderDetailId		= LOTTED.intLineNo
	LEFT OUTER JOIN tblTMSite TMSITE
	ON TMSITE.intSiteID = ARID.intSiteId
	OUTER APPLY(
	    SELECT strAccountingPeriod =  FORMAT( dtmEndDate, 'MMM yyyy') from tblGLFiscalYearPeriod P
		WHERE ARI.intPeriodId = P.intGLFiscalYearPeriodId
	) AccPeriod
	WHERE ARI.ysnPosted = 1 
	  AND ARI.strTransactionType IN ('Invoice', 'Credit Memo', 'Debit Memo', 'Cash', 'Cash Refund')
	  AND ICI.strType = 'Software'
	  AND ARID.strMaintenanceType IN ('License/Maintenance', 'License Only')
	  AND ISNULL(ARID.intStorageScheduleTypeId, 0) = 0

	UNION ALL

	--SALES ORDER/SOFTWARE ITEMS/LICENSE MAINTENANCE TYPE
	SELECT strRecordNumber				= SO.strSalesOrderNumber
	    , strInvoiceOriginId			= NULL
		, intSourceId					= NULL
		, intTransactionId				= SO.intSalesOrderId
		, intEntityCustomerId			= SO.intEntityCustomerId
		, intAccountId					= SO.intAccountId
		, intItemId						= SOD.intItemId
		, intItemUOMId					= SOD.intItemUOMId
		, dtmDate						= SO.dtmDate
		, intCompanyLocationId			= SO.intCompanyLocationId
		, intEntitySalespersonId		= SO.intEntitySalespersonId
		, strTransactionType			= SO.strTransactionType
		, strType						= SO.strType
		, strItemDescription			= SOD.strItemDescription
		, intItemAccountId				= ISNULL(INV.intLicenseAccountId, SOD.intLicenseAccountId)
		, dblQtyOrdered					= SOD.dblQtyOrdered
		, dblQtyShipped					= SOD.dblQtyShipped
		, dblStandardCost				= (CASE WHEN ISNULL(ICI.strLotTracking, 'No') = 'No' AND ISNULL(INV.intSalesOrderDetailId, 0) <> 0
													THEN dbo.fnCalculateCostBetweenUOM(INV.intOrderUOMId, SOD.intItemUOMId, ISNULL(INV.dblCost, 0))
												WHEN ISNULL(ICI.strLotTracking, 'No') = 'No' AND ISNULL(NONLOTTED.intInventoryShipmentItemId, 0) <> 0
													THEN dbo.fnCalculateCostBetweenUOM(NONLOTTED.intItemUOMId, SOD.intItemUOMId, ISNULL(NONLOTTED.dblCost, 0))
												WHEN ISNULL(ICI.strLotTracking, 'No') <> 'No' AND ISNULL(LOTTED.intInventoryShipmentItemId, 0) <> 0
													THEN dbo.fnCalculateCostBetweenUOM(LOTTED.intItemUOMId, SOD.intItemUOMId, ISNULL(LOTTED.dblCost, 0))
												ELSE 0.000000
											END)
		, dblPrice						= SOD.dblLicenseAmount
		, dblTax						= SOD.dblTotalTax
		, dblLineTotal					= SOD.dblQtyOrdered * SOD.dblLicenseAmount
		, dblTotal						= SO.dblSalesOrderTotal
		, strBillToLocationName			= SO.strBillToLocationName
		, strShipToLocationName			= SO.strShipToLocationName
		, intSiteId						= NULL
		, intTicketId					= NULL
		, strShipToCity					= SO.strShipToCity
		, strShipToState				= SO.strShipToState
		, strShipToCountry				= SO.strShipToCountry
		, strShipToZipCode				= SO.strShipToZipCode
		, intCurrencyId					= SO.intCurrencyId
		, strCurrency					= SMC.strCurrency
		, strCurrencyDescription		= SMC.strDescription
		, intInvoiceDetailId			= NULL
		, dblRebateAmount				= 0.000000
		, dblBuybackAmount				= 0.
		, strAccountingPeriod		    = NULL
	FROM tblSOSalesOrder SO
	LEFT OUTER JOIN (
		SELECT intCurrencyID
			 , strCurrency
			 , strDescription 
		FROM tblSMCurrency
	) SMC ON SO.intCurrencyId = SMC.intCurrencyID	
	INNER JOIN tblSOSalesOrderDetail SOD ON SO.intSalesOrderId = SOD.intSalesOrderId
	LEFT JOIN tblICItem ICI ON SOD.intItemId = ICI.intItemId			
	LEFT JOIN tblICItemUOM SU ON SOD.intItemId = SU.intItemId AND SU.ysnStockUnit = 1
	LEFT JOIN (
		tblICItemLocation ICL 
		INNER JOIN tblICItemPricing ICP ON ICL.intItemLocationId = ICP.intItemLocationId
	) ON SO.intCompanyLocationId = ICL.intLocationId 
	 AND SOD.intItemId = ICL.intItemId 
	 AND SOD.intItemId = ICP.intItemId	
	LEFT OUTER JOIN (
		SELECT ID.intSalesOrderDetailId
			 , ID.intItemId
			 , ID.intOrderUOMId
			 , ICIT.dblCost
			 , ID.intLicenseAccountId
		FROM tblARInvoiceDetail ID
		INNER JOIN tblARInvoice I ON ID.intInvoiceId = I.intInvoiceId
		INNER JOIN tblICItem ICI ON ID.intItemId = ICI.intItemId
								AND ISNULL(ICI.strLotTracking, 'No') = 'No'
		INNER JOIN tblICInventoryTransaction ICIT ON ICIT.ysnIsUnposted			= 0
												 AND ISNULL(ICIT.intLotId, 0)	= 0
												 AND I.intInvoiceId				= ICIT.intTransactionId
												 AND I.strInvoiceNumber			= ICIT.strTransactionId
												 AND ID.intInvoiceDetailId		= ICIT.intTransactionDetailId
												 AND ID.intItemId				= ICIT.intItemId
												 AND ICIT.intItemUOMId 			IS NOT NULL
												 AND ICIT.intTransactionTypeId 	<> 1
	) AS INV ON SOD.intSalesOrderDetailId = INV.intSalesOrderDetailId
			AND SOD.intItemId			 = INV.intItemId
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
	) AS NONLOTTED ON SOD.intItemId					= NONLOTTED.intItemId
				  AND SOD.intSalesOrderDetailId		= NONLOTTED.intLineNo
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
												 AND ICIT.intItemUOMId 					IS NOT NULL
												 AND ICIT.intTransactionTypeId 			<> 1
		INNER JOIN tblICLot ICL ON ICIT.intLotId = ICL.intLotId
							   AND ICISI.intItemUOMId = (CASE WHEN ICI.strType = 'Finished Good' OR ICI.ysnAutoBlend = 1 THEN ICISI.intItemUOMId ELSE ICL.intItemUOMId END)
		GROUP BY ICISI.intInventoryShipmentItemId, ICISI.intLineNo, ICISI.intItemId, ICISI.intItemUOMId
	) AS LOTTED ON SOD.intItemId				= LOTTED.intItemId
				AND SOD.intSalesOrderDetailId	= LOTTED.intLineNo
	WHERE SO.ysnProcessed = 1
	  AND SO.strTransactionType = 'Order'
	  AND ICI.strType = 'Software'
	  AND SOD.strMaintenanceType IN ('License/Maintenance', 'License Only')

	UNION ALL

	--INVOICE/SOFTWARE ITEMS/MAINTENANCE TYPE
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
		, intItemAccountId			= ARID.intMaintenanceAccountId
		, dblQtyOrdered				= ARID.dblQtyOrdered
		, dblQtyShipped				= ARID.dblQtyShipped
		, dblStandardCost			= (CASE WHEN ISNULL(ARID.intInventoryShipmentItemId, 0) = 0
												THEN dbo.fnCalculateCostBetweenUOM(NONSO.intItemUOMId, ARID.intItemUOMId, ISNULL(NONSO.dblCost, 0))
											WHEN ISNULL(ICI.strLotTracking, 'No') = 'No' AND ISNULL(ARID.intInventoryShipmentItemId, 0) <> 0 AND ISNULL(ARID.intSalesOrderDetailId, 0) <> 0
												THEN dbo.fnCalculateCostBetweenUOM(NONLOTTED.intItemUOMId, ARID.intItemUOMId, ISNULL(NONLOTTED.dblCost, 0))
											WHEN ISNULL(ICI.strLotTracking, 'No') <> 'No' AND ISNULL(ARID.intInventoryShipmentItemId, 0) <> 0 AND ISNULL(ARID.intSalesOrderDetailId, 0) <> 0
												THEN dbo.fnCalculateCostBetweenUOM(LOTTED.intItemUOMId, ARID.intItemUOMId, ISNULL(LOTTED.dblCost, 0))
											ELSE 0.000000
										END)
		, dblPrice					= ARID.dblMaintenanceAmount  
		, dblTax					= ARID.dblTotalTax
		, dblLineTotal				= ARID.dblQtyShipped * ARID.dblMaintenanceAmount
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
		, strCurrency				= SMC.strCurrency
		, strCurrencyDescription	= SMC.strDescription
		, intInvoiceDetailId		= ARID.intInvoiceDetailId
		, dblRebateAmount			= ARID.dblRebateAmount
		, dblBuybackAmount			= ARID.dblBuybackAmount
		, strAccountingPeriod		= AccPeriod.strAccountingPeriod
	FROM tblARInvoiceDetail ARID 
	INNER JOIN tblARInvoice ARI ON ARID.intInvoiceId = ARI.intInvoiceId
	LEFT OUTER JOIN (
		SELECT intCurrencyID
			 , strCurrency
			 , strDescription 
		FROM tblSMCurrency
	) SMC ON ARI.intCurrencyId = SMC.intCurrencyID	
	LEFT JOIN tblICItem ICI ON ARID.intItemId = ICI.intItemId
	LEFT OUTER JOIN (
		SELECT intTransactionId
			 , strTransactionId
			 , intItemId
			 , intItemUOMId
			 , dblCost				= CASE WHEN SUM(dblQty) <> 0 THEN SUM(dblQty * dblCost + dblValue) / SUM(dblQty) ELSE 0 END
		FROM tblICInventoryTransaction 
		WHERE ysnIsUnposted = 0
		  AND intItemUOMId IS NOT NULL
		  AND intTransactionTypeId <> 1 
		GROUP BY intTransactionId, strTransactionId, intItemId, intItemUOMId
	) AS NONSO ON ARI.intInvoiceId		= NONSO.intTransactionId
			  AND ARI.strInvoiceNumber	= NONSO.strTransactionId
			  AND ARID.intItemId		= NONSO.intItemId
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
												AND ICIS.intInventoryShipmentId			= ICIT.intTransactionId
												AND ICIS.strShipmentNumber				= ICIT.strTransactionId
												AND ICISI.intInventoryShipmentItemId	= ICIT.intTransactionDetailId
												AND ICISI.intItemId						= ICIT.intItemId
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
							   AND ICISI.intItemUOMId = (CASE WHEN ICI.strType = 'Finished Good' OR ICI.ysnAutoBlend = 1 THEN ICISI.intItemUOMId ELSE ICL.intItemUOMId END)
		GROUP BY ICISI.intInventoryShipmentItemId, ICISI.intLineNo, ICISI.intItemId, ICISI.intItemUOMId
	) AS LOTTED ON ARID.intInventoryShipmentItemId	= LOTTED.intInventoryShipmentItemId
			   AND ARID.intItemId					= LOTTED.intItemId
			   AND ARID.intSalesOrderDetailId		= LOTTED.intLineNo
	LEFT OUTER JOIN tblTMSite TMSITE
	ON TMSITE.intSiteID = ARID.intSiteId
	OUTER APPLY(
	    SELECT strAccountingPeriod =  FORMAT( dtmEndDate, 'MMM yyyy') from tblGLFiscalYearPeriod P
		WHERE ARI.intPeriodId = P.intGLFiscalYearPeriodId
	) AccPeriod
	WHERE ARI.ysnPosted = 1 
	  AND ARI.strTransactionType IN ('Invoice', 'Credit Memo', 'Debit Memo', 'Cash', 'Cash Refund')
	  AND ICI.strType = 'Software'
	  AND ARID.strMaintenanceType IN ('License/Maintenance', 'Maintenance Only', 'SaaS')
	  AND ISNULL(ARID.intStorageScheduleTypeId, 0) = 0

	UNION ALL

	--SALES ORDER/SOFTWARE ITEMS/MAINTENANCE TYPE
	SELECT strRecordNumber				= SO.strSalesOrderNumber
	    , strInvoiceOriginId			= NULL
		, intSourceId					= NULL
		, intTransactionId				= SO.intSalesOrderId
		, intEntityCustomerId			= SO.intEntityCustomerId
		, intAccountId					= SO.intAccountId
		, intItemId						= SOD.intItemId
		, intItemUOMId					= SOD.intItemUOMId
		, dtmDate						= SO.dtmDate
		, intCompanyLocationId			= SO.intCompanyLocationId
		, intEntitySalespersonId		= SO.intEntitySalespersonId
		, strTransactionType			= SO.strTransactionType
		, strType						= SO.strType
		, strItemDescription			= SOD.strItemDescription
		, intItemAccountId				= ISNULL(INV.intMaintenanceAccountId, SOD.intMaintenanceAccountId)
		, dblQtyOrdered					= SOD.dblQtyOrdered
		, dblQtyShipped					= SOD.dblQtyShipped
		, dblStandardCost				= (CASE WHEN ISNULL(ICI.strLotTracking, 'No') = 'No' AND ISNULL(INV.intSalesOrderDetailId, 0) <> 0
													THEN dbo.fnCalculateCostBetweenUOM(INV.intOrderUOMId, SOD.intItemUOMId, ISNULL(INV.dblCost, 0))
												WHEN ISNULL(ICI.strLotTracking, 'No') = 'No' AND ISNULL(NONLOTTED.intInventoryShipmentItemId, 0) <> 0
													THEN dbo.fnCalculateCostBetweenUOM(NONLOTTED.intItemUOMId, SOD.intItemUOMId, ISNULL(NONLOTTED.dblCost, 0))
												WHEN ISNULL(ICI.strLotTracking, 'No') <> 'No' AND ISNULL(LOTTED.intInventoryShipmentItemId, 0) <> 0
													THEN dbo.fnCalculateCostBetweenUOM(LOTTED.intItemUOMId, SOD.intItemUOMId, ISNULL(LOTTED.dblCost, 0))
												ELSE 0.000000
											END)
		, dblPrice						= SOD.dblMaintenanceAmount
		, dblTax						= SOD.dblTotalTax
		, dblLineTotal					= SOD.dblQtyOrdered * SOD.dblMaintenanceAmount
		, dblTotal						= SO.dblSalesOrderTotal
		, strBillToLocationName			= SO.strBillToLocationName
		, strShipToLocationName			= SO.strShipToLocationName
		, intSiteId						= NULL
		, intTicketId					= NULL
		, strShipToCity					= SO.strShipToCity
		, strShipToState				= SO.strShipToState
		, strShipToCountry				= SO.strShipToCountry
		, strShipToZipCode				= SO.strShipToZipCode
		, intCurrencyId					= SO.intCurrencyId
		, strCurrency					= SMC.strCurrency
		, strCurrencyDescription		= SMC.strDescription
		, intInvoiceDetailId			= NULL
		, dblRebateAmount				= 0.000000
		, dblBuybackAmount				= 0.000000
		, strAccountingPeriod			= NULL
	FROM tblSOSalesOrder SO 
	LEFT OUTER JOIN (
		SELECT intCurrencyID
			 , strCurrency 
			 , strDescription 
		FROM tblSMCurrency
	) SMC ON SO.intCurrencyId = SMC.intCurrencyID	
	INNER JOIN tblSOSalesOrderDetail SOD ON SO.intSalesOrderId = SOD.intSalesOrderId
	LEFT JOIN tblICItem ICI ON SOD.intItemId = ICI.intItemId			
	LEFT JOIN tblICItemUOM SU ON SOD.intItemId = SU.intItemId AND SU.ysnStockUnit = 1
	LEFT JOIN (
		tblICItemLocation ICL 
		INNER JOIN tblICItemPricing ICP ON ICL.intItemLocationId = ICP.intItemLocationId
	) ON SO.intCompanyLocationId = ICL.intLocationId 
	 AND SOD.intItemId = ICL.intItemId 
	 AND SOD.intItemId = ICP.intItemId
	LEFT OUTER JOIN (
		SELECT ID.intSalesOrderDetailId
			 , ID.intItemId
			 , ID.intOrderUOMId
			 , ICIT.dblCost
			 , ID.intMaintenanceAccountId
		FROM tblARInvoiceDetail ID
		INNER JOIN tblARInvoice I ON ID.intInvoiceId = I.intInvoiceId
		INNER JOIN tblICItem ICI ON ID.intItemId = ICI.intItemId
								AND ISNULL(ICI.strLotTracking, 'No') = 'No'
		INNER JOIN tblICInventoryTransaction ICIT ON ICIT.ysnIsUnposted			= 0
												 AND ISNULL(ICIT.intLotId, 0)	= 0
												 AND I.intInvoiceId				= ICIT.intTransactionId
												 AND I.strInvoiceNumber			= ICIT.strTransactionId
												 AND ID.intInvoiceDetailId		= ICIT.intTransactionDetailId
												 AND ID.intItemId				= ICIT.intItemId
												 AND ICIT.intItemUOMId 			IS NOT NULL
												 AND ICIT.intTransactionTypeId 	<> 1
	) AS INV ON SOD.intSalesOrderDetailId = INV.intSalesOrderDetailId
			AND SOD.intItemId			 = INV.intItemId
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
	) AS NONLOTTED ON SOD.intItemId					= NONLOTTED.intItemId
				  AND SOD.intSalesOrderDetailId		= NONLOTTED.intLineNo
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
												 AND ICIT.intItemUOMId 					IS NOT NULL
												 AND ICIT.intTransactionTypeId 			<> 1
		INNER JOIN tblICLot ICL ON ICIT.intLotId = ICL.intLotId
							   AND ICISI.intItemUOMId = (CASE WHEN ICI.strType = 'Finished Good' OR ICI.ysnAutoBlend = 1 THEN ICISI.intItemUOMId ELSE ICL.intItemUOMId END)
		GROUP BY ICISI.intInventoryShipmentItemId, ICISI.intLineNo, ICISI.intItemId, ICISI.intItemUOMId
	) AS LOTTED ON SOD.intItemId				= LOTTED.intItemId
			   AND SOD.intSalesOrderDetailId	= LOTTED.intLineNo
	WHERE SO.ysnProcessed = 1
	  AND SO.strTransactionType = 'Order'
	  AND ICI.strType = 'Software'
	  AND SOD.strMaintenanceType IN ('License/Maintenance', 'Maintenance Only', 'SaaS')

	UNION ALL 

	--INVOICE/SOFTWARE ITEMS/NO MAINTENANCE TYPE
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
		, intItemAccountId			=  ISNULL(ARID.intSalesAccountId , ARID.intAccountId)   
		, dblQtyOrdered				= ARID.dblQtyOrdered
		, dblQtyShipped				= ARID.dblQtyShipped
		, dblStandardCost			= (CASE WHEN ISNULL(ARID.intInventoryShipmentItemId, 0) = 0												
												THEN dbo.fnCalculateCostBetweenUOM(NONSO.intItemUOMId, ARID.intItemUOMId, ISNULL(NONSO.dblCost, 0))
											WHEN ISNULL(ICI.strLotTracking, 'No') = 'No' AND ISNULL(ARID.intInventoryShipmentItemId, 0) <> 0 AND ISNULL(ARID.intSalesOrderDetailId, 0) <> 0
												THEN dbo.fnCalculateCostBetweenUOM(NONLOTTED.intItemUOMId, ARID.intItemUOMId, ISNULL(NONLOTTED.dblCost, 0))
											WHEN ISNULL(ICI.strLotTracking, 'No') <> 'No' AND ISNULL(ARID.intInventoryShipmentItemId, 0) <> 0 AND ISNULL(ARID.intSalesOrderDetailId, 0) <> 0
												THEN dbo.fnCalculateCostBetweenUOM(LOTTED.intItemUOMId, ARID.intItemUOMId, ISNULL(LOTTED.dblCost, 0))
											ELSE dbo.fnCalculateCostBetweenUOM(NONSO.intItemUOMId, ARID.intItemUOMId, ISNULL(NONSO.dblCost, 0))
										END)
		, dblPrice					= ARID.dblPrice
		, dblTax					= ARID.dblTotalTax
		, dblLineTotal				= ARID.dblTotal
		, dblTotal					= ARI.dblInvoiceTotal			
		, strBillToLocationName		= ARI.strBillToLocationName
		, strShipToLocationName		= CASE WHEN ARI.strType = 'Tank Delivery' AND TMSITE.intSiteID IS NOT NULL 
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
		, strCurrency				= SMC.strCurrency
		, strCurrencyDescription	= SMC.strDescription
		, intInvoiceDetailId		= ARID.intInvoiceDetailId
		, dblRebateAmount			= ARID.dblRebateAmount
		, dblBuybackAmount			= ARID.dblBuybackAmount
		, strAccountingPeriod		= AccPeriod.strAccountingPeriod
	FROM tblARInvoiceDetail ARID 
	INNER JOIN tblARInvoice ARI ON ARID.intInvoiceId = ARI.intInvoiceId
	LEFT OUTER JOIN (
		SELECT intCurrencyID
			 , strCurrency
			 , strDescription 
		FROM tblSMCurrency
	) SMC ON ARI.intCurrencyId = SMC.intCurrencyID	
	LEFT JOIN tblICItem ICI ON ARID.intItemId = ICI.intItemId
	LEFT OUTER JOIN (
		SELECT intTransactionId
			 , strTransactionId
			 , intItemId
			 , intItemUOMId
			 , dblCost				= CASE WHEN SUM(dblQty) <> 0 THEN SUM(dblQty * dblCost + dblValue) / SUM(dblQty) ELSE 0 END
		FROM tblICInventoryTransaction 
		WHERE ysnIsUnposted = 0
		  AND intItemUOMId IS NOT NULL
		  AND intTransactionTypeId <> 1
		GROUP BY intTransactionId, strTransactionId, intItemId, intItemUOMId
	) AS NONSO ON ARI.intInvoiceId		= NONSO.intTransactionId
			  AND ARI.strInvoiceNumber	= NONSO.strTransactionId
			  AND ARID.intItemId		= NONSO.intItemId			  
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
							   AND ICISI.intItemUOMId = (CASE WHEN ICI.strType = 'Finished Good' OR ICI.ysnAutoBlend = 1 THEN ICISI.intItemUOMId ELSE ICL.intItemUOMId END)
		GROUP BY ICISI.intInventoryShipmentItemId, ICISI.intLineNo, ICISI.intItemId, ICISI.intItemUOMId
	) AS LOTTED ON ARID.intInventoryShipmentItemId	= LOTTED.intInventoryShipmentItemId
			   AND ARID.intItemId					= LOTTED.intItemId			   
			   AND ARID.intSalesOrderDetailId		= LOTTED.intLineNo
	LEFT OUTER JOIN tblTMSite TMSITE
	ON TMSITE.intSiteID = ARID.intSiteId
	OUTER APPLY(
	    SELECT strAccountingPeriod =  FORMAT( dtmEndDate, 'MMM yyyy') from tblGLFiscalYearPeriod P
		WHERE ARI.intPeriodId = P.intGLFiscalYearPeriodId
	) AccPeriod
	WHERE ARI.ysnPosted = 1 
	  AND ARI.strTransactionType IN ('Invoice', 'Credit Memo', 'Debit Memo', 'Cash', 'Cash Refund', 'Service Charge')
	  AND ISNULL(ICI.strType, '') = 'Software'
	  AND ISNULL(ARID.strMaintenanceType  ,'') =''
	  AND ISNULL(ARID.intStorageScheduleTypeId, 0) = 0
) AS SAR
LEFT JOIN tblGLAccount GA ON SAR.intItemAccountId = GA.intAccountId
INNER JOIN tblSMCompanyLocation L ON SAR.intCompanyLocationId = L.intCompanyLocationId
INNER JOIN (
	tblARCustomer C 
	INNER JOIN tblEMEntity E ON C.[intEntityId] = E.intEntityId
) ON SAR.intEntityCustomerId = C.[intEntityId]
LEFT JOIN (
	tblARSalesperson SP 
	INNER JOIN tblEMEntity ESP ON SP.[intEntityId] = ESP.intEntityId
) ON SAR.intEntitySalespersonId = SP.[intEntityId]	
LEFT JOIN (
	tblICItem IC 
	LEFT JOIN tblICManufacturer ICM ON IC.intManufacturerId = ICM.intManufacturerId
	LEFT JOIN tblICCommodity ICC ON IC.intCommodityId = ICC.intCommodityId
	LEFT JOIN tblICCategory CAT ON IC.intCategoryId = CAT.intCategoryId		
	LEFT JOIN tblICBrand ICB ON IC.intBrandId = ICB.intBrandId
) ON SAR.intItemId = IC.intItemId
LEFT JOIN vyuARItemUOM UOM ON SAR.intItemUOMId = UOM.intItemUOMId		
LEFT JOIN tblTMSite TMS ON SAR.intSiteId = TMS.intSiteID
LEFT JOIN tblSCTicket SCT ON SAR.intTicketId = SCT.intTicketId
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
	  WHERE CAS.intEntityCustomerId = SAR.intEntityCustomerId
	  FOR XML PATH ('')
	 ) SC (strAccountStatusCode)
) STATUSCODES
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
	, E.strName
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
	, SAR.strCurrency
	, SAR.strCurrencyDescription
	, SAR.intInvoiceDetailId
	, STATUSCODES.strAccountStatusCode
	, SAR.strAccountingPeriod
