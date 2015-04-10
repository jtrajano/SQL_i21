CREATE VIEW dbo.vyuCFCustomerEntity
AS
SELECT     entity.intEntityId, entity.strName, entity.strEmail, entity.strWebsite, entity.strInternalNotes, entity.ysnPrint1099, entity.str1099Name, entity.str1099Form, 
                      entity.str1099Type, entity.strFederalTaxId, entity.dtmW9Signed, entity.imgPhoto, entity.strContactNumber, entity.strTitle, entity.strDepartment, entity.strMobile, 
                      entity.strPhone, entity.strPhone2, entity.strEmail2, entity.strFax, entity.strNotes, entity.strContactMethod, entity.strTimezone, entity.intDefaultLocationId, 
                      entity.ysnActive, entity.intConcurrencyId, customer.intEntityCustomerId, customer.strCustomerNumber, customer.strType, customer.dblCreditLimit, 
                      customer.dblARBalance, customer.strAccountNumber, customer.strTaxNumber, customer.strCurrency, customer.intCurrencyId, customer.intAccountStatusId, 
                      customer.intSalespersonId, customer.strPricing, customer.strLevel, customer.dblPercent, customer.strTimeZone AS EXPR1, customer.ysnActive AS EXPR2, 
                      customer.intDefaultContactId, customer.intDefaultLocationId AS EXPR3, customer.intBillToId, customer.intShipToId, customer.strTaxState, customer.ysnPORequired, 
                      customer.ysnCreditHold, customer.ysnStatementDetail, customer.strStatementFormat, customer.intCreditStopDays, customer.strTaxAuthority1, 
                      customer.strTaxAuthority2, customer.ysnPrintPriceOnPrintTicket, customer.intServiceChargeId, customer.ysnApplySalesTax, customer.ysnApplyPrepaidTax, 
                      customer.dblBudgetAmountForBudgetBilling, customer.strBudgetBillingBeginMonth, customer.strBudgetBillingEndMonth, customer.ysnCalcAutoFreight, 
                      customer.strUpdateQuote, customer.strCreditCode, customer.strDiscSchedule, customer.strPrintInvoice, customer.ysnSpecialPriceGroup, 
                      customer.ysnExcludeDunningLetter, customer.strLinkCustomerNumber, customer.intReferredByCustomer, customer.ysnReceivedSignedLiscense, 
                      customer.strDPAContract, customer.dtmDPADate, customer.strGBReceiptNumber, customer.ysnCheckoffExempt, customer.ysnVoluntaryCheckoff, 
                      customer.strCheckoffState, customer.ysnMarketAgreementSigned, customer.intMarketZoneId, customer.ysnHoldBatchGrainPayment, 
                      customer.ysnFederalWithholding, customer.strAEBNumber, customer.strAgrimineId, customer.strHarvestPartnerCustomerId, customer.strComments, 
                      customer.ysnTransmittedCustomer, customer.dtmMembershipDate, customer.dtmBirthDate, customer.strStockStatus, customer.strPatronClass, 
                      customer.dtmDeceasedDate, customer.ysnSubjectToFWT, customer.intConcurrencyId AS EXPR4
FROM         dbo.tblEntity AS entity INNER JOIN
                      dbo.tblARCustomer AS customer ON entity.intEntityId = customer.intEntityCustomerId