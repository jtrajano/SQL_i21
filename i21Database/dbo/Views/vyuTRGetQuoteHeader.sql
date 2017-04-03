CREATE VIEW [dbo].[vyuTRGetQuoteHeader]
	AS

SELECT QuoteHeader.intQuoteHeaderId
	, QuoteHeader.strQuoteNumber
	, QuoteHeader.strQuoteStatus
	, QuoteHeader.dtmQuoteDate
	, QuoteHeader.dtmQuoteEffectiveDate
	, QuoteHeader.intEntityCustomerId
	, strCustomerName = Customer.strName
	, Customer.strCustomerNumber
	, Customer.strAddress
	, strCustomerPhone = Customer.strPhone
	, AgingReport.dblCreditLimit
	, dblBalance = AgingReport.dblTotalAR
	, dblBalanceWithDiscount = AgingReport.dblTotalARDiscount
	, Customer.intSalespersonId
	, SalesPerson.strSalespersonId
	, SalesPerson.strSalespersonName
	, QuoteHeader.strQuoteComments
	, QuoteHeader.strCustomerComments
	, ysnHasEmailSetup = CASE WHEN (SELECT COUNT(*) FROM vyuARCustomerContacts CC WHERE CC.intCustomerEntityId = Customer.[intEntityId] AND ISNULL(CC.strEmail, '') <> '' AND CC.strEmailDistributionOption LIKE '%' + 'Transport Quote' + '%') > 0 THEN CONVERT(BIT, 1) ELSE CONVERT(BIT, 0) END
	, dblQuoteTotal = CONVERT(DECIMAL, 0.000000) 
FROM tblTRQuoteHeader QuoteHeader
LEFT JOIN vyuARCustomer Customer ON Customer.[intEntityId] = QuoteHeader.intEntityCustomerId
LEFT JOIN vyuEMSalesperson SalesPerson ON SalesPerson.[intEntityId] = Customer.intSalespersonId
LEFT JOIN vyuARCustomerAgingReport AgingReport ON AgingReport.intEntityCustomerId = Customer.[intEntityId]