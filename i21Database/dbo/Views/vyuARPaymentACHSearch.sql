﻿CREATE VIEW [dbo].[vyuARPaymentACHSearch]
AS 
SELECT P.* 
FROM vyuARPaymentSearch P WITH (NOLOCK)
LEFT JOIN (
	SELECT intSourceTransactionId
		 , intBankDepositId
		 , intUndepositedFundId
		 , strSourceTransactionId
	FROM dbo.tblCMUndepositedFund WITH (NOLOCK)
) UF ON UF.intSourceTransactionId = P.intPaymentId
	AND UF.strSourceTransactionId = P.strRecordNumber
OUTER APPLY (
	SELECT TOP 1 intUndepositedFundId
	FROM dbo.tblCMBankTransactionDetail BTD
	WHERE BTD.intUndepositedFundId = UF.intUndepositedFundId
) BTD 
WHERE P.strPaymentMethod = 'ACH' 
  AND P.ysnPosted = 1
  AND UF.intBankDepositId IS NULL
  AND BTD.intUndepositedFundId IS NULL
  AND P.dblAmountPaid <> 0