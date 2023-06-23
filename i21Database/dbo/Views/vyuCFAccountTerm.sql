CREATE VIEW dbo.vyuCFAccountTerm
AS
SELECT cfAccnt.intAccountId, cfAccnt.intCustomerId, cfAccnt.intDiscountDays, cfAccnt.intDiscountScheduleId, cfAccnt.intInvoiceCycle, cfAccnt.intImportMapperId, cfAccnt.intSalesPersonId, cfAccnt.dtmBonusCommissionDate, cfAccnt.dblBonusCommissionRate, 
             cfAccnt.dblRegularCommissionRate, cfAccnt.ysnPrintTimeOnInvoices, cfAccnt.ysnPrintTimeOnReports, cfAccnt.intTermsCode, cfAccnt.strBillingSite, cfAccnt.strPrimarySortOptions, cfAccnt.strSecondarySortOptions, cfAccnt.ysnSummaryByCard,cfAccnt.ysnSummaryByDepartmentProduct, 
             cfAccnt.ysnSummaryByVehicle, cfAccnt.ysnSummaryByMiscellaneous, cfAccnt.ysnSummaryByProduct, cfAccnt.ysnSummaryByDepartment, cfAccnt.ysnSummaryByDeptCardProd, cfAccnt.ysnSummaryByCardProd, cfAccnt.ysnVehicleRequire, 
             cfAccnt.intAccountStatusCodeId, cfAccnt.strPrintRemittancePage, cfAccnt.strInvoiceProgramName, cfAccnt.intPriceRuleGroup, cfAccnt.strPrintPricePerGallon, cfAccnt.ysnPPTransferCostForRemote, cfAccnt.ysnPPTransferCostForNetwork, 
             cfAccnt.ysnShowSST, cfAccnt.ysnPrintMiscellaneous,  cfAccnt.intFeeProfileId, cfAccnt.strPrintSiteAddress, cfAccnt.dtmLastBillingCycleDate, cfAccnt.intRemotePriceProfileId, cfAccnt.intExtRemotePriceProfileId, cfAccnt.intLocalPriceProfileId, cfAccnt.intCreatedUserId, cfAccnt.dtmCreated, 
             cfAccnt.intLastModifiedUserId, cfAccnt.dtmLastModified, smTerm.intTermID, smTerm.strTerm, smTerm.strType, smTerm.dblDiscountEP, smTerm.intBalanceDue, smTerm.intDiscountDay, smTerm.dblAPR, smTerm.strTermCode, smTerm.ysnAllowEFT, 
             smTerm.intDayofMonthDue, smTerm.intDueNextMonth, smTerm.dtmDiscountDate, smTerm.dtmDueDate, smTerm.ysnActive, smTerm.ysnEnergyTrac, smTerm.intSort
FROM   dbo.tblCFAccount AS cfAccnt LEFT OUTER JOIN
             dbo.tblSMTerm AS smTerm ON cfAccnt.intTermsCode = smTerm.intTermID
