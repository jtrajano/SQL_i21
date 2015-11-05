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
   0 "dblQuoteTotal" 
    	
FROM
    tblTRQuoteHeader QH
	join vyuARCustomer AR on QH.intEntityCustomerId = AR.intEntityCustomerId

	