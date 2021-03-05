

CREATE VIEW [dbo].[vyuCFInvoiceReport]
AS


SELECT 
--count(*),
----------------------------------------------
 cfTrans.intCustomerId
 ,cfTrans.intTransactionId
 ,cfTrans.dtmTransactionDate
 ,cfTrans.dtmBillingDate
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
 ,cfTrans.ysnExpensed
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
,cfAccount.ysnSummaryByDepartmentProduct
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
,cfAccount.ysnSummaryByDriverPin
,cfAccount.strDetailDisplay
,cfAccount.ysnShowVehicleDescriptionOnly	
,cfAccount.ysnShowDriverPinDescriptionOnly
,cfAccount.ysnPageBreakByPrimarySortOrder
,cfAccount.ysnSummaryByDeptDriverPinProd
,cfAccount.strDepartmentGrouping
----------------------------------------------
,strCustomerName = emEntity.strName
,emEntity.strName
,emEntity.strCustomerNumber
----------------------------------------------
,strBillTo =  dbo.fnARFormatCustomerAddress (
				 NULL
				,NULL
				,NULL
				,emEntity.strBillToAddress
				,emEntity.strBillToCity
				,emEntity.strBillToState
				,emEntity.strBillToZipCode
				,emEntity.strBillToCountry
				,emEntity.strName
				,1)
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
,cfItem.ysnMPGCalculation
----------------------------------------------
,icItem.strItemNo
,icItem.strShortName AS strDescription
----------------------------------------------
,cfVehicle.strVehicleNumber
,cfVehicle.strVehicleDescription
,cfVehicle.intVehicleId
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
						WHEN cfAccount.strPrimaryDepartment = 'Driver Pin' 
						THEN 
                        CASE WHEN ISNULL(cfDriverPinDepartment.intDepartmentId, 0) >= 1 
							 THEN cfDriverPinDepartment.strDepartment 
                             ELSE 
                                 CASE WHEN ISNULL(cfVehicleDepartment.intDepartmentId, 0) >= 1 
									  THEN cfVehicleDepartment.strDepartment 
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
						WHEN cfAccount.strPrimaryDepartment = 'Driver Pin' 
						THEN 
                        CASE WHEN ISNULL(cfDriverPinDepartment.intDepartmentId, 0) >= 1 
							 THEN cfDriverPinDepartment.strDepartmentDescription 
                             ELSE 
                                 CASE WHEN ISNULL(cfVehicleDepartment.intDepartmentId, 0) >= 1 
									  THEN cfVehicleDepartment.strDepartmentDescription 
									  ELSE 'Unknown' 
                                 END 
                        END 
                        ELSE 'Unknown' 
                    END)

,intOdometerAging = 0 
					--MOVED TO INSERT PART OF uspCFInsertToStagingTable--
					--(CASE 
					--	WHEN cfAccount.strPrimarySortOptions = 'Card' 
					--	THEN cfCardOdom.intOdometer
     --                   WHEN cfAccount.strPrimarySortOptions = 'Vehicle' 
					--		THEN 
					--			CASE 
					--			WHEN ISNULL(cfVehicle.intVehicleId, 0) =  0
					--				THEN cfCardOdom.intOdometer
					--			ELSE cfVehicleOdom.intOdometer
					--			END
					--	 WHEN cfAccount.strPrimarySortOptions = 'Miscellaneous' 
					--		THEN 
					--			CASE 
					--			WHEN ISNULL(strMiscellaneous, '') =  ''
					--				THEN cfCardOdom.intOdometer
					--			ELSE cfMiscOdom.intOdometer
					--			END
					--	ELSE 0
					--END)
					--MOVED TO INSERT PART OF uspCFInsertToStagingTable--

--,cfMiscOdom.intOdometer as x
,dblTotalMiles = 0
					--MOVED TO INSERT PART OF uspCFInsertToStagingTable--
					--(CASE 
					--	WHEN cfAccount.strPrimarySortOptions = 'Card' 
					--	THEN
					--		CASE
					--			WHEN  ISNULL (cfCardOdom.intOdometer, 0)   > 0 
					--			THEN cfTrans.intOdometer -	ISNULL (cfCardOdom.intOdometer, 0) 
					--			ELSE 0 
					--		END
     --                   WHEN cfAccount.strPrimarySortOptions = 'Vehicle' 
					--		THEN 
					--			CASE 
					--				WHEN ISNULL(cfVehicle.intVehicleId, 0) =  0
					--				THEN 
					--					CASE WHEN ISNULL(cfCardType.ysnDualCard, 0) =  0
					--						THEN 
					--							CASE
					--								WHEN  ISNULL (cfCardOdom.intOdometer, 0)   > 0 
					--								THEN cfTrans.intOdometer -	ISNULL (cfCardOdom.intOdometer, 0) 
					--								ELSE 0 
					--							END
					--						ELSE 0
					--					END
					--				ELSE 
					--					CASE
					--						WHEN  ISNULL (cfVehicleOdom.intOdometer, 0)   > 0 
					--						THEN cfTrans.intOdometer -	ISNULL (cfVehicleOdom.intOdometer, 0) 
					--						ELSE 0 
					--					END
					--			END
					--	ELSE 0
					--END)
					--MOVED TO INSERT PART OF uspCFInsertToStagingTable--

,strCompanyName				= smCompSetup.strCompanyName
,strCompanyAddress			= smCompSetup.strCompanyAddress
,dblTotalTax				= cfTransTotalTax.dblTotalTax
,dblTotalSST				= cfTransSSTTax.dblTotalTax
,dblTaxExceptSST			= cfTransExceptSSTTax.dblTotalTax
--,strEmailDistributionOption = arCustomerContact.strEmailDistributionOption
,strEmail					= arCustomerContact.strEmail
--,strDocumentDelivery		= emEntity.strDocumentDelivery
,strEmailDistributionOption = 
	(SELECT (CASE 
		WHEN (LOWER(emEntity.strDocumentDelivery) like '%direct mail%' AND LOWER(ISNULL(arCustomerContact.strEmailDistributionOption,'')) like '%cf invoice%')
			THEN 'print , email , CF Invoice'

		WHEN (LOWER(emEntity.strDocumentDelivery) like '%email%' AND LOWER(ISNULL(arCustomerContact.strEmailDistributionOption,'')) like '%cf invoice%')
			THEN 'email , CF Invoice'

		WHEN ( (LOWER(emEntity.strDocumentDelivery) not like '%email%' OR  LOWER(emEntity.strDocumentDelivery) not like '%direct mail%') AND LOWER(ISNULL(arCustomerContact.strEmailDistributionOption,'')) like '%cf invoice%')
			THEN 'email , CF Invoice'

		WHEN ( LOWER(emEntity.strDocumentDelivery) like '%direct mail%' AND LOWER(ISNULL(arCustomerContact.strEmailDistributionOption,'')) not like '%cf invoice%')
			THEN 'print'

		WHEN ( LOWER(emEntity.strDocumentDelivery) like '%email%' AND LOWER(ISNULL(arCustomerContact.strEmailDistributionOption,'')) not like '%cf invoice%')
			THEN 'print'

		WHEN (  (LOWER(emEntity.strDocumentDelivery) not like '%email%' OR  LOWER(emEntity.strDocumentDelivery) not like '%direct mail%') AND LOWER(ISNULL(arCustomerContact.strEmailDistributionOption,'')) not like '%cf invoice%')
			THEN 'print'
	END))
,cfDriverPin.strDriverPinNumber
,cfDriverPin.strDriverDescription
,cfDriverPin.intDriverPinId

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
LEFT JOIN tblCFCardType AS cfCardType
	ON cfCard.intCardTypeId = cfCardType.intCardTypeId
-------------------------------------------------------------
LEFT JOIN tblCFDriverPin AS cfDriverPin 
	ON cfDriverPin.intDriverPinId = cfTrans.intDriverPinId 
-------------------------------------------------------------
LEFT JOIN tblCFVehicle AS cfVehicle 
	ON cfVehicle.intVehicleId = cfTrans.intVehicleId 
-------------------------------------------------------------
LEFT JOIN tblCFDepartment AS cfCardDepartment
	ON cfCardDepartment.intDepartmentId = cfCard.intDepartmentId
-------------------------------------------------------------
LEFT JOIN tblCFDepartment AS cfDriverPinDepartment
	ON cfDriverPinDepartment.intDepartmentId = cfDriverPin.intDepartmentId
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

--MOVED TO INSERT PART OF uspCFInsertToStagingTable--
-------------------------------------------------------------
--OUTER APPLY (
--	SELECT TOP (1) intOdometer 
--		  FROM   dbo.tblCFTransaction as iocftran
--		  LEFT JOIN tblCFItem as iocfitem
--		  ON iocftran.intProductId = iocfitem.intItemId
--		  WHERE ISNULL(iocfitem.ysnMPGCalculation,0) = 1 
--		  AND ( dtmTransactionDate < cfTrans.dtmTransactionDate ) 
--		  AND ( intCardId = cfTrans.intCardId ) 
--		  AND (ISNULL(iocftran.ysnPosted,0) = 1) 
--		  ORDER  BY dtmTransactionDate DESC
--) AS cfCardOdom
-------------------------------------------------------------
--OUTER APPLY (
--	SELECT TOP (1) intOdometer 
--		  FROM   dbo.tblCFTransaction as iocftran
--		  LEFT JOIN tblCFItem as iocfitem
--		  ON iocftran.intProductId = iocfitem.intItemId
--		  WHERE ISNULL(iocfitem.ysnMPGCalculation,0) = 1 
--		  AND ( dtmTransactionDate < cfTrans.dtmTransactionDate ) 
--		  AND ( intVehicleId = cfTrans.intVehicleId ) 
--		  AND (ISNULL(iocftran.ysnPosted,0) = 1) 
--		  ORDER  BY dtmTransactionDate DESC
--) AS cfVehicleOdom
-------------------------------------------------------------
--OUTER APPLY (
--	SELECT TOP 1 intOdometer FROM (
--		SELECT iocftran.*  
--			FROM   dbo.tblCFTransaction as iocftran
--			LEFT JOIN tblCFItem as iocfitem
--			ON iocftran.intProductId = iocfitem.intItemId
--			WHERE ISNULL(iocfitem.ysnMPGCalculation,0) = 1 
--			AND strMiscellaneous IS NOT NULL
--			AND strMiscellaneous != ''
--		) as miscBase
--	WHERE  (dtmTransactionDate < cfTrans.dtmTransactionDate ) 
--	AND ( strMiscellaneous = cfTrans.strMiscellaneous ) 
--	ORDER  BY dtmTransactionDate DESC
--) AS cfMiscOdom
-------------------------------------------------------------
--MOVED TO INSERT PART OF uspCFInsertToStagingTable--

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
AND LOWER(smTCl.strTaxClass) like '%sst%' 
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
AND LOWER(smTCl.strTaxClass) not like '%sst%' 
GROUP  BY cfTT.intTransactionId      
) AS cfTransExceptSSTTax
-------------------------------------------------------------
OUTER APPLY (
	SELECT TOP 1 
		 strEmailDistributionOption
		,strEmail 
	FROM vyuARCustomerContacts
	WHERE intEntityId = cfTrans.intCustomerId  AND strEmailDistributionOption LIKE '%CF Invoice%' AND ISNULL(strEmail,'') != '' AND ISNULL(ysnActive,0) = 1
) AS arCustomerContact
-------------------------------------------------------------
WHERE (ysnPosted = 1 AND ysnPosted IS NOT NULL) 
AND (ysnInvalid = 0 OR ysnInvoiced IS NULL) 
AND cfTrans.intTransactionId NOT IN (
			SELECT tblCFTransaction.intTransactionId FROM tblCFTransaction
			INNER JOIN tblCFNetwork ON tblCFTransaction.intNetworkId = tblCFNetwork.intNetworkId
			 where strTransactionType = 'Foreign Sale' and (tblCFNetwork.ysnPostForeignSales = 0 OR tblCFNetwork.ysnPostForeignSales IS NULL))

GO


