CREATE VIEW [dbo].[vyuTMSalesAnalysisReport]
AS
SELECT
	 intTransactionId = ROW_NUMBER() OVER (ORDER BY intTransactionId)
	 ,A.intSiteId
	 ,IC.intCategoryId
	 ,A.intEntityCustomerId
	 ,A.dtmDate
	 ,A.dblQtyShipped
	 ,A.intItemId
	 ,dblMargin = (ISNULL(A.dblPrice, 0) - ISNULL(A.dblStandardCost, 0)) * 
					CASE WHEN A.strTransactionType IN ('Invoice', 'Credit Memo') 
						THEN ISNULL(A.dblQtyShipped, 0) 
						ELSE ISNULL(A.dblQtyOrdered, 0)
					END
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
		INNER JOIN tblEMEntity ESP ON SP.intEntitySalespersonId = ESP.intEntityId) ON A.intEntitySalespersonId = SP.intEntitySalespersonId	
	LEFT JOIN (tblICItem IC 
		LEFT JOIN tblICManufacturer ICM ON IC.intManufacturerId = ICM.intManufacturerId
		LEFT JOIN tblICCommodity ICC ON IC.intCommodityId = ICC.intCommodityId
		LEFT JOIN tblICCategory CAT ON IC.intCategoryId = CAT.intCategoryId		
		LEFT JOIN tblICBrand ICB ON IC.intBrandId = ICB.intBrandId) ON A.intItemId = IC.intItemId
	LEFT JOIN vyuARItemUOM UOM ON A.intItemUOMId = UOM.intItemUOMId		
	LEFT JOIN tblTMSite TMS ON A.intSiteId = TMS.intSiteID



	