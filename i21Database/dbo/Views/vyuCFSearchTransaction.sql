﻿CREATE VIEW [dbo].[vyuCFSearchTransaction]
AS
SELECT   cfVehicle.strVehicleNumber, cfTransaction.intOdometer, cfTransaction.intPumpNumber, cfTransaction.strPONumber, cfTransaction.strMiscellaneous,
                         cfTransaction.strDeliveryPickupInd, cfTransaction.intTransactionId, cfTransaction.dtmBillingDate, cfTransaction.intTransTime, cfTransaction.strSequenceNumber,
                         cfSite.strLocationName AS strCompanyLocation, cfTransaction.strTransactionId, cfTransaction.dtmTransactionDate, cfTransaction.strTransactionType,
                         cfTransaction.dblQuantity, 

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
						 END) AS strName,

						 (CASE 
						 WHEN cfTransaction.strTransactionType = 'Foreign Sale' THEN cfTransaction.strForeignCardId
						 ELSE cfCard.strCardNumber
						 END) AS strCardNumber,

						 (CASE 
						 WHEN cfTransaction.strTransactionType = 'Foreign Sale' THEN 'Foreign Card'
						 ELSE cfCard.strCardDescription
						 END) AS strCardDescription,
						
						 cfNetwork.strNetwork, cfSite.strSiteNumber,
                         cfSite.strSiteName, cfItem.strProductNumber, cfItem.strItemNo, cfItem.strDescription, ROUND(cfTransPrice.dblCalculatedAmount,2) AS dblCalculatedTotalAmount,
                         ROUND(cfTransPrice.dblOriginalAmount,2) AS dblOriginalTotalAmount, cfTransGrossPrice.dblCalculatedAmount AS dblCalculatedGrossAmount,
                         cfTransGrossPrice.dblOriginalAmount AS dblOriginalGrossAmount, cfTransNetPrice.dblCalculatedAmount AS dblCalculatedNetAmount,
                         cfTransNetPrice.dblOriginalAmount AS dblOriginalNetAmount, cfTransaction.ysnInvalid, cfTransaction.ysnPosted, tblCFTransactionTax_1.dblTaxCalculatedAmount,
                         tblCFTransactionTax_1.dblTaxOriginalAmount, ctContracts.strContractNumber, cfTransaction.strPriceMethod, cfTransaction.strPriceBasis, cfTransaction.dblTransferCost,
						 cfTransaction.dtmPostedDate,
                         
						 
						 --ISNULL(CASE WHEN cfTransaction.strTransactionType = 'Local/Network' 
						 --THEN 
						 --CASE
						 -- WHEN cfTransaction.ysnPosted = 1 THEN cfTransNetPrice.dblCalculatedAmount - arSalesAnalysisReport.dblUnitCost
       --                   ELSE cfTransNetPrice.dblCalculatedAmount - cfItem.dblAverageCost END ELSE cfTransGrossPrice.dblCalculatedAmount - cfTransaction.dblTransferCost END, 0)
			
                         0.0 AS dblMargin,  cfTransaction.dtmInvoiceDate, cfTransaction.strInvoiceReportNumber
	,cfSite.strSiteGroup
	,cfTransaction.strPriceProfileId
	,cfCard.strPriceGroup
	,strPriceProfileSite = ISNULL(cfTransaction.strPriceProfileId,'') + '-' + ISNULL(cfSite.strSiteName, '')
	,dtmTransactionDateOnly = cfTransaction.dtmTransactionDate
	,dtmTransactionTimeOnly = cfTransaction.dtmTransactionDate
	,dblTaxDiff = ISNULL(tblCFTransactionTax_1.dblTaxCalculatedAmount,0.0) - ISNULL(tblCFTransactionTax_1.dblTaxOriginalAmount,0.0)
FROM dbo.tblCFTransaction AS cfTransaction 
LEFT OUTER JOIN 
	(	SELECT cfNetwork.* , emEntity.strName as strForeignCustomer , emEntity.strEntityNo FROM tblCFNetwork as cfNetwork
		INNER JOIN tblEMEntity emEntity 
			ON cfNetwork.intCustomerId = emEntity.intEntityId) as cfNetwork  
	ON cfNetwork.intNetworkId = cfTransaction.intNetworkId
LEFT OUTER JOIN
	(	SELECT   smiCompanyLocation.strLocationName, cfiSite.intSiteId, cfiSite.strSiteNumber, cfiSite.strSiteName
			,SG.strSiteGroup
        FROM dbo.tblCFSite AS cfiSite 
		LEFT OUTER JOIN	dbo.tblSMCompanyLocation AS smiCompanyLocation 
			ON cfiSite.intARLocationId = smiCompanyLocation.intCompanyLocationId
		LEFT JOIN tblCFSiteGroup SG
			ON cfiSite.intAdjustmentSiteGroupId = SG.intSiteGroupId
			) AS cfSite 
	ON cfTransaction.intSiteId = cfSite.intSiteId 
LEFT OUTER JOIN 
		dbo.tblCFVehicle AS cfVehicle ON cfTransaction.intVehicleId = cfVehicle.intVehicleId LEFT OUTER JOIN
			(SELECT   cfiItem.intItemId, cfiItem.strProductNumber, iciItem.strDescription, iciItem.intItemId AS intARItemId, iciItem.strItemNo, iciItemPricing.dblAverageCost,
										iciItemPricing.dblStandardCost 
			FROM         dbo.tblCFItem AS cfiItem LEFT OUTER JOIN 
										dbo.tblCFSite AS cfiSite ON cfiSite.intSiteId = cfiItem.intSiteId LEFT OUTER JOIN
										dbo.tblICItem AS iciItem ON cfiItem.intARItemId = iciItem.intItemId LEFT OUTER JOIN
										dbo.tblICItemLocation AS iciItemLocation ON cfiItem.intARItemId = iciItemLocation.intItemId AND
										iciItemLocation.intLocationId = cfiSite.intARLocationId LEFT OUTER JOIN
										dbo.vyuICGetItemPricing AS iciItemPricing ON cfiItem.intARItemId = iciItemPricing.intItemId AND iciItemLocation.intLocationId = iciItemPricing.intLocationId AND
										iciItemLocation.intItemLocationId = iciItemPricing.intItemLocationId AND iciItemLocation.intIssueUOMId = iciItemPricing.intUnitMeasureId) AS cfItem ON
		cfTransaction.intProductId = cfItem.intItemId 
LEFT OUTER JOIN 
		(SELECT   cfiAccount.intAccountId, cfiCustomer.strName, cfiCustomer.strEntityNo, cfiCustomer.intEntityId, cfiCard.intCardId, cfiCard.strCardNumber,
										cfiCard.strCardDescription 
			,strPriceGroup
		 FROM         dbo.tblCFAccount AS cfiAccount 
		 INNER JOIN dbo.tblCFCard AS cfiCard 
			ON cfiCard.intAccountId = cfiAccount.intAccountId 
		 INNER JOIN dbo.tblEMEntity AS cfiCustomer
			ON cfiCustomer.intEntityId = cfiAccount.intCustomerId
		 LEFT JOIN tblCFPriceRuleGroup AS PRG
			ON  cfiAccount.intPriceRuleGroup = PRG.intPriceRuleGroupId
		) AS cfCard 
	ON cfTransaction.intCardId = cfCard.intCardId 
LEFT OUTER JOIN 
			(SELECT   intTransactionPriceId, intTransactionId, strTransactionPriceId, dblOriginalAmount, dblCalculatedAmount, intConcurrencyId
			FROM         dbo.tblCFTransactionPrice 
			WHERE     (strTransactionPriceId = 'Total Amount')) AS cfTransPrice ON cfTransaction.intTransactionId = cfTransPrice.intTransactionId LEFT OUTER JOIN
			(SELECT   intTransactionPriceId, intTransactionId, strTransactionPriceId, dblOriginalAmount, dblCalculatedAmount, intConcurrencyId
			FROM         dbo.tblCFTransactionPrice AS tblCFTransactionPrice_2
			WHERE     (strTransactionPriceId = 'Gross Price')) AS cfTransGrossPrice ON cfTransaction.intTransactionId = cfTransGrossPrice.intTransactionId LEFT OUTER JOIN
			(SELECT   intTransactionPriceId, intTransactionId, strTransactionPriceId, dblOriginalAmount, dblCalculatedAmount, intConcurrencyId
			FROM         dbo.tblCFTransactionPrice AS tblCFTransactionPrice_1
			WHERE     (strTransactionPriceId = 'Net Price')) AS cfTransNetPrice ON cfTransaction.intTransactionId = cfTransNetPrice.intTransactionId LEFT OUTER JOIN
			(SELECT   intTransactionId, ISNULL(SUM(dblTaxOriginalAmount), 0) AS dblTaxOriginalAmount, ISNULL(SUM(dblTaxCalculatedAmount), 0) AS dblTaxCalculatedAmount
			FROM         dbo.tblCFTransactionTax AS tblCFTransactionTax 
			GROUP BY intTransactionId) AS tblCFTransactionTax_1 
	ON cfTransaction.intTransactionId = tblCFTransactionTax_1.intTransactionId 
LEFT OUTER JOIN dbo.tblCTContractHeader AS ctContracts 
	ON cfTransaction.intContractId = ctContracts.intContractHeaderId
GO



GO



GO


