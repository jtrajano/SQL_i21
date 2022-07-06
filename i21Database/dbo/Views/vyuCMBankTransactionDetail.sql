CREATE VIEW [dbo].[vyuCMBankTransactionDetail]
AS
SELECT
	Header.intTransactionId
	,Header.strTransactionId
	,TransactionType.strBankTransactionTypeName
	,strBankAccountNo = dbo.fnAESDecryptASym(BankAccount.strBankAccountNo)
	,Account.strAccountId
	,Detail.strDescription
	,Header.dtmDate
	,Currency.strCurrency
	,dblCredit = ISNULL(Detail.dblCredit, 0)
	,dblDebit = ISNULL(Detail.dblDebit, 0)
	,dblCreditForeign = ISNULL(Detail.dblCreditForeign, 0)
	,dblDebitForeign = ISNULL(Detail.dblDebitForeign, 0)
	,dblExchangeRate = ISNULL(Detail.dblExchangeRate, 1)
	,RateType.strCurrencyExchangeRateType
	,Header.ysnPosted
	,Detail.intConcurrencyId
FROM tblCMBankTransactionDetail Detail
INNER JOIN tblCMBankTransaction Header
	ON Header.intTransactionId = Detail.intTransactionId
INNER JOIN tblGLAccount Account 
	ON Account.intAccountId = Detail.intGLAccountId
INNER JOIN tblCMBankAccount BankAccount
	ON BankAccount.intBankAccountId = Header.intBankAccountId
LEFT JOIN tblCMBankTransactionType TransactionType
	ON TransactionType.intBankTransactionTypeId = Header.intBankTransactionTypeId
LEFT JOIN tblSMCurrency Currency
	ON Currency.intCurrencyID = Header.intCurrencyId
LEFT JOIN tblSMCurrencyExchangeRateType RateType
	ON RateType.intCurrencyExchangeRateTypeId = Detail.intCurrencyExchangeRateTypeId
