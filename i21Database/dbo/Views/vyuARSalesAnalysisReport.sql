CREATE VIEW [dbo].[vyuARSalesAnalysisReport]
AS
SELECT strRecordNumber
	 , intTransactionId
	 , A.intAccountId	 
	 , dtmDate
	 , A.intCompanyLocationId
	 , A.intEntityCustomerId	 
	 , IC.intItemId
	 , IC.intManufacturerId
	 , IC.intBrandId
	 , IC.intCommodityId
	 , IC.intCategoryId
	 , A.intEntitySalespersonId	 
	 , A.strTransactionType
	 , A.strType
	 , ISNULL(A.dblQtyOrdered, 0)	  AS dblQtyOrdered
	 , ISNULL(A.dblQtyShipped, 0)     AS dblQtyShipped
	 , ISNULL(A.dblStandardCost, 0)	  AS dblCost	 
	 , dblMargin = (ISNULL(A.dblPrice, 0) - ISNULL(A.dblStandardCost, 0)) * 
						CASE WHEN A.strTransactionType IN ('Invoice', 'Credit Memo') 
							THEN ISNULL(A.dblQtyShipped, 0) 
							ELSE ISNULL(A.dblQtyOrdered, 0)
						END
	 , dblMarginPercentage = CASE WHEN ISNULL(A.dblStandardCost, 0) > 0 THEN ((ISNULL(A.dblPrice, 0) - ISNULL(A.dblStandardCost, 0)) / ISNULL(A.dblStandardCost, 0)) * 100 ELSE 100 END
	 , ISNULL(A.dblPrice, 0)		  AS dblPrice 
	 , ISNULL(A.dblTax, 0)			  AS dblTax
	 , ISNULL(A.dblLineTotal, 0)	  AS dblLineTotal
	 , ISNULL(A.dblTotal, 0)		  AS dblTotal
	 , C.strCustomerNumber
	 , GA.strDescription			  AS strAccountName
	 , L.strLocationName
	 , IC.strItemNo					  AS strItemName
	 , IC.strDescription              AS strItemDesc
	 , A.strItemDescription			  AS strLineDesc
	 , UOM.strUnitMeasure			  AS strUOM
	 , ICM.strManufacturer
	 , ICB.strBrandName
	 , ICC.strCommodityCode			  AS strCommodityName
	 , CAT.strCategoryCode			  AS strCategoryName
     , E.strName					  AS strCustomerName
	 , ESP.strName					  AS strSalespersonName	 
	 , RTRIM(A.strBillToLocationName) AS strBillTo
	 , RTRIM(A.strShipToLocationName) AS strShipTo
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
	  , ID.intAccountId				  AS intItemAccountId
	  , ID.dblQtyOrdered
	  , ID.dblQtyShipped
	  , dblStandardCost				  = (CASE WHEN ISNULL(ID.intInventoryShipmentItemId,0) = 0 THEN ICIT.dblCost ELSE ICIT1.dblCost END)
	  , dblPrice
	  , ID.dblTotalTax				  AS dblTax
	  , ID.dblTotal					  AS dblLineTotal
	  , I.dblInvoiceTotal			  AS dblTotal
	  , I.strBillToLocationName
	  , I.strShipToLocationName
FROM tblARInvoice I INNER JOIN tblARInvoiceDetail ID ON I.intInvoiceId = ID.intInvoiceId
LEFT OUTER JOIN 
	tblICInventoryTransaction ICIT 
		ON  ISNULL(ICIT.ysnIsUnposted,0) = 0
		AND I.intInvoiceId = ICIT.intTransactionId 
		AND I.strInvoiceNumber = ICIT.strTransactionId 
		AND ID.intItemId = ICIT.intItemId 
		AND ID.intItemUOMId = ICIT.intItemUOMId
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
	 , SOD.intAccountId				  AS intItemAccountId
	 , SOD.dblQtyOrdered
	 , SOD.dblQtyShipped
	 , ICP.dblStandardCost			  AS dblStandardCost				  
	 , dblPrice
	 , SOD.dblTotalTax				  AS dblTax
	 , SOD.dblTotal					  AS dblLineTotal
	 , SO.dblSalesOrderTotal		  AS dblTotal 
	 , SO.strBillToLocationName
	 , SO.strShipToLocationName
FROM tblSOSalesOrder SO INNER JOIN tblSOSalesOrderDetail SOD ON SO.intSalesOrderId = SOD.intSalesOrderId
LEFT JOIN tblICItemUOM SU ON SOD.intItemId = SU.intItemId AND SU.ysnStockUnit = 1
LEFT JOIN (tblICItemLocation ICL 
		INNER JOIN tblICItemPricing ICP ON ICL.intItemLocationId = ICP.intItemLocationId) ON SO.intCompanyLocationId = ICL.intLocationId AND SOD.intItemId = ICL.intItemId AND SOD.intItemId = ICP.intItemId	

WHERE SO.ysnProcessed = 1) AS A
	LEFT JOIN tblGLAccount GA ON A.intItemAccountId = GA.intAccountId
	INNER JOIN tblSMCompanyLocation L ON A.intCompanyLocationId = L.intCompanyLocationId
	INNER JOIN (tblARCustomer C 
		INNER JOIN tblEntity E ON C.intEntityCustomerId = E.intEntityId) ON A.intEntityCustomerId = C.intEntityCustomerId
	LEFT JOIN (tblARSalesperson SP 
		INNER JOIN tblEntity ESP ON SP.intEntitySalespersonId = ESP.intEntityId) ON A.intEntitySalespersonId = SP.intEntitySalespersonId	
	LEFT JOIN (tblICItem IC 
		LEFT JOIN tblICManufacturer ICM ON IC.intManufacturerId = ICM.intManufacturerId
		LEFT JOIN tblICCommodity ICC ON IC.intCommodityId = ICC.intCommodityId
		LEFT JOIN tblICCategory CAT ON IC.intCategoryId = CAT.intCategoryId		
		LEFT JOIN tblICBrand ICB ON IC.intBrandId = ICB.intBrandId) ON A.intItemId = IC.intItemId
	LEFT JOIN vyuARItemUOM UOM ON A.intItemUOMId = UOM.intItemUOMId		