CREATE VIEW [dbo].[vyuCMUnassignedBrokerageAccount]
AS
SELECT
	A.intBrokerageAccountId
	,A.strAccountNumber
	,A.strDescription
	,A.strName
	,A.strInstrumentType
	,A.intConcurrencyId
FROM vyuRKBrokerageAccount A
OUTER APPLY (
	SELECT COUNT(1) intCount FROM tblCMBankAccount
	WHERE intBrokerageAccountId = A.intBrokerageAccountId
) BankAccount
WHERE BankAccount.intCount = 0
