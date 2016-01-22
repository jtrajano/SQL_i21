CREATE VIEW dbo.vyuCFSearchTransaction
AS
SELECT 
		cfVehicle.strVehicleNumber, cfTransaction.intOdometer, cfTransaction.intPumpNumber, cfTransaction.strPONumber, cfTransaction.strMiscellaneous, cfTransaction.strDeliveryPickupInd, cfTransaction.intTransactionId, cfTransaction.dtmBillingDate, 
       cfTransaction.intTransTime, cfTransaction.strSequenceNumber, cfSite.strLocationName AS strCompanyLocation, cfTransaction.strTransactionId, cfTransaction.dtmTransactionDate, cfTransaction.strTransactionType, cfTransaction.dblQuantity, 
       cfCard.strCustomerNumber, cfCard.strName, cfCard.strCardNumber, cfCard.strCardDescription, cfNetwork.strNetwork, cfSite.strSiteNumber, cfSite.strSiteName, 
       cfItem.strProductNumber, cfItem.strItemNo, cfItem.strDescription, cfTransPrice.dblCalculatedAmount AS dblCalculatedTotalAmount, cfTransPrice.dblOriginalAmount AS dblOriginalTotalAmount, 
       cfTransGrossPrice.dblCalculatedAmount AS dblCalculatedGrossAmount, cfTransGrossPrice.dblOriginalAmount AS dblOriginalGrossAmount, cfTransNetPrice.dblCalculatedAmount AS dblCalculatedNetAmount, 
       cfTransNetPrice.dblOriginalAmount AS dblOriginalNetAmount, cfTransNetPrice.dblCalculatedAmount - cfItem.dblAverageCost AS dblMargin, cfTransaction.ysnInvalid, cfTransaction.ysnPosted, 
       FETTaxes.dblTaxCalculatedAmount AS FETTaxes, SETTaxes.dblTaxCalculatedAmount AS SETTaxes, SSTTaxes.dblTaxCalculatedAmount AS SSTTaxes, LCTaxes.dblTaxCalculatedAmount AS LCTaxes, 
       TotalTaxes.dblTaxCalculatedAmount AS TotalTaxes
FROM tblCFTransaction AS cfTransaction
LEFT JOIN tblCFNetwork AS cfNetwork
ON cfTransaction.intNetworkId = cfNetwork.intNetworkId
LEFT JOIN 
	(select 
	smiCompanyLocation.strLocationName,
	cfiSite.*
	from tblCFSite cfiSite
	LEFT JOIN tblSMCompanyLocation smiCompanyLocation
	ON cfiSite.intARLocationId = smiCompanyLocation.intCompanyLocationId
	) AS cfSite
ON cfTransaction.intSiteId = cfSite.intSiteId
LEFT JOIN tblCFVehicle AS cfVehicle
ON cfTransaction.intVehicleId = cfVehicle.intVehicleId
LEFT JOIN 
	(select 
	cfiItem.intItemId,
	cfiItem.strProductNumber,
	iciItem.strDescription,
	iciItem.intItemId as intARItemId,
	iciItem.strItemNo,
	iciItemPricing.dblAverageCost
	from tblCFItem cfiItem
	LEFT JOIN tblICItem iciItem
	ON cfiItem.intARItemId = iciItem.intItemId
	LEFT JOIN tblICItemLocation iciItemLocation
	ON cfiItem.intARItemId = iciItemLocation.intItemId
	LEFT JOIN vyuICGetItemPricing iciItemPricing
	ON cfiItem.intARItemId = iciItemPricing.intItemId 
		AND iciItemLocation.intLocationId = iciItemPricing.intLocationId 
		AND iciItemLocation.intItemLocationId = iciItemPricing.intItemLocationId) AS cfItem
ON cfTransaction.intProductId = cfItem.intItemId
LEFT JOIN 
	(select
	cfiAccount.intAccountId,
	cfiCustomer.strName,
	cfiCustomer.strCustomerNumber,
	cfiCustomer.intEntityCustomerId,
	cfiCard.intCardId,
	cfiCard.strCardNumber,
	cfiCard.strCardDescription
	from tblCFAccount cfiAccount
	INNER JOIN tblCFCard cfiCard
	ON cfiCard.intAccountId = cfiAccount.intAccountId
	INNER JOIN vyuCFCustomerEntity  cfiCustomer
	ON cfiCustomer.intEntityCustomerId = cfiAccount.intCustomerId) AS cfCard
ON cfTransaction.intCardId = cfCard.intCardId
LEFT JOIN
(SELECT        intTransactionPriceId, intTransactionId, strTransactionPriceId, dblOriginalAmount, dblCalculatedAmount, intConcurrencyId
FROM            dbo.tblCFTransactionPrice
WHERE        (strTransactionPriceId = 'Total Amount')) AS cfTransPrice ON cfTransaction.intTransactionId = cfTransPrice.intTransactionId LEFT JOIN
(SELECT        intTransactionPriceId, intTransactionId, strTransactionPriceId, dblOriginalAmount, dblCalculatedAmount, intConcurrencyId
FROM            dbo.tblCFTransactionPrice AS tblCFTransactionPrice_2
WHERE        (strTransactionPriceId = 'Gross Price')) AS cfTransGrossPrice ON cfTransaction.intTransactionId = cfTransGrossPrice.intTransactionId LEFT JOIN
(SELECT        intTransactionPriceId, intTransactionId, strTransactionPriceId, dblOriginalAmount, dblCalculatedAmount, intConcurrencyId
FROM            dbo.tblCFTransactionPrice AS tblCFTransactionPrice_1
WHERE        (strTransactionPriceId = 'Net Price')) AS cfTransNetPrice ON cfTransaction.intTransactionId = cfTransNetPrice.intTransactionId LEFT JOIN
(SELECT        intTransactionTaxId, intTransactionId, strTransactionTaxId, dblTaxOriginalAmount, dblTaxCalculatedAmount, intConcurrencyId, strCalculationMethod, dblTaxRate
FROM            dbo.tblCFTransactionTax
WHERE        (strTransactionTaxId = 'FET')) AS FETTaxes ON cfTransaction.intTransactionId = FETTaxes.intTransactionId LEFT JOIN
(SELECT        intTransactionTaxId, intTransactionId, strTransactionTaxId, dblTaxOriginalAmount, dblTaxCalculatedAmount, intConcurrencyId, strCalculationMethod, dblTaxRate
FROM            dbo.tblCFTransactionTax AS tblCFTransactionTax_4
WHERE        (strTransactionTaxId = 'SET')) AS SETTaxes ON cfTransaction.intTransactionId = SETTaxes.intTransactionId LEFT JOIN
(SELECT        intTransactionTaxId, intTransactionId, strTransactionTaxId, dblTaxOriginalAmount, dblTaxCalculatedAmount, intConcurrencyId, strCalculationMethod, dblTaxRate
FROM            dbo.tblCFTransactionTax AS tblCFTransactionTax_3
WHERE        (strTransactionTaxId = 'SST')) AS SSTTaxes ON cfTransaction.intTransactionId = SSTTaxes.intTransactionId LEFT JOIN
(SELECT        intTransactionId, ISNULL(SUM(dblTaxOriginalAmount), 0) AS dblTaxOriginalAmount, ISNULL(SUM(dblTaxCalculatedAmount), 0) AS dblTaxCalculatedAmount, ISNULL(SUM(dblTaxRate), 0) 
							AS dblTaxRate
FROM            dbo.tblCFTransactionTax AS tblCFTransactionTax_2
GROUP BY intTransactionId) AS TotalTaxes ON cfTransaction.intTransactionId = TotalTaxes.intTransactionId LEFT JOIN
(SELECT        intTransactionId, ISNULL(SUM(dblTaxOriginalAmount), 0) AS dblTaxOriginalAmount, ISNULL(SUM(dblTaxCalculatedAmount), 0) AS dblTaxCalculatedAmount, ISNULL(SUM(dblTaxRate), 0) 
							AS dblTaxRate
FROM            dbo.tblCFTransactionTax AS tblCFTransactionTax_1
WHERE        (strTransactionTaxId LIKE 'LC%')
GROUP BY intTransactionId) AS LCTaxes ON cfTransaction.intTransactionId = LCTaxes.intTransactionId LEFT JOIN
dbo.vyuCTContractDetailView AS ctContracts ON cfTransaction.intContractId = ctContracts.intContractDetailId

						