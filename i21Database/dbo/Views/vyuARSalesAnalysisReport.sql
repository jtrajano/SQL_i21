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
													WHEN ARID.intItemId IS NULL
														THEN ARGIA.intGeneralAccountId
													ELSE
														ARID.intSalesAccountId
												 END)
			,dblQtyOrdered					= ARID.dblQtyOrdered
			,dblQtyShipped					= ARID.dblQtyShipped
			,dblStandardCost				= (CASE WHEN ISNULL(ARID.intInventoryShipmentItemId, 0) = 0
														THEN ISNULL(NONSO.dblCost, 0)
													WHEN ISNULL(ICI.strLotTracking, 'No') = 'No' AND ISNULL(ARID.intInventoryShipmentItemId, 0) <> 0 AND ISNULL(ARID.intSalesOrderDetailId, 0) <> 0
														THEN NONLOTTED.dblCost
													WHEN ISNULL(ICI.strLotTracking, 'No') <> 'No' AND ISNULL(ARID.intInventoryShipmentItemId, 0) <> 0 AND ISNULL(ARID.intSalesOrderDetailId, 0) <> 0
														THEN LOTTED.dblCost
													ELSE
														0.000000
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
			tblICItem ICI
				ON ARID.intItemId = ICI.intItemId
		LEFT JOIN 
			vyuARGetItemAccount ARGIA 
				ON ARID.intItemId = ARGIA.intItemId AND ARI.intCompanyLocationId = ARGIA.intLocationId
		LEFT OUTER JOIN (
			SELECT intTransactionId
				 , strTransactionId
				 , intItemId
				 , intItemUOMId
				 , dblCost				= AVG(dblCost)
			FROM
				tblICInventoryTransaction 
			WHERE ysnIsUnposted = 0
			GROUP BY intTransactionId, strTransactionId, intItemId, intItemUOMId) AS NONSO
				ON ARI.intInvoiceId			= NONSO.intTransactionId
				AND ARI.strInvoiceNumber	= NONSO.strTransactionId
				AND ARID.intItemId			= NONSO.intItemId
				AND ARID.intItemUOMId		= NONSO.intItemUOMId
		LEFT OUTER JOIN (
			SELECT ICISI.intInventoryShipmentItemId
				 , ICISI.intLineNo
				 , ICISI.intItemId
				 , ICISI.intItemUOMId
				 , ICIT.dblCost		 
			FROM
				tblICInventoryShipmentItem ICISI	
			INNER JOIN tblICInventoryShipment ICIS
				ON ICISI.intInventoryShipmentId = ICIS.intInventoryShipmentId
			INNER JOIN tblICItem ICI
				ON ICISI.intItemId = ICI.intItemId
				AND ISNULL(ICI.strLotTracking, 'No') = 'No'
			INNER JOIN tblICInventoryTransaction ICIT
				ON ICIT.ysnIsUnposted							= 0
				AND ISNULL(ICIT.intLotId, 0)					= 0
				AND ICIS.intInventoryShipmentId					= ICIT.intTransactionId
				AND ICIS.strShipmentNumber						= ICIT.strTransactionId
				AND ICISI.intInventoryShipmentItemId			= ICIT.intTransactionDetailId
				AND ICISI.intItemId								= ICIT.intItemId
				AND ICISI.intItemUOMId							= ICIT.intItemUOMId) AS NONLOTTED
					ON ARID.intInventoryShipmentItemId	= NONLOTTED.intInventoryShipmentItemId
					AND ARID.intItemId					= NONLOTTED.intItemId
					AND ARID.intItemUOMId				= NONLOTTED.intItemUOMId
					AND ARID.intSalesOrderDetailId		= NONLOTTED.intLineNo
		LEFT OUTER JOIN (
			SELECT ICISI.intInventoryShipmentItemId
				 , ICISI.intLineNo
				 , ICISI.intItemId
				 , ICISI.intItemUOMId
				 , dblCost = dbo.fnCalculateQtyBetweenUOM(ICISI.intItemUOMId, MAX(ICIT.intItemUOMId), AVG(ICIT.dblCost))
			FROM
				tblICInventoryShipmentItem ICISI
			INNER JOIN tblICInventoryShipment ICIS
				ON ICISI.intInventoryShipmentId = ICIS.intInventoryShipmentId
			INNER JOIN tblICItem ICI
				ON ICISI.intItemId = ICI.intItemId
				AND ISNULL(ICI.strLotTracking, 'No') <> 'No'
			INNER JOIN tblICInventoryTransaction ICIT
				ON ICIT.ysnIsUnposted							= 0
				AND ISNULL(ICIT.intLotId, 0)					<> 0
				AND ICIS.intInventoryShipmentId					= ICIT.intTransactionId
				AND ICIS.strShipmentNumber						= ICIT.strTransactionId
				AND ICISI.intInventoryShipmentItemId			= ICIT.intTransactionDetailId
				AND ICISI.intItemId								= ICIT.intItemId		
				AND ISNULL(ICI.strLotTracking, 'No')			<> 'No'
			INNER JOIN tblICLot ICL
				ON ICIT.intLotId = ICL.intLotId
				AND ICISI.intItemUOMId = (CASE WHEN ICI.strType = 'Finished Good' THEN ICISI.intItemUOMId ELSE ICL.intItemUOMId END)
			GROUP BY ICISI.intInventoryShipmentItemId, ICISI.intLineNo, ICISI.intItemId, ICISI.intItemUOMId) AS LOTTED
					ON ARID.intInventoryShipmentItemId	= LOTTED.intInventoryShipmentItemId
					AND ARID.intItemId					= LOTTED.intItemId
					AND ARID.intItemUOMId				= LOTTED.intItemUOMId
					AND ARID.intSalesOrderDetailId		= LOTTED.intLineNo
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
										WHEN SOD.intItemId IS NULL
											THEN IA.intGeneralAccountId
										ELSE
											SOD.intSalesAccountId
									 END)
		,dblQtyOrdered				= SOD.dblQtyOrdered
		,dblQtyShipped				= SOD.dblQtyShipped
		,dblStandardCost			= (CASE WHEN ISNULL(ICI.strLotTracking, 'No') = 'No' AND ISNULL(INV.intSalesOrderDetailId, 0) <> 0
												THEN INV.dblCost
											WHEN ISNULL(ICI.strLotTracking, 'No') = 'No' AND ISNULL(NONLOTTED.intInventoryShipmentItemId, 0) <> 0
												THEN NONLOTTED.dblCost
											WHEN ISNULL(ICI.strLotTracking, 'No') <> 'No' AND ISNULL(LOTTED.intInventoryShipmentItemId, 0) <> 0
												THEN LOTTED.dblCost
											ELSE
												0.000000
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
		tblICItem ICI
			ON SOD.intItemId = ICI.intItemId
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
	LEFT OUTER JOIN (
		SELECT ID.intSalesOrderDetailId
			 , ID.intItemId
			 , ID.intOrderUOMId
			 , ICIT.dblCost
		FROM 
			tblARInvoiceDetail ID
		INNER JOIN tblARInvoice I
			ON ID.intInvoiceId = I.intInvoiceId
		INNER JOIN tblICItem ICI
			ON ID.intItemId = ICI.intItemId
			AND ISNULL(ICI.strLotTracking, 'No') = 'No'
		INNER JOIN tblICInventoryTransaction ICIT
			ON ICIT.ysnIsUnposted			= 0
			AND ISNULL(ICIT.intLotId, 0)	= 0
			AND I.intInvoiceId				= ICIT.intTransactionId
			AND I.strInvoiceNumber			= ICIT.strTransactionId
			AND ID.intInvoiceDetailId		= ICIT.intTransactionDetailId
			AND ID.intItemId				= ICIT.intItemId
			AND ID.intItemUOMId				= ICIT.intItemUOMId) AS INV
				ON SOD.intSalesOrderDetailId = INV.intSalesOrderDetailId
				AND SOD.intItemId			 = INV.intItemId
				AND SOD.intItemUOMId		 = INV.intOrderUOMId
	LEFT OUTER JOIN (
		SELECT ICISI.intInventoryShipmentItemId
			 , ICISI.intLineNo
			 , ICISI.intItemId
			 , ICISI.intItemUOMId
			 , ICIT.dblCost		 
		FROM
			tblICInventoryShipmentItem ICISI	
		INNER JOIN tblICInventoryShipment ICIS
			ON ICISI.intInventoryShipmentId = ICIS.intInventoryShipmentId
		INNER JOIN tblICItem ICI
			ON ICISI.intItemId = ICI.intItemId
			AND ISNULL(ICI.strLotTracking, 'No') = 'No'
		INNER JOIN tblICInventoryTransaction ICIT
			ON ICIT.ysnIsUnposted							= 0
			AND ISNULL(ICIT.intLotId, 0)					= 0
			AND ICIS.intInventoryShipmentId					= ICIT.intTransactionId
			AND ICIS.strShipmentNumber						= ICIT.strTransactionId
			AND ICISI.intInventoryShipmentItemId			= ICIT.intTransactionDetailId
			AND ICISI.intItemId								= ICIT.intItemId
			AND ICISI.intItemUOMId							= ICIT.intItemUOMId) AS NONLOTTED
				ON SOD.intItemId					= NONLOTTED.intItemId
				AND SOD.intItemUOMId				= NONLOTTED.intItemUOMId
				AND SOD.intSalesOrderDetailId		= NONLOTTED.intLineNo
	LEFT OUTER JOIN (
		SELECT ICISI.intInventoryShipmentItemId
			 , ICISI.intLineNo
			 , ICISI.intItemId
			 , ICISI.intItemUOMId
			 , dblCost = dbo.fnCalculateQtyBetweenUOM(ICISI.intItemUOMId, MAX(ICIT.intItemUOMId), AVG(ICIT.dblCost))
		FROM
			tblICInventoryShipmentItem ICISI
		INNER JOIN tblICInventoryShipment ICIS
			ON ICISI.intInventoryShipmentId = ICIS.intInventoryShipmentId
		INNER JOIN tblICItem ICI
			ON ICISI.intItemId = ICI.intItemId
			AND ISNULL(ICI.strLotTracking, 'No') <> 'No'
		INNER JOIN tblICInventoryTransaction ICIT
			ON ICIT.ysnIsUnposted							= 0
			AND ISNULL(ICIT.intLotId, 0)					<> 0
			AND ICIS.intInventoryShipmentId					= ICIT.intTransactionId
			AND ICIS.strShipmentNumber						= ICIT.strTransactionId
			AND ICISI.intInventoryShipmentItemId			= ICIT.intTransactionDetailId
			AND ICISI.intItemId								= ICIT.intItemId
		INNER JOIN tblICLot ICL
			ON ICIT.intLotId = ICL.intLotId
			AND ICISI.intItemUOMId = (CASE WHEN ICI.strType = 'Finished Good' THEN ICISI.intItemUOMId ELSE ICL.intItemUOMId END)
		GROUP BY ICISI.intInventoryShipmentItemId, ICISI.intLineNo, ICISI.intItemId, ICISI.intItemUOMId) AS LOTTED
				ON SOD.intItemId					= LOTTED.intItemId
				AND SOD.intItemUOMId				= LOTTED.intItemUOMId
				AND SOD.intSalesOrderDetailId		= LOTTED.intLineNo
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