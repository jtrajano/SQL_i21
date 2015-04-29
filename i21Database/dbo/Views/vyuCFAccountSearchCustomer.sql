CREATE VIEW dbo.vyuCFAccountSearchCustomer
AS
SELECT     intEntityCustomerId, strCustomerNumber, strType, dblCreditLimit, dblARBalance, strAccountNumber, strTaxNumber, strCurrency, intCurrencyId, intAccountStatusId, 
                      intSalespersonId, strPricing, strLevel, dblPercent, strTimeZone, ysnActive, intDefaultContactId, intDefaultLocationId, intBillToId, intShipToId, strTaxState, 
                      ysnPORequired, ysnCreditHold, ysnStatementDetail, strStatementFormat, intCreditStopDays, strTaxAuthority1, strTaxAuthority2, ysnPrintPriceOnPrintTicket, 
                      intServiceChargeId, ysnApplySalesTax, ysnApplyPrepaidTax, dblBudgetAmountForBudgetBilling, strBudgetBillingBeginMonth, strBudgetBillingEndMonth, 
                      ysnCalcAutoFreight, strUpdateQuote, strCreditCode, strDiscSchedule, strPrintInvoice, ysnSpecialPriceGroup, ysnExcludeDunningLetter, strLinkCustomerNumber, 
                      intReferredByCustomer, ysnReceivedSignedLiscense, strDPAContract, dtmDPADate, strGBReceiptNumber, ysnCheckoffExempt, ysnVoluntaryCheckoff, 
                      strCheckoffState, ysnMarketAgreementSigned, intMarketZoneId, ysnHoldBatchGrainPayment, ysnFederalWithholding, strAEBNumber, strAgrimineId, 
                      strHarvestPartnerCustomerId, strComments, ysnTransmittedCustomer, dtmMembershipDate, dtmBirthDate, strStockStatus, strPatronClass, dtmDeceasedDate, 
                      ysnSubjectToFWT, ysnHDBillableSupport, intTaxCodeId, intConcurrencyId
FROM         dbo.tblARCustomer
WHERE     (intEntityCustomerId NOT IN
                          (SELECT     intCustomerId
                            FROM          dbo.tblCFAccount))
