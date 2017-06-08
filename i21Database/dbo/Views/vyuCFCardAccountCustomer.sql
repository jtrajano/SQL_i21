CREATE VIEW dbo.vyuCFCardAccountCustomer
AS
SELECT cfCard.intCardId, cfCard.intNetworkId, cfCard.strCardNumber, cfCard.strCardDescription, cfCard.intAccountId, cfCard.intProductAuthId, cfCard.intEntryCode, cfCard.strCardXReference, cfCard.strCardForOwnUse, cfCard.intExpenseItemId, 
             cfCard.intDefaultFixVehicleNumber, cfCard.intDepartmentId, cfCard.dtmLastUsedDated, cfCard.intCardTypeId, cfCard.dtmIssueDate, cfCard.ysnActive, cfCard.ysnCardLocked, cfCard.strCardPinNumber, cfCard.dtmCardExpiratioYearMonth, 
             cfCard.strCardValidationCode, cfCard.intNumberOfCardsIssued, cfCard.intCardLimitedCode, cfCard.intCardFuelCode, cfCard.strCardTierCode, cfCard.strCardOdometerCode, cfCard.strCardWCCode, cfCard.strSplitNumber, cfCard.intCardManCode, 
             cfCard.intCardShipCat, cfCard.intCardProfileNumber, cfCard.intCardPositionSite, cfCard.intCardvehicleControl, cfCard.intCardCustomPin, cfCard.intCreatedUserId, cfCard.dtmCreated, cfCard.intLastModifiedUserId, cfCard.intConcurrencyId, cfCard.dtmLastModified, 
             cfCard.ysnCardForOwnUse, cfCard.ysnIgnoreCardTransaction, cfCard.strComment, cfAccount.intAccountId AS EXPR1, cfAccount.intCustomerId, cfAccount.intDiscountDays, cfAccount.intDiscountScheduleId, cfAccount.intInvoiceCycle, cfAccount.intImportMapperId, 
             cfAccount.intSalesPersonId, cfAccount.dtmBonusCommissionDate, cfAccount.dblBonusCommissionRate, cfAccount.dblRegularCommissionRate, cfAccount.ysnPrintTimeOnInvoices, cfAccount.ysnPrintTimeOnReports, cfAccount.intTermsCode, cfAccount.strBillingSite, 
             cfAccount.strPrimarySortOptions, cfAccount.strSecondarySortOptions, cfAccount.ysnSummaryByCard,  cfAccount.ysnSummaryByCardProd,cfAccount.ysnSummaryByDeptCardProd,cfAccount.ysnSummaryByVehicle, cfAccount.ysnSummaryByMiscellaneous, cfAccount.ysnSummaryByProduct, cfAccount.ysnSummaryByDepartment, 
             cfAccount.ysnVehicleRequire, cfAccount.intAccountStatusCodeId, cfAccount.strPrintRemittancePage, cfAccount.strInvoiceProgramName, cfAccount.intPriceRuleGroup, cfAccount.strPrintPricePerGallon, cfAccount.ysnPPTransferCostForRemote, 
             cfAccount.ysnPPTransferCostForNetwork, cfAccount.ysnPrintMiscellaneous, cfAccount.intFeeProfileId, cfAccount.strPrintSiteAddress, cfAccount.dtmLastBillingCycleDate, cfAccount.intRemotePriceProfileId, cfAccount.intExtRemotePriceProfileId, 
             cfAccount.intLocalPriceProfileId, cfAccount.intCreatedUserId AS EXPR2, cfAccount.dtmCreated AS EXPR3, cfAccount.intLastModifiedUserId AS EXPR4, cfAccount.dtmLastModified AS EXPR5, cfAccount.intConcurrencyId AS EXPR6, emEntity.intEntityId, 
             emEntity.intEntityCustomerId, emEntity.strName, emEntity.strCustomerNumber, emEntity.strType, emEntity.strPhone, emEntity.strAddress, emEntity.strCity, emEntity.strState, emEntity.strZipCode, emEntity.ysnActive AS EXPR7, emEntity.intSalespersonId AS EXPR8, 
             emEntity.intCurrencyId, emEntity.intTermsId, emEntity.intShipViaId, emEntity.strShipToLocationName, emEntity.strShipToAddress, emEntity.strShipToCity, emEntity.strShipToState, emEntity.strShipToZipCode, emEntity.strShipToCountry, 
             emEntity.strBillToLocationName, emEntity.strBillToAddress, emEntity.strBillToCity, emEntity.strBillToState, emEntity.strBillToZipCode, emEntity.strBillToCountry
FROM   dbo.tblCFCard AS cfCard INNER JOIN
             dbo.tblCFAccount AS cfAccount ON cfAccount.intAccountId = cfCard.intAccountId INNER JOIN
             dbo.vyuCFCustomerEntity AS emEntity ON emEntity.intEntityCustomerId = cfAccount.intCustomerId
