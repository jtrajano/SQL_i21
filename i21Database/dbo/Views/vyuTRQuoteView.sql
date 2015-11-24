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
   DATEADD(dd, DATEDIFF(dd, 0, dtmQuoteDate), 0) "dtmQuote"
    	
FROM
    tblTRQuoteHeader QH
	join vyuARCustomer AR on QH.intEntityCustomerId = AR.intEntityCustomerId

	