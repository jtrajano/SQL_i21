CREATE VIEW [dbo].[vyuARPaymentACHSearch]
AS 
SELECT P.* FROM vyuARPaymentSearch P
	INNER JOIN tblCMUndepositedFund UF ON UF.intSourceTransactionId = P.intPaymentId
WHERE P.strPaymentMethod = 'ACH' 
  AND ISNULL(UF.ysnCommitted, 0) = 0