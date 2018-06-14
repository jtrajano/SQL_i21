

CREATE VIEW [dbo].[vyuCFInvoiceReport]
AS

SELECT intCustomerId = ( CASE cfTrans.strTransactionType 
                           WHEN 'Foreign Sale' THEN cfSiteItem.intCustomerId 
                           ELSE cfCardAccount.intCustomerId 
                         END ), 
       intAccountId = ( CASE cfTrans.strTransactionType 
                          WHEN 'Foreign Sale' THEN cfSiteItem.intAccountId 
                          ELSE cfCardAccount.intAccountId 
                        END ), 
       strCustomerName = ( CASE cfTrans.strTransactionType 
                             WHEN 'Foreign Sale' THEN cfSiteItem.strName 
                             ELSE cfCardAccount.strName 
                           END ), 
       strCustomerNumber = ( CASE cfTrans.strTransactionType 
                               WHEN 'Foreign Sale' THEN cfSiteItem.strEntityNo 
                               ELSE cfCardAccount.strCustomerNumber 
                             END ), 
       strBillTo = ( CASE cfTrans.strTransactionType 
                       WHEN 'Foreign Sale' THEN cfSiteItem.strBillTo 
                       ELSE 
							CASE cfTrans.ysnPostedCSV 
								WHEN 1 
								THEN 
									dbo.fnARFormatCustomerAddress(NULL, NULL, BILLTO.strLocationName, BILLTO.strAddress, BILLTO.strCity, BILLTO.strState, BILLTO.strZipCode, BILLTO.strCountry, cfCardAccount.strName, NULL)
									--dbo.fnARFormatCustomerAddress(NULL, NULL, INV.strBillToLocationName, INV.strBillToAddress, INV.strBillToCity, INV.strBillToState, INV.strBillToZipCode, INV.strBillToCountry, E.strName, 0)
							ELSE 
								arInv.strBillTo 
							END
                     END ), 
       cfSiteItem.strNetwork, 
       ISNULL(emGroup.intCustomerGroupId, 0)                           AS 
       intCustomerGroupId, 
       intInvoiceCycle = ( CASE cfTrans.strTransactionType 
                             WHEN 'Foreign Sale' THEN cfSiteItem.intInvoiceCycle 
                             ELSE cfCardAccount.intInvoiceCycle 
                           END ), 
       strInvoiceCycle = ( CASE cfTrans.strTransactionType 
                             WHEN 'Foreign Sale' THEN cfSiteItem.strInvoiceCycle 
                             ELSE cfCardAccount.strInvoiceCycle 
                           END ), 
       strPrimarySortOptions = ( CASE cfTrans.strTransactionType 
                                   WHEN 'Foreign Sale' THEN 
                                   cfSiteItem.strPrimarySortOptions 
                                   ELSE cfCardAccount.strPrimarySortOptions 
                                 END ), 
       strSecondarySortOptions = ( CASE cfTrans.strTransactionType 
                                     WHEN 'Foreign Sale' THEN 
                                     cfSiteItem.strSecondarySortOptions 
                                     ELSE cfCardAccount.strSecondarySortOptions 
                                   END ), 
       strPrintRemittancePage = ( CASE cfTrans.strTransactionType 
                                    WHEN 'Foreign Sale' THEN 
                                    cfSiteItem.strPrintRemittancePage 
                                    ELSE cfCardAccount.strPrintRemittancePage 
                                  END ), 
       strPrintPricePerGallon = ( CASE cfTrans.strTransactionType 
                                    WHEN 'Foreign Sale' THEN 
                                    cfSiteItem.strPrintPricePerGallon 
                                    ELSE cfCardAccount.strPrintPricePerGallon 
                                  END ), 
       ysnPrintMiscellaneous = ( CASE cfTrans.strTransactionType 
                                   WHEN 'Foreign Sale' THEN 
                                   cfSiteItem.ysnPrintMiscellaneous 
                                   ELSE cfCardAccount.ysnPrintMiscellaneous 
                                 END ), 
       strPrintSiteAddress = ( CASE cfTrans.strTransactionType 
                                 WHEN 'Foreign Sale' THEN 
                                 cfSiteItem.strPrintSiteAddress 
                                 ELSE cfCardAccount.strPrintSiteAddress 
                               END ), 
       ysnSummaryByCard = ( CASE cfTrans.strTransactionType 
                              WHEN 'Foreign Sale' THEN 
                              cfSiteItem.ysnSummaryByCard 
                              ELSE cfCardAccount.ysnSummaryByCard 
                            END ), 
       ysnSummaryByDepartment = ( CASE cfTrans.strTransactionType 
                                    WHEN 'Foreign Sale' THEN 
                                    cfSiteItem.ysnSummaryByDepartment 
                                    ELSE cfCardAccount.ysnSummaryByDepartment 
                                  END ), 
       ysnSummaryByMiscellaneous = ( CASE cfTrans.strTransactionType 
                                       WHEN 'Foreign Sale' THEN 
                                       cfSiteItem.ysnSummaryByMiscellaneous 
                                       ELSE 
       cfCardAccount.ysnSummaryByMiscellaneous 
                                     END ), 
       ysnSummaryByProduct = ( CASE cfTrans.strTransactionType 
                                 WHEN 'Foreign Sale' THEN 
                                 cfSiteItem.ysnSummaryByProduct 
                                 ELSE cfCardAccount.ysnSummaryByProduct 
                               END ), 
       ysnSummaryByVehicle = ( CASE cfTrans.strTransactionType 
                                 WHEN 'Foreign Sale' THEN 
                                 cfSiteItem.ysnSummaryByVehicle 
                                 ELSE cfCardAccount.ysnSummaryByVehicle 
                               END ), 
       ysnSummaryByCardProd = ( CASE cfTrans.strTransactionType 
                                  WHEN 'Foreign Sale' THEN 
                                  cfSiteItem.ysnSummaryByCardProd 
                                  ELSE cfCardAccount.ysnSummaryByCardProd 
                                END ), 
       ysnSummaryByDeptCardProd = ( CASE cfTrans.strTransactionType 
                                      WHEN 'Foreign Sale' THEN 
                                      cfSiteItem.ysnSummaryByDeptCardProd 
                                      ELSE 
       cfCardAccount.ysnSummaryByDeptCardProd 
                                    END ), 
       ysnPrintTimeOnInvoices = ( CASE cfTrans.strTransactionType 
                                    WHEN 'Foreign Sale' THEN 
                                    cfSiteItem.ysnPrintTimeOnInvoices 
                                    ELSE cfCardAccount.ysnPrintTimeOnInvoices 
                                  END ), 
       ysnPrintTimeOnReports = ( CASE cfTrans.strTransactionType 
                                   WHEN 'Foreign Sale' THEN 
                                   cfSiteItem.ysnPrintTimeOnReports 
                                   ELSE cfCardAccount.ysnPrintTimeOnReports 
                                 END ), 
       ysnSummaryByDeptVehicleProd = ( CASE cfTrans.strTransactionType 
                                         WHEN 'Foreign Sale' THEN 
                                         cfSiteItem.ysnSummaryByDeptVehicleProd 
                                         ELSE 
       cfCardAccount.ysnSummaryByDeptVehicleProd 
                                       END ), 
       strPrimaryDepartment = ( CASE cfTrans.strTransactionType 
                                  WHEN 'Foreign Sale' THEN 
                                  cfSiteItem.strPrimaryDepartment 
                                  ELSE cfCardAccount.strPrimaryDepartment 
                                END ), 
       ysnDepartmentGrouping = ( CASE cfTrans.strTransactionType 
                                   WHEN 'Foreign Sale' THEN 
                                   cfSiteItem.ysnDepartmentGrouping 
                                   ELSE cfCardAccount.ysnDepartmentGrouping 
                                 END ), 
       strDepartment = ( CASE 
                           WHEN cfCardAccount.strPrimaryDepartment = 'Card' THEN 
                             CASE 
                               WHEN ISNULL(cfCardAccount.intDepartmentId, 0) >= 
                                    1 THEN 
                               cfCardAccount.strDepartment 
                               ELSE 
                                 CASE 
                                   WHEN ISNULL(cfVehicle.intDepartmentId, 0) >= 
                                        1 THEN 
                                   cfVehicle.strDepartment 
                                   ELSE 'Unknown' 
                                 END 
                             END 
                           WHEN cfCardAccount.strPrimaryDepartment = 'Vehicle' 
                         THEN 
                             CASE 
                               WHEN ISNULL(cfVehicle.intDepartmentId, 0) >= 1 
                             THEN 
                               cfVehicle.strDepartment 
                               ELSE 
                                 CASE 
                                   WHEN ISNULL(cfCardAccount.intDepartmentId, 0) 
                                        >= 1 
                                 THEN 
                                   cfCardAccount.strDepartment 
                                   ELSE 'Unknown' 
                                 END 
                             END 
                           ELSE 'Unknown' 
                         END ), 
       strDepartmentDescription = ( CASE 
                                      WHEN cfCardAccount.strPrimaryDepartment = 
                                           'Card' 
                                    THEN 
                                        CASE 
                                          WHEN ISNULL( 
                                          cfCardAccount.intDepartmentId, 0) 
                                               >= 1 THEN 
                                          cfCardAccount.strDepartmentDescription 
                                          ELSE 
                                            CASE 
                                              WHEN ISNULL( 
                                              cfVehicle.intDepartmentId, 0) 
                                                   >= 1 THEN 
                                              cfVehicle.strDepartmentDescription 
                                              ELSE 'Unknown' 
                                            END 
                                        END 
                                      WHEN cfCardAccount.strPrimaryDepartment = 
                                           'Vehicle' THEN 
                                        CASE 
                                          WHEN 
                                    ISNULL(cfVehicle.intDepartmentId, 0) >= 
                                    1 THEN 
                                          cfVehicle.strDepartmentDescription 
                                          ELSE 
                                            CASE 
                                              WHEN 
                                        ISNULL(cfCardAccount.intDepartmentId, 0) 
                                        >= 1 
                                            THEN 
cfCardAccount.strDepartmentDescription 
ELSE 'Unknown' 
END 
END 
ELSE 'Unknown' 
END ), 
emGroup.strGroupName, 
cfTrans.intTransactionId, 
cfTrans.dtmTransactionDate, 
Dateadd(dd, Datediff(dd, 0, cfTrans.dtmInvoiceDate), 0)         AS 
       dtmInvoiceDate, 
cfTrans.intOdometer, 
ISNULL ((SELECT TOP (1) intOdometer 
FROM   dbo.tblCFTransaction 
WHERE  ( dtmTransactionDate < cfTrans.dtmTransactionDate ) 
AND ( intCardId = cfTrans.intCardId ) 
AND ( intVehicleId = cfTrans.intVehicleId ) 
AND ( intProductId = cfTrans.intProductId ) 
ORDER  BY dtmTransactionDate DESC), 0)                 AS intOdometerAging, 
( CASE 
WHEN ( ISNULL ((SELECT TOP (1) intOdometer 
FROM   dbo.tblCFTransaction AS tblCFTransaction_1 
WHERE  ( dtmTransactionDate < cfTrans.dtmTransactionDate ) 
AND ( intCardId = cfTrans.intCardId ) 
AND ( intCardId = cfTrans.intCardId ) 
AND ( intVehicleId = cfTrans.intVehicleId ) 
AND ( intProductId = cfTrans.intProductId ) 
ORDER  BY dtmTransactionDate DESC), 0) ) > 0 THEN 
cfTrans.intOdometer - ISNULL ((SELECT TOP (1) intOdometer 
FROM   dbo.tblCFTransaction AS 
   tblCFTransaction_1 
WHERE  ( 
dtmTransactionDate < cfTrans.dtmTransactionDate ) 
   AND ( intCardId = cfTrans.intCardId ) 
   AND ( intCardId = cfTrans.intCardId ) 
   AND 
( intVehicleId = cfTrans.intVehicleId ) 
   AND 
( intProductId = cfTrans.intProductId ) 
ORDER  BY dtmTransactionDate DESC), 0) 
ELSE 0 
END )                                                         AS dblTotalMiles, 
arInv.strShipTo, 
--arInv.strCompanyName, 
--arInv.strCompanyAddress, 
(SELECT        TOP 1 strCompanyName
                               FROM            tblSMCompanySetup) AS strCompanyName,

(SELECT        TOP 1 [dbo].fnARFormatCustomerAddress(NULL, NULL, NULL, strAddress, strCity, strState, strZip, strCountry, NULL, 0)
FROM            tblSMCompanySetup) AS strCompanyAddress,
							   
arInv.strType, 
arInv.strLocationName, 
arInv.intInvoiceId, 
arInv.strInvoiceNumber, 
arInv.dtmDate, 
cfTrans.dtmPostedDate                                               AS dtmPostedDate 
       , 
cfTrans.intProductId, 
cfTrans.intCardId, 
cfTrans.intTransactionId                                        AS EXPR18, 
cfTrans.strTransactionId, 
cfTrans.strTransactionType, 
cfTrans.strInvoiceReportNumber, 
cfTrans.strTempInvoiceReportNumber, 
cfTrans.dblQuantity, 
cfTrans.strMiscellaneous, 
cfTrans.dtmCreatedDate, 
cfCardAccount.strName, 
cfCardAccount.strCardNumber, 
cfCardAccount.strCardDescription, 
cfSiteItem.strSiteNumber, 
cfSiteItem.strSiteName, 
cfSiteItem.strProductNumber, 
cfSiteItem.strItemNo, 
cfSiteItem.strShortName                                         AS 
       strDescription, 
Round(cfTransPrice.dblCalculatedAmount, 2)                      AS 
       dblCalculatedTotalAmount, 
cfTransPrice.dblOriginalAmount                                  AS 
       dblOriginalTotalAmount, 
cfTransGrossPrice.dblCalculatedAmount                           AS 
       dblCalculatedGrossAmount, 
cfTransGrossPrice.dblOriginalAmount                             AS 
       dblOriginalGrossAmount, 
cfTransNetPrice.dblCalculatedAmount                             AS 
       dblCalculatedNetAmount, 
cfTransNetPrice.dblOriginalAmount                               AS 
       dblOriginalNetAmount, 
cfTransNetPrice.dblCalculatedAmount - cfSiteItem.dblAverageCost AS dblMargin, 
cfTrans.ysnInvalid, 
cfTrans.ysnPosted, 
cfVehicle.strVehicleNumber                                      AS 
       strVehicleNumber, 
cfVehicle.strVehicleDescription, 
cfSiteItem.strTaxState, 
cfSiteItem.strSiteType, 
cfSiteItem.strTaxState                                          AS strState, 
cfSiteItem.strSiteAddress, 
cfSiteItem.ysnPostForeignSales, 
cfSiteItem.strSiteCity, 
(SELECT Sum(dblTaxCalculatedAmount) AS dblTotalTax 
FROM   dbo.tblCFTransactionTax 
WHERE  ( intTransactionId = cfTrans.intTransactionId )) / cfTrans.dblQuantity 
                         AS dblTotalTax, 
(SELECT ISNULL(Sum(cfTT.dblTaxCalculatedAmount), 0) AS dblTotalSST 
FROM   dbo.tblCFTransactionTax AS cfTT 
INNER JOIN dbo.tblSMTaxCode AS smTCd 
ON cfTT.intTaxCodeId = smTCd.intTaxCodeId 
INNER JOIN dbo.tblSMTaxClass AS smTCl 
ON smTCd.intTaxClassId = smTCl.intTaxClassId 
WHERE  ( smTCl.strTaxClass LIKE '%(SST)%' ) 
AND ( smTCl.strTaxClass LIKE '%State Sales Tax%' ) 
AND ( cfTT.intTransactionId = cfTrans.intTransactionId ) 
GROUP  BY cfTT.intTransactionId) / cfTrans.dblQuantity         AS dblTotalSST, 
(SELECT ISNULL(Sum(cfTT.dblTaxCalculatedAmount), 0) AS dblTaxExceptSST 
FROM   dbo.tblCFTransactionTax AS cfTT 
INNER JOIN dbo.tblSMTaxCode AS smTCd 
ON cfTT.intTaxCodeId = smTCd.intTaxCodeId 
INNER JOIN dbo.tblSMTaxClass AS smTCl 
ON smTCd.intTaxClassId = smTCl.intTaxClassId 
WHERE  ( smTCl.strTaxClass NOT LIKE '%(SST)%' ) 
AND ( smTCl.strTaxClass NOT LIKE '%State Sales Tax%' ) 
AND ( smTCl.strTaxClass <> 'SST' ) 
AND ( cfTT.intTransactionId = cfTrans.intTransactionId ) 
GROUP  BY cfTT.intTransactionId) / cfTrans.dblQuantity         AS 
       dblTaxExceptSST, 
cfTrans.strPrintTimeStamp, 

 strEmailDistributionOption = ( CASE cfTrans.strTransactionType 
                                 WHEN 'Foreign Sale' 
								 THEN 
								 (select top 1 strEmailDistributionOption from vyuARCustomerContacts where [intEntityId] = cfSiteItem.intCustomerId  AND strEmailDistributionOption LIKE '%CF Invoice%' AND ISNULL(strEmail,'') != '')
                                 ELSE 
								 (select top 1 strEmailDistributionOption from vyuARCustomerContacts where [intEntityId] = cfCardAccount.intCustomerId  AND strEmailDistributionOption LIKE '%CF Invoice%' AND ISNULL(strEmail,'') != '')
                               END ), 

 strEmail = ( CASE cfTrans.strTransactionType 
                                 WHEN 'Foreign Sale' 
								 THEN 
								 (select top 1 strEmail from vyuARCustomerContacts where [intEntityId] = cfSiteItem.intCustomerId  AND strEmailDistributionOption LIKE '%CF Invoice%' AND ISNULL(strEmail,'') != '')
                                 ELSE 
								 (select top 1 strEmail from vyuARCustomerContacts where [intEntityId] = cfCardAccount.intCustomerId  AND strEmailDistributionOption LIKE '%CF Invoice%' AND ISNULL(strEmail,'') != '')
                               END ),
							   
	   cfTrans.ysnPostedCSV


FROM   dbo.vyuCFInvoice AS arInv 
       RIGHT OUTER JOIN dbo.tblCFTransaction AS cfTrans 
                     ON arInv.intTransactionId = cfTrans.intTransactionId 
						AND ISNULL(cfTrans.ysnPosted,0) = 1
						AND ISNULL(cfTrans.ysnInvalid,0) = 0
                        AND arInv.intInvoiceId = cfTrans.intInvoiceId 
       LEFT OUTER JOIN (SELECT icfVehicle.intVehicleId, 
                               icfVehicle.intAccountId, 
                               icfVehicle.strVehicleNumber, 
                               icfVehicle.strCustomerUnitNumber, 
                               icfVehicle.strVehicleDescription, 
                               icfVehicle.intDaysBetweenService, 
                               icfVehicle.intMilesBetweenService, 
                               icfVehicle.intLastReminderOdometer, 
                               icfVehicle.dtmLastReminderDate, 
                               icfVehicle.dtmLastServiceDate, 
                               icfVehicle.intLastServiceOdometer, 
                               icfVehicle.strNoticeMessageLine1, 
                               icfVehicle.strNoticeMessageLine2, 
                               icfVehicle.strVehicleForOwnUse, 
                               icfVehicle.intExpenseItemId, 
                               icfVehicle.strLicencePlateNumber, 
                               icfVehicle.intCreatedUserId, 
                               icfVehicle.dtmCreated, 
                               icfVehicle.intLastModifiedUserId, 
                               icfVehicle.intConcurrencyId, 
                               icfVehicle.dtmLastModified, 
                               icfVehicle.ysnCardForOwnUse, 
                               icfVehicle.ysnActive 
                               --,icfVehicle.intDepartmentId 
                               , 
                               icfVecleDep.intDepartmentId, 
                               icfVecleDep.strDepartment, 
                               icfVecleDep.strDepartmentDescription 
                        FROM   tblCFVehicle AS icfVehicle 
                               LEFT JOIN tblCFDepartment as icfVecleDep 
                                      on icfVehicle.intDepartmentId = 
                                         icfVecleDep.intDepartmentId) AS 
                       cfVehicle 
                    ON cfTrans.intVehicleId = cfVehicle.intVehicleId 
       LEFT OUTER JOIN dbo.vyuCFCardAccount AS cfCardAccount 
                    ON 
					--arInv.intEntityCustomerId = cfCardAccount.intCustomerId 
     --                  AND 
					   cfTrans.intCardId = cfCardAccount.intCardId 
       LEFT OUTER JOIN (SELECT arCustGroupDetail.intCustomerGroupDetailId, 
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
                               INNER JOIN dbo.tblARCustomerGroupDetail AS 
                                          arCustGroupDetail 
                                       ON arCustGroup.intCustomerGroupId = 
                                          arCustGroupDetail.intCustomerGroupId) 
                       AS 
       emGroup 
                    ON emGroup.intEntityId = cfCardAccount.intCustomerId 
                       AND emGroup.ysnVolumeDiscount = 1 
       INNER JOIN (SELECT icfSite.intSiteId, 
                          icfSite.intNetworkId, 
                          icfSite.intTaxGroupId, 
                          icfSite.strSiteNumber, 
                          icfSite.intARLocationId, 
                          icfSite.intCardId, 
                          icfSite.strTaxState, 
                          icfSite.strAuthorityId1, 
                          icfSite.strAuthorityId2, 
                          icfSite.ysnFederalExciseTax, 
                          icfSite.ysnStateExciseTax, 
                          icfSite.ysnStateSalesTax, 
                          icfSite.ysnLocalTax1, 
                          icfSite.ysnLocalTax2, 
                          icfSite.ysnLocalTax3, 
                          icfSite.ysnLocalTax4, 
                          icfSite.ysnLocalTax5, 
                          icfSite.ysnLocalTax6, 
                          icfSite.ysnLocalTax7, 
                          icfSite.ysnLocalTax8, 
                          icfSite.ysnLocalTax9, 
                          icfSite.ysnLocalTax10, 
                          icfSite.ysnLocalTax11, 
                          icfSite.ysnLocalTax12, 
                          icfSite.intNumberOfLinesPerTransaction, 
                          icfSite.intIgnoreCardID, 
                          icfSite.strImportFileName, 
                          icfSite.strImportPath, 
                          icfSite.intNumberOfDecimalInPrice, 
                          icfSite.intNumberOfDecimalInQuantity, 
                          icfSite.intNumberOfDecimalInTotal, 
                          icfSite.strImportType, 
                          icfSite.strControllerType, 
                          icfSite.ysnPumpCalculatesTaxes, 
                          icfSite.ysnSiteAcceptsMajorCreditCards, 
                          icfSite.ysnCenexSite, 
                          icfSite.ysnUseControllerCard, 
                          icfSite.intCashCustomerID, 
                          icfSite.ysnProcessCashSales, 
                          icfSite.ysnAssignBatchByDate, 
                          icfSite.ysnMultipleSiteImport, 
                          icfSite.strSiteName, 
                          icfSite.strDeliveryPickup, 
                          icfSite.strSiteAddress, 
                          icfSite.strSiteCity, 
                          icfSite.intPPHostId, 
                          icfSite.strPPSiteType, 
                          icfSite.ysnPPLocalPrice, 
                          icfSite.intPPLocalHostId, 
                          icfSite.strPPLocalSiteType, 
                          icfSite.intPPLocalSiteId, 
                          icfSite.intRebateSiteGroupId, 
                          icfSite.intAdjustmentSiteGroupId, 
                          icfSite.dtmLastTransactionDate, 
                          icfSite.ysnEEEStockItemDetail, 
                          icfSite.ysnRecalculateTaxesOnRemote, 
                          icfSite.strSiteType, 
                          icfSite.intCreatedUserId, 
                          icfSite.dtmCreated, 
                          icfSite.intLastModifiedUserId, 
                          icfSite.dtmLastModified, 
                          icfSite.intConcurrencyId, 
                          icfSite.intImportMapperId, 
                          icfItem.intItemId, 
                          icfItem.intARItemId, 
                          iicItemLoc.intItemLocationId, 
                          iicItemLoc.intIssueUOMId, 
                          iicItem.strDescription, 
                          iicItem.strShortName, 
                          iicItem.strItemNo, 
                          icfItem.strProductNumber, 
                          dblAverageCost = ISNULL(ItemPricing.dblAverageCost * 
                                                  ItemUOM.dblUnitQty, 
                                           0), 
                          icfNetwork.ysnPostForeignSales, 
                          icfNetwork.intCustomerId, 
                          iemEnt.strName, 
                          iemEnt.strEntityNo, 
                          icfNetwork.strNetwork, 
                          [dbo].fnARFormatCustomerAddress(NULL, NULL, arBillTo.strLocationName, arBillTo.strAddress, arBillTo.strCity, arBillTo.strState, arBillTo.strZipCode, arBillTo.strCountry, iemEnt.strName, 0) AS strBillTo, 
						  --dbo.fnARFormatCustomerAddress(NULL, NULL, INV.strBillToLocationName, INV.strBillToAddress, INV.strBillToCity, INV.strBillToState, INV.strBillToZipCode, INV.strBillToCountry, E.strName, 0)
                          cfAcct.intInvoiceCycle, 
                          cfInvCycle.strInvoiceCycle, 
                          cfAcct.strPrimarySortOptions, 
                          cfAcct.strSecondarySortOptions, 
                          cfAcct.strPrintRemittancePage, 
                          cfAcct.strPrintPricePerGallon, 
                          cfAcct.ysnPrintMiscellaneous, 
                          cfAcct.strPrintSiteAddress, 
                          cfAcct.ysnSummaryByCard, 
                          cfAcct.ysnSummaryByDepartment, 
                          cfAcct.ysnSummaryByMiscellaneous, 
                          cfAcct.ysnSummaryByProduct, 
                          cfAcct.ysnSummaryByVehicle, 
                          cfAcct.ysnSummaryByCardProd, 
                          cfAcct.ysnSummaryByDeptCardProd, 
                          cfAcct.ysnPrintTimeOnInvoices, 
                          cfAcct.ysnPrintTimeOnReports, 
                          cfAcct.ysnSummaryByDeptVehicleProd, 
                          cfAcct.strPrimaryDepartment, 
                          cfAcct.ysnDepartmentGrouping,
						  cfAcct.intAccountId
                   FROM   dbo.tblCFSite AS icfSite 
                          INNER JOIN dbo.tblCFNetwork AS icfNetwork 
                                  ON icfNetwork.intNetworkId = 
                                     icfSite.intNetworkId 
                          LEFT JOIN tblEMEntity iemEnt 
                                 ON iemEnt.intEntityId = 
                                    icfNetwork.intCustomerId 
                          LEFT JOIN tblARCustomer iarCus 
                                 ON iarCus.intEntityId = 
                                    iemEnt.intEntityId 
                          LEFT JOIN tblCFAccount cfAcct 
                                 ON iarCus.intEntityId = 
                                    cfAcct.intCustomerId 
                          LEFT JOIN tblCFInvoiceCycle cfInvCycle 
                                 ON cfAcct.intInvoiceCycle = 
                                    cfInvCycle.intInvoiceCycleId 
                          LEFT JOIN tblEMEntityLocation arBillTo 
                                 ON arBillTo.intEntityLocationId = 
                                    iarCus.intBillToId 
                          INNER JOIN dbo.tblCFItem AS icfItem 
                                  ON icfSite.intSiteId = icfItem.intSiteId 
                                      OR icfNetwork.intNetworkId = 
                                         icfItem.intNetworkId 
                          INNER JOIN dbo.tblICItem AS iicItem 
                                  ON icfItem.intARItemId = iicItem.intItemId 
                          LEFT OUTER JOIN dbo.tblICItemLocation AS iicItemLoc 
                                       ON iicItemLoc.intLocationId = 
                                          icfSite.intARLocationId 
                                          AND iicItemLoc.intItemId = 
                                              icfItem.intARItemId 
                          LEFT JOIN tblICItemPricing ItemPricing 
                                 ON ItemPricing.intItemId = icfItem.intARItemId 
                                    and ItemPricing.intItemLocationId = 
                                        icfSite.intARLocationId 
                          LEFT JOIN tblICItemUOM ItemUOM 
                                 ON ItemUOM.intItemId = icfItem.intARItemId) AS 
                                                                    cfSiteItem 
               ON cfTrans.intSiteId = cfSiteItem.intSiteId 
                  AND cfTrans.intNetworkId = cfSiteItem.intNetworkId 
                  AND cfSiteItem.intItemId = cfTrans.intProductId 
       CROSS APPLY (SELECT intTransactionPriceId, 
                           intTransactionId, 
                           strTransactionPriceId, 
                           dblOriginalAmount, 
                           dblCalculatedAmount, 
                           intConcurrencyId 
                    FROM   dbo.tblCFTransactionPrice 
                    WHERE  ( strTransactionPriceId = 'Total Amount' ) 
                           AND cfTrans.intTransactionId = intTransactionId) AS 
       cfTransPrice 
       CROSS APPLY (SELECT intTransactionPriceId, 
                           intTransactionId, 
                           strTransactionPriceId, 
                           dblOriginalAmount, 
                           dblCalculatedAmount, 
                           intConcurrencyId 
                    FROM   dbo.tblCFTransactionPrice AS tblCFTransactionPrice_2 
                    WHERE  ( strTransactionPriceId = 'Gross Price' ) 
                           AND cfTrans.intTransactionId = intTransactionId) AS 
                                cfTransGrossPrice 
       CROSS APPLY (SELECT intTransactionPriceId, 
                           intTransactionId, 
                           strTransactionPriceId, 
                           dblOriginalAmount, 
                           dblCalculatedAmount, 
                           intConcurrencyId 
                    FROM   dbo.tblCFTransactionPrice AS tblCFTransactionPrice_1 
                    WHERE  ( strTransactionPriceId = 'Net Price' ) 
                           AND cfTrans.intTransactionId = intTransactionId) AS 
                                                              cfTransNetPrice 
       LEFT OUTER JOIN dbo.tblCFDepartment AS cfAccntDep 
                    ON cfAccntDep.intDepartmentId = 
                       cfCardAccount.intDepartmentId

		LEFT JOIN dbo.tblARCustomer AS arCust 
                    ON arCust.intEntityId = 
                       cfCardAccount.intCustomerId
					LEFT JOIN dbo.tblEMEntityLocation BILLTO 
					ON arCust.intBillToId = BILLTO.intEntityLocationId
	   
	WHERE ISNULL(cfTrans.ysnPosted,0) = 1 AND ISNULL(cfTrans.ysnInvalid,0) = 0
GO


