CREATE VIEW [dbo].[vyuCMDerivativesForCommissionPosting]
AS 
SELECT 
	  A.*
	, BA.intBankAccountId
	, strBankAccountNo = ISNULL(dbo.fnAESDecryptASym(BA.strBankAccountNo),strBankAccountNo) COLLATE Latin1_General_CI_AS
	, intBankAccountCurrencyId = BA.intCurrencyId
	, strBankAccountCurrency = C.strCurrency
	, strBankTransactionId = CASE 
							WHEN A.strInternalTradeNo <> '' AND A.strInternalTradeNo IS NOT NULL THEN BankTransactionFromSourceTransaction.strTransactionId
							WHEN A.intMatchNo <> '' AND A.intMatchNo IS NOT NULL THEN BankTransactionFromMatchDerivative.strTransactionId
							ELSE NULL END
	, intConcurrencyId = 1
FROM vyuRKDerivativesForCommissionPosting A
INNER JOIN tblCMBankAccount BA
	ON BA.intBrokerageAccountId = A.intBrokerageAccountId
LEFT JOIN tblSMCurrency C
	ON C.intCurrencyID = BA.intCurrencyId
OUTER APPLY (
	SELECT TOP 1 strTransactionId 
	FROM tblCMBankTransaction BT
	INNER JOIN tblCMBankTransactionDetail BTD
		ON BTD.intTransactionId = BT.intTransactionId
	WHERE
		BT.intBankTransactionTypeId = 26
		AND BTD.strSourceModule = 'Risk Management'
		AND BTD.strSourceTransactionId = A.strInternalTradeNo
		AND BT.ysnPosted = 1
		AND A.ysnPosted = 1
) BankTransactionFromSourceTransaction
OUTER APPLY (
	SELECT TOP 1 strTransactionId 
	FROM tblCMBankTransaction BT
	INNER JOIN tblCMBankTransactionDetail BTD
		ON BTD.intTransactionId = BT.intTransactionId
	WHERE
		BT.intBankTransactionTypeId = 26
		AND BTD.strSourceModule = 'Risk Management'
		AND BTD.intMatchDerivativeNo = A.intMatchNo
		AND BT.ysnPosted = 1
		AND A.ysnPosted = 1
) BankTransactionFromMatchDerivative
