CREATE VIEW [dbo].[vyuTRQuoteView]
	AS 

SELECT QH.intQuoteHeaderId
   , QH.strQuoteNumber
   , QH.strQuoteStatus
   , QH.strQuoteComments
   , QH.strCustomerComments
   , QH.dtmQuoteDate
   , QH.dtmQuoteEffectiveDate
   , AR.strName
   , AR.intEntityCustomerId
   , dblQuoteTotal = CONVERT(DECIMAL, 0.000000)
   , dtmQuote = DATEADD(dd, DATEDIFF(dd, 0, dtmQuoteDate), 0)
   , ysnHasEmailSetup = CASE WHEN (SELECT COUNT(*) 
									FROM vyuARCustomerContacts CC 
									WHERE CC.intCustomerEntityId = QH.intEntityCustomerId 
										AND ISNULL(CC.strEmail, '') <> '' 
										AND CC.strEmailDistributionOption LIKE '%' + 'Transport Quote' + '%') > 0 THEN CONVERT(BIT, 1) 
							ELSE CONVERT(BIT, 0) END
FROM tblTRQuoteHeader QH
LEFT JOIN vyuARCustomer AR ON QH.intEntityCustomerId = AR.intEntityCustomerId	