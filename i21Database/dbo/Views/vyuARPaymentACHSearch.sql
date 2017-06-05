CREATE VIEW [dbo].[vyuARPaymentACHSearch]
AS 
SELECT P.* 
FROM vyuARPaymentSearch P WITH (NOLOCK)
	LEFT JOIN (SELECT intSourceTransactionId
					, intBankDepositId
		       FROM dbo.tblCMUndepositedFund WITH (NOLOCK)
	) UF ON UF.intSourceTransactionId = P.intPaymentId
WHERE P.strPaymentMethod = 'ACH' 
  AND UF.intBankDepositId IS NULL