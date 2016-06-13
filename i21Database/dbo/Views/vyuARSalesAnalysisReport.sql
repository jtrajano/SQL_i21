CREATE VIEW [dbo].[vyuARSalesAnalysisReport]
AS

SELECT 
	 strRecordNumber			= SAR.strRecordNumber
	,intTransactionId			= SAR.intTransactionId
	,intAccountId				= SAR.intAccountId
	,dtmDate					= DATEADD(dd, DATEDIFF(dd, 0, dtmDate), 0)
	,intCompanyLocationId		= SAR.intCompanyLocationId
	,intEntityCustomerId		= SAR.intEntityCustomerId
	,intItemId					= IC.intItemId
	,intManufacturerId			= IC.intManufacturerId
	,intBrandId					= IC.intBrandId
	,intCommodityId				= IC.intCommodityId
	,intCategoryId				= IC.intCategoryId
	,intEntitySalespersonId		= SAR.intEntitySalespersonId
	,strTransactionType			= SAR.strTransactionType
	,strType					= SAR.strType
	,dblQtyOrdered				= ISNULL(SAR.dblQtyOrdered, 0)
	,dblQtyShipped				= ISNULL(SAR.dblQtyShipped, 0)
	,dblCost					= ISNULL(SAR.dblStandardCost, 0)
	,dblMargin					= (ISNULL(SAR.dblPrice, 0) - ISNULL(SAR.dblStandardCost, 0)) * 
									CASE WHEN SAR.strTransactionType IN ('Invoice', 'Credit Memo') 
										THEN ISNULL(SAR.dblQtyShipped, 0) 
										ELSE ISNULL(SAR.dblQtyOrdered, 0)
									END
	,dblMarginPercentage		= CASE WHEN (ISNULL(SAR.dblPrice, 0) - ISNULL(SAR.dblStandardCost, 0)) * 
											CASE WHEN SAR.strTransactionType IN ('Invoice', 'Credit Memo') 
												THEN ISNULL(SAR.dblQtyShipped, 0) 
												ELSE ISNULL(SAR.dblQtyOrdered, 0)
											END > 0 
									THEN ((ISNULL(SAR.dblPrice, 0) - ISNULL(SAR.dblStandardCost, 0)) * 
											CASE WHEN SAR.strTransactionType IN ('Invoice', 'Credit Memo') 
												THEN ISNULL(SAR.dblQtyShipped, 0) 
												ELSE ISNULL(SAR.dblQtyOrdered, 0)
											END / ISNULL(SAR.dblLineTotal, 0)) * 100 
									ELSE 0 
								  END
	,dblPrice					= ISNULL(SAR.dblPrice, 0)
	,dblTax						= ISNULL(SAR.dblTax, 0)
	,dblLineTotal				= ISNULL(SAR.dblLineTotal, 0)
	,dblTotal					= ISNULL(SAR.dblTotal, 0)
	,strCustomerNumber			= C.strCustomerNumber
	,strAccountId				= GA.strAccountId
	,strAccountName				= GA.strDescription
	,strLocationName			= L.strLocationName
	,strItemName				= IC.strItemNo
	,strItemDesc				= IC.strDescription
	,strLineDesc				= SAR.strItemDescription
	,strUOM						= UOM.strUnitMeasure
	,strManufacturer			= ICM.strManufacturer
	,strBrandName				= ICB.strBrandName
	,strCommodityName			= ICC.strCommodityCode
	,strCategoryName			= CAT.strCategoryCode
	,strCustomerName			= E.strName
	,strSalespersonName			= ESP.strName
	,strBillTo					= RTRIM(SAR.strBillToLocationName)
	,strShipTo					= RTRIM(SAR.strShipToLocationName)
	,strSiteNumber				= REPLACE(STR(TMS.intSiteNumber, 4), SPACE(1), '0')
	,strSiteDescription			= TMS.strDescription
FROM
	(
		SELECT 
			 strRecordNumber				= ARI.strInvoiceNumber
			,intTransactionId				= ARI.intInvoiceId
			,intEntityCustomerId			= ARI.intEntityCustomerId
			,intAccountId					= ARI.intAccountId
			,intItemId						= ARID.intItemId
			,intItemUOMId					= ARID.intItemUOMId
			,dtmDate						= ARI.dtmDate
			,intCompanyLocationId			= ARI.intCompanyLocationId
			,intEntitySalespersonId			= ARI.intEntitySalespersonId
			,strTransactionType				= ARI.strTransactionType
			,strType						= ARI.strType
			,strItemDescription				= ARID.strItemDescription
			,intItemAccountId				= (CASE WHEN dbo.fnIsStockTrackingItem(ARID.intItemId) = 1 OR ARGIA.strType = 'Bundle'
														THEN ARGIA.intSalesAccountId 
													  WHEN ARGIA.strType = 'Other Charge'
														THEN ARGIA.intOtherChargeIncomeAccountId
													ELSE ARGIA.intGeneralAccountId 
												 END)
			,dblQtyOrdered					= ARID.dblQtyOrdered
			,dblQtyShipped					= ARID.dblQtyShipped
			,dblStandardCost				= (CASE WHEN ISNULL(ICIC.intTransactionDetailId,0) <> 0 THEN ICIC.dblCost
													--WHEN ISNULL(SOIC.intTransactionDetailId,0) <> 0 THEN SOIC.dblCost
													WHEN (ISNULL(ARID.intInventoryShipmentItemId,0) = 0 AND ISNULL(ARID.intSalesOrderDetailId,0) = 0 )
														AND EXISTS
														(
															SELECT TOP 1 dblCost FROM tblICInventoryTransaction WHERE ISNULL(ysnIsUnposted,0) = 0
															AND intTransactionId = ARI.intInvoiceId
															AND strTransactionId = ARI.strInvoiceNumber
															AND intItemId		 = ARID.intItemId
															AND intItemUOMId	 = ARID.intItemUOMId
														)
														THEN
														(
															SELECT TOP 1 dblCost FROM tblICInventoryTransaction WHERE ISNULL(ysnIsUnposted,0) = 0
															AND intTransactionId = ARI.intInvoiceId
															AND strTransactionId = ARI.strInvoiceNumber
															AND intItemId		 = ARID.intItemId
															AND intItemUOMId	 = ARID.intItemUOMId
														)
													WHEN (ISNULL(ARID.intInventoryShipmentItemId,0) <> 0 AND ISNULL(ARID.intSalesOrderDetailId,0) <> 0 AND ISNULL(ICIC.dblCost,0) = 0)
														AND NOT EXISTS
														(
															SELECT TOP 1 dblCost FROM tblICInventoryTransaction WHERE ISNULL(ysnIsUnposted,0) = 0
															AND intTransactionId = ARI.intInvoiceId
															AND strTransactionId = ARI.strInvoiceNumber
															AND intItemId		 = ARID.intItemId
															AND intItemUOMId	 = ARID.intItemUOMId
														)
														THEN
														(
															SELECT TOP 1
																 dbo.fnCalculateQtyBetweenUOM(ICISI.intItemUOMId, ICIT.intItemUOMId, ICIT.dblCost) dblCost
															FROM 
																tblICInventoryShipmentItem ICISI
															INNER JOIN
																tblICInventoryShipment ICIS
																	ON ICISI.intInventoryShipmentId = ICIS.intInventoryShipmentId
															INNER JOIN
																tblICInventoryTransaction ICIT
																	ON  ISNULL(ICIT.ysnIsUnposted,0) = 0
																	AND ICIS.intInventoryShipmentId = ICIT.intTransactionId 
																	AND ICIS.strShipmentNumber = ICIT.strTransactionId 
																	AND ICISI.intItemId = ICIT.intItemId
																	AND ICISI.intInventoryShipmentItemId = ICIT.intTransactionDetailId 
																	AND ICISI.intItemUOMId <> ICIT.intItemUOMId
															WHERE ARID.intInventoryShipmentItemId = ICISI.intInventoryShipmentItemId 
																	AND ARID.intItemId = ICISI.intItemId 
														)
													WHEN (ISNULL(ARID.intInventoryShipmentItemId,0) = 0 AND ISNULL(ARID.intSalesOrderDetailId,0) <> 0 AND ISNULL(ICIC.dblCost,0) = 0)
														AND EXISTS
														(
															SELECT
																 NULL 
															FROM
																tblSOSalesOrderDetail SOSOD
															INNER JOIN 
																tblICInventoryShipmentItem ICISI
																	ON SOSOD.intSalesOrderDetailId = ICISI.intLineNo 
															INNER JOIN
																tblICInventoryShipment ICIS
																	ON ICISI.intInventoryShipmentId = ICIS.intInventoryShipmentId
																	AND ICIS.intOrderType = 2
															INNER JOIN
																tblICInventoryTransaction ICIT
																	ON  ISNULL(ICIT.ysnIsUnposted,0) = 0
																	AND ICIS.intInventoryShipmentId = ICIT.intTransactionId 
																	AND ICIS.strShipmentNumber = ICIT.strTransactionId 
																	AND ICISI.intItemId = ICIT.intItemId 
																	AND ICISI.intItemUOMId = ICIT.intItemUOMId
																	AND ICIT.intTransactionDetailId = ICISI.intInventoryShipmentItemId 
															WHERE
																ARID.intSalesOrderDetailId = SOSOD.intSalesOrderDetailId 
																AND ARID.intItemId = ICISI.intItemId
																AND ARID.intItemUOMId = ICISI.intItemUOMId
														)
														THEN
														(
															SELECT TOP 1
																 ICIT.dblCost 
															FROM
																tblSOSalesOrderDetail SOSOD
															INNER JOIN 
																tblICInventoryShipmentItem ICISI
																	ON SOSOD.intSalesOrderDetailId = ICISI.intLineNo 
															INNER JOIN
																tblICInventoryShipment ICIS
																	ON ICISI.intInventoryShipmentId = ICIS.intInventoryShipmentId
																	AND ICIS.intOrderType = 2
															INNER JOIN
																tblICInventoryTransaction ICIT
																	ON  ISNULL(ICIT.ysnIsUnposted,0) = 0
																	AND ICIS.intInventoryShipmentId = ICIT.intTransactionId 
																	AND ICIS.strShipmentNumber = ICIT.strTransactionId 
																	AND ICISI.intItemId = ICIT.intItemId 
																	AND ICISI.intItemUOMId = ICIT.intItemUOMId
																	AND ICIT.intTransactionDetailId = ICISI.intInventoryShipmentItemId 
															WHERE
																ARID.intSalesOrderDetailId = SOSOD.intSalesOrderDetailId 
																AND ARID.intItemId = SOSOD.intItemId
																AND ARID.intItemUOMId = SOSOD.intItemUOMId														
														)
													WHEN (ISNULL(ARID.intInventoryShipmentItemId,0) = 0 AND ISNULL(ARID.intSalesOrderDetailId,0) <> 0 AND ISNULL(ICIC.dblCost,0) = 0)
														AND NOT EXISTS
														(
															SELECT
																 NULL 
															FROM
																tblSOSalesOrderDetail SOSOD
															INNER JOIN 
																tblICInventoryShipmentItem ICISI
																	ON SOSOD.intSalesOrderDetailId = ICISI.intLineNo 
															INNER JOIN
																tblICInventoryShipment ICIS
																	ON ICISI.intInventoryShipmentId = ICIS.intInventoryShipmentId
																	AND ICIS.intOrderType = 2
															INNER JOIN
																tblICInventoryTransaction ICIT
																	ON  ISNULL(ICIT.ysnIsUnposted,0) = 0
																	AND ICIS.intInventoryShipmentId = ICIT.intTransactionId 
																	AND ICIS.strShipmentNumber = ICIT.strTransactionId 
																	AND ICISI.intItemId = ICIT.intItemId 
																	AND ICISI.intItemUOMId = ICIT.intItemUOMId
																	AND ICIT.intTransactionDetailId = ICISI.intInventoryShipmentItemId 
															WHERE
																ARID.intSalesOrderDetailId = SOSOD.intSalesOrderDetailId 
																AND ARID.intItemId = ICISI.intItemId
																AND ARID.intItemUOMId = ICISI.intItemUOMId
														)
														THEN
														(
															SELECT TOP 1
																 dbo.fnCalculateQtyBetweenUOM(ICISI.intItemUOMId, ICIT.intItemUOMId, ICIT.dblCost) dblCost
															FROM 
																tblSOSalesOrderDetail SOSOD
															INNER JOIN 
																tblICInventoryShipmentItem ICISI
																	ON SOSOD.intSalesOrderDetailId = ICISI.intLineNo 
															INNER JOIN
																tblICInventoryShipment ICIS
																	ON ICISI.intInventoryShipmentId = ICIS.intInventoryShipmentId
																	AND ICIS.intOrderType = 2
															INNER JOIN
																tblICInventoryTransaction ICIT
																	ON  ISNULL(ICIT.ysnIsUnposted,0) = 0
																	AND ICIS.intInventoryShipmentId = ICIT.intTransactionId 
																	AND ICIS.strShipmentNumber = ICIT.strTransactionId 
																	AND ICISI.intItemId = ICIT.intItemId 
																	AND ICISI.intItemUOMId <> ICIT.intItemUOMId
																	AND ICIT.intTransactionDetailId = ICISI.intInventoryShipmentItemId 
															WHERE
																SOSOD.intSalesOrderDetailId = ARID.intSalesOrderDetailId  
																AND ARID.intItemId = ICISI.intItemId																
														)
												END)
			,dblPrice						= ARID.dblPrice
			,dblTax							= ARID.dblTotalTax
			,dblLineTotal					= ARID.dblTotal
			,dblTotal						= ARI.dblInvoiceTotal
			,strBillToLocationName			= ARI.strBillToLocationName
			,strShipToLocationName			= ARI.strShipToLocationName
			,intSiteId						= ARID.intSiteId	
		FROM
			tblARInvoiceDetail ARID 
		INNER JOIN
			tblARInvoice ARI 
				ON ARID.intInvoiceId = ARI.intInvoiceId
		LEFT JOIN 
			vyuARGetItemAccount ARGIA 
				ON ARID.intItemId = ARGIA.intItemId AND ARI.intCompanyLocationId = ARGIA.intLocationId
		LEFT OUTER JOIN
			(
				SELECT
					 ICIT.dblCost
					,ICIT.intTransactionDetailId
					,ICISI.intItemId
					,ICISI.intItemUOMId
				FROM 
					tblICInventoryShipmentItem ICISI
				INNER JOIN
					tblICInventoryShipment ICIS
						ON ICISI.intInventoryShipmentId = ICIS.intInventoryShipmentId
				INNER JOIN
					tblICInventoryTransaction ICIT
						ON  ISNULL(ICIT.ysnIsUnposted,0) = 0
						AND ICIS.intInventoryShipmentId = ICIT.intTransactionId 
						AND ICIS.strShipmentNumber = ICIT.strTransactionId 
						AND ICISI.intItemId = ICIT.intItemId 
						AND ICISI.intItemUOMId = ICIT.intItemUOMId
						AND ICIT.intTransactionDetailId = ICISI.intInventoryShipmentItemId 
			) ICIC
				ON  ARID.intInventoryShipmentItemId = ICIC.intTransactionDetailId 
				AND ARID.intItemId = ICIC.intItemId 
				AND ARID.intItemUOMId = ICIC.intItemUOMId
		WHERE ARI.ysnPosted = 1 
		  AND ARI.strTransactionType IN ('Invoice', 'Credit Memo')							

	UNION ALL

	SELECT 
		strRecordNumber				= SO.strSalesOrderNumber
		,intTransactionId			= SO.intSalesOrderId
		,intEntityCustomerId		= SO.intEntityCustomerId
		,intAccountId				= SO.intAccountId
		,intItemId					= SOD.intItemId
		,intItemUOMId				= SOD.intItemUOMId
		,dtmDate					= SO.dtmDate
		,intCompanyLocationId		= SO.intCompanyLocationId
		,intEntitySalespersonId		= SO.intEntitySalespersonId
		,strTransactionType			= SO.strTransactionType
		,strType					= SO.strType
		,strItemDescription			= SOD.strItemDescription
		,intItemAccountId			= (CASE WHEN dbo.fnIsStockTrackingItem(SOD.intItemId) = 1  OR IA.strType = 'Bundle'
											THEN IA.intSalesAccountId 
										WHEN IA.strType = 'Other Charge'
											THEN IA.intOtherChargeIncomeAccountId
										ELSE IA.intGeneralAccountId 
									 END)
		,dblQtyOrdered				= SOD.dblQtyOrdered
		,dblQtyShipped				= SOD.dblQtyShipped
		,dblStandardCost			= (CASE WHEN ISNULL(LOTTEDITEMS.intLineNo, 0) <> 0 
												THEN LOTTEDITEMS.dblCost
											WHEN ISNULL(NONLOTTEDITEMS.intLineNo, 0) <> 0 
												THEN NONLOTTEDITEMS.dblCost
											ELSE
												ICP.dblStandardCost
										END)
		,dblPrice					= dblPrice
		,dblTax						= SOD.dblTotalTax
		,dblLineTotal				= SOD.dblTotal
		,dblTotal					= SO.dblSalesOrderTotal
		,strBillToLocationName		= SO.strBillToLocationName
		,strShipToLocationName		= SO.strShipToLocationName
		,intSiteId					= NULL
	FROM
		tblSOSalesOrder SO 
	INNER JOIN 
		tblSOSalesOrderDetail SOD 
			ON SO.intSalesOrderId = SOD.intSalesOrderId
	LEFT JOIN 
		tblICItemUOM SU 
			ON SOD.intItemId = SU.intItemId AND SU.ysnStockUnit = 1
	LEFT JOIN 
		(
			tblICItemLocation ICL 
			INNER JOIN 
				tblICItemPricing ICP 
			ON ICL.intItemLocationId = ICP.intItemLocationId
		) ON SO.intCompanyLocationId = ICL.intLocationId AND SOD.intItemId = ICL.intItemId AND SOD.intItemId = ICP.intItemId	
	LEFT JOIN
		(
			SELECT ICISI.intLineNo
				 , ICISI.intOrderId
				 , dblCost = dbo.fnCalculateQtyBetweenUOM(ICISI.intItemUOMId, ISNULL(ICL.intWeightUOMId, ICIT.intItemUOMId), AVG(dblCost))
			FROM
				tblICInventoryShipmentItem ICISI
			INNER JOIN 
				tblICInventoryShipment ICIS
					ON ICISI.intInventoryShipmentId = ICIS.intInventoryShipmentId
			INNER JOIN
				tblICInventoryTransaction ICIT
					ON ICISI.intInventoryShipmentId			= ICIT.intTransactionId
					AND ICISI.intInventoryShipmentItemId	= ICIT.intTransactionDetailId
					AND ICISI.intItemId						= ICIT.intItemId 
					AND ICIS.strShipmentNumber				= ICIT.strTransactionId
					AND ICIT.ysnIsUnposted					= 0
			INNER JOIN
				tblICLot ICL
					ON ICIT.intLotId = ICL.intLotId
					AND ICISI.intItemUOMId = ICL.intItemUOMId		
			GROUP BY ICISI.intLineNo, ICISI.intOrderId, ICISI.intItemUOMId, ICIT.intItemUOMId, ICL.intWeightUOMId
		) AS LOTTEDITEMS ON LOTTEDITEMS.intLineNo = SOD.intSalesOrderDetailId AND SOD.intSalesOrderId = LOTTEDITEMS.intOrderId
	LEFT JOIN
		(
			SELECT ICISI.intLineNo
				 , ICISI.intOrderId
				 , dblCost = dbo.fnCalculateQtyBetweenUOM(ICISI.intItemUOMId, ICIT.intItemUOMId, AVG(dblCost))
			FROM
				tblICInventoryShipmentItem ICISI
			INNER JOIN 
				tblICInventoryShipment ICIS
					ON ICISI.intInventoryShipmentId = ICIS.intInventoryShipmentId
			INNER JOIN
				tblICInventoryTransaction ICIT
					ON ICISI.intInventoryShipmentId			= ICIT.intTransactionId
					AND ICISI.intInventoryShipmentItemId	= ICIT.intTransactionDetailId
					AND ICISI.intItemId						= ICIT.intItemId
					AND ICISI.intItemUOMId					= ICIT.intItemUOMId
					AND ICIS.strShipmentNumber				= ICIT.strTransactionId					
					AND ICIT.ysnIsUnposted					= 0	
			GROUP BY ICISI.intLineNo, ICISI.intOrderId, ICISI.intItemUOMId, ICIT.intItemUOMId
		) AS NONLOTTEDITEMS ON NONLOTTEDITEMS.intLineNo = SOD.intSalesOrderDetailId AND SOD.intSalesOrderId = NONLOTTEDITEMS.intOrderId
	LEFT JOIN 
		vyuARGetItemAccount IA 
			ON SOD.intItemId = IA.intItemId AND SO.intCompanyLocationId = IA.intLocationId
	WHERE 
		SO.ysnProcessed = 1
	) AS SAR
LEFT JOIN 
	tblGLAccount GA 
		ON SAR.intItemAccountId = GA.intAccountId
INNER JOIN
	tblSMCompanyLocation L 
		ON SAR.intCompanyLocationId = L.intCompanyLocationId
INNER JOIN 
	(
	tblARCustomer C 
	INNER JOIN 
		tblEntity E 
			ON C.intEntityCustomerId = E.intEntityId
	) ON SAR.intEntityCustomerId = C.intEntityCustomerId
LEFT JOIN 
	(
	tblARSalesperson SP 
	INNER JOIN
		tblEntity ESP 
			ON SP.intEntitySalespersonId = ESP.intEntityId
	) ON SAR.intEntitySalespersonId = SP.intEntitySalespersonId	
LEFT JOIN 
	(
	tblICItem IC 
	LEFT JOIN 
		tblICManufacturer ICM 
			ON IC.intManufacturerId = ICM.intManufacturerId
	LEFT JOIN 
		tblICCommodity ICC 
			ON IC.intCommodityId = ICC.intCommodityId
	LEFT JOIN 
		tblICCategory CAT 
			ON IC.intCategoryId = CAT.intCategoryId		
	LEFT JOIN 
		tblICBrand ICB 
			ON IC.intBrandId = ICB.intBrandId
	) ON SAR.intItemId = IC.intItemId
LEFT JOIN
	vyuARItemUOM UOM 
		ON SAR.intItemUOMId = UOM.intItemUOMId		
LEFT JOIN 
	tblTMSite TMS ON SAR.intSiteId = TMS.intSiteID