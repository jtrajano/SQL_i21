CREATE VIEW [dbo].[vyuCMDerivativesForCommissionPosting]
AS 
SELECT 
	A.*
	,BA.intBankAccountId
	,strBankAccountNo = ISNULL(dbo.fnAESDecryptASym(BA.strBankAccountNo),strBankAccountNo) COLLATE Latin1_General_CI_AS
	,intBankAccountCurrencyId = BA.intCurrencyId
	,strBankAccountCurrency = C.strCurrency
	,intConcurrencyId = 1
FROM vyuRKDerivativesForCommissionPosting A
INNER JOIN tblCMBankAccount BA
	ON BA.intBrokerageAccountId = A.intBrokerageAccountId
LEFT JOIN tblSMCurrency C
	ON C.intCurrencyID = BA.intCurrencyId
