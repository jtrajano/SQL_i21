CREATE VIEW [dbo].[vyuTRQuoteView]
	AS 
SELECT 
   QH.intQuoteHeaderId,
   QH.strQuoteNumber,
   QH.strQuoteStatus,
   QH.strQuoteComments,
   QH.strCustomerComments,
   QH.dtmQuoteDate,
   AR.strName,
   AR.intEntityCustomerId,
   convert(decimal,0.000000) "dblQuoteTotal",
   DATEADD(dd, DATEDIFF(dd, 0, dtmQuoteDate), 0) "dtmQuote",
   ysnHasEmailSetup = CASE WHEN (SELECT COUNT(*) FROM vyuARCustomerContacts CC WHERE CC.intCustomerEntityId = QH.intEntityCustomerId AND ISNULL(CC.strEmail, '') <> '' AND CC.strEmailDistributionOption LIKE '%' + 'Quotes' + '%') > 0 THEN CONVERT(BIT, 1) ELSE CONVERT(BIT, 0) END
    	
FROM
    tblTRQuoteHeader QH
	join vyuARCustomer AR on QH.intEntityCustomerId = AR.intEntityCustomerId

	