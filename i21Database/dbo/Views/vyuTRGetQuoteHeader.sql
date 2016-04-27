﻿CREATE VIEW [dbo].[vyuTRGetQuoteHeader]
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
FROM tblTRQuoteHeader QuoteHeader
LEFT JOIN vyuARCustomer Customer ON Customer.intEntityCustomerId = QuoteHeader.intEntityCustomerId
LEFT JOIN vyuEMSalesperson SalesPerson ON SalesPerson.intEntitySalespersonId = Customer.intSalespersonId
LEFT JOIN vyuARCustomerAgingReport AgingReport ON AgingReport.intEntityCustomerId = Customer.intEntityCustomerId