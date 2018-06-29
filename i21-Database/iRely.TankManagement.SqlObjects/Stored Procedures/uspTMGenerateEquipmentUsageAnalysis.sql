
CREATE PROCEDURE uspTMGenerateEquipmentUsageAnalysis 
@dtmFromDate DATETIME
,@dtmToDate DATETIME
AS
BEGIN
--SET @dtmFromDate = '1/1/1900'
--SET @dtmToDate = '1/1/2016'


-------Start Sales Analysis Report
SELECT 
	 DATEADD(dd, DATEDIFF(dd, 0, dtmDate), 0) AS dtmDate
	 , A.intEntityCustomerId	 
	 , IC.intItemId
	 , IC.intCategoryId
	 , A.strType
	 , ISNULL(A.dblQtyShipped, 0)     AS dblQtyShipped
	 , dblMargin = (ISNULL(A.dblPrice, 0) - ISNULL(A.dblStandardCost, 0)) * 
						CASE WHEN A.strTransactionType IN ('Invoice', 'Credit Memo') 
							THEN ISNULL(A.dblQtyShipped, 0) 
							ELSE ISNULL(A.dblQtyOrdered, 0)
						END
	, TMS.intSiteID
INTO #tmpSalesAnalysisTable
FROM
(SELECT I.strInvoiceNumber			  AS strRecordNumber
	  , I.intInvoiceId				  AS intTransactionId
	  , I.intEntityCustomerId
	  , I.intAccountId
	  , ID.intItemId
	  , ID.intItemUOMId
	  , I.dtmDate
	  , I.intCompanyLocationId	 
	  , I.intEntitySalespersonId	 
	  , I.strTransactionType
	  , I.strType
	  , ID.strItemDescription
	  , intItemAccountId			  = (CASE WHEN dbo.fnIsStockTrackingItem(ID.intItemId) = 1 OR IA.strType = 'Bundle'
												THEN IA.intSalesAccountId 
											  WHEN IA.strType = 'Other Charge'
												THEN IA.intOtherChargeIncomeAccountId
											ELSE IA.intGeneralAccountId 
										 END)
	  , ID.dblQtyOrdered
	  , ID.dblQtyShipped
	  , dblStandardCost				  = (CASE WHEN ISNULL(ID.intInventoryShipmentItemId,0) = 0 
											THEN (SELECT TOP 1 dblCost FROM tblICInventoryTransaction WHERE ISNULL(ysnIsUnposted,0) = 0
												AND intTransactionId = I.intInvoiceId
												AND strTransactionId = I.strInvoiceNumber
												AND intItemId		 = ID.intItemId
												AND intItemUOMId	 = ID.intItemUOMId) 
											ELSE ICIT1.dblCost 
										END)
	  , dblPrice
	  , ID.dblTotalTax				  AS dblTax
	  , ID.dblTotal					  AS dblLineTotal
	  , I.dblInvoiceTotal			  AS dblTotal
	  , I.strBillToLocationName
	  , I.strShipToLocationName
	  , intSiteId
FROM tblARInvoice I INNER JOIN tblARInvoiceDetail ID ON I.intInvoiceId = ID.intInvoiceId
LEFT JOIN vyuARGetItemAccount IA ON ID.intItemId = IA.intItemId AND I.intCompanyLocationId = IA.intLocationId
LEFT OUTER JOIN
	(
		SELECT
			 ICIT.dblCost
			,ICISI.intInventoryShipmentItemId
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
	) ICIT1
		ON  ID.intInventoryShipmentItemId = ICIT1.intInventoryShipmentItemId 
		AND ID.intItemId = ICIT1.intItemId 
		AND ID.intItemUOMId = ICIT1.intItemUOMId
WHERE I.ysnPosted = 1 
  AND I.strTransactionType IN ('Invoice', 'Credit Memo')

UNION ALL

SELECT SO.strSalesOrderNumber		  AS strRecordNumber
	 , SO.intSalesOrderId			  AS intTransactionId
	 , SO.intEntityCustomerId
	 , SO.intAccountId
	 , SOD.intItemId
	 , SOD.intItemUOMId
	 , SO.dtmDate
	 , SO.intCompanyLocationId
	 , SO.intEntitySalespersonId	 
	 , SO.strTransactionType
	 , SO.strType
	 , SOD.strItemDescription
	 , intItemAccountId				= (CASE WHEN dbo.fnIsStockTrackingItem(SOD.intItemId) = 1  OR IA.strType = 'Bundle'
												THEN IA.intSalesAccountId 
											WHEN IA.strType = 'Other Charge'
												THEN IA.intOtherChargeIncomeAccountId
											ELSE IA.intGeneralAccountId 
									   END)
	 , SOD.dblQtyOrdered
	 , SOD.dblQtyShipped
	 , ICP.dblStandardCost			  AS dblStandardCost				  
	 , dblPrice
	 , SOD.dblTotalTax				  AS dblTax
	 , SOD.dblTotal					  AS dblLineTotal
	 , SO.dblSalesOrderTotal		  AS dblTotal 
	 , SO.strBillToLocationName
	 , SO.strShipToLocationName
	 , NULL							  AS intSiteId
FROM tblSOSalesOrder SO INNER JOIN tblSOSalesOrderDetail SOD ON SO.intSalesOrderId = SOD.intSalesOrderId
LEFT JOIN tblICItemUOM SU ON SOD.intItemId = SU.intItemId AND SU.ysnStockUnit = 1
LEFT JOIN (tblICItemLocation ICL 
		INNER JOIN tblICItemPricing ICP ON ICL.intItemLocationId = ICP.intItemLocationId) ON SO.intCompanyLocationId = ICL.intLocationId AND SOD.intItemId = ICL.intItemId AND SOD.intItemId = ICP.intItemId	
LEFT JOIN vyuARGetItemAccount IA ON SOD.intItemId = IA.intItemId AND SO.intCompanyLocationId = IA.intLocationId
WHERE SO.ysnProcessed = 1) AS A
	LEFT JOIN tblGLAccount GA ON A.intItemAccountId = GA.intAccountId
	INNER JOIN tblSMCompanyLocation L ON A.intCompanyLocationId = L.intCompanyLocationId
	INNER JOIN (tblARCustomer C 
		INNER JOIN tblEMEntity E ON C.[intEntityId] = E.intEntityId) ON A.intEntityCustomerId = C.[intEntityId]
	LEFT JOIN (tblARSalesperson SP 
		INNER JOIN tblEMEntity ESP ON SP.[intEntityId] = ESP.intEntityId) ON A.intEntitySalespersonId = SP.[intEntityId]	
	LEFT JOIN (tblICItem IC 
		LEFT JOIN tblICManufacturer ICM ON IC.intManufacturerId = ICM.intManufacturerId
		LEFT JOIN tblICCommodity ICC ON IC.intCommodityId = ICC.intCommodityId
		LEFT JOIN tblICCategory CAT ON IC.intCategoryId = CAT.intCategoryId		
		LEFT JOIN tblICBrand ICB ON IC.intBrandId = ICB.intBrandId) ON A.intItemId = IC.intItemId
	LEFT JOIN vyuARItemUOM UOM ON A.intItemUOMId = UOM.intItemUOMId		
	LEFT JOIN tblTMSite TMS ON A.intSiteId = TMS.intSiteID	

------END Sales Analysis Report

AND IC.intItemId IS NOT NULL
	AND DATEADD(dd, DATEDIFF(dd, 0, dtmDate), 0) >= DATEADD(dd, DATEDIFF(dd, 0, @dtmFromDate), 0) AND DATEADD(dd, DATEDIFF(dd, 0, dtmDate), 0) <= DATEADD(dd, DATEDIFF(dd, 0, @dtmToDate), 0)



SELECT
	strCustomerNumber = G.strName
	,intSiteNumber = E.intSiteNumber
	,strItemNumber = H.strItemNo
	,strSiteDescription = E.strDescription
	,strLeaseNumber = A.strLeaseNumber
	,dblLeaseAmount = B.dblAmount
	,strDeviceSerialNumber = C.strSerialNumber
	,strDeviceDescription = C.strDescription
	,dblSalesQuantity = CASE WHEN ISNULL(A.strEvaluationMethod,'Site Product') = 'Site Product' THEN 
									(SELECT SUM(Z.dblQtyShipped) 
									 FROM #tmpSalesAnalysisTable Z
									 WHERE Z.intItemId = E.intProduct
										AND Z.intEntityCustomerId = G.intEntityId
										AND Z.intSiteID = E.intSiteID)
							 WHEN ISNULL(A.strEvaluationMethod,'Site Product') = 'Site Product/Category' THEN 
									(SELECT SUM(Z.dblQtyShipped) 
									 FROM #tmpSalesAnalysisTable Z
									 WHERE Z.intCategoryId = (SELECT TOP 1 intCategoryId 
															FROM tblICItem 
															WHERE intItemId = E.intSiteID)
										AND intEntityCustomerId = G.intEntityId)
							 WHEN ISNULL(A.strEvaluationMethod,'Site Product') = 'All Products' THEN 
									(SELECT SUM(Z.dblQtyShipped) 
									 FROM #tmpSalesAnalysisTable Z
									 WHERE Z.intEntityCustomerId = G.intEntityId)
							 ELSE
								0
						END
	,dblProfitMargin = CASE WHEN ISNULL(A.strEvaluationMethod,'Site Product') = 'Site Product' THEN 
									(SELECT SUM(Z.dblMargin) 
									 FROM #tmpSalesAnalysisTable Z
									 WHERE Z.intItemId = E.intProduct
										AND Z.intEntityCustomerId = G.intEntityId
										AND Z.intSiteID = E.intSiteID)
							 WHEN ISNULL(A.strEvaluationMethod,'Site Product') = 'Site Product/Category' THEN 
									(SELECT SUM(Z.dblMargin) 
									 FROM #tmpSalesAnalysisTable Z
									 WHERE Z.intCategoryId = (SELECT TOP 1 intCategoryId 
															FROM tblICItem 
															WHERE intItemId = E.intSiteID)
										AND intEntityCustomerId = G.intEntityId)
							 WHEN ISNULL(A.strEvaluationMethod,'Site Product') = 'All Products' THEN 
									(SELECT SUM(Z.dblMargin) 
									 FROM #tmpSalesAnalysisTable Z
									 WHERE Z.intEntityCustomerId = G.intEntityId)
							 ELSE
								0
						END
	,intSiteId = E.intSiteID
	,intTMCustomerId = E.intCustomerID
	,intEntityId = G.intEntityId
	,intLeaseId = A.intLeaseId
FROM tblTMLease A
INNER JOIN tblTMLeaseCode B
	ON A.intLeaseCodeId = B.intLeaseCodeId
LEFT JOIN tblTMLeaseDevice CC
	ON A.intLeaseId = CC.intLeaseId
LEFT JOIN tblTMDevice C
	ON CC.intDeviceId = C.intDeviceId
LEFT JOIN tblTMSiteDevice D
	ON C.intDeviceId = D.intDeviceId
LEFT JOIN tblTMSite E
	ON D.intSiteID = E.intSiteID
LEFT JOIN tblTMCustomer F
	ON E.intCustomerID = F.intCustomerID
LEFT JOIN tblEMEntity G
	ON F.intCustomerNumber = G.intEntityId
LEFT JOIN tblICItem H
	ON E.intProduct = H.intItemId
END


