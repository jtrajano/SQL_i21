CREATE VIEW [dbo].[vyuCMCashFlowReportBankAccount]
AS 
SELECT
	BankAccount.intBankAccountId,
	Bank.intBankId,
	Bank.strBankName,
	BankAccount.ysnActive,
	BankAccount.strBankAccountHolder COLLATE Latin1_General_CI_AS strBankAccountHolder,
	dbo.fnAESDecryptASym(BankAccount.strBankAccountNo) COLLATE Latin1_General_CI_AS strBankAccountNo,
	BankAccount.intGLAccountId,
	A.strAccountId strGLAccountId,
	A.strDescription strGLAccountDescription,
	BankAccount.intConcurrencyId
FROM tblCMBankAccount BankAccount
JOIN tblCMBank Bank ON Bank.intBankId = BankAccount.intBankId
JOIN tblGLAccount A ON A.intAccountId = BankAccount.intGLAccountId
