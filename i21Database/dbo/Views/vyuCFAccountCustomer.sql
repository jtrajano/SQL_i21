﻿CREATE VIEW [dbo].[vyuCFAccountCustomer]
AS
SELECT 
     intAccountId=ISNULL(intAccountId,0)
	,intCustomerId=ISNULL(intCustomerId,0)
	,intDiscountDays=ISNULL(intDiscountDays,0)
	,intDiscountScheduleId=ISNULL(intDiscountScheduleId,0)
	,intInvoiceCycle=ISNULL(intInvoiceCycle,0)
	,intImportMapperId=ISNULL(intImportMapperId,0)
	,intSalesPersonId=ISNULL(cfAccount.intSalesPersonId,0)
	,intTermsCode=ISNULL(intTermsCode,0)
	,intAccountStatusCodeId=ISNULL(intAccountStatusCodeId,0)
	,intEntityId=ISNULL(intEntityId,0)
	,intConcurrencyId=ISNULL(intConcurrencyId,0)
	,intLastModifiedUserId=ISNULL(intLastModifiedUserId,0)
	,intRemotePriceProfileId=ISNULL(intRemotePriceProfileId,0)
	,intExtRemotePriceProfileId=ISNULL(intExtRemotePriceProfileId,0)
	,intLocalPriceProfileId=ISNULL(intLocalPriceProfileId,0)
	,intCreatedUserId=ISNULL(intCreatedUserId,0)
	,intFeeProfileId=ISNULL(intFeeProfileId,0)
	,intPriceRuleGroup=ISNULL(intPriceRuleGroup,0)
	,intCustomerGroupId=ISNULL(intCustomerGroupId,0)
	,intQuoteProduct1Id=ISNULL(intQuoteProduct1Id,0)
	,intQuoteProduct2Id=ISNULL(intQuoteProduct2Id,0)
	,intQuoteProduct3Id=ISNULL(intQuoteProduct3Id,0)
	,intQuoteProduct4Id=ISNULL(intQuoteProduct4Id,0)
	,intQuoteProduct5Id=ISNULL(intQuoteProduct5Id,0)
	,intCurrencyId=ISNULL(intCurrencyId,0)
	,intTermsId=ISNULL(intTermsId,0)
	,intShipViaId=ISNULL(intShipViaId,0)
	,intDailyTransactionCount = ISNULL(intDailyTransactionCount,0)
	,dblBonusCommissionRate=ISNULL(dblBonusCommissionRate,0)
	,dblRegularCommissionRate=ISNULL(dblRegularCommissionRate,0)
	,ysnPrintTimeOnInvoices=ISNULL(ysnPrintTimeOnInvoices,0)
	,ysnPrintTimeOnReports=ISNULL(ysnPrintTimeOnReports,0)
	,ysnSummaryByCard=ISNULL(ysnSummaryByCard,0)
	,ysnSummaryByVehicle=ISNULL(ysnSummaryByVehicle,0)
	,ysnSummaryByMiscellaneous=ISNULL(ysnSummaryByMiscellaneous,0)
	,ysnSummaryByProduct=ISNULL(ysnSummaryByProduct,0)
	,ysnSummaryByDepartment=ISNULL(ysnSummaryByDepartment,0)
	,ysnSummaryByDeptCardProd=ISNULL(ysnSummaryByDeptCardProd,0)
	,ysnSummaryByDriverPin=ISNULL(ysnSummaryByDriverPin,0)
	,ysnSummaryByCardProd=ISNULL(ysnSummaryByCardProd,0)
	,ysnVehicleRequire=ISNULL(ysnVehicleRequire,0)
	,ysnPPTransferCostForRemote=ISNULL(ysnPPTransferCostForRemote,0)
	,ysnPPTransferCostForNetwork=ISNULL(ysnPPTransferCostForNetwork,0)
	,ysnPrintMiscellaneous=ISNULL(ysnPrintMiscellaneous,0)
	,ysnShowSST=ISNULL(ysnShowSST,0)
	,ysnDepartmentGrouping=ISNULL(ysnDepartmentGrouping,0)
	,ysnSummaryByDeptVehicleProd=ISNULL(ysnSummaryByDeptVehicleProd,0)
	,ysnQuoteTaxExempt=ISNULL(ysnQuoteTaxExempt,0)
	,ysnConvertMiscToVehicle=ISNULL(ysnConvertMiscToVehicle,0)
	,ysnShowVehicleDescriptionOnly=ISNULL(ysnShowVehicleDescriptionOnly,0)
	,ysnShowDriverPinDescriptionOnly=ISNULL(ysnShowDriverPinDescriptionOnly,0)
	,ysnPageBreakByPrimarySortOrder=ISNULL(ysnPageBreakByPrimarySortOrder,0)
	,ysnSummaryByDeptDriverPinProd=ISNULL(ysnSummaryByDeptDriverPinProd,0)
	,strDepartmentGrouping=ISNULL(strDepartmentGrouping,0)
	,ysnActive=ISNULL(ysnActive,0)
	,dtmBonusCommissionDate
	,dtmLastBillingCycleDate
	,dtmCreated
	,dtmLastModified
	,strBillingSite=ISNULL(strBillingSite,'')
	,strPrimarySortOptions=ISNULL(strPrimarySortOptions,'')
	,strSecondarySortOptions=ISNULL(strSecondarySortOptions,'')
	,strPrintRemittancePage=ISNULL(strPrintRemittancePage,'')
	,strInvoiceProgramName=ISNULL(strInvoiceProgramName,'')
	,strPrintPricePerGallon=ISNULL(strPrintPricePerGallon,'')
	,strPrintSiteAddress=ISNULL(strPrintSiteAddress,'')
	,strPrimaryDepartment=ISNULL(strPrimaryDepartment,'')
	,strDetailDisplay=ISNULL(strDetailDisplay,'')
	,strName=ISNULL(strName,'')
	,strCustomerNumber=ISNULL(strCustomerNumber,'')
	,strType=ISNULL(strType,'')
	,strPhone=ISNULL(strPhone,'')
	,strAddress=ISNULL(strAddress,'')
	,strCity=ISNULL(strCity,'')
	,strState=ISNULL(strState,'')
	,strZipCode=ISNULL(strZipCode,'')
	,strShipToLocationName=ISNULL(strShipToLocationName,'')
	,strShipToAddress=ISNULL(strShipToAddress,'')
	,strShipToCity=ISNULL(strShipToCity,'')
	,strShipToState=ISNULL(strShipToState,'')
	,strShipToZipCode=ISNULL(strShipToZipCode,'')
	,strShipToCountry=ISNULL(strShipToCountry,'')
	,strBillToLocationName=ISNULL(strBillToLocationName,'')
	,strBillToAddress=ISNULL(strBillToAddress,'')
	,strBillToCity=ISNULL(strBillToCity,'')
	,strBillToState=ISNULL(strBillToState,'')
	,strBillToZipCode=ISNULL(strBillToZipCode,'')
	,strBillToCountry=ISNULL(strBillToCountry,'')
FROM  dbo.tblCFAccount AS cfAccount INNER JOIN
dbo.vyuCFCustomerEntity AS emEntity ON emEntity.intEntityId = cfAccount.intCustomerId
GO


