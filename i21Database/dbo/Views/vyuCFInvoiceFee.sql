
CREATE VIEW [dbo].[vyuCFInvoiceFee]
AS
SELECT   ROUND(ISNULL(cfTransPrice.dblCalculatedAmount, 0), 2) AS dblTotalAmount, smTerm.intTermID, smTerm.strTerm, smTerm.strType, smTerm.dblDiscountEP, 
                         smTerm.intBalanceDue, smTerm.intDiscountDay, smTerm.dblAPR, smTerm.strTermCode, smTerm.ysnAllowEFT, smTerm.intDayofMonthDue, smTerm.intDueNextMonth, 
                         smTerm.dtmDiscountDate, smTerm.dtmDueDate, smTerm.ysnActive, smTerm.ysnEnergyTrac, smTerm.intSort, smTerm.intConcurrencyId, cfTrans.dblQuantity, 
                         cfCardAccount.intAccountId,cfCardAccount.intCardId, cfCardAccount.intFeeProfileId, cfTrans.intTransactionId, arInv.strCustomerName, cfCardAccount.intNetworkId, cfCardAccount.strNetwork, arInv.dtmPostDate AS dtmPostedDate, 
                         cfCardAccount.strInvoiceCycle, cfTrans.dtmTransactionDate, cfTrans.strTransactionType, cfCardAccount.intDiscountScheduleId, cfCardAccount.intCustomerId, 
                         ISNULL(emGroup.intCustomerGroupId, 0) AS intCustomerGroupId, emGroup.strGroupName, arInv.intInvoiceId, arInv.strInvoiceNumber, cfTrans.strInvoiceReportNumber, 
                         cfTrans.strPrintTimeStamp, cfCardAccount.strEmailDistributionOption, cfCardAccount.strEmail, cfTrans.dtmInvoiceDate, cfTrans.intSalesPersonId
						 ,cfSiteItem.intARLocationId
FROM         dbo.vyuCFInvoice AS arInv INNER JOIN
                         dbo.tblCFTransaction AS cfTrans ON arInv.intTransactionId = cfTrans.intTransactionId AND arInv.intInvoiceId = cfTrans.intInvoiceId LEFT OUTER JOIN
                         dbo.tblCFVehicle AS cfVehicle ON cfTrans.intVehicleId = cfVehicle.intVehicleId INNER JOIN
                         dbo.vyuCFCardAccount AS cfCardAccount ON cfTrans.intCardId = cfCardAccount.intCardId INNER JOIN
                         dbo.tblCFDiscountSchedule AS cfDiscount ON cfDiscount.intDiscountScheduleId = cfCardAccount.intDiscountScheduleId LEFT OUTER JOIN
                             (SELECT   arCustGroupDetail.intCustomerGroupDetailId, arCustGroupDetail.intCustomerGroupId, arCustGroupDetail.intEntityId, arCustGroupDetail.ysnSpecialPricing, 
                                                         arCustGroupDetail.ysnContract, arCustGroupDetail.ysnBuyback, arCustGroupDetail.ysnQuote, arCustGroupDetail.ysnVolumeDiscount, 
                                                         arCustGroupDetail.intConcurrencyId, arCustGroup.strGroupName
                                FROM         dbo.tblARCustomerGroup AS arCustGroup INNER JOIN
                                                         dbo.tblARCustomerGroupDetail AS arCustGroupDetail ON arCustGroup.intCustomerGroupId = arCustGroupDetail.intCustomerGroupId) AS emGroup ON 
                         emGroup.intEntityId = cfCardAccount.intCustomerId AND emGroup.ysnVolumeDiscount = 1 INNER JOIN
                         dbo.tblSMTerm AS smTerm ON cfCardAccount.intTermsCode = smTerm.intTermID INNER JOIN
                             (SELECT   icfSite.intSiteId, icfSite.intNetworkId, icfSite.intTaxGroupId, icfSite.strSiteNumber, icfSite.intARLocationId, icfSite.intCardId, icfSite.strTaxState, 
                                                         icfSite.strAuthorityId1, icfSite.strAuthorityId2, icfSite.ysnFederalExciseTax, icfSite.ysnStateExciseTax, icfSite.ysnStateSalesTax, icfSite.ysnLocalTax1, 
                                                         icfSite.ysnLocalTax2, icfSite.ysnLocalTax3, icfSite.ysnLocalTax4, icfSite.ysnLocalTax5, icfSite.ysnLocalTax6, icfSite.ysnLocalTax7, icfSite.ysnLocalTax8, 
                                                         icfSite.ysnLocalTax9, icfSite.ysnLocalTax10, icfSite.ysnLocalTax11, icfSite.ysnLocalTax12, icfSite.intNumberOfLinesPerTransaction, icfSite.intIgnoreCardID, 
                                                         icfSite.strImportFileName, icfSite.strImportPath, icfSite.intNumberOfDecimalInPrice, icfSite.intNumberOfDecimalInQuantity, icfSite.intNumberOfDecimalInTotal, 
                                                         icfSite.strImportType, icfSite.strControllerType, icfSite.ysnPumpCalculatesTaxes, icfSite.ysnSiteAcceptsMajorCreditCards, icfSite.ysnCenexSite, 
                                                         icfSite.ysnUseControllerCard, icfSite.intCashCustomerID, icfSite.ysnProcessCashSales, icfSite.ysnAssignBatchByDate, icfSite.ysnMultipleSiteImport, 
                                                         icfSite.strSiteName, icfSite.strDeliveryPickup, icfSite.strSiteAddress, icfSite.strSiteCity, icfSite.intPPHostId, icfSite.strPPSiteType, icfSite.ysnPPLocalPrice, 
                                                         icfSite.intPPLocalHostId, icfSite.strPPLocalSiteType, icfSite.intPPLocalSiteId, icfSite.intRebateSiteGroupId, icfSite.intAdjustmentSiteGroupId, 
                                                         icfSite.dtmLastTransactionDate, icfSite.ysnEEEStockItemDetail, icfSite.ysnRecalculateTaxesOnRemote, icfSite.strSiteType, icfSite.intCreatedUserId, 
                                                         icfSite.dtmCreated, icfSite.intLastModifiedUserId, icfSite.dtmLastModified, icfSite.intConcurrencyId, icfSite.intImportMapperId, icfItem.intItemId, 
                                                         icfItem.intARItemId, iicItemLoc.intItemLocationId, iicItemLoc.intIssueUOMId, iicItem.strDescription, iicItem.strShortName, iicItem.strItemNo, 
                                                         icfItem.strProductNumber, iicItemPricing.dblAverageCost, icfItem.strProductDescription, icfItem.ysnIncludeInQuantityDiscount
                                FROM         dbo.tblCFSite AS icfSite INNER JOIN
                                                         dbo.tblCFNetwork AS icfNetwork ON icfNetwork.intNetworkId = icfSite.intNetworkId INNER JOIN
                                                         dbo.tblCFItem AS icfItem ON icfSite.intSiteId = icfItem.intSiteId OR icfNetwork.intNetworkId = icfItem.intNetworkId INNER JOIN
                                                         dbo.tblICItem AS iicItem ON icfItem.intARItemId = iicItem.intItemId LEFT OUTER JOIN
                                                         dbo.tblICItemLocation AS iicItemLoc ON iicItemLoc.intLocationId = icfSite.intARLocationId AND iicItemLoc.intItemId = icfItem.intARItemId INNER JOIN
                                                         dbo.vyuICGetItemPricing AS iicItemPricing ON iicItemPricing.intItemId = icfItem.intARItemId AND iicItemPricing.intLocationId = iicItemLoc.intLocationId AND 
                                                         iicItemPricing.intItemLocationId = iicItemLoc.intItemLocationId) AS cfSiteItem ON cfTrans.intSiteId = cfSiteItem.intSiteId AND 
                         cfTrans.intNetworkId = cfSiteItem.intNetworkId AND cfSiteItem.intItemId = cfTrans.intProductId LEFT OUTER JOIN
                             (SELECT   intTransactionPriceId, intTransactionId, strTransactionPriceId, dblOriginalAmount, dblCalculatedAmount, intConcurrencyId
                                FROM         dbo.tblCFTransactionPrice
                                WHERE     (strTransactionPriceId = 'Total Amount')) AS cfTransPrice ON cfTrans.intTransactionId = cfTransPrice.intTransactionId LEFT OUTER JOIN
                             (SELECT   intTransactionPriceId, intTransactionId, strTransactionPriceId, dblOriginalAmount, dblCalculatedAmount, intConcurrencyId
                                FROM         dbo.tblCFTransactionPrice AS tblCFTransactionPrice_2
                                WHERE     (strTransactionPriceId = 'Gross Price')) AS cfTransGrossPrice ON cfTrans.intTransactionId = cfTransGrossPrice.intTransactionId LEFT OUTER JOIN
                             (SELECT   intTransactionPriceId, intTransactionId, strTransactionPriceId, dblOriginalAmount, dblCalculatedAmount, intConcurrencyId
                                FROM         dbo.tblCFTransactionPrice AS tblCFTransactionPrice_1
                                WHERE     (strTransactionPriceId = 'Net Price')) AS cfTransNetPrice ON cfTrans.intTransactionId = cfTransNetPrice.intTransactionId LEFT OUTER JOIN
                             (SELECT   icfTramsactionTax.intTransactionId, ISNULL(SUM(icfTramsactionTax.dblTaxOriginalAmount), 0) AS dblTaxOriginalAmount, 
                                                         ISNULL(SUM(icfTramsactionTax.dblTaxCalculatedAmount), 0) AS dblTaxCalculatedAmount, ISNULL(SUM(icfTramsactionTax.dblTaxRate), 0) AS dblTaxRate
                                FROM         dbo.tblCFTransactionTax AS icfTramsactionTax INNER JOIN
                                                         dbo.tblSMTaxCode AS ismTaxCode ON icfTramsactionTax.intTaxCodeId = ismTaxCode.intTaxCodeId INNER JOIN
                                                         dbo.tblSMTaxClass AS ismTaxClass ON ismTaxCode.intTaxClassId = ismTaxClass.intTaxClassId
                                WHERE     (ismTaxClass.strTaxClass LIKE '%(FET)%') AND (ismTaxClass.strTaxClass LIKE '%Federal Excise Tax%')
                                GROUP BY icfTramsactionTax.intTransactionId) AS FETTaxes ON cfTrans.intTransactionId = FETTaxes.intTransactionId LEFT OUTER JOIN
                             (SELECT   icfTramsactionTax.intTransactionId, ISNULL(SUM(icfTramsactionTax.dblTaxOriginalAmount), 0) AS dblTaxOriginalAmount, 
                                                         ISNULL(SUM(icfTramsactionTax.dblTaxCalculatedAmount), 0) AS dblTaxCalculatedAmount, ISNULL(SUM(icfTramsactionTax.dblTaxRate), 0) AS dblTaxRate
                                FROM         dbo.tblCFTransactionTax AS icfTramsactionTax INNER JOIN
                                                         dbo.tblSMTaxCode AS ismTaxCode ON icfTramsactionTax.intTaxCodeId = ismTaxCode.intTaxCodeId INNER JOIN
                                                         dbo.tblSMTaxClass AS ismTaxClass ON ismTaxCode.intTaxClassId = ismTaxClass.intTaxClassId
                                WHERE     (ismTaxClass.strTaxClass LIKE '%(SET)%') AND (ismTaxClass.strTaxClass LIKE '%State Excise Tax%')
                                GROUP BY icfTramsactionTax.intTransactionId) AS SETTaxes ON cfTrans.intTransactionId = SETTaxes.intTransactionId LEFT OUTER JOIN
                             (SELECT   icfTramsactionTax.intTransactionId, ISNULL(SUM(icfTramsactionTax.dblTaxOriginalAmount), 0) AS dblTaxOriginalAmount, 
                                                         ISNULL(SUM(icfTramsactionTax.dblTaxCalculatedAmount), 0) AS dblTaxCalculatedAmount, ISNULL(SUM(icfTramsactionTax.dblTaxRate), 0) AS dblTaxRate
                                FROM         dbo.tblCFTransactionTax AS icfTramsactionTax INNER JOIN
                                                         dbo.tblSMTaxCode AS ismTaxCode ON icfTramsactionTax.intTaxCodeId = ismTaxCode.intTaxCodeId INNER JOIN
                                                         dbo.tblSMTaxClass AS ismTaxClass ON ismTaxCode.intTaxClassId = ismTaxClass.intTaxClassId
                                WHERE     (ismTaxClass.strTaxClass LIKE '%(SST)%') AND (ismTaxClass.strTaxClass LIKE '%State Sales Tax%')
                                GROUP BY icfTramsactionTax.intTransactionId) AS SSTTaxes ON cfTrans.intTransactionId = SSTTaxes.intTransactionId LEFT OUTER JOIN
                             (SELECT   icfTramsactionTax.intTransactionId, ISNULL(SUM(icfTramsactionTax.dblTaxOriginalAmount), 0) AS dblTaxOriginalAmount, 
                                                         ISNULL(SUM(icfTramsactionTax.dblTaxCalculatedAmount), 0) AS dblTaxCalculatedAmount, ISNULL(SUM(icfTramsactionTax.dblTaxRate), 0) AS dblTaxRate
                                FROM         dbo.tblCFTransactionTax AS icfTramsactionTax INNER JOIN
                                                         dbo.tblSMTaxCode AS ismTaxCode ON icfTramsactionTax.intTaxCodeId = ismTaxCode.intTaxCodeId INNER JOIN
                                                         dbo.tblSMTaxClass AS ismTaxClass ON ismTaxCode.intTaxClassId = ismTaxClass.intTaxClassId
                                WHERE     (ismTaxClass.strTaxClass NOT LIKE '%(SET)%') AND (ismTaxClass.strTaxClass NOT LIKE '%State Excise Tax%') AND (ismTaxClass.strTaxClass <> 'SET') AND 
                                                         (ismTaxClass.strTaxClass NOT LIKE '%(FET)%') AND (ismTaxClass.strTaxClass NOT LIKE '%Federal Excise Tax%') AND (ismTaxClass.strTaxClass <> 'FET') AND 
                                                         (ismTaxClass.strTaxClass NOT LIKE '%(SST)%') AND (ismTaxClass.strTaxClass NOT LIKE '%State Sales Tax%') AND (ismTaxClass.strTaxClass <> 'SST')
                                GROUP BY icfTramsactionTax.intTransactionId) AS LCTaxes ON cfTrans.intTransactionId = LCTaxes.intTransactionId LEFT OUTER JOIN
                             (SELECT   icfTramsactionTax.intTransactionId, ISNULL(SUM(icfTramsactionTax.dblTaxOriginalAmount), 0) AS dblTaxOriginalAmount, 
                                                         ISNULL(SUM(icfTramsactionTax.dblTaxCalculatedAmount), 0) AS dblTaxCalculatedAmount, ISNULL(SUM(icfTramsactionTax.dblTaxRate), 0) AS dblTaxRate
                                FROM         dbo.tblCFTransactionTax AS icfTramsactionTax INNER JOIN
                                                         dbo.tblSMTaxCode AS ismTaxCode ON icfTramsactionTax.intTaxCodeId = ismTaxCode.intTaxCodeId INNER JOIN
                                                         dbo.tblSMTaxClass AS ismTaxClass ON ismTaxCode.intTaxClassId = ismTaxClass.intTaxClassId
                                GROUP BY icfTramsactionTax.intTransactionId) AS TotalTaxes ON cfTrans.intTransactionId = TotalTaxes.intTransactionId
WHERE     (cfSiteItem.ysnIncludeInQuantityDiscount = 1) AND (cfTrans.ysnPosted = 1) OR
                         (cfTrans.strTransactionType = 'Local/Network') OR
                         (cfTrans.strTransactionType = 'Remote') AND (cfDiscount.ysnDiscountOnRemotes = 1) OR
                         (cfTrans.strTransactionType = 'Extended Remote') AND (cfDiscount.ysnDiscountOnExtRemotes = 1)



