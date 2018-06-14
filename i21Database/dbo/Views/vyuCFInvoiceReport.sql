CREATE VIEW [dbo].[vyuCFInvoiceReport]
AS


SELECT 
--count(*),
----------------------------------------------
 cfTrans.intCustomerId
 ,cfTrans.intTransactionId
 ,cfTrans.dtmTransactionDate
 ,dtmInvoiceDate =Dateadd(dd, Datediff(dd, 0, cfTrans.dtmInvoiceDate), 0)
 ,cfTrans.intOdometer
 ,cfTrans.dtmPostedDate
 ,cfTrans.intProductId
 ,cfTrans.intCardId
 ,cfTrans.strTransactionId
 ,cfTrans.strTransactionType
 ,cfTrans.strInvoiceReportNumber
 ,cfTrans.strTempInvoiceReportNumber
 ,cfTrans.dblQuantity
 ,cfTrans.strMiscellaneous
 ,cfTrans.dtmCreatedDate
 ,dblCalculatedTotalAmount	  = Round(cfTrans.dblCalculatedTotalPrice, 2)
 ,dblOriginalTotalAmount	  = cfTrans.dblOriginalTotalPrice
 ,dblCalculatedGrossAmount	  = cfTrans.dblCalculatedGrossPrice
 ,dblOriginalGrossAmount	  = cfTrans.dblOriginalGrossPrice
 ,dblCalculatedNetAmount	  = cfTrans.dblCalculatedNetPrice
 ,dblOriginalNetAmount		  = cfTrans.dblOriginalNetPrice
 ,cfTrans.dblMargin
 ,cfTrans.ysnInvalid
 ,cfTrans.ysnPosted
 ,cfTrans.strPrintTimeStamp
 ,cfTrans.ysnPostedCSV
 ,cfTrans.ysnInvoiced
----------------------------------------------
,cfAccount.intAccountId
,cfAccount.intInvoiceCycle
,cfAccount.strPrimarySortOptions
,cfAccount.strSecondarySortOptions
,cfAccount.strPrintRemittancePage
,cfAccount.strPrintPricePerGallon
,cfAccount.ysnPrintMiscellaneous
,cfAccount.strPrintSiteAddress
,cfAccount.ysnSummaryByCard
,cfAccount.ysnSummaryByDepartment
,cfAccount.ysnSummaryByMiscellaneous
,cfAccount.ysnSummaryByProduct
,cfAccount.ysnSummaryByVehicle
,cfAccount.ysnSummaryByCardProd
,cfAccount.ysnSummaryByDeptCardProd
,cfAccount.ysnPrintTimeOnInvoices
,cfAccount.ysnPrintTimeOnReports
,cfAccount.ysnSummaryByDeptVehicleProd
,cfAccount.strPrimaryDepartment
,cfAccount.ysnDepartmentGrouping
----------------------------------------------
,strCustomerName = emEntity.strName
,emEntity.strName
,emEntity.strCustomerNumber
----------------------------------------------
,strBillTo =(CASE 
				WHEN ISNULL(cfTrans.intInvoiceId,0) = 0
				THEN dbo.fnARFormatCustomerAddress (
				 NULL
				,NULL
				,emEntity.strBillToLocationName
				,emEntity.strBillToAddress
				,emEntity.strBillToCity
				,emEntity.strBillToState
				,emEntity.strBillToZipCode
				,emEntity.strBillToCountry
				,emEntity.strName
				,NULL)
				ELSE
				arInv.strBillTo
			END)
,arInv.strShipTo
,arInv.strType
,arInv.strLocationName
,arInv.intInvoiceId
,arInv.strInvoiceNumber
,arInv.dtmDate
----------------------------------------------
,cfNetwork.strNetwork
,cfNetwork.ysnPostForeignSales
----------------------------------------------
,emGroup.intCustomerGroupId
,emGroup.strGroupName
----------------------------------------------
,cfInvCycle.strInvoiceCycle
----------------------------------------------
,cfCard.strCardNumber
,cfCard.strCardDescription
----------------------------------------------
,cfSite.strSiteNumber
,cfSite.strSiteName
,cfSite.strTaxState
,cfSite.strSiteType
,strState = cfSite.strTaxState
,cfSite.strSiteAddress
,cfSite.strSiteCity
----------------------------------------------
,cfItem.strProductNumber
----------------------------------------------
,icItem.strItemNo
,icItem.strShortName AS strDescription
----------------------------------------------
,cfVehicle.strVehicleNumber
,cfVehicle.strVehicleDescription
----------------------------------------------

--SPECIAL CASE--------------------------------
,strDepartment = ( CASE 
						WHEN cfAccount.strPrimaryDepartment = 'Card' 
						THEN 
                        CASE WHEN ISNULL(cfCardDepartment.intDepartmentId, 0) >= 1 
							 THEN cfCardDepartment.strDepartment 
                             ELSE 
                                 CASE WHEN ISNULL(cfVehicleDepartment.intDepartmentId, 0) >= 1 
									  THEN cfVehicleDepartment.strDepartment 
									  ELSE 'Unknown' 
                                 END 
                        END 
                        WHEN cfAccount.strPrimaryDepartment = 'Vehicle' 
                        THEN 
                        CASE WHEN ISNULL(cfVehicleDepartment.intDepartmentId, 0) >=  1 
                             THEN cfVehicleDepartment.strDepartment 
                             ELSE 
                                 CASE WHEN ISNULL(cfCardDepartment.intDepartmentId, 0) >= 1 
									  THEN cfCardDepartment.strDepartment 
									  ELSE 'Unknown' 
                                 END 
                             END 
                        ELSE 'Unknown' 
                    END)

,strDepartmentDescription = ( CASE 
						WHEN cfAccount.strPrimaryDepartment = 'Card' 
						THEN 
                        CASE WHEN ISNULL(cfCardDepartment.intDepartmentId, 0) >= 1 
							 THEN cfCardDepartment.strDepartmentDescription 
                             ELSE 
                                 CASE WHEN ISNULL(cfVehicleDepartment.intDepartmentId, 0) >= 1 
									  THEN cfVehicleDepartment.strDepartmentDescription 
									  ELSE 'Unknown' 
                                 END 
                        END 
                        WHEN cfAccount.strPrimaryDepartment = 'Vehicle' 
                        THEN 
                        CASE WHEN ISNULL(cfVehicleDepartment.intDepartmentId, 0) >=  1 
                             THEN cfVehicleDepartment.strDepartmentDescription 
                             ELSE 
                                 CASE WHEN ISNULL(cfCardDepartment.intDepartmentId, 0) >= 1 
									  THEN cfCardDepartment.strDepartmentDescription 
									  ELSE 'Unknown' 
                                 END 
                             END 
                        ELSE 'Unknown' 
                    END)

,intOdometerAging = cfOdom.intOdometer

,dblTotalMiles = (	CASE 
						WHEN  ISNULL (cfOdom.intOdometer, 0)   > 0 
						THEN cfTrans.intOdometer -	ISNULL (cfOdom.intOdometer, 0) 
						ELSE 0 
					END)       

,strCompanyName				= smCompSetup.strCompanyName
,strCompanyAddress			= smCompSetup.strCompanyAddress
,dblTotalTax				= cfTransTotalTax.dblTotalTax
,dblTotalSST				= cfTransSSTTax.dblTotalTax
,dblTaxExceptSST			= cfTransExceptSSTTax.dblTotalTax
,strEmailDistributionOption = arCustomerContact.strEmailDistributionOption
,strEmail					= arCustomerContact.strEmail

--SPECIAL CASE--------------------------------

FROM   dbo.tblCFTransaction AS cfTrans 
-----------------------------------------------------------
LEFT JOIN dbo.vyuCFInvoice AS arInv  
    ON arInv.intTransactionId = cfTrans.intTransactionId 
    AND arInv.intInvoiceId = cfTrans.intInvoiceId 
-------------------------------------------------------------
INNER JOIN tblCFAccount AS cfAccount
	ON cfAccount.intCustomerId = cfTrans.intCustomerId
-------------------------------------------------------------
INNER JOIN vyuCFCustomerEntity AS emEntity 
	ON emEntity.intEntityId = cfTrans.intCustomerId
-------------------------------------------------------------
INNER JOIN tblCFNetwork AS cfNetwork
	ON cfNetwork.intNetworkId = cfTrans.intNetworkId
-------------------------------------------------------------
LEFT JOIN (
	SELECT arCustGroupDetail.intCustomerGroupDetailId, 
			arCustGroupDetail.intCustomerGroupId, 
			arCustGroupDetail.intEntityId, 
			arCustGroupDetail.ysnSpecialPricing, 
			arCustGroupDetail.ysnContract, 
			arCustGroupDetail.ysnBuyback, 
			arCustGroupDetail.ysnQuote, 
			arCustGroupDetail.ysnVolumeDiscount, 
			arCustGroupDetail.intConcurrencyId, 
			arCustGroup.strGroupName 
	FROM   dbo.tblARCustomerGroup AS arCustGroup 
	INNER JOIN dbo.tblARCustomerGroupDetail AS arCustGroupDetail 
	ON arCustGroup.intCustomerGroupId = arCustGroupDetail.intCustomerGroupId
) AS emGroup 
	ON emGroup.intEntityId = cfTrans.intCustomerId AND emGroup.ysnVolumeDiscount = 1 
-------------------------------------------------------------
LEFT JOIN tblCFInvoiceCycle AS cfInvCycle 
	ON cfAccount.intInvoiceCycle = cfInvCycle.intInvoiceCycleId 
-------------------------------------------------------------
LEFT JOIN tblCFCard AS cfCard 
	ON cfCard.intCardId = cfTrans.intCardId 
-------------------------------------------------------------
LEFT JOIN tblCFVehicle AS cfVehicle 
	ON cfVehicle.intVehicleId = cfTrans.intVehicleId 
-------------------------------------------------------------
LEFT JOIN tblCFDepartment AS cfCardDepartment
	ON cfCardDepartment.intDepartmentId = cfCard.intDepartmentId
-------------------------------------------------------------
LEFT JOIN tblCFDepartment AS cfVehicleDepartment
	ON cfVehicleDepartment.intDepartmentId = cfVehicle.intDepartmentId
-------------------------------------------------------------
LEFT JOIN tblCFSite AS cfSite
	ON cfSite.intSiteId = cfTrans.intSiteId
-------------------------------------------------------------
LEFT JOIN tblCFItem AS cfItem
	ON cfItem.intItemId = cfTrans.intProductId
-------------------------------------------------------------
LEFT JOIN tblICItem AS icItem
	ON cfItem.intARItemId = icItem.intItemId
-------------------------------------------------------------
OUTER APPLY (
	SELECT TOP (1) intOdometer 
		  FROM   dbo.tblCFTransaction 
		  WHERE  ( dtmTransactionDate < cfTrans.dtmTransactionDate ) 
				  AND ( intCardId = cfTrans.intCardId ) 
			  AND ( intVehicleId = cfTrans.intVehicleId ) 
			  AND ( intProductId = cfTrans.intProductId ) 
		  ORDER  BY dtmTransactionDate DESC
) AS cfOdom
-------------------------------------------------------------
OUTER APPLY (
	SELECT TOP 1 
		strCompanyName 
		,strCompanyAddress = [dbo].fnARFormatCustomerAddress(NULL, NULL, NULL, strAddress, strCity, strState, strZip, strCountry, NULL, 0)
	FROM tblSMCompanySetup
) AS smCompSetup
-------------------------------------------------------------
OUTER APPLY (
SELECT 
	 dblTotalTax = ISNULL(Sum(dblTaxCalculatedAmount),0) / cfTrans.dblQuantity
FROM   dbo.tblCFTransactionTax 
WHERE  intTransactionId = cfTrans.intTransactionId         
) AS cfTransTotalTax
-------------------------------------------------------------
OUTER APPLY (
SELECT 
	 dblTotalTax = ISNULL(Sum(cfTT.dblTaxCalculatedAmount),0) / cfTrans.dblQuantity
FROM   dbo.tblCFTransactionTax AS cfTT
INNER JOIN dbo.tblSMTaxCode AS smTCd 
ON cfTT.intTaxCodeId = smTCd.intTaxCodeId 
INNER JOIN dbo.tblSMTaxClass AS smTCl 
ON smTCd.intTaxClassId = smTCl.intTaxClassId 
WHERE  intTransactionId = cfTrans.intTransactionId   
AND smTCl.strTaxClass = 'SST' 
GROUP  BY cfTT.intTransactionId      
) AS cfTransSSTTax
-------------------------------------------------------------
OUTER APPLY (
SELECT 
	 dblTotalTax = ISNULL(Sum(cfTT.dblTaxCalculatedAmount),0) / cfTrans.dblQuantity
FROM   dbo.tblCFTransactionTax AS cfTT
INNER JOIN dbo.tblSMTaxCode AS smTCd 
ON cfTT.intTaxCodeId = smTCd.intTaxCodeId 
INNER JOIN dbo.tblSMTaxClass AS smTCl 
ON smTCd.intTaxClassId = smTCl.intTaxClassId 
WHERE  intTransactionId = cfTrans.intTransactionId   
AND smTCl.strTaxClass != 'SST' 
GROUP  BY cfTT.intTransactionId      
) AS cfTransExceptSSTTax
-------------------------------------------------------------
OUTER APPLY (
	SELECT TOP 1 
		 strEmailDistributionOption
		,strEmail 
	FROM vyuARCustomerContacts
	WHERE intEntityId = cfTrans.intCustomerId  AND strEmailDistributionOption LIKE '%CF Invoice%' AND ISNULL(strEmail,'') != ''
) AS arCustomerContact
-------------------------------------------------------------
WHERE ISNULL(cfTrans.ysnPosted,0) = 1 
AND ISNULL(cfTrans.ysnInvalid,0) = 0
GO


