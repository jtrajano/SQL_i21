CREATE VIEW [dbo].[vyuTRSearchQuote]
	AS
		SELECT QuoteHeader.intQuoteHeaderId
			, QuoteHeader.strQuoteNumber
			, QuoteHeader.strQuoteStatus
			, QuoteHeader.dtmQuoteDate
			, QuoteHeader.dtmQuoteEffectiveDate
			, QuoteHeader.intEntityCustomerId
			, strCustomerName = Customer.strName
		FROM tblTRQuoteHeader QuoteHeader
		LEFT JOIN tblEMEntity Customer ON Customer.intEntityId = QuoteHeader.intEntityCustomerId
