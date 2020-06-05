

CREATE VIEW [dbo].[vyuCFTransactionSummary]
AS
SELECT   

YEAR(cfTransaction.dtmTransactionDate) AS intYear,
MONTH(cfTransaction.dtmTransactionDate) AS intMonth,
cfSite.intSiteId,
cfSite.strSiteAddress,
RTRIM(LTRIM(cfSite.strSiteName)) AS strSiteName,
cfSite.strSiteNumber,
cfSite.strSiteCity,
cfSite.intAdjustmentSiteGroupId,
(CASE 
WHEN cfTransaction.strTransactionType = 'Foreign Sale' THEN cfNetwork.intCustomerId
ELSE  cfCard.intEntityId
END)
AS intEntityId,

(CASE 
WHEN cfTransaction.strTransactionType = 'Foreign Sale' THEN cfNetwork.strEntityNo
ELSE  cfCard.strEntityNo
END) AS strCustomerNumber,

(CASE 
WHEN cfTransaction.strTransactionType = 'Foreign Sale' THEN cfNetwork.strForeignCustomer
ELSE cfCard.strName
END) AS strName

,cfTransaction.strTransactionType
,DATEADD(dd, DATEDIFF(dd, 0, cfTransaction.dtmTransactionDate ), 0) as dtmTransactionDate
,dtmTransactionDate as dtmTransactionDateTime
,DATEADD(dd, DATEDIFF(dd, 0, cfTransaction.dtmPostedDate ), 0) as dtmPostedDate
,cfTransaction.intTransactionId

,cfNetwork.strNetwork
,cfNetwork.strNetworkDescription
,cfNetwork.intNetworkId

,cfItem.intARItemId
,cfItem.strItemNo
,cfItem.strItemDescription AS strItemDescription
,cfItem.strProductNumber
,cfItem.strCategoryCode
,cfItem.strCategoryDescription

,cfCard.strSalespersonEntityNo
,cfCard.strSalespersonName
,cfCard.intSalesPersonId


,cfTransaction.dblQuantity AS dblQuantity
,ISNULL(tblCFTransactionTax_1.dblTaxCalculatedAmount,0) AS dblTaxCalculatedAmount
,ISNULL(cfTransaction.dblCalculatedGrossPrice,0) AS dblGrossPrice
,ISNULL(cfTransaction.dblCalculatedNetPrice,0) AS dblNetPrice
,ISNULL(cfTransaction.dblCalculatedTotalPrice,0) AS dblTotalAmount

,ISNULL(cfTransaction.dblInventoryCost,0) AS dblInventoryCost
,ISNULL(cfTransaction.dblTransferCost,0) AS dblTransferCost

,ROUND(ISNULL(cfTransaction.dblCalculatedTotalPrice,0),2) AS dblSalesAmount

,(CASE  
		WHEN cfTransaction.strTransactionType IN ('Local/Network','Foreign Sale','Foreign Sales') AND ISNULL(cfTransaction.dblInventoryCost,0) > 0
		THEN 
			ROUND(ISNULL(cfTransaction.dblInventoryCost,0) * cfTransaction.dblQuantity + ISNULL(tblCFTransactionTax_1.dblTaxCalculatedAmount,0) ,2)
		ELSE
			ROUND(ISNULL(cfTransaction.dblNetTransferCost,0) * cfTransaction.dblQuantity + ISNULL(tblCFTransactionTax_1.dblTaxCalculatedAmount,0),2) 

END) AS dblCost

,strCustomerInvoiceNumber = arinvoice.strInvoiceNumber
,strInvoiceReportNumber = cfTransaction.strInvoiceReportNumber
,strSiteState = cfSite.strTaxState
,dtmARInvoiceDate = arinvoice.dtmDate
,cfSite.strSiteType
,ysnInvoiced = CAST((CASE WHEN ISNULL(cfTransaction.strInvoiceReportNumber,'') = '' THEN 0 ELSE 1 END) AS BIT)
,strSiteNumberName = cfSite.strSiteNumber + ' - ' + cfSite.strSiteName
FROM         dbo.tblCFTransaction AS cfTransaction 
INNER JOIN tblCFSite cfSite
on cfSite.intSiteId = cfTransaction.intSiteId
--J1
LEFT OUTER JOIN  
		(SELECT cfNetwork.* , emEntity.strName as strForeignCustomer , emEntity.strEntityNo 
		FROM tblCFNetwork as cfNetwork
		LEFT JOIN tblEMEntity emEntity 
		ON cfNetwork.intCustomerId = emEntity.intEntityId) 
	AS cfNetwork  
	on cfNetwork.intNetworkId = cfTransaction.intNetworkId
		
LEFT OUTER JOIN
    (SELECT   cfiItem.intItemId, cfiItem.strProductNumber, iciItem.strDescription AS strItemDescription, iciItem.intItemId AS intARItemId, iciItem.strItemNo, iciItemPricing.dblAverageCost,iciItemPricing.dblStandardCost ,iciCat.strCategoryCode,iciCat.strDescription as strCategoryDescription
    FROM         dbo.tblCFItem AS cfiItem 
	LEFT OUTER JOIN 
        dbo.tblCFSite AS cfiSite ON cfiSite.intSiteId = cfiItem.intSiteId LEFT OUTER JOIN
        dbo.tblICItem AS iciItem ON cfiItem.intARItemId = iciItem.intItemId LEFT OUTER JOIN
		dbo.tblICCategory AS iciCat ON iciItem.intCategoryId = iciCat.intCategoryId LEFT OUTER JOIN
        dbo.tblICItemLocation AS iciItemLocation ON cfiItem.intARItemId = iciItemLocation.intItemId AND
        iciItemLocation.intLocationId = cfiSite.intARLocationId LEFT OUTER JOIN
        dbo.vyuICGetItemPricing AS iciItemPricing ON cfiItem.intARItemId = iciItemPricing.intItemId AND iciItemLocation.intLocationId = iciItemPricing.intLocationId AND
        iciItemLocation.intItemLocationId = iciItemPricing.intItemLocationId AND iciItemLocation.intIssueUOMId = iciItemPricing.intUnitMeasureId) 
	AS cfItem 
	ON cfTransaction.intProductId = cfItem.intItemId 
--J4
			
--J5	
LEFT OUTER JOIN 
        (SELECT   cfiAccount.intAccountId, cfiCustomer.strName, cfiCustomer.strEntityNo, cfiCustomer.intEntityId, cfiCard.intCardId, cfiCard.strCardNumber,cfiCard.strCardDescription , cfiAccount.intSalesPersonId, cfiSalesPerson.strEntityNo as strSalespersonEntityNo, cfiSalesPerson.strName as strSalespersonName
        FROM         dbo.tblCFAccount AS cfiAccount 
		INNER JOIN 
        dbo.tblCFCard AS cfiCard ON cfiCard.intAccountId = cfiAccount.intAccountId 
		INNER JOIN
		dbo.tblEMEntity AS cfiCustomer ON cfiCustomer.intEntityId = cfiAccount.intCustomerId
		LEFT JOIN 
		dbo.tblEMEntity AS cfiSalesPerson ON cfiSalesPerson.intEntityId = cfiAccount.intSalesPersonId) 
AS cfCard 
ON cfTransaction.intCardId = cfCard.intCardId 
			--J5

			--J6
			--LEFT OUTER JOIN 
   --             (SELECT   intTransactionPriceId, intTransactionId, strTransactionPriceId, dblOriginalAmount, dblCalculatedAmount, intConcurrencyId
   --             FROM         dbo.tblCFTransactionPrice 
   --             WHERE     (strTransactionPriceId = 'Total Amount')) 
			--AS cfTransPrice 
			--ON cfTransaction.intTransactionId = cfTransPrice.intTransactionId
			----J6

			----J7
			--LEFT OUTER JOIN
   --             (SELECT   intTransactionPriceId, intTransactionId, strTransactionPriceId, dblOriginalAmount, dblCalculatedAmount, intConcurrencyId
   --             FROM         dbo.tblCFTransactionPrice AS tblCFTransactionPrice_2
   --             WHERE     (strTransactionPriceId = 'Gross Price')) 
			--AS cfTransGrossPrice 
			--ON cfTransaction.intTransactionId = cfTransGrossPrice.intTransactionId 
			----J7

			----J8
			--LEFT OUTER JOIN
   --             (SELECT   intTransactionPriceId, intTransactionId, strTransactionPriceId, dblOriginalAmount, dblCalculatedAmount, intConcurrencyId
   --             FROM         dbo.tblCFTransactionPrice AS tblCFTransactionPrice_1
   --             WHERE     (strTransactionPriceId = 'Net Price')) 
			--AS cfTransNetPrice 
			--ON cfTransaction.intTransactionId = cfTransNetPrice.intTransactionId 
			----J8

			--J9
LEFT OUTER JOIN
    (SELECT   intTransactionId, ISNULL(SUM(dblTaxOriginalAmount), 0) AS dblTaxOriginalAmount, ISNULL(SUM(dblTaxCalculatedAmount), 0) AS dblTaxCalculatedAmount
    FROM         dbo.tblCFTransactionTax AS tblCFTransactionTax 
    GROUP BY intTransactionId) 
AS tblCFTransactionTax_1 
ON cfTransaction.intTransactionId = tblCFTransactionTax_1.intTransactionId 
LEFT JOIN tblARInvoice arinvoice
	ON cfTransaction.intInvoiceId = arinvoice.intInvoiceId


			--WHERE ISNULL(cfTransaction.ysnPosted,0) = 1

			where ISNULL(cfTransaction.ysnPosted,0) = 1
GO


