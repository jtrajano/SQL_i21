CREATE VIEW dbo.vyuCFCardAccount
AS
SELECT   A.intAccountId, A.intCustomerId, A.intDiscountDays, A.intDiscountScheduleId, A.intInvoiceCycle, A.intSalesPersonId, A.dtmBonusCommissionDate, 
                         A.dblBonusCommissionRate, A.dblRegularCommissionRate, A.ysnPrintTimeOnInvoices, A.ysnPrintTimeOnReports, A.intTermsCode, A.strBillingSite, A.strPrimarySortOptions, 
                         A.strSecondarySortOptions, A.ysnSummaryByCard, A.ysnSummaryByVehicle, A.ysnSummaryByMiscellaneous, A.ysnSummaryByProduct, A.ysnSummaryByDepartment, 
                         A.ysnVehicleRequire, A.intAccountStatusCodeId, A.strPrintRemittancePage, A.strInvoiceProgramName, A.intPriceRuleGroup, A.strPrintPricePerGallon, 
                         A.ysnPPTransferCostForRemote, A.ysnPPTransferCostForNetwork, A.ysnPrintMiscellaneous, A.intFeeProfileId, A.strPrintSiteAddress, A.dtmLastBillingCycleDate, 
                         A.intRemotePriceProfileId, A.intExtRemotePriceProfileId, A.intLocalPriceProfileId, A.intCreatedUserId, A.dtmCreated, A.intLastModifiedUserId, A.dtmLastModified, 
                         A.intConcurrencyId, C.intCardId, C.intNetworkId, C.strCardNumber, C.strCardDescription, C.intAccountId AS EXPR1, C.strCardForOwnUse, C.intExpenseItemId, 
                         C.intDefaultFixVehicleNumber, C.intDepartmentId, C.dtmLastUsedDated, C.intCardTypeId, C.dtmIssueDate, C.ysnActive, C.ysnCardLocked, C.strCardPinNumber, 
                         C.dtmCardExpiratioYearMonth, C.strCardValidationCode, C.intNumberOfCardsIssued, C.intCardLimitedCode, C.intCardFuelCode, C.strCardTierCode, 
                         C.strCardOdometerCode, C.strCardWCCode, C.strSplitNumber, C.intCardManCode, C.intCardShipCat, C.intCardProfileNumber, C.intCardPositionSite, 
                         C.intCardvehicleControl, C.intCardCustomPin, C.intCreatedUserId AS EXPR2, C.dtmCreated AS EXPR3, C.intLastModifiedUserId AS EXPR4, C.intConcurrencyId AS EXPR5, 
                         C.dtmLastModified AS EXPR6, C.ysnCardForOwnUse, C.ysnIgnoreCardTransaction, N.intNetworkId AS EXPR7, N.strNetwork, N.strNetworkType, N.strNetworkDescription, 
                         N.intCustomerId AS EXPR8, N.intCACustomerId, N.intDebitMemoGLAccount, N.intLocationId, N.dblFeeRateAmount, N.dblFeePerGallon, N.dblFeeTransactionPerGallon, 
                         N.dblMonthlyCommisionFeeAmount, N.dblVariableCommisionFeePerGallon, N.strImportPath, N.dtmLastImportDate, N.intErrorBatchNumber, N.intPPhostId, 
                         N.intPPDistributionSite, N.strPPFileImportType, N.ysnRejectExportCard, N.strRejectPath, N.strParticipant, N.strCFNFileVersion, N.ysnPassOnSSTFromRemotes, 
                         N.ysnExemptFETOnRemotes, N.ysnExemptSETOnRemotes, N.ysnExemptLCOnRemotes, N.strExemptLCCode, N.intImportMapperId, N.strLinkNetwork, 
                         N.intConcurrencyId AS EXPR9, D.intDepartmentId AS EXPR10, D.intAccountId AS EXPR11, D.strDepartment, D.strDepartmentDescription, D.intConcurrencyId AS EXPR12, 
                         Cus.[intEntityId], Cus.strName, Cus.strCustomerNumber, Cus.strType, Cus.strPhone, Cus.strAddress, Cus.strCity, Cus.strState, Cus.strZipCode, 
                         Cus.ysnActive AS EXPR13, Cus.intSalespersonId AS EXPR14, Cus.intCurrencyId, Cus.intTermsId, Cus.intShipViaId, Cus.strShipToLocationName, Cus.strShipToAddress, 
                         Cus.strShipToCity, Cus.strShipToState, Cus.strShipToZipCode, Cus.strShipToCountry, Cus.strBillToLocationName, Cus.strBillToAddress, Cus.strBillToCity, Cus.strBillToState,
                          Cus.strBillToZipCode, Cus.strBillToCountry, I.strInvoiceCycle, 
						  (select top 1 strEmailDistributionOption from vyuARCustomerContacts where intEntityId = A.intCustomerId AND strEmailDistributionOption LIKE '%CF Invoice%' AND ISNULL(strEmail,'') != '') AS strEmailDistributionOption, 
						  (select top 1 strEmail from vyuARCustomerContacts where intEntityId = A.intCustomerId AND strEmailDistributionOption LIKE '%CF Invoice%' AND ISNULL(strEmail,'') != '') AS strEmail 
FROM         dbo.tblCFAccount AS A LEFT JOIN
                         dbo.tblCFCard AS C ON A.intAccountId = C.intAccountId LEFT OUTER JOIN
                         dbo.tblCFNetwork AS N ON N.intNetworkId = C.intNetworkId LEFT OUTER JOIN
                         dbo.tblCFDepartment AS D ON D.intDepartmentId = C.intDepartmentId LEFT JOIN
                         dbo.vyuCFCustomerEntity AS Cus ON A.intCustomerId = Cus.intEntityId INNER JOIN
                         dbo.tblCFInvoiceCycle AS I ON I.intInvoiceCycleId = A.intInvoiceCycle INNER JOIN
						 dbo.tblEMEntity AS E ON E.intEntityId = A.intCustomerId
GO