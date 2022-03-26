CREATE VIEW [dbo].[vyuCMDerivativesForCommissionPosting]
AS 
SELECT 
	  A.*
	, BA.intBankAccountId
	, strBankAccountNo = ISNULL(dbo.fnAESDecryptASym(BA.strBankAccountNo),strBankAccountNo) COLLATE Latin1_General_CI_AS
	, intBankAccountCurrencyId = BA.intCurrencyId
	, strBankAccountCurrency = C.strCurrency
	, strBankTransactionId = BankTransaction.strTransactionId
	, intConcurrencyId = 1
FROM vyuRKDerivativesForCommissionPosting A
INNER JOIN tblCMBankAccount BA
	ON BA.intBrokerageAccountId = A.intBrokerageAccountId
LEFT JOIN tblSMCurrency C
	ON C.intCurrencyID = BA.intCurrencyId
OUTER APPLY (
	SELECT strTransactionId 
	FROM tblCMBankTransaction BT
	INNER JOIN tblCMBankTransactionDetail BTD
		ON BTD.intTransactionId = BT.intTransactionId
	WHERE
		BT.intBankTransactionTypeId = 26
		AND BTD.strSourceModule = 'Risk Management'
		AND (BTD.strSourceTransactionId = A.strInternalTradeNo OR BTD.intMatchDerivativeNo = A.intMatchNo)
) BankTransaction
