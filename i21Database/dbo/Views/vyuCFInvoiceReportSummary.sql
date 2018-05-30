

CREATE VIEW [dbo].[vyuCFInvoiceReportSummary]
AS



SELECT 
--count(*),
 cfTrans.intCustomerId
,cfTrans.strMiscellaneous
,cfTrans.dtmTransactionDate
,cfTrans.intOdometer
,cfTrans.strTransactionId
,cfTrans.intCardId
,cfTrans.intProductId
,cfTrans.intARItemId
,cfTrans.intTransactionId
,cfTrans.strPrintTimeStamp
,cfTrans.ysnPostedCSV
,cfTrans.ysnInvoiced
,dblTotalQuantity = ISNULL(cfTrans.dblQuantity, 0)
,dblTotalGrossAmount = ISNULL(cfTrans.dblCalculatedGrossPrice, 0)
,dblTotalNetAmount = ISNULL(Round(cfTrans.dblCalculatedTotalPrice, 2), 0) -     ( ISNULL(FETTaxes_1.dblTaxCalculatedAmount, 0) 
																				+ ISNULL(SETTaxes_1.dblTaxCalculatedAmount, 0) 
																				+ ISNULL(SSTTaxes_1.dblTaxCalculatedAmount, 0) 
																				+ ISNULL(LCTaxes_1.dblTaxCalculatedAmount, 0) ) 
,dblTotalAmount = ISNULL(Round(cfTrans.dblCalculatedTotalPrice, 2), 0)
,dblTotalTaxAmount = ISNULL(FETTaxes_1.dblTaxCalculatedAmount, 0) 
					+ ISNULL(SETTaxes_1.dblTaxCalculatedAmount, 0) 
					+ ISNULL(SSTTaxes_1.dblTaxCalculatedAmount, 0) 
					+ ISNULL(LCTaxes_1.dblTaxCalculatedAmount, 0)

,dtmCreatedDate = Dateadd(dd, Datediff(dd, 0, cfTrans.dtmCreatedDate), 0)   
,dtmInvoiceDate = Dateadd(dd, Datediff(dd, 0, cfTrans.dtmInvoiceDate), 0) 
,strUpdateInvoiceReportNumber = cfTrans.strInvoiceReportNumber
,dtmPostedDate = cfTrans.dtmPostedDate
,strInvoiceReportNumber =cfTrans.strTempInvoiceReportNumber 
----------------------------------------------
,cfAccount.intAccountId
,cfAccount.intDiscountScheduleId
,cfAccount.intTermsCode
----------------------------------------------
,strCustomerName = emEntity.strName
,emEntity.strName
,emEntity.strCustomerNumber
,emEntity.intTermsId
----------------------------------------------
,arInv.strBillTo
----------------------------------------------
,cfCard.strCardNumber
,cfCard.strCardDescription
----------------------------------------------
,cfVehicle.strVehicleNumber
,cfVehicle.strVehicleDescription
----------------------------------------------
,icItem.strShortName
,strItemNumber		= icItem.strItemNo
,strItemDescription = icItem.strDescription
----------------------------------------------
,cfNetwork.strNetwork
----------------------------------------------
,cfItem.strProductNumber
,cfItem.strProductDescription
,ysnIncludeInQuantityDiscount = cfItem.ysnIncludeInQuantityDiscount
----------------------------------------------
,cfSite.strSiteNumber
,strSiteAddress = cfSite.strSiteAddress + ', ' + cfSite.strSiteCity + ', ' + cfSite.strTaxState
,cfSite.strTaxState
----------------------------------------------
,cfInvCycle.strInvoiceCycle
----------------------------------------------
,TotalFET=ISNULL(FETTaxes_1.dblTaxCalculatedAmount, 0)         
,TotalSET=ISNULL(SETTaxes_1.dblTaxCalculatedAmount, 0)         
,TotalSST=ISNULL(SSTTaxes_1.dblTaxCalculatedAmount, 0)         
,TotalLC =ISNULL(LCTaxes_1.dblTaxCalculatedAmount, 0)          

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

,strEmailDistributionOption = arCustomerContact.strEmailDistributionOption
,strEmail					= arCustomerContact.strEmail
-----------------------------------------------------------
FROM   dbo.tblCFTransaction AS cfTrans 
-----------------------------------------------------------
LEFT JOIN dbo.vyuCFInvoice AS arInv  
    ON arInv.intTransactionId = cfTrans.intTransactionId 
    AND arInv.intInvoiceId = cfTrans.intInvoiceId 
-------------------------------------------------------------
INNER JOIN tblCFAccount AS cfAccount
	ON cfAccount.intCustomerId = cfTrans.intCustomerId
-------------------------------------------------------------
INNER JOIN tblCFNetwork AS cfNetwork
	ON cfNetwork.intNetworkId = cfTrans.intNetworkId
-------------------------------------------------------------
INNER JOIN vyuCFCustomerEntity AS emEntity 
	ON emEntity.intEntityId = cfTrans.intCustomerId
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
LEFT JOIN tblCFItem AS cfItem
	ON cfItem.intItemId = cfTrans.intProductId
-------------------------------------------------------------
LEFT JOIN tblICItem AS icItem
	ON cfItem.intARItemId = icItem.intItemId
-------------------------------------------------------------
LEFT JOIN tblCFSite AS cfSite
	ON cfSite.intSiteId = cfTrans.intSiteId
-------------------------------------------------------------
LEFT JOIN tblCFInvoiceCycle AS cfInvCycle 
	ON cfAccount.intInvoiceCycle = cfInvCycle.intInvoiceCycleId 
-------------------------------------------------------------
OUTER APPLY (
	SELECT TOP 1 
		 strEmailDistributionOption
		,strEmail 
	FROM vyuARCustomerContacts
	WHERE intEntityId = cfTrans.intCustomerId  AND strEmailDistributionOption LIKE '%CF Invoice%' AND ISNULL(strEmail,'') != ''
) AS arCustomerContact
-------------------------------------------------------------
LEFT OUTER JOIN (
	SELECT intTransactionId, 
        ISNULL(Sum(dblTaxOriginalAmount), 0)   AS dblTaxOriginalAmount, 
        ISNULL(Sum(dblTaxCalculatedAmount), 0) AS dblTaxCalculatedAmount, 
        ISNULL(Sum(dblTaxRate), 0)             AS dblTaxRate 
        FROM   dbo.vyuCFTransactionTax AS FETTaxes 
        WHERE  ( strTaxClass LIKE '%(FET)%' ) 
        GROUP  BY intTransactionId) AS FETTaxes_1 
	ON cfTrans.intTransactionId = FETTaxes_1.intTransactionId 
-------------------------------------------------------------
LEFT OUTER JOIN (
	SELECT intTransactionId, 
		ISNULL(Sum(dblTaxOriginalAmount), 0)   AS dblTaxOriginalAmount, 
        ISNULL(Sum(dblTaxCalculatedAmount), 0) AS dblTaxCalculatedAmount, 
        ISNULL(Sum(dblTaxRate), 0)             AS dblTaxRate 
        FROM   dbo.vyuCFTransactionTax AS SETTaxes 
        WHERE  ( strTaxClass LIKE '%(SET)%' ) 
        GROUP  BY intTransactionId) AS SETTaxes_1 
    ON cfTrans.intTransactionId = SETTaxes_1.intTransactionId 
-------------------------------------------------------------
LEFT OUTER JOIN (
	SELECT intTransactionId, 
		ISNULL(Sum(dblTaxOriginalAmount), 0)   AS dblTaxOriginalAmount, 
		ISNULL(Sum(dblTaxCalculatedAmount), 0) AS dblTaxCalculatedAmount, 
		ISNULL(Sum(dblTaxRate), 0)             AS dblTaxRate 
		FROM   dbo.vyuCFTransactionTax AS SSTTaxes 
		WHERE  ( strTaxClass LIKE '%(SST)%' ) 
		GROUP  BY intTransactionId) AS SSTTaxes_1 
	ON cfTrans.intTransactionId = SSTTaxes_1.intTransactionId 
-------------------------------------------------------------
LEFT OUTER JOIN (
	SELECT intTransactionId, 
		ISNULL(Sum(dblTaxOriginalAmount), 0)   AS dblTaxOriginalAmount, 
		ISNULL(Sum(dblTaxCalculatedAmount), 0) AS dblTaxCalculatedAmount, 
		ISNULL(Sum(dblTaxRate), 0)             AS dblTaxRate 
		FROM   dbo.vyuCFTransactionTax AS LCTaxes 
		WHERE  ( strTaxClass NOT LIKE '%(SET)%' ) 
		AND ( strTaxClass <> 'SET' ) 
		AND ( strTaxClass NOT LIKE '%(FET)%' ) 
		AND ( strTaxClass <> 'FET' ) 
		AND ( strTaxClass NOT LIKE '%(SST)%' ) 
		AND ( strTaxClass <> 'SST' ) 
		GROUP  BY intTransactionId) AS LCTaxes_1 
	ON cfTrans.intTransactionId = LCTaxes_1.intTransactionId 
-------------------------------------------------------------
LEFT OUTER JOIN (
	SELECT intTransactionId, 
		ISNULL(Sum(dblTaxOriginalAmount), 0)   AS dblTaxOriginalAmount, 
		ISNULL(Sum(dblTaxCalculatedAmount), 0) AS dblTaxCalculatedAmount, 
		ISNULL(Sum(dblTaxRate), 0)             AS dblTaxRate 
		FROM   dbo.vyuCFTransactionTax AS TotalTaxes 
		GROUP  BY intTransactionId) AS TotalTaxes_1 
	ON cfTrans.intTransactionId = TotalTaxes_1.intTransactionId
-------------------------------------------------------------
WHERE ISNULL(cfTrans.ysnPosted,0) = 1 
AND ISNULL(cfTrans.ysnInvalid,0) = 0

GO


