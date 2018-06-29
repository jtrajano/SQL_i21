CREATE VIEW [dbo].[vyuCFSearchTransaction]
AS
SELECT   
	cfVehicle.strVehicleNumber
	,cfTransaction.intOdometer
	,cfTransaction.intPumpNumber
	,cfTransaction.strPONumber
	,cfTransaction.strMiscellaneous
	,cfTransaction.strDeliveryPickupInd
	,cfTransaction.intTransactionId
	,cfTransaction.dtmBillingDate
	,cfTransaction.intTransTime
	,cfTransaction.strSequenceNumber
	,cfSite.strLocationName AS strCompanyLocation
	,cfTransaction.strTransactionId
	,cfTransaction.dtmTransactionDate
	,cfTransaction.strTransactionType
	,cfTransaction.dblQuantity
	,cfTransaction.ysnOnHold
	,cfTransaction.dtmCreatedDate
	,(CASE 
		WHEN cfTransaction.strTransactionType = 'Foreign Sale' THEN cfNetwork.intCustomerId
		ELSE  cfCard.intEntityId
		END)
		AS intEntityId
	,(CASE 
		WHEN cfTransaction.strTransactionType = 'Foreign Sale' THEN cfNetwork.strEntityNo
		ELSE  cfCard.strEntityNo
		END) AS strCustomerNumber
	,(CASE 
		WHEN cfTransaction.strTransactionType = 'Foreign Sale' THEN cfNetwork.strForeignCustomer
		ELSE cfCard.strName
		END) AS strName
	,(CASE 
		WHEN cfTransaction.strTransactionType = 'Foreign Sale' THEN cfTransaction.strForeignCardId
		ELSE cfCard.strCardNumber
		END) AS strCardNumber
	,(CASE 
		WHEN cfTransaction.strTransactionType = 'Foreign Sale' THEN 'Foreign Card'
		ELSE cfCard.strCardDescription
		END) AS strCardDescription
	,cfNetwork.strNetwork
	,cfSite.strSiteNumber
	,cfSite.strTaxState
	,cfSite.strTaxGroup
	,cfSite.strSiteName
	,cfItem.strProductNumber
	,cfItem.strItemNo
	,cfItem.strDescription
	,ROUND(cfTransaction.dblCalculatedTotalPrice,2) AS dblCalculatedTotalAmount
	,ROUND(cfTransaction.dblOriginalTotalPrice,2) AS dblOriginalTotalAmount
	,cfTransaction.dblCalculatedGrossPrice AS dblCalculatedGrossAmount
	,cfTransaction.dblOriginalGrossPrice AS dblOriginalGrossAmount
	,cfTransaction.dblCalculatedNetPrice AS dblCalculatedNetAmount
	,cfTransaction.dblOriginalNetPrice AS dblOriginalNetAmount
	,cfTransaction.dblCalculatedTotalTax AS dblTaxCalculatedAmount
	,cfTransaction.dblOriginalTotalTax AS dblTaxOriginalAmount
	,cfTransaction.ysnInvalid
	,cfTransaction.ysnPosted
	,cfTransaction.dblCalculatedTotalTax
	,cfTransaction.dblOriginalTotalTax
	,ctContracts.strContractNumber
	,cfTransaction.strPriceMethod
	,cfTransaction.strPriceBasis
	,cfTransaction.dblTransferCost
	,cfTransaction.dtmPostedDate
	,cfTransaction.dblMargin 
	,cfTransaction.dtmInvoiceDate
	,cfTransaction.strInvoiceReportNumber
	,cfSite.strSiteGroup
	,cfTransaction.strPriceProfileId
	,cfCard.strPriceGroup
	,strPriceProfileSite = ISNULL(cfTransaction.strPriceProfileId,'') + '-' + ISNULL(cfSite.strSiteName, '')
	,dtmTransactionDateOnly = cfTransaction.dtmTransactionDate
	,dtmTransactionTimeOnly = cfTransaction.dtmTransactionDate
	,dblTaxDiff = ISNULL(cfTransaction.dblCalculatedTotalTax,0.0) - ISNULL(cfTransaction.dblOriginalTotalTax,0.0)
	,dblTotalFET = ISNULL(FETTaxes_1.dblTaxCalculatedAmount, 0) 
    ,dblTotalSET = ISNULL(SETTaxes_1.dblTaxCalculatedAmount, 0)
    ,dblTotalSST = ISNULL(SSTTaxes_1.dblTaxCalculatedAmount, 0) 
    ,dblTotalLC =  ISNULL(LCTaxes_1.dblTaxCalculatedAmount, 0)
	,strItemCategory = cfItem.strCategoryCode           
FROM dbo.tblCFTransaction AS cfTransaction 
LEFT OUTER JOIN 
	(	SELECT cfNetwork.* , emEntity.strName as strForeignCustomer , emEntity.strEntityNo FROM tblCFNetwork as cfNetwork
		LEFT JOIN tblEMEntity emEntity 
			ON cfNetwork.intCustomerId = emEntity.intEntityId) as cfNetwork  
	ON cfNetwork.intNetworkId = cfTransaction.intNetworkId
LEFT OUTER JOIN
	(	SELECT   smiCompanyLocation.strLocationName, cfiSite.intSiteId, cfiSite.strSiteNumber, cfiSite.strSiteName, cfiSite.strTaxState, TG.strTaxGroup
			,SG.strSiteGroup
        FROM dbo.tblCFSite AS cfiSite 
		LEFT OUTER JOIN	dbo.tblSMCompanyLocation AS smiCompanyLocation 
			ON cfiSite.intARLocationId = smiCompanyLocation.intCompanyLocationId
		LEFT JOIN tblCFSiteGroup SG
			ON cfiSite.intAdjustmentSiteGroupId = SG.intSiteGroupId
		LEFT JOIN tblSMTaxGroup TG 
			ON cfiSite.intTaxGroupId = TG.intTaxGroupId
			) AS cfSite 
	ON cfTransaction.intSiteId = cfSite.intSiteId 
LEFT OUTER JOIN dbo.tblCFVehicle AS cfVehicle 
	ON cfTransaction.intVehicleId = cfVehicle.intVehicleId 
LEFT OUTER JOIN(SELECT   
					cfiItem.intItemId
					,cfiItem.strProductNumber
					,iciItem.strDescription
					,iciItem.intItemId AS intARItemId
					,iciItem.strItemNo
					,iciItemPricing.dblAverageCost
					,iciItemPricing.dblStandardCost 
					,iciItem.intCategoryId
					,iccategory.strCategoryCode
				FROM dbo.tblCFItem AS cfiItem 
				LEFT OUTER JOIN dbo.tblCFSite AS cfiSite 
					ON cfiSite.intSiteId = cfiItem.intSiteId 
				INNER JOIN	dbo.tblICItem AS iciItem 
					ON cfiItem.intARItemId = iciItem.intItemId 
				LEFT JOIN tblICCategory iccategory
	ON iciItem.intCategoryId = iccategory.intCategoryId
				LEFT OUTER JOIN dbo.tblICItemLocation AS iciItemLocation 
					ON cfiItem.intARItemId = iciItemLocation.intItemId 
						AND iciItemLocation.intLocationId = cfiSite.intARLocationId 
				LEFT OUTER JOIN dbo.vyuICGetItemPricing AS iciItemPricing 
					ON cfiItem.intARItemId = iciItemPricing.intItemId 
						AND iciItemLocation.intLocationId = iciItemPricing.intLocationId 
						AND iciItemLocation.intItemLocationId = iciItemPricing.intItemLocationId 
						AND iciItemLocation.intIssueUOMId = iciItemPricing.intUnitMeasureId) AS cfItem 
	ON cfTransaction.intProductId = cfItem.intItemId 
LEFT OUTER JOIN (SELECT   
					cfiAccount.intAccountId
					,cfiCustomer.strName
					,cfiCustomer.strEntityNo
					,cfiCustomer.intEntityId
					,cfiCard.intCardId
					,cfiCard.strCardNumber
					,cfiCard.strCardDescription 
					,PRG.strPriceGroup
					
				 FROM dbo.tblCFAccount AS cfiAccount 
				 INNER JOIN dbo.tblCFCard AS cfiCard 
					ON cfiCard.intAccountId = cfiAccount.intAccountId 
				 INNER JOIN dbo.tblEMEntity AS cfiCustomer
					ON cfiCustomer.intEntityId = cfiAccount.intCustomerId
				 LEFT JOIN tblCFPriceRuleGroup AS PRG
					ON  cfiAccount.intPriceRuleGroup = PRG.intPriceRuleGroupId
				) AS cfCard 
	ON cfTransaction.intCardId = cfCard.intCardId 
LEFT OUTER JOIN dbo.tblCTContractHeader AS ctContracts 
	ON cfTransaction.intContractId = ctContracts.intContractHeaderId
LEFT OUTER JOIN (SELECT intTransactionId, 
					ISNULL(Sum(dblTaxCalculatedAmount), 0) AS dblTaxCalculatedAmount 
				FROM   dbo.vyuCFTransactionTax AS FETTaxes 
				WHERE  ( strTaxClass LIKE '%(FET)%' ) 
				GROUP  BY intTransactionId) AS FETTaxes_1 
	ON cfTransaction.intTransactionId = FETTaxes_1.intTransactionId 
LEFT OUTER JOIN (SELECT intTransactionId, 
					ISNULL(Sum(dblTaxCalculatedAmount), 0) AS dblTaxCalculatedAmount
                FROM   dbo.vyuCFTransactionTax AS SETTaxes 
                WHERE  ( strTaxClass LIKE '%(SET)%' ) 
                GROUP  BY intTransactionId) AS SETTaxes_1 
    ON cfTransaction.intTransactionId = SETTaxes_1.intTransactionId 
LEFT OUTER JOIN (SELECT intTransactionId, 
                        ISNULL(Sum(dblTaxCalculatedAmount), 0) AS dblTaxCalculatedAmount
                FROM   dbo.vyuCFTransactionTax AS SSTTaxes 
                WHERE  ( strTaxClass LIKE '%(SST)%' ) 
                GROUP  BY intTransactionId) AS SSTTaxes_1 
	ON cfTransaction.intTransactionId = SSTTaxes_1.intTransactionId 
LEFT OUTER JOIN (SELECT intTransactionId, 
                        ISNULL(Sum(dblTaxCalculatedAmount), 0) AS dblTaxCalculatedAmount 
                FROM   dbo.vyuCFTransactionTax AS LCTaxes 
                WHERE  ( strTaxClass NOT LIKE '%(SET)%' ) 
                        AND ( strTaxClass <> 'SET' ) 
                        AND ( strTaxClass NOT LIKE '%(FET)%' ) 
                        AND ( strTaxClass <> 'FET' ) 
                        AND ( strTaxClass NOT LIKE '%(SST)%' ) 
                        AND ( strTaxClass <> 'SST' ) 
                GROUP  BY intTransactionId) AS LCTaxes_1 
    ON cfTransaction.intTransactionId = LCTaxes_1.intTransactionId 




GO


