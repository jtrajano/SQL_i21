CREATE VIEW dbo.vyuCFVehicleAccountCustomer
AS
SELECT cfVehicle.intVehicleId, cfVehicle.intAccountId, cfVehicle.strVehicleNumber, cfVehicle.strCustomerUnitNumber, cfVehicle.strVehicleDescription, cfVehicle.intDaysBetweenService, cfVehicle.intMilesBetweenService, cfVehicle.intLastReminderOdometer, 
             cfVehicle.dtmLastReminderDate, cfVehicle.dtmLastServiceDate, cfVehicle.intLastServiceOdometer, cfVehicle.strNoticeMessageLine1, cfVehicle.strNoticeMessageLine2, cfVehicle.strVehicleForOwnUse, cfVehicle.intExpenseItemId, cfVehicle.strLicencePlateNumber, 
             cfVehicle.strDepartment, cfVehicle.intCreatedUserId, cfVehicle.dtmCreated, cfVehicle.intLastModifiedUserId, cfVehicle.intConcurrencyId, cfVehicle.dtmLastModified, cfVehicle.ysnCardForOwnUse, cfAccount.intAccountId AS EXPR1, cfAccount.intCustomerId, 
             cfAccount.intDiscountDays, cfAccount.intDiscountScheduleId, cfAccount.intInvoiceCycle, cfAccount.intImportMapperId, cfAccount.intSalesPersonId, cfAccount.dtmBonusCommissionDate, cfAccount.dblBonusCommissionRate, cfAccount.dblRegularCommissionRate, 
             cfAccount.ysnPrintTimeOnInvoices, cfAccount.ysnPrintTimeOnReports, cfAccount.intTermsCode, cfAccount.strBillingSite, cfAccount.strPrimarySortOptions, cfAccount.strSecondarySortOptions, cfAccount.ysnSummaryByDepartmentProduct,cfAccount.ysnSummaryByCard, cfAccount.ysnSummaryByVehicle, 
             cfAccount.ysnSummaryByMiscellaneous, cfAccount.ysnSummaryByProduct, cfAccount.ysnSummaryByDepartment, cfAccount.ysnVehicleRequire, cfAccount.intAccountStatusCodeId, cfAccount.strPrintRemittancePage, cfAccount.strInvoiceProgramName, 
             cfAccount.intPriceRuleGroup, cfAccount.strPrintPricePerGallon, cfAccount.ysnPPTransferCostForRemote, cfAccount.ysnPPTransferCostForNetwork, cfAccount.ysnShowSST,cfAccount.ysnPrintMiscellaneous, cfAccount.intFeeProfileId, cfAccount.strPrintSiteAddress, 
             cfAccount.dtmLastBillingCycleDate, cfAccount.intRemotePriceProfileId, cfAccount.intExtRemotePriceProfileId, cfAccount.intLocalPriceProfileId, cfAccount.intCreatedUserId AS EXPR2, cfAccount.dtmCreated AS EXPR3, cfAccount.intLastModifiedUserId AS EXPR4, 
             cfAccount.dtmLastModified AS EXPR5, cfAccount.intConcurrencyId AS EXPR6, emEntity.intEntityId,  emEntity.strName, emEntity.strCustomerNumber, emEntity.strType, emEntity.strPhone, emEntity.strAddress, emEntity.strCity, 
             emEntity.strState, emEntity.strZipCode, emEntity.ysnActive, emEntity.intSalespersonId AS EXPR7, emEntity.intCurrencyId, emEntity.intTermsId, emEntity.intShipViaId, emEntity.strShipToLocationName, emEntity.strShipToAddress, emEntity.strShipToCity, 
             emEntity.strShipToState, emEntity.strShipToZipCode, emEntity.strShipToCountry, emEntity.strBillToLocationName, emEntity.strBillToAddress, emEntity.strBillToCity, emEntity.strBillToState, emEntity.strBillToZipCode, emEntity.strBillToCountry
FROM   dbo.tblCFVehicle AS cfVehicle INNER JOIN
             dbo.tblCFAccount AS cfAccount ON cfAccount.intAccountId = cfVehicle.intAccountId INNER JOIN
             dbo.vyuCFCustomerEntity AS emEntity ON emEntity.[intEntityId] = cfAccount.intCustomerId
